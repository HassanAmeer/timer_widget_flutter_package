import 'package:flutter/material.dart';
import 'dart:async';

typedef TimerWidgetBuilder = Widget Function(
    BuildContext context, int seconds, bool isCounting);

enum ButtonType { none, elavated, outline, icon }

const int aSec = 1;

class TimerWidget extends StatefulWidget {
  final TimerWidgetBuilder builder;
  final VoidCallback onPressed;
  final int timeOutInSeconds;
  final bool resetTimerOnPressed;
  final ButtonType buttonType;
  final ButtonStyle? buttonStyle;
  final TimerWidgetController? controller;

  /// `________________________________`
  /// - ### can used as a widget OR Button
  ///   - ### Fully Customized
  ///
  /// `________________________________`
  /// ## Example
  /// ```dart
  /// TimerWidget(
  ///                 timeOutInSeconds: 5,
  ///                 onPressed: () {},
  ///                 controller: timerController, //handle by this out side of the widget
  ///                 buttonType: ButtonType.outline,
  ///                 buttonStyle: ButtonStyle(
  ///                              backgroundColor: MaterialStateProperty.all(
  ///                              Colors.orangeAccent)),
  ///                 builder: (context, seconds, isCounting) {
  ///                   if(isCounting){
  ///                     // show any widget when time count Down
  ///                       return const CircularProgressIndicator();
  ///                   }else{
  ///                     // show before on press any widget
  ///                       return const Icon(Icons.ads_click);
  ///                   }
  ///                 }),
  /// `_______________________________________________`
  /// // handle by controller from another widget OR by Function
  /// TimerWidgetController timerController = TimerWidgetController(); // Make Controlleer before widget building
  /// timerController.startTimer();
  /// timerController.stopTimer();
  /// timerController.isCounting;
  ///
  /// ```

  const TimerWidget(
      {super.key,
      required this.builder,
      required this.onPressed,
      required this.timeOutInSeconds,
      this.resetTimerOnPressed = true,
      this.buttonType = ButtonType.none,
      this.buttonStyle,
      this.controller});

  @override
  State<TimerWidget> createState() => _CustomTimerWidgetState();
}

class _CustomTimerWidgetState extends State<TimerWidget> {
  bool _isTimeUp = true;
  int _timeCounter = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    ///////// for call only when fully ui page is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateTime();
    });
    widget.controller!.startTimer = _onPressed;
    //// step2. if need to get and pass a value
    ////    widget.controller!.startTimer = (value) {
    ////   _onPressed(value);
    //// };
  }

  @override
  void dispose() {
    _timer.cancel();
    widget.controller!.isCounting = false;
    super.dispose();
  }

  void _updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  void _updateTime() {
    if (_isTimeUp) {
      return;
    }
    _timer = Timer(const Duration(seconds: aSec), () async {
      if (!mounted) return;
      _timeCounter--;
      _updateState();
      if (_timeCounter > 0) {
        _updateTime();
      } else {
        widget.controller!.isCounting = false;
        _isTimeUp = true;
      }
    });
  }

  void _onPressed() {
    _isTimeUp = false;
    _timeCounter = widget.timeOutInSeconds;
    _updateState();
    widget.onPressed();
    widget.controller!.isCounting = true;
    if (widget.resetTimerOnPressed) {
      _updateTime();
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.buttonType) {
      case ButtonType.none:
        return GestureDetector(
            onTap: _isTimeUp ? _onPressed : null,
            child: widget.builder(context, _timeCounter, !_isTimeUp));
      case ButtonType.elavated:
        return ElevatedButton(
            style: widget.buttonStyle,
            onPressed: _isTimeUp ? _onPressed : null,
            child: widget.builder(context, _timeCounter, !_isTimeUp));
      case ButtonType.outline:
        return OutlinedButton(
            onPressed: _isTimeUp ? _onPressed : null,
            style: widget.buttonStyle,
            child: widget.builder(context, _timeCounter, !_isTimeUp));
      case ButtonType.icon:
        return IconButton(
            onPressed: _isTimeUp ? _onPressed : null,
            style: widget.buttonStyle,
            icon: widget.builder(context, _timeCounter, !_isTimeUp));
      default:
        return const SizedBox.shrink();
    }
  }
}

class TimerWidgetController {
  bool isCounting = false;
  Function() startTimer = () {};
  Function() stopTimer = () {};
  // step1. if need to get and pass a value
  // from call:  controller.startTimer("your_value");
  // Function(dynamic) startTimer = (dynamic value) {};
}
