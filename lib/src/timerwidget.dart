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
enum TimerType {
  /// Simple countdown timer
  countdown,

  /// Button with cooldown period after press (e.g., OTP resend)
  cooldown,

  /// Debounced button to prevent rapid clicks
  debounce,

  /// Async operation handler with loading state and retry
  asyncLoader,

  /// Infinite timer that counts up (stopwatch style)
  stopwatch,
}

/// Select Button Type
enum ButtonType { none, elevated, outline, icon }

// ============================================================================
// GLOBAL TIMER WIDGET CONTROLLER - Control any timer from anywhere!
// ============================================================================

/// Global controller to control any TimerWidget by its ID from anywhere.
///
/// ## Usage
/// ```dart
/// // 1. Give your widget an ID
/// TimerWidget(
///   id: "otp_button",
///   timerType: TimerType.cooldown,
///   timeOutInSeconds: 30,
///   builder: (context, state) { ... },
/// )
///
/// // 2. Control from ANYWHERE - no need to pass controller!
/// TimerWidgetController.start("otp_button");
/// TimerWidgetController.stop("otp_button");
/// TimerWidgetController.pause("otp_button");
/// TimerWidgetController.resume("otp_button");
///
/// // 3. Get state from anywhere
/// TimerWidgetController.getState("otp_button")?.isCounting;
/// TimerWidgetController.isCounting("otp_button");
/// TimerWidgetController.isLoading("submit_button");
///
/// // 4. Bulk control
/// TimerWidgetController.stopAll();
/// TimerWidgetController.resetAll();
/// ```
class TimerWidgetController {
  // Private constructor - this is a static-only class
  TimerWidgetController._();

  // Global registry of all timer widgets
  static final Map<String, _TimerWidgetActions> _registry = {};

  // ==================== Registration (used internally) ====================

  /// Register a timer widget (called internally by TimerWidget)
  static void _register(String id, _TimerWidgetActions actions) {
    _registry[id] = actions;
  }

  /// Unregister a timer widget (called internally when widget disposes)
  static void _unregister(String id) {
    _registry.remove(id);
  }

  // ==================== Control Methods by ID ====================

  /// Start timer by ID
  static void start(String id) => _registry[id]?.start();

  /// Stop timer by ID (resets to 0)
  static void stop(String id) => _registry[id]?.stop();

  /// Pause timer by ID (keeps remaining time)
  static void pause(String id) => _registry[id]?.pause();

  /// Resume timer by ID
  static void resume(String id) => _registry[id]?.resume();

  /// Execute async operation by ID
  static void execute(String id) => _registry[id]?.execute();

  /// Retry failed operation by ID
  static void retry(String id) => _registry[id]?.retry();

  /// Reset timer by ID
  static void reset(String id) => _registry[id]?.reset();

  // ==================== State Getters by ID ====================

  /// Get state of timer by ID
  static TimerWidgetState? getState(String id) => _registry[id]?.getState();

  /// Check if timer is counting
  static bool isCounting(String id) =>
      _registry[id]?.getState().isCounting ?? false;

  /// Check if timer is paused
  static bool isPaused(String id) =>
      _registry[id]?.getState().isPaused ?? false;

  /// Check if async is loading
  static bool isLoading(String id) =>
      _registry[id]?.getState().isLoading ?? false;

  /// Check if async succeeded
  static bool isSuccess(String id) =>
      _registry[id]?.getState().isSuccess ?? false;

  /// Check if async failed
  static bool isError(String id) => _registry[id]?.getState().isError ?? false;

  /// Get remaining seconds
  static int remainingSeconds(String id) =>
      _registry[id]?.getState().remainingSeconds ?? 0;

  /// Get data from successful async operation
  static dynamic getData(String id) => _registry[id]?.getState().data;

  /// Get error from failed async operation
  static Object? getError(String id) => _registry[id]?.getState().error;

  // ==================== Utility Methods ====================

  /// Get all registered timer IDs
  static List<String> get allIds => _registry.keys.toList();

  /// Check if a timer with given ID exists
  static bool hasId(String id) => _registry.containsKey(id);

  /// Get count of registered timers
  static int get count => _registry.length;

  // ==================== Bulk Control Methods ====================

  /// Start all timers
  static void startAll() {
    for (final actions in _registry.values) {
      actions.start();
    }
  }

  /// Stop all timers
  static void stopAll() {
    for (final actions in _registry.values) {
      actions.stop();
    }
  }

  /// Pause all timers
  static void pauseAll() {
    for (final actions in _registry.values) {
      actions.pause();
    }
  }

  /// Resume all timers
  static void resumeAll() {
    for (final actions in _registry.values) {
      actions.resume();
    }
  }

  /// Reset all timers
  static void resetAll() {
    for (final actions in _registry.values) {
      actions.reset();
    }
  }

  /// Clear all registrations (use with caution)
  static void clear() {
    _registry.clear();
  }
}

/// Internal class to hold timer actions
class _TimerWidgetActions {
  final VoidCallback start;
  final VoidCallback stop;
  final VoidCallback pause;
  final VoidCallback resume;
  final VoidCallback execute;
  final VoidCallback retry;
  final VoidCallback reset;
  final TimerWidgetState Function() getState;

  _TimerWidgetActions({
    required this.start,
    required this.stop,
    required this.pause,
    required this.resume,
    required this.execute,
    required this.retry,
    required this.reset,
    required this.getState,
  });
}

// ============================================================================
// TIMER WIDGET
// ============================================================================

/// # TimerWidget - All-in-one timer/loading widget
///
/// ## Select behavior with `timerType`:
/// - `TimerType.countdown` - Simple countdown timer
/// - `TimerType.cooldown` - Button with cooldown (OTP/resend)
/// - `TimerType.debounce` - Prevents rapid clicks
/// - `TimerType.asyncLoader` - Async ops with loading/retry
/// - `TimerType.stopwatch` - Infinite count-up timer (useful for API loading)
///
/// ## Example - Just give ID and control from anywhere!
/// ```dart
/// // Widget
/// TimerWidget(
///   id: "otp_button",  // Just give an ID
///   timerType: TimerType.cooldown,
///   timeOutInSeconds: 30,
///   builder: (context, state) {
///     return Text(state.isCounting ? "${state.remainingSeconds}s" : "Send OTP");
///   },
/// )
///
/// // Control from ANYWHERE - even from another class/page!
/// TimerWidgetController.start("otp_button");
/// TimerWidgetController.stop("otp_button");
/// ```

class TimerWidget<T> extends StatefulWidget {
  /// Builder that receives current state
  final TimerWidgetBuilder builder;

  /// **Unique ID for this timer** - Use this to control from anywhere!
  final String? id;

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
    this.id,
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
    _registerWithGlobalController();

    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleAutoStart();
      });
    }
  }

  void _registerWithGlobalController() {
    if (widget.id != null) {
      TimerWidgetController._register(
        widget.id!,
        _TimerWidgetActions(
          start: _startCountdown,
          stop: _stopCountdown,
          pause: _pauseCountdown,
          resume: _resumeCountdown,
          execute: _executeAsync,
          retry: _retry,
          reset: _reset,
          getState: () => _state,
        ),
      );
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
      case TimerType.stopwatch:
        _startCountdown();
        break;
      case TimerType.debounce:
        // Debounce doesn't auto-start
        break;
    }
  }

  @override
  void didUpdateWidget(covariant TimerWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-register if ID changed
    if (oldWidget.id != widget.id) {
      if (oldWidget.id != null) {
        TimerWidgetController._unregister(oldWidget.id!);
      }
      _registerWithGlobalController();
    }
  }

  // ======================== COUNTDOWN LOGIC ========================

  void _startCountdown() {
    if (!mounted) return;

    // Cancel any existing timer first
    _timer?.cancel();
    _timer = null;

    setState(() {
      _state = _state.copyWith(
        isCounting: true,
        isPaused: false,
        remainingSeconds: widget.timerType == TimerType.stopwatch
            ? 0
            : widget.timeOutInSeconds,
      );
    });

    // If stopwatch and asyncOperation is provided, start it too
    if (widget.timerType == TimerType.stopwatch &&
        widget.asyncOperation != null) {
      _executeAsync();
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final isStopwatch = widget.timerType == TimerType.stopwatch;

      if (!isStopwatch && _state.remainingSeconds <= 1) {
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
      } else {
        setState(() {
          _state = _state.copyWith(
            remainingSeconds: isStopwatch
                ? _state.remainingSeconds + 1
                : _state.remainingSeconds - 1,
          );
        });
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
      }
    }
  }

  void _resumeCountdown() {
    if (!mounted) return;
    final isStopwatch = widget.timerType == TimerType.stopwatch;
    if (!_state.isPaused) return;
    if (!isStopwatch && _state.remainingSeconds <= 0) return;

    // Cancel any existing timer first
    _timer?.cancel();
    _timer = null;

    setState(() {
      _state = _state.copyWith(isPaused: false);
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final isStopwatch = widget.timerType == TimerType.stopwatch;

      if (!isStopwatch && _state.remainingSeconds <= 1) {
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
      } else {
        setState(() {
          _state = _state.copyWith(
            remainingSeconds: isStopwatch
                ? _state.remainingSeconds + 1
                : _state.remainingSeconds - 1,
          );
        });
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
    _currentRetry = 0;

    await _performAsyncOperation();
  }

  Future<void> _performAsyncOperation() async {
    try {
      final result = await widget.asyncOperation!();
      if (!mounted) return;

      // If it's a stopwatch, stop it now
      if (widget.timerType == TimerType.stopwatch) {
        _timer?.cancel();
        _timer = null;
      }

      setState(() {
        _state = TimerWidgetState(
          remainingSeconds: _state.remainingSeconds,
          isCounting: false,
          isPaused: false,
          isLoading: false,
          isSuccess: true,
          isError: false,
          data: result,
        );
      });
      widget.onSuccess?.call(result);
      widget.onComplete?.call();
    } catch (e) {
      if (!mounted) return;

      if (_currentRetry < widget.retryCount) {
        _currentRetry++;
        await Future.delayed(widget.retryDelay);
        if (mounted) {
          await _performAsyncOperation();
        }
      } else {
        // If it's a stopwatch, stop it on error too after all retries
        if (widget.timerType == TimerType.stopwatch) {
          _timer?.cancel();
          _timer = null;
        }

        setState(() {
          _state = TimerWidgetState(
            remainingSeconds: _state.remainingSeconds,
            isLoading: false,
            isSuccess: false,
            isError: true,
            error: e,
            isCounting: false,
            isPaused: false,
          );
        });
        widget.onError?.call(e);
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
    }
  }

  // ======================== DEBOUNCE LOGIC ========================

  Future<void> _handleDebounce() async {
    if (_state.isLoading || widget.asyncOperation == null) return;

    _debounceTimer?.cancel();

    setState(() {
      _state = _state.copyWith(isLoading: true);
    });

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
      case TimerType.stopwatch:
        if (_state.isCounting && !_state.isPaused) {
          _stopCountdown();
        } else {
          widget.onPressed?.call();
          _startCountdown();
        }
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
      case TimerType.stopwatch:
        return false; // Stopwatch is usually manually stopped
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    _debounceTimer?.cancel();
    _debounceTimer = null;

    // Unregister from global controller
    if (widget.id != null) {
      TimerWidgetController._unregister(widget.id!);
    }

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
