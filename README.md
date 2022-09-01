# Smooth Compass

[![Pub Package](https://img.shields.io/pub/v/table_calendar.svg?style=flat-square)](https://pub.dartlang.org/packages/table_calendar)

[comment]: <> ([![Awesome Flutter]&#40;https://img.shields.io/badge/Awesome-Flutter-52bdeb.svg?longCache=true&style=flat-square&#41;]&#40;https://github.com/Solido/awesome-flutter&#41;)

Customizable flutter package to find direction using device motion sensors.

| ![Image](https://raw.githubusercontent.com/aleksanderwozniak/table_calendar/assets/table_calendar_styles.gif) | ![Image](https://raw.githubusercontent.com/aleksanderwozniak/table_calendar/assets/table_calendar_builders.gif) |
| :------------: | :------------: |
| **TableCalendar** with custom styles | **TableCalendar** with custom builders |

## Features

* Extensive, yet easy to use
* Preconfigured UI with customizable styling
* Custom builder
* Locale support
* Smooth Rotation
* Values in degrees

## Usage

Make sure to check out [examples](https://github.com/alihadi5125/smooth_compass/tree/master/example)

### Installation

Add the following line to `pubspec.yaml`:

```yaml
dependencies:
  smooth_compass: ^0.0.1
```

### Basic setup

*The complete example is available [here](https://github.com/alihadi5125/smooth_compass/tree/master/example).*

**SmoothCompass** requires you to provide `compassBuilder` which returns:
* `degrees` is the directional value.
* `turns` is the value for compass rotation.
* `compassAsset` the (default) widget for compass.

**SmoothCompass** Optional Arguments `Height`, `Width`, `Duration` and `compassAsset`:
* `compassAsset` is the customizable widget for compass. if not provider default will shown.
  
**Default Widget**:
```dart
SmoothCompass(
 rotationSpeed: 200,
 height: 300,
 width: 300,
// compassAsset:CustomWidget(),   you custom compass widget here
 compassBuilder: (context,AsyncSnapshot<CompassModel>? compassData,Widget compassAsset){
   return compassAsset;
    },
  ),
```

**Default Widget**:
```dart
SmoothCompass(
 rotationSpeed: 200,
 height: 300,
 width: 300,
  compassAsset:Container(
  height:200,
  width:200,
    decoration:BoxDecoration(
    shape:BoxShape.circle,
    image:DecorationImage(
    image:AssetImage("path for compass image"),
    fit:BoxFit.cover
   )
  ),
),
 compassBuilder: (context,AsyncSnapshot<CompassModel>? compassData,Widget compassAsset){
   return compassAsset;
    },
  ),
```

#### Adding interactivity

You will surely notice that previously set up calendar widget isn't quite interactive - you can only swipe it horizontally, to change the currently visible month. While it may be sufficient in certain situations, you can easily bring it to life by specifying a couple of callbacks.

Adding the following code to the calendar widget will allow it to respond to user's taps, marking the tapped day as selected:
