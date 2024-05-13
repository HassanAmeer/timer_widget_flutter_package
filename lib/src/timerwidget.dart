import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

typedef TimerWidgetBuilder = Widget Function(
    BuildContext context, int seconds, bool isCounting);

/// - Select Button Type
/// ```dart
///  buttonType: ButtonType.outline,
///              ButtonType.elavated,
///              ButtonType.icon,
///              ButtonType.none,
/// ```
enum ButtonType { none, elevated, outline, icon }

class TimerState extends ChangeNotifier {
  bool isCounting = false;
  int remainingSeconds = 0;

  Timer _timer = Timer(const Duration(seconds: 1), () {});

  void startCountF(context, {required int secondsCount}) {
    isCounting = true;
    _timer.cancel();
    remainingSeconds = secondsCount;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds <= 0) {
        _timer.cancel();
        remainingSeconds = 0;
        isCounting = false;
        notifyListeners();
      } else {
        remainingSeconds--;
        notifyListeners();
      }
    });
  }

  stopCountdown(context) {
    if (_timer.isActive) {
      _timer.cancel();
      remainingSeconds = 0;
      isCounting = false;
      notifyListeners();
    }
  }

  @override
  dispose() {
    isCounting = false;
    remainingSeconds = 0;
    _timer.cancel();
    super.dispose();
  }
}

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
///                 disableDuringCounting:true,
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

class TimerWidget extends StatelessWidget {
  final TimerWidgetController controller;
  final TimerWidgetBuilder builder;
  final VoidCallback onPressed;
  final int timeOutInSeconds;
  final bool disableDuringCounting;
  final ButtonType buttonType;
  final ButtonStyle? buttonStyle;

  const TimerWidget({
    super.key,
    required this.builder,
    required this.onPressed,
    required this.timeOutInSeconds,
    required this.controller,
    this.disableDuringCounting = true,
    this.buttonType = ButtonType.none,
    this.buttonStyle,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TimerState()),
        ChangeNotifierProvider(create: (context) => TimerWidgetController()),
      ],
      child: TimerWidgetForView(
        builder: builder,
        controller: controller,
        onPressed: onPressed,
        timeOutInSeconds: timeOutInSeconds,
        disableDuringCounting: disableDuringCounting,
        buttonType: buttonType,
        buttonStyle: buttonStyle,
      ),
    );
  }
}

// ignore: must_be_immutable
class TimerWidgetForView extends StatefulWidget {
  final TimerWidgetBuilder builder;
  VoidCallback? onPressed;
  final int timeOutInSeconds;
  final bool disableDuringCounting;
  final ButtonType buttonType;
  final ButtonStyle? buttonStyle;
  final TimerWidgetController controller;

  TimerWidgetForView({
    super.key,
    required this.builder,
    required this.onPressed,
    required this.timeOutInSeconds,
    this.disableDuringCounting = true,
    this.buttonType = ButtonType.none,
    this.buttonStyle,
    required this.controller,
  });

  @override
  State<TimerWidgetForView> createState() => _TimerWidgetForViewState();
}

class _TimerWidgetForViewState extends State<TimerWidgetForView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    TimerState timerState = Provider.of<TimerState>(context, listen: false);
    if (widget.disableDuringCounting && timerState.isCounting) {
    } else {
      widget.onPressed = _onPress;
    }
    widget.controller.startTimer = () {
      _onPress();
    };
    widget.controller.stopTimer = () {
      try {
        widget.controller.isCounting = false;
        Provider.of<TimerWidgetController>(context, listen: false)
            .changeCountingSate(false);
        timerState.stopCountdown(context);
      } catch (e) {
        debugPrint("💥 $e");
      }
    };

    /// - 🗑 `optional: dispose it when not used.`
    widget.controller.disposeit = () {
      try {
        widget.controller.isCounting = false;
        Provider.of<TimerWidgetController>(context, listen: false)
            .changeCountingSate(false);
        timerState.dispose();
      } catch (e) {
        debugPrint("💥 $e");
      }
    };
    //// step2. if need to get and pass a value
    ////    widget.controller!.startTimer = (value) {
    ////   _onPressed(value);
    //// };
  }

  _onPress() {
    try {
      widget.controller.isCounting = true;
      Provider.of<TimerWidgetController>(context, listen: false)
          .changeCountingSate(true);
      TimerState timerState = Provider.of<TimerState>(context, listen: false);
      timerState.startCountF(context, secondsCount: widget.timeOutInSeconds);
      // debugPrint("⏱ isCounting:${timerState.isCounting}");
      // } on Exception catch (e) {
    } catch (e) {
      debugPrint("💥 $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerState>(builder: (context, state, child) {
      switch (widget.buttonType) {
        case ButtonType.none:
          return GestureDetector(
            onTap: widget.disableDuringCounting && state.isCounting
                ? null
                : widget.onPressed,
            child: widget.builder(
              context,
              state.remainingSeconds,
              state.isCounting,
            ),
          );
        case ButtonType.elevated:
          return ElevatedButton(
              style: widget.buttonStyle,
              onPressed: widget.disableDuringCounting && state.isCounting
                  ? null
                  : widget.onPressed,
              child: widget.builder(
                  context, state.remainingSeconds, state.isCounting));
        case ButtonType.outline:
          return OutlinedButton(
              onPressed: widget.disableDuringCounting && state.isCounting
                  ? null
                  : widget.onPressed,
              style: widget.buttonStyle,
              child: widget.builder(
                  context, state.remainingSeconds, state.isCounting));
        case ButtonType.icon:
          return IconButton(
              onPressed: widget.disableDuringCounting && state.isCounting
                  ? null
                  : widget.onPressed,
              icon: widget.builder(
                  context, state.remainingSeconds, state.isCounting));
        default:
          return const SizedBox.shrink();
      }
    });
  }
}

class TimerWidgetController extends ChangeNotifier {
  bool isCounting = false;
  Function() startTimer = () {};
  Function() stopTimer = () {};

  /// - 🗑 `optional: dispose it when not used`
  Function() disposeit = () {};

  changeCountingSate(bool boolVal) {
    isCounting = boolVal;
    debugPrint("👉 changeCountingSate:$isCounting");
    notifyListeners();
  }
  // step1. if need to get and pass a value
  // from call:  controller.startTimer("your_value");
  // Function(dynamic) startTimer = (dynamic value) {};
}
