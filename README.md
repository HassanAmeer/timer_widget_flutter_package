# Timer Widget

- 🌍 updated by livedbs (Free Live Database, Storage)
- [livedbs.web.app](https://livedbs.web.app/)

## ✨ Features
- ⏱️ **Countdown Timer** - Simple countdown with pause/resume
- ❄️ **Cooldown Button** - OTP resend, rate-limited actions
- 🛡️ **Debounce Button** - Prevent rapid clicks, form submission
- 🔄 **Async Loader** - API calls with auto-retry support
- 🎮 **Global Controller** - Control ANY timer from ANYWHERE by ID
- 🎨 **Customizable** - Multiple button types, custom styles
- 📦 **Zero Dependencies** - No Provider, no external packages

A powerful, **all-in-one Flutter timer widget** for countdown timers, cooldown buttons, debounce buttons, and async loading. Perfect for **OTP resend**, **rate limiting**, **form submission**, and **API calls with retry**.

**Zero external dependencies** - all state management is handled internally!

![demo](screenshots/demo.png)

[![pub package](https://img.shields.io/pub/v/timer_widget.svg)](https://pub.dev/packages/timer_widget)
[![likes](https://img.shields.io/pub/likes/timer_widget)](https://pub.dev/packages/timer_widget/score)
[![popularity](https://img.shields.io/pub/popularity/timer_widget)](https://pub.dev/packages/timer_widget/score)
[![pub points](https://img.shields.io/pub/points/timer_widget)](https://pub.dev/packages/timer_widget/score)

## 📦 Installation

```yaml
dependencies:
  timer_widget: ^1.0.0
```

```dart
import 'package:timer_widget/timer_widget.dart';
```

## 🎯 One Widget, Four Behaviors

Select the behavior using `timerType`:

```dart
TimerWidget(
  timerType: TimerType.countdown,  // countdown | cooldown | debounce | asyncLoader
  // ...
)
```

| TimerType | Use Case | Example |
|-----------|----------|---------|
| `countdown` | Simple countdown timer | Timeouts, delays |
| `cooldown` | Button with cooldown period | OTP resend, refresh |
| `debounce` | Prevent rapid clicks | Form submission |
| `asyncLoader` | Async operations with retry | API calls, data loading |

---

## 🎮 Global Controller - Control from ANYWHERE!

**Just give widget an `id` and control from any widget, class, or file!**

### Step 1: Give widgets unique IDs

```dart
// OTP Button
TimerWidget(
  id: "otp_button",  // Unique ID
  timerType: TimerType.cooldown,
  timeOutInSeconds: 30,
  builder: (context, state) {
    if (state.isCounting) {
      return Text("Resend in ${state.remainingSeconds}s");
    }
    return Text("Send OTP");
  },
)

// Submit Button
TimerWidget(
  id: "submit_button",  // Different ID
  timerType: TimerType.debounce,
  asyncOperation: () async => await submitForm(),
  builder: (context, state) {
    return Text(state.isLoading ? "Submitting..." : "Submit");
  },
)
```

### Step 2: Control from ANYWHERE!

```dart
// From any widget, any page, any class!
TimerWidgetController.start("otp_button");
TimerWidgetController.stop("otp_button");
TimerWidgetController.pause("otp_button");
TimerWidgetController.resume("otp_button");
```

### Step 3: Check state from ANYWHERE!

```dart
// Get state
TimerWidgetController.isCounting("otp_button");      // bool
TimerWidgetController.isPaused("otp_button");        // bool
TimerWidgetController.remainingSeconds("otp_button"); // int
TimerWidgetController.isLoading("submit_button");    // bool
TimerWidgetController.isSuccess("submit_button");    // bool
TimerWidgetController.isError("submit_button");      // bool
TimerWidgetController.getData("loader");             // dynamic
TimerWidgetController.getError("loader");            // Object?
```

### Bulk Control All Timers

```dart
TimerWidgetController.startAll();
TimerWidgetController.stopAll();
TimerWidgetController.pauseAll();
TimerWidgetController.resumeAll();
TimerWidgetController.resetAll();
```

### Utility Methods

```dart
TimerWidgetController.allIds;        // List<String> - all registered IDs
TimerWidgetController.hasId("x");    // bool - check if exists
TimerWidgetController.count;         // int - number of registered timers
```

---

## 📱 Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:timer_widget/timer_widget.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // OTP Resend Button
        TimerWidget(
          id: "otp",
          timerType: TimerType.cooldown,
          timeOutInSeconds: 30,
          buttonType: ButtonType.outline,
          onPressed: () => sendOTP(),
          builder: (context, state) {
            if (state.isCounting) {
              return Text("Resend in ${state.remainingSeconds}s");
            }
            return Text("Send OTP");
          },
        ),

        // Form Submit with Debounce
        TimerWidget<void>(
          id: "submit",
          timerType: TimerType.debounce,
          debounceMs: 500,
          buttonType: ButtonType.elevated,
          asyncOperation: () async {
            await submitForm();
          },
          builder: (context, state) {
            if (state.isLoading) {
              return CircularProgressIndicator();
            }
            return Text("Submit");
          },
        ),

        // External Control Buttons
        ElevatedButton(
          onPressed: () => TimerWidgetController.start("otp"),
          child: Text("Force Send OTP"),
        ),
        ElevatedButton(
          onPressed: () => TimerWidgetController.stopAll(),
          child: Text("Stop All Timers"),
        ),
      ],
    );
  }
}

// Control from ANY class - like a service/provider!
class AuthService {
  static void onLogout() {
    // Stop all timers when user logs out
    TimerWidgetController.stopAll();
  }
  
  static void refreshOTP() {
    // Control specific timer
    TimerWidgetController.start("otp");
  }
}
```

---

## 🚀 Quick Examples

### 1. Countdown Timer

```dart
TimerWidget(
  id: "countdown",
  timerType: TimerType.countdown,
  timeOutInSeconds: 5,
  buttonType: ButtonType.elevated,
  onPressed: () => print("Started!"),
  onComplete: () => print("Done!"),
  builder: (context, state) {
    if (state.isCounting) {
      return Text("Wait ${state.remainingSeconds}s");
    }
    return Text("Click Me");
  },
)
```

### 2. OTP Resend / Cooldown Button

```dart
TimerWidget(
  id: "otp_resend",
  timerType: TimerType.cooldown,
  timeOutInSeconds: 30,
  buttonType: ButtonType.outline,
  onPressed: () => sendOTP(),
  builder: (context, state) {
    if (state.isCounting) {
      return Text("Resend in ${state.remainingSeconds}s");
    }
    return Text("Send OTP");
  },
)
```

### 3. Debounce Button (Form Submission)

```dart
TimerWidget<void>(
  id: "form_submit",
  timerType: TimerType.debounce,
  debounceMs: 500,
  buttonType: ButtonType.elevated,
  asyncOperation: () async {
    await submitForm();
  },
  builder: (context, state) {
    if (state.isLoading) {
      return CircularProgressIndicator();
    }
    return Text("Submit");
  },
)
```

### 4. Async Loader with Auto-Retry

```dart
TimerWidget<UserData>(
  id: "user_loader",
  timerType: TimerType.asyncLoader,
  asyncOperation: () => fetchUserData(),
  retryCount: 3,
  retryDelay: Duration(seconds: 1),
  autoStart: true,
  onSuccess: (data) => print("Loaded!"),
  onError: (error) => print("Failed!"),
  builder: (context, state) {
    if (state.isLoading) return CircularProgressIndicator();
    if (state.isError) return Text("Error: ${state.error}");
    if (state.isSuccess) return Text("Data: ${state.data}");
    return Text("Tap to load");
  },
)

// Control from anywhere
TimerWidgetController.execute("user_loader");  // Load
TimerWidgetController.retry("user_loader");    // Retry
TimerWidgetController.reset("user_loader");    // Reset
```

---

## 📖 State Object

The builder receives a `TimerWidgetState` with all information:

```dart
builder: (context, state) {
  state.remainingSeconds  // Countdown seconds remaining
  state.isCounting        // Is timer active?
  state.isPaused          // Is timer paused?
  state.isLoading         // Is async operation loading?
  state.isSuccess         // Did async operation succeed?
  state.isError           // Did async operation fail?
  state.data              // Data from successful operation
  state.error             // Error from failed operation
}
```

---

## ⚙️ All Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `id` | `String?` | `null` | **Unique ID for global control** |
| `timerType` | `TimerType` | `countdown` | Widget behavior mode |
| `builder` | `Function` | required | Build the UI |
| `timeOutInSeconds` | `int` | `5` | Countdown/cooldown duration |
| `buttonType` | `ButtonType` | `none` | Button wrapper type |
| `buttonStyle` | `ButtonStyle?` | `null` | Custom button style |
| `disableDuringCounting` | `bool` | `true` | Disable during countdown |
| `autoStart` | `bool` | `false` | Auto-start on mount |
| `onPressed` | `VoidCallback?` | `null` | Press callback |
| `onComplete` | `VoidCallback?` | `null` | Complete callback |
| `asyncOperation` | `Future<T> Function()?` | `null` | Async function |
| `debounceMs` | `int` | `300` | Debounce delay (ms) |
| `retryCount` | `int` | `0` | Auto-retry count |
| `retryDelay` | `Duration` | `1s` | Retry delay |
| `onSuccess` | `Function(T)?` | `null` | Success callback |
| `onError` | `Function(Object)?` | `null` | Error callback |

---

## 🎨 Button Types

```dart
ButtonType.none      // Raw widget (GestureDetector)
ButtonType.elevated  // ElevatedButton
ButtonType.outline   // OutlinedButton
ButtonType.icon      // IconButton
```

---

## 📱 Example App

Check the `/example` folder for a complete demo app with all features.

```bash
cd example
flutter run
```

---

## 🔑 Keywords

`flutter timer`, `countdown widget`, `cooldown button`, `otp resend flutter`, 
`debounce button`, `async loader`, `loading button`, `rate limit`, 
`flutter button timer`, `countdown button`, `timer controller`, `global controller`

---

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please open an issue or PR on [GitHub](https://github.com/HassanAmeer/timer_widget_flutter_package).

---

<img src="screenshots/demo.png"/>

## Our Other Packages

[![livedb](https://img.shields.io/pub/v/livedb.svg)](https://pub.dev/packages/livedb)
[![media_link_generator](https://img.shields.io/pub/v/media_link_generator.svg)](https://pub.dev/packages/media_link_generator)
[![mediagetter](https://img.shields.io/pub/v/mediagetter.svg)](https://pub.dev/packages/mediagetter)
[![contacts_getter](https://img.shields.io/pub/v/contacts_getter.svg)](https://pub.dev/packages/contacts_getter)
