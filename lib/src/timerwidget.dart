import 'package:flutter/material.dart';
import 'dart:async';

typedef TimerWidgetBuilder = Widget Function(
    BuildContext context, TimerWidgetState state);

/// Timer widget state containing all info
class TimerWidgetState {
  final int remainingSeconds;
  final bool isCounting;
  final bool isPaused;
  final bool isLoading;
  final bool isSuccess;
  final bool isError;
  final dynamic data;
  final Object? error;

  const TimerWidgetState({
    this.remainingSeconds = 0,
    this.isCounting = false,
    this.isPaused = false,
    this.isLoading = false,
    this.isSuccess = false,
    this.isError = false,
    this.data,
    this.error,
  });

  TimerWidgetState copyWith({
    int? remainingSeconds,
    bool? isCounting,
    bool? isPaused,
    bool? isLoading,
    bool? isSuccess,
    bool? isError,
    dynamic data,
    Object? error,
  }) {
    return TimerWidgetState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isCounting: isCounting ?? this.isCounting,
      isPaused: isPaused ?? this.isPaused,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
      data: data ?? this.data,
      error: error ?? this.error,
    );
  }
}

/// Select widget behavior type
/// ```dart
/// TimerType.countdown   - Simple countdown timer
/// TimerType.cooldown    - Button with cooldown (OTP resend)
/// TimerType.debounce    - Debounced button (prevent rapid clicks)
/// TimerType.asyncLoader - Async operation with loading/retry
/// ```
enum TimerType {
  /// Simple countdown timer
  countdown,

  /// Button with cooldown period after press (e.g., OTP resend)
  cooldown,

  /// Debounced button to prevent rapid clicks
  debounce,

  /// Async operation handler with loading state and retry
  asyncLoader,
}

/// Select Button Type
/// ```dart
/// ButtonType.none      - No button wrapper (raw widget)
/// ButtonType.elevated  - ElevatedButton
/// ButtonType.outline   - OutlinedButton
/// ButtonType.icon      - IconButton
/// ```
enum ButtonType { none, elevated, outline, icon }

/// `________________________________`
/// # TimerWidget - All-in-one timer/loading widget
///
/// ## Select behavior with `timerType`:
/// - `TimerType.countdown` - Simple countdown timer
/// - `TimerType.cooldown` - Button with cooldown (OTP/resend)
/// - `TimerType.debounce` - Prevents rapid clicks
/// - `TimerType.asyncLoader` - Async ops with loading/retry
///
/// ## Example - Countdown Timer
/// ```dart
/// TimerWidget(
///   timerType: TimerType.countdown,
///   timeOutInSeconds: 5,
///   onPressed: () => print("Pressed!"),
///   builder: (context, state) {
///     return Text(state.isCounting ? "Wait ${state.remainingSeconds}s" : "Click");
///   },
/// )
/// ```

class TimerWidget<T> extends StatefulWidget {
  /// Controller for external control
  final TimerWidgetController<T>? controller;

  /// Builder that receives current state
  final TimerWidgetBuilder builder;

  /// Callback when button is pressed (for countdown, cooldown)
  final VoidCallback? onPressed;

  /// Timeout/cooldown duration in seconds
  final int timeOutInSeconds;

  /// Disable button during countdown
  final bool disableDuringCounting;

  /// Button style type
  final ButtonType buttonType;

  /// Custom button style
  final ButtonStyle? buttonStyle;

  /// Auto-start timer when widget mounts
  final bool autoStart;

  /// Callback when timer/operation completes
  final VoidCallback? onComplete;

  /// **Select the widget behavior**
  final TimerType timerType;

  // ============ Debounce specific ============
  /// Debounce delay in milliseconds (for TimerType.debounce)
  final int debounceMs;

  // ============ Async specific ============
  /// Async operation to perform (for debounce and asyncLoader)
  final Future<T> Function()? asyncOperation;

  /// Number of auto-retries on failure (for asyncLoader)
  final int retryCount;

  /// Delay between retries
  final Duration retryDelay;

  /// Callback on success
  final void Function(T data)? onSuccess;

  /// Callback on error
  final void Function(Object error)? onError;

  const TimerWidget({
    super.key,
    required this.builder,
    this.controller,
    this.onPressed,
    this.timeOutInSeconds = 5,
    this.disableDuringCounting = true,
    this.buttonType = ButtonType.none,
    this.buttonStyle,
    this.autoStart = false,
    this.onComplete,
    this.timerType = TimerType.countdown,
    this.debounceMs = 300,
    this.asyncOperation,
    this.retryCount = 0,
    this.retryDelay = const Duration(seconds: 1),
    this.onSuccess,
    this.onError,
  });

  @override
  State<TimerWidget<T>> createState() => _TimerWidgetState<T>();
}

class _TimerWidgetState<T> extends State<TimerWidget<T>> {
  TimerWidgetState _state = const TimerWidgetState();
  Timer? _timer;
  Timer? _debounceTimer;
  int _currentRetry = 0;

  @override
  void initState() {
    super.initState();
    _bindController();

    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleAutoStart();
      });
    }
  }

  void _handleAutoStart() {
    switch (widget.timerType) {
      case TimerType.countdown:
      case TimerType.cooldown:
        _startCountdown();
        break;
      case TimerType.asyncLoader:
        _executeAsync();
        break;
      case TimerType.debounce:
        // Debounce doesn't auto-start
        break;
    }
  }

  @override
  void didUpdateWidget(covariant TimerWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _bindController();
    }
  }

  void _bindController() {
    final controller = widget.controller;
    if (controller != null) {
      controller._bind(
        startTimer: _startCountdown,
        stopTimer: _stopCountdown,
        pauseTimer: _pauseCountdown,
        resumeTimer: _resumeCountdown,
        executeAsync: _executeAsync,
        retry: _retry,
        reset: _reset,
        getState: () => _state,
      );
    }
  }

  // ======================== COUNTDOWN LOGIC ========================

  void _startCountdown() {
    if (!mounted) return;

    // IMPORTANT: Cancel any existing timer first to prevent multiple timers
    _timer?.cancel();
    _timer = null;

    setState(() {
      _state = _state.copyWith(
        isCounting: true,
        isPaused: false,
        remainingSeconds: widget.timeOutInSeconds,
      );
    });
    widget.controller?._notifyStateChange();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_state.remainingSeconds <= 1) {
        timer.cancel();
        _timer = null;
        setState(() {
          _state = _state.copyWith(
            remainingSeconds: 0,
            isCounting: false,
            isPaused: false,
          );
        });
        widget.onComplete?.call();
        widget.controller?._notifyStateChange();
      } else {
        setState(() {
          _state = _state.copyWith(
            remainingSeconds: _state.remainingSeconds - 1,
          );
        });
        widget.controller?._notifyStateChange();
      }
    });
  }

  void _stopCountdown() {
    _timer?.cancel();
    _timer = null;
    if (mounted) {
      setState(() {
        _state = _state.copyWith(
          remainingSeconds: 0,
          isCounting: false,
          isPaused: false,
        );
      });
      widget.controller?._notifyStateChange();
    }
  }

  void _pauseCountdown() {
    if (_timer?.isActive == true && _state.isCounting) {
      _timer?.cancel();
      _timer = null;
      if (mounted) {
        setState(() {
          _state = _state.copyWith(isPaused: true);
        });
        widget.controller?._notifyStateChange();
      }
    }
  }

  void _resumeCountdown() {
    if (!mounted) return;
    if (!_state.isPaused || _state.remainingSeconds <= 0) return;

    // Cancel any existing timer first
    _timer?.cancel();
    _timer = null;

    setState(() {
      _state = _state.copyWith(isPaused: false);
    });
    widget.controller?._notifyStateChange();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_state.remainingSeconds <= 1) {
        timer.cancel();
        _timer = null;
        setState(() {
          _state = _state.copyWith(
            remainingSeconds: 0,
            isCounting: false,
            isPaused: false,
          );
        });
        widget.onComplete?.call();
        widget.controller?._notifyStateChange();
      } else {
        setState(() {
          _state = _state.copyWith(
            remainingSeconds: _state.remainingSeconds - 1,
          );
        });
        widget.controller?._notifyStateChange();
      }
    });
  }

  // ======================== ASYNC LOGIC ========================

  Future<void> _executeAsync() async {
    if (!mounted || widget.asyncOperation == null) return;

    setState(() {
      _state = _state.copyWith(
        isLoading: true,
        isSuccess: false,
        isError: false,
        error: null,
      );
    });
    widget.controller?._notifyStateChange();
    _currentRetry = 0;

    await _performAsyncOperation();
  }

  Future<void> _performAsyncOperation() async {
    try {
      final result = await widget.asyncOperation!();
      if (!mounted) return;

      setState(() {
        _state = TimerWidgetState(
          isLoading: false,
          isSuccess: true,
          isError: false,
          data: result,
        );
      });
      widget.onSuccess?.call(result);
      widget.onComplete?.call();
      widget.controller?._notifyStateChange();
    } catch (e) {
      if (!mounted) return;

      if (_currentRetry < widget.retryCount) {
        _currentRetry++;
        await Future.delayed(widget.retryDelay);
        if (mounted) {
          await _performAsyncOperation();
        }
      } else {
        setState(() {
          _state = TimerWidgetState(
            isLoading: false,
            isSuccess: false,
            isError: true,
            error: e,
          );
        });
        widget.onError?.call(e);
        widget.controller?._notifyStateChange();
      }
    }
  }

  void _retry() {
    _currentRetry = 0;
    _executeAsync();
  }

  void _reset() {
    _timer?.cancel();
    _timer = null;
    _debounceTimer?.cancel();
    _debounceTimer = null;
    if (mounted) {
      setState(() {
        _state = const TimerWidgetState();
      });
      widget.controller?._notifyStateChange();
    }
  }

  // ======================== DEBOUNCE LOGIC ========================

  Future<void> _handleDebounce() async {
    if (_state.isLoading || widget.asyncOperation == null) return;

    _debounceTimer?.cancel();

    setState(() {
      _state = _state.copyWith(isLoading: true);
    });
    widget.controller?._notifyStateChange();

    try {
      final result = await widget.asyncOperation!();
      if (!mounted) return;

      setState(() {
        _state = TimerWidgetState(
          isLoading: false,
          isSuccess: true,
          data: result,
        );
      });
      widget.onSuccess?.call(result);
      widget.onComplete?.call();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = TimerWidgetState(
          isLoading: false,
          isError: true,
          error: e,
        );
      });
      widget.onError?.call(e);
    } finally {
      if (mounted) {
        _debounceTimer = Timer(Duration(milliseconds: widget.debounceMs), () {
          // Debounce complete
        });
        widget.controller?._notifyStateChange();
      }
    }
  }

  // ======================== PRESS HANDLERS ========================

  void _handlePress() {
    switch (widget.timerType) {
      case TimerType.countdown:
        // For countdown: if already counting, don't restart
        if (_state.isCounting && !_state.isPaused) return;
        widget.onPressed?.call();
        _startCountdown();
        break;
      case TimerType.cooldown:
        // For cooldown: if already counting, ignore
        if (_state.isCounting) return;
        widget.onPressed?.call();
        _startCountdown();
        break;
      case TimerType.debounce:
        _handleDebounce();
        break;
      case TimerType.asyncLoader:
        _executeAsync();
        break;
    }
  }

  bool get _shouldDisable {
    switch (widget.timerType) {
      case TimerType.countdown:
        return widget.disableDuringCounting &&
            _state.isCounting &&
            !_state.isPaused;
      case TimerType.cooldown:
        return _state.isCounting;
      case TimerType.debounce:
        return _state.isLoading;
      case TimerType.asyncLoader:
        return _state.isLoading;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _debounceTimer?.cancel();
    _debounceTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final VoidCallback? handler = _shouldDisable ? null : _handlePress;

    switch (widget.buttonType) {
      case ButtonType.none:
        return GestureDetector(
          onTap: handler,
          child: widget.builder(context, _state),
        );
      case ButtonType.elevated:
        return ElevatedButton(
          style: widget.buttonStyle,
          onPressed: handler,
          child: widget.builder(context, _state),
        );
      case ButtonType.outline:
        return OutlinedButton(
          style: widget.buttonStyle,
          onPressed: handler,
          child: widget.builder(context, _state),
        );
      case ButtonType.icon:
        return IconButton(
          onPressed: handler,
          icon: widget.builder(context, _state),
        );
    }
  }
}

/// Controller for external control of the TimerWidget.
class TimerWidgetController<T> extends ChangeNotifier {
  VoidCallback _startTimer = () {};
  VoidCallback _stopTimer = () {};
  VoidCallback _pauseTimer = () {};
  VoidCallback _resumeTimer = () {};
  VoidCallback _executeAsync = () {};
  VoidCallback _retry = () {};
  VoidCallback _reset = () {};
  TimerWidgetState Function() _getState = () => const TimerWidgetState();

  /// Current state of the widget
  TimerWidgetState get state => _getState();

  /// Whether timer is counting
  bool get isCounting => state.isCounting;

  /// Whether timer is paused
  bool get isPaused => state.isPaused;

  /// Remaining seconds
  int get remainingSeconds => state.remainingSeconds;

  /// Whether async operation is loading
  bool get isLoading => state.isLoading;

  /// Whether async operation succeeded
  bool get isSuccess => state.isSuccess;

  /// Whether async operation failed
  bool get isError => state.isError;

  /// Data from successful operation
  T? get data => state.data as T?;

  /// Error from failed operation
  Object? get error => state.error;

  /// Start the countdown timer
  void startTimer() => _startTimer();

  /// Stop the timer (resets to 0)
  void stopTimer() => _stopTimer();

  /// Pause the timer (keeps remaining time)
  void pauseTimer() => _pauseTimer();

  /// Resume the timer from paused state
  void resumeTimer() => _resumeTimer();

  /// Execute async operation
  void execute() => _executeAsync();

  /// Retry failed operation
  void retry() => _retry();

  /// Reset to initial state
  void reset() => _reset();

  void _bind({
    required VoidCallback startTimer,
    required VoidCallback stopTimer,
    required VoidCallback pauseTimer,
    required VoidCallback resumeTimer,
    required VoidCallback executeAsync,
    required VoidCallback retry,
    required VoidCallback reset,
    required TimerWidgetState Function() getState,
  }) {
    _startTimer = startTimer;
    _stopTimer = stopTimer;
    _pauseTimer = pauseTimer;
    _resumeTimer = resumeTimer;
    _executeAsync = executeAsync;
    _retry = retry;
    _reset = reset;
    _getState = getState;
  }

  void _notifyStateChange() {
    notifyListeners();
  }
}
