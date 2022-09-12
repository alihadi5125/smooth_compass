

import 'package:flutter/material.dart';
import '../smooth_compass.dart';
double preValue=0;
double turns=0;
///custom callback for building widgets
typedef WidgetBuilder=Widget Function(BuildContext context,AsyncSnapshot<CompassModel>? compassData,Widget compassAsset);
class SmoothCompass extends StatelessWidget {
  final WidgetBuilder compassBuilder;
  final Widget? compassAsset;
  final Widget? loadingAnimation;
  final int? rotationSpeed;
  final double? height;
  final double? width;

  const SmoothCompass({Key? key,required this.compassBuilder,this.compassAsset, this.rotationSpeed=200, this.height=200, this.width=200, this.loadingAnimation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// check if the compass support available
    return FutureBuilder(
      future: Compass().isCompassAvailable(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if(snapshot.connectionState==ConnectionState.waiting)
          {
            return loadingAnimation!=null ?loadingAnimation!: const Center(
              child: CircularProgressIndicator(),
            );
          }
        if(!snapshot.data!)
          {
            return const Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                    child: Text("Compass support for this device is not available"))
            );
          }
        /// start compass stream
        return StreamBuilder<CompassModel>(
          stream: Compass().compassUpdates(
              interval: const Duration(milliseconds: -1,), azimuthFix: 0.0),
          builder: (context, AsyncSnapshot<CompassModel> snapshot) {
            if (compassAsset == null) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return loadingAnimation!=null? loadingAnimation!: const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              return compassBuilder(
                  context, snapshot, _defaultWidget(snapshot));
            }
            else {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              return compassBuilder(context, snapshot, AnimatedRotation(
                turns: snapshot.data!.turns * -1,
                duration: Duration(milliseconds: rotationSpeed!),
                child: compassAsset!,
              ),
              );
            }
          },
        );
      }

    );
  }
///default widget if custom widget isn't provided
  Widget _defaultWidget(AsyncSnapshot<CompassModel> snapshot)
  {
    return AnimatedRotation(
      turns: snapshot.data!.turns*-1,
      duration: Duration(milliseconds: rotationSpeed!),
      child: Container(
        height: height,
        width: width,
        decoration:  const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/compass.png', package: 'smooth_compass'),
                fit: BoxFit.cover
            )
        ),
      ),
    );
  }
}


///calculating compass turn from heading value
getCompassValues(double heading)
{
  double direction = heading;
  direction = direction < 0 ? (360 + direction): direction;


  double diff = direction - preValue;
  if(diff.abs() > 180) {
    if(preValue > direction) {
      diff = 360 - (direction-preValue).abs();
    } else {
      diff = (360 - (preValue-direction).abs()).toDouble();
      diff = diff * -1;
    }
  }

  turns += (diff / 360);
  preValue = direction;
  return CompassModel(turns: turns, angle: heading);
}
/// model to store the sensor value
class CompassModel{
  double turns;
  double angle;
  CompassModel({required this.turns,required this.angle});
}
