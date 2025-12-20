# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2024-12-20

### 🎉 Major Release - Complete Rewrite

#### ✨ New Features
- **Four Timer Types** - Select behavior with `timerType`:
  - `TimerType.countdown` - Simple countdown timer
  - `TimerType.cooldown` - OTP resend / cooldown button
  - `TimerType.debounce` - Prevent rapid clicks
  - `TimerType.asyncLoader` - Async loading with retry

- **Async Loader Support**
  - Execute async operations (API calls)
  - Auto-retry on failure with configurable `retryCount`
  - `retryDelay` between attempts
  - `onSuccess` and `onError` callbacks

- **Debounce Button**
  - Prevents duplicate form submissions
  - Configurable `debounceMs` delay
  - Shows loading state during operation

- **Enhanced Controller**
  - `pauseTimer()` - Pause countdown
  - `resumeTimer()` - Resume from pause
  - `execute()` - Trigger async operation
  - `retry()` - Retry failed operation
  - `reset()` - Reset to initial state
  - Access `isPaused`, `isLoading`, `isSuccess`, `isError`, `data`, `error`

- **State Object**
  - `TimerWidgetState` with all information
  - `remainingSeconds`, `isCounting`, `isPaused`
  - `isLoading`, `isSuccess`, `isError`, `data`, `error`

- **New Properties**
  - `autoStart` - Auto-start on widget mount
  - `onComplete` - Callback when timer/operation completes

#### 🐛 Bug Fixes
- Fixed multiple timers issue when clicking rapidly
- Fixed controller pause/resume not working
- Timer properly cancelled before starting new one

#### 💥 Breaking Changes
- Removed `provider` dependency - zero external dependencies now!
- Builder signature changed: `(context, state)` instead of `(context, seconds, isCounting)`
- Controller is now optional (was required)

#### 📦 Other
- Updated to support Flutter 3.10+ and Dart 3.0+
- Added comprehensive example app with 4 tabs
- Added SEO topics for pub.dev ranking

## [0.0.4] - Previous Version

- Basic countdown timer functionality
- Required provider dependency
- Basic controller support

## [0.0.3] - [0.0.1]

- Initial releases with basic features
