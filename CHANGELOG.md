# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2024-12-20

### 🎉 Major Release - Complete Rewrite

#### ✨ New Features

- **Global Static Controller** 🎮
  - Control ANY timer from ANYWHERE using `TimerWidgetController.start("id")`
  - No need to pass controller around!
  - Just give widget an `id` parameter
  
- **Four Timer Types** - Select behavior with `timerType`:
  - `TimerType.countdown` - Simple countdown timer
  - `TimerType.cooldown` - OTP resend / cooldown button
  - `TimerType.debounce` - Prevent rapid clicks
  - `TimerType.asyncLoader` - Async loading with retry

- **Global Control Methods**
  ```dart
  TimerWidgetController.start("id");
  TimerWidgetController.stop("id");
  TimerWidgetController.pause("id");
  TimerWidgetController.resume("id");
  TimerWidgetController.execute("id");  // For async
  TimerWidgetController.retry("id");
  TimerWidgetController.reset("id");
  ```

- **Bulk Control**
  ```dart
  TimerWidgetController.startAll();
  TimerWidgetController.stopAll();
  TimerWidgetController.pauseAll();
  TimerWidgetController.resetAll();
  ```

- **State Getters**
  ```dart
  TimerWidgetController.isCounting("id");
  TimerWidgetController.isPaused("id");
  TimerWidgetController.remainingSeconds("id");
  TimerWidgetController.isLoading("id");
  TimerWidgetController.isSuccess("id");
  TimerWidgetController.isError("id");
  TimerWidgetController.getData("id");
  TimerWidgetController.getError("id");
  ```

- **Async Loader Support**
  - Execute async operations (API calls)
  - Auto-retry on failure with configurable `retryCount`
  - `retryDelay` between attempts
  - `onSuccess` and `onError` callbacks

- **State Object**
  - `TimerWidgetState` with all information
  - `remainingSeconds`, `isCounting`, `isPaused`
  - `isLoading`, `isSuccess`, `isError`, `data`, `error`

#### 💥 Breaking Changes
- Removed `controller` parameter - use `id` instead!
- Removed `provider` dependency - zero external dependencies now!
- Builder signature: `(context, state)` with full `TimerWidgetState`

#### 📦 Other
- Updated to support Flutter 3.10+ and Dart 3.0+
- Added comprehensive example app with 5 tabs
- Added SEO topics for pub.dev ranking

---

## [0.0.4] - Previous Version

- Basic countdown timer functionality
- Required provider dependency
- Basic controller support (passed via parameter)

## [0.0.3] - [0.0.1]

- Initial releases with basic features
