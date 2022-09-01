part of flutter_sensor_compass;

class _Compass {
  List<double> _rotationMatrix = List.filled(9, 0.0);
  double _azimuth = 0.0;
  double azimuthFix = 0.0;
  final List<_CompassStreamSubscription> _updatesSubscriptions = [];
  StreamSubscription<SensorEvent>? _rotationSensorStream;
  StreamController<double> _internalUpdateController =
      StreamController.broadcast();

  /// Starts the compass updates.
  Stream<CompassModel> compassUpdates(Duration interval, double azimuthFix) {
    this.azimuthFix = azimuthFix;
    // ignore: close_sinks
    StreamController<CompassModel>? compassStreamController;
    _CompassStreamSubscription? compassStreamSubscription;
    // ignore: cancel_subscriptions
    StreamSubscription<double> compassSubscription =
        _internalUpdateController.stream.listen((value) {
      if (interval != null) {
        DateTime instant = DateTime.now();
        int difference = instant
            .difference(compassStreamSubscription!.lastUpdated!)
            .inMicroseconds;
        if (difference < interval.inMicroseconds) {
          return;
        } else {
          compassStreamSubscription.lastUpdated = instant;
        }
      }
      compassStreamController!.add(getCompassValues(value));
    });
    compassSubscription.onDone(() {
      _updatesSubscriptions.remove(compassStreamSubscription);
    });
    compassStreamSubscription = _CompassStreamSubscription(compassSubscription);
    _updatesSubscriptions.add(compassStreamSubscription);
    compassStreamController = StreamController<CompassModel>.broadcast(
      onListen: () {
        if (_sensorStarted()) return;
        _startSensor();
      },
      onCancel: () {
        compassStreamSubscription!.subscription.cancel();
        _updatesSubscriptions.remove(compassStreamSubscription);
        if (_updatesSubscriptions.isEmpty) _stopSensor();
      },
    );
    return compassStreamController.stream;
  }

  /// Checks if the rotation sensor is available in the system.
  static Future<bool> get isCompassAvailable async {
    return SensorManager().isSensorAvailable(Sensors.ROTATION);
  }

  /// Determines which sensor is available and starts the updates if possible.
  void _startSensor() async {
    bool isAvailable = await isCompassAvailable;
    if (isAvailable) {
      _startRotationSensor();
    }
  }

  /// Starts the rotation sensor for each platform.
  void _startRotationSensor() async {
    final stream = await SensorManager().sensorUpdates(
      sensorId: Sensors.ROTATION,
      interval: Sensors.SENSOR_DELAY_UI,
    );
    _rotationSensorStream = stream.listen((event) {
      if (Platform.isAndroid) {
        _computeRotationMatrixFromVector(event.data);
        List<double> orientation = _computeOrientation();
        _azimuth = degrees(orientation[0]);
        _azimuth = (_azimuth + azimuthFix + 360) % 360;
      } else if (Platform.isIOS) {
        _azimuth = event.data[0];
      }
      _internalUpdateController.add(_azimuth);
    });
  }

  /// Checks if the sensors has been started.
  bool _sensorStarted() {
    return _rotationSensorStream != null;
  }

  /// Stops the sensors updates subscribed.
  void _stopSensor() {
    if (_sensorStarted()) {
      _rotationSensorStream!.cancel();
      _rotationSensorStream = null;
    }
  }

  /// Updates the current rotation matrix using the values gathered by the
  /// rotation vector sensor.
  ///
  /// Returns true if the computation was successful and false otherwise.
  void _computeRotationMatrixFromVector(List<double> rotationVector) {
    double q0;
    double q1 = rotationVector[0];
    double q2 = rotationVector[1];
    double q3 = rotationVector[2];
    if (rotationVector.length == 4) {
      q0 = rotationVector[3];
    } else {
      q0 = 1 - q1 * q1 - q2 * q2 - q3 * q3;
      q0 = (q0 > 0) ? sqrt(q0) : 0;
    }
    double sqQ1 = 2 * q1 * q1;
    double sqQ2 = 2 * q2 * q2;
    double sqQ3 = 2 * q3 * q3;
    double q1Q2 = 2 * q1 * q2;
    double q3Q0 = 2 * q3 * q0;
    double q1Q3 = 2 * q1 * q3;
    double q2Q0 = 2 * q2 * q0;
    double q2Q3 = 2 * q2 * q3;
    double q1Q0 = 2 * q1 * q0;
    _rotationMatrix[0] = 1 - sqQ2 - sqQ3;
    _rotationMatrix[1] = q1Q2 - q3Q0;
    _rotationMatrix[2] = q1Q3 + q2Q0;
    _rotationMatrix[3] = q1Q2 + q3Q0;
    _rotationMatrix[4] = 1 - sqQ1 - sqQ3;
    _rotationMatrix[5] = q2Q3 - q1Q0;
    _rotationMatrix[6] = q1Q3 - q2Q0;
    _rotationMatrix[7] = q2Q3 + q1Q0;
    _rotationMatrix[8] = 1 - sqQ1 - sqQ2;
  }

  /// Compute the orientation utilizing the data realized by the
  /// [_computeRotationMatrix] method.
  ///
  /// * [rotationMatrix] the rotation matrix to calculate the orientation.
  ///
  /// Returns a list with the result of the orientation.
  List<double> _computeOrientation() {
    var orientation = <double>[];
    orientation.add(atan2(_rotationMatrix[1], _rotationMatrix[4]));
    orientation.add(asin(-_rotationMatrix[7]));
    orientation.add(atan2(-_rotationMatrix[6], _rotationMatrix[8]));
    return orientation;
  }
}

/// Class that represents a subscription to the stream of compass updates.
class _CompassStreamSubscription {
  /// Subscription to the stream of the compass.
  StreamSubscription subscription;

  /// Date of the last update.
  DateTime? lastUpdated;

  _CompassStreamSubscription(this.subscription) {
    lastUpdated = DateTime.now();
  }
}
