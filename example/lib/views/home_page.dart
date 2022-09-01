import 'package:flutter/material.dart';
import 'package:smooth_compass/utils/src/compass_ui.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SmoothCompass(
          rotationSpeed: 200,
          height: 300,
          width: 300,
          compassAsset: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(.7)
            ),
            child: const Divider(
              thickness: 1,
              color: Colors.white,
            ),
          ),
          compassBuilder: (context,AsyncSnapshot<CompassModel>? compassData,Widget compassAsset){
            return compassAsset;
          },
        ),
      ),
    );
  }
}
