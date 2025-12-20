import 'package:flutter/material.dart';
import 'package:timer_widget/timer_widget.dart';

void main() {
  runApp(const TimerWidgetExampleApp());
}

/// # Timer Widget Package Examples
///
/// This app demonstrates all features of the timer_widget package.
/// Navigate through tabs to see different examples.
class TimerWidgetExampleApp extends StatelessWidget {
  const TimerWidgetExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timer Widget Examples',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    CountdownExample(),
    CooldownExample(),
    DebounceExample(),
    AsyncLoaderExample(),
  ];

  final List<String> _titles = const [
    'Countdown Timer',
    'Cooldown (OTP)',
    'Debounce Button',
    'Async Loader',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: 'Countdown',
          ),
          NavigationDestination(
            icon: Icon(Icons.lock_clock_outlined),
            selectedIcon: Icon(Icons.lock_clock),
            label: 'Cooldown',
          ),
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield),
            label: 'Debounce',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud_download_outlined),
            selectedIcon: Icon(Icons.cloud_download),
            label: 'Async',
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 1: COUNTDOWN TIMER
// ============================================================================

/// ## TimerType.countdown
///
/// Use this for simple countdown timers.
/// Great for rate limiting, cooldowns, timeouts, etc.
///
/// ### Features:
/// - Start/Stop/Pause/Resume via controller
/// - Auto-start option
/// - `onComplete` callback when timer finishes
/// - `disableDuringCounting` to prevent clicks while counting
class CountdownExample extends StatefulWidget {
  const CountdownExample({super.key});

  @override
  State<CountdownExample> createState() => _CountdownExampleState();
}

class _CountdownExampleState extends State<CountdownExample> {
  // Create a controller for external control
  final TimerWidgetController controller = TimerWidgetController();
  String message = "Press the button to start countdown";

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Description Card
          _buildInfoCard(
            title: "TimerType.countdown",
            description:
                "A simple countdown timer. Disables the button while counting down. "
                "Use the controller to start, stop, pause, or resume externally.",
            codeExample: '''
TimerWidget(
  timerType: TimerType.countdown,
  timeOutInSeconds: 5,
  buttonType: ButtonType.elevated,
  controller: controller,
  onPressed: () => print("Started!"),
  onComplete: () => print("Done!"),
  builder: (context, state) {
    if (state.isCounting) {
      return Text("Wait \${state.remainingSeconds}s");
    }
    return Text("Click Me");
  },
)''',
          ),

          const SizedBox(height: 24),

          // Status Message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ),

          const SizedBox(height: 24),

          // The Timer Widget
          Center(
            child: TimerWidget(
              timerType: TimerType.countdown,
              timeOutInSeconds: 5,
              buttonType: ButtonType.elevated,
              controller: controller,
              disableDuringCounting: true,
              onPressed: () {
                setState(() => message = "⏳ Counting down...");
              },
              onComplete: () {
                setState(() => message = "✅ Timer completed!");
              },
              builder: (context, state) {
                if (state.isCounting) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text("Wait ${state.remainingSeconds}s"),
                    ],
                  );
                }
                return const Text("Start 5s Timer");
              },
            ),
          ),

          const SizedBox(height: 24),

          // External Control Buttons
          _buildControlButtons(),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "External Control (via Controller)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonal(
                  onPressed: () => controller.startTimer(),
                  child: const Text("Start"),
                ),
                FilledButton.tonal(
                  onPressed: () => controller.pauseTimer(),
                  child: const Text("Pause"),
                ),
                FilledButton.tonal(
                  onPressed: () => controller.resumeTimer(),
                  child: const Text("Resume"),
                ),
                FilledButton.tonal(
                  onPressed: () {
                    controller.stopTimer();
                    setState(() => message = "Timer stopped");
                  },
                  child: const Text("Stop"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 2: COOLDOWN BUTTON (OTP/Resend)
// ============================================================================

/// ## TimerType.cooldown
///
/// Use this for buttons that need a cooldown period after each press.
/// Perfect for OTP resend, rate-limited actions, etc.
///
/// ### Features:
/// - Button automatically disabled during cooldown
/// - Shows remaining seconds
/// - Re-enables when cooldown expires
class CooldownExample extends StatefulWidget {
  const CooldownExample({super.key});

  @override
  State<CooldownExample> createState() => _CooldownExampleState();
}

class _CooldownExampleState extends State<CooldownExample> {
  int otpSentCount = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Description Card
          _buildInfoCard(
            title: "TimerType.cooldown",
            description:
                "Perfect for OTP resend buttons. After pressing, the button enters "
                "a cooldown period and shows a countdown. User cannot press again until cooldown expires.",
            codeExample: '''
TimerWidget(
  timerType: TimerType.cooldown,
  timeOutInSeconds: 30,
  buttonType: ButtonType.outline,
  onPressed: () => sendOTP(),
  builder: (context, state) {
    if (state.isCounting) {
      return Text("Resend in \${state.remainingSeconds}s");
    }
    return Text("Send OTP");
  },
)''',
          ),

          const SizedBox(height: 24),

          // OTP Input Simulation
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.phone_android,
                      size: 48, color: Colors.indigo),
                  const SizedBox(height: 12),
                  const Text(
                    "Enter OTP",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "OTP sent $otpSentCount time(s)",
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 20),

                  // OTP Input Fields (decorative)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                        4,
                        (index) => Container(
                              width: 50,
                              height: 50,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.grey.shade300, width: 2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child:
                                    Text("•", style: TextStyle(fontSize: 24)),
                              ),
                            )),
                  ),

                  const SizedBox(height: 24),

                  // Cooldown Timer Widget
                  TimerWidget(
                    timerType: TimerType.cooldown,
                    timeOutInSeconds: 10, // 10 seconds for demo
                    buttonType: ButtonType.none,
                    onPressed: () {
                      setState(() => otpSentCount++);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("OTP sent! ✉️"),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    builder: (context, state) {
                      if (state.isCounting) {
                        return TextButton.icon(
                          onPressed: null,
                          icon: const Icon(Icons.timer),
                          label: Text("Resend in ${state.remainingSeconds}s"),
                        );
                      }
                      return TextButton.icon(
                        onPressed: null, // Handled by TimerWidget
                        icon: const Icon(Icons.refresh),
                        label: const Text("Resend OTP"),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 3: DEBOUNCE BUTTON
// ============================================================================

/// ## TimerType.debounce
///
/// Use this to prevent rapid/duplicate button clicks.
/// Great for form submissions, API calls, etc.
///
/// ### Features:
/// - Shows loading state during async operation
/// - Prevents clicking while loading
/// - Debounce delay after completion
class DebounceExample extends StatefulWidget {
  const DebounceExample({super.key});

  @override
  State<DebounceExample> createState() => _DebounceExampleState();
}

class _DebounceExampleState extends State<DebounceExample> {
  List<String> submissions = [];

  Future<void> _submitForm() async {
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      submissions
          .add("Submitted at ${DateTime.now().toString().substring(11, 19)}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Description Card
          _buildInfoCard(
            title: "TimerType.debounce",
            description:
                "Prevents rapid button clicks and duplicate submissions. "
                "Shows loading state during async operation. "
                "Has a debounce delay after completion.",
            codeExample: '''
TimerWidget<void>(
  timerType: TimerType.debounce,
  debounceMs: 500,
  buttonType: ButtonType.elevated,
  asyncOperation: () async {
    await submitForm();
  },
  builder: (context, state) {
    if (state.isLoading) {
      return Text("Submitting...");
    }
    return Text("Submit");
  },
)''',
          ),

          const SizedBox(height: 24),

          // Form Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Sample Form",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Debounce Submit Button
                  TimerWidget<void>(
                    timerType: TimerType.debounce,
                    debounceMs: 500,
                    buttonType: ButtonType.elevated,
                    asyncOperation: _submitForm,
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text("Submitting..."),
                          ],
                        );
                      }
                      return const Text("Submit Form");
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Submissions Log
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Submission Log",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (submissions.isNotEmpty)
                        TextButton(
                          onPressed: () => setState(() => submissions.clear()),
                          child: const Text("Clear"),
                        ),
                    ],
                  ),
                  const Divider(),
                  if (submissions.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        "No submissions yet. Try clicking the button rapidly!",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ...submissions.reversed.map((s) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.green, size: 16),
                              const SizedBox(width: 8),
                              Text(s),
                            ],
                          ),
                        )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 4: ASYNC LOADER
// ============================================================================

/// ## TimerType.asyncLoader
///
/// Use this for loading data with automatic retry support.
/// Great for API calls, data fetching, etc.
///
/// ### Features:
/// - Loading, success, error states
/// - Auto-retry on failure
/// - Manual retry support
/// - Access to data and error in state
class AsyncLoaderExample extends StatefulWidget {
  const AsyncLoaderExample({super.key});

  @override
  State<AsyncLoaderExample> createState() => _AsyncLoaderExampleState();
}

class _AsyncLoaderExampleState extends State<AsyncLoaderExample> {
  final TimerWidgetController<Map<String, dynamic>> controller =
      TimerWidgetController();
  bool shouldFail = false;

  // Simulate API call
  Future<Map<String, dynamic>> _fetchUserData() async {
    await Future.delayed(const Duration(seconds: 2));

    if (shouldFail) {
      throw Exception("Network error - Please check your connection");
    }

    return {
      "name": "John Doe",
      "email": "john@example.com",
      "role": "Developer",
      "joinedAt": "2024-01-15",
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Description Card
          _buildInfoCard(
            title: "TimerType.asyncLoader",
            description: "Perfect for loading data from APIs. "
                "Handles loading, success, and error states. "
                "Supports automatic retry on failure.",
            codeExample: '''
TimerWidget<UserData>(
  timerType: TimerType.asyncLoader,
  asyncOperation: () => fetchUserData(),
  retryCount: 2,
  autoStart: true,
  builder: (context, state) {
    if (state.isLoading) return CircularProgressIndicator();
    if (state.isError) return Text("Error: \${state.error}");
    if (state.isSuccess) return Text("Data: \${state.data}");
    return Text("Tap to load");
  },
)''',
          ),

          const SizedBox(height: 24),

          // Toggle for simulating failure
          Card(
            color: shouldFail ? Colors.red.shade50 : Colors.green.shade50,
            child: SwitchListTile(
              title: Text(
                shouldFail ? "Simulate API Failure" : "Simulate API Success",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                shouldFail
                    ? "Next load will fail and trigger retry"
                    : "Next load will succeed",
              ),
              value: shouldFail,
              onChanged: (value) => setState(() => shouldFail = value),
            ),
          ),

          const SizedBox(height: 24),

          // Async Loader Widget
          TimerWidget<Map<String, dynamic>>(
            timerType: TimerType.asyncLoader,
            controller: controller,
            asyncOperation: _fetchUserData,
            retryCount: 2,
            retryDelay: const Duration(seconds: 1),
            autoStart: false,
            buttonType: ButtonType.none,
            onSuccess: (data) => debugPrint("Loaded: $data"),
            onError: (error) => debugPrint("Error: $error"),
            builder: (context, state) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildAsyncContent(state),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          // Manual control
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => controller.execute(),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Load Data"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => controller.reset(),
                  icon: const Icon(Icons.clear),
                  label: const Text("Reset"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAsyncContent(TimerWidgetState state) {
    // Loading State
    if (state.isLoading) {
      return Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            "Loading user data...",
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            "(Will auto-retry 2x on failure)",
            style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
          ),
        ],
      );
    }

    // Success State
    if (state.isSuccess && state.data != null) {
      final data = state.data as Map<String, dynamic>;
      return Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.indigo,
            child: Icon(Icons.person, size: 40, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            data["name"] ?? "",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            data["email"] ?? "",
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 12),
          Chip(label: Text(data["role"] ?? "")),
          const SizedBox(height: 8),
          Text(
            "Joined: ${data["joinedAt"]}",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
        ],
      );
    }

    // Error State
    if (state.isError) {
      return Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            "Failed to Load",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "${state.error}",
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => controller.retry(),
            icon: const Icon(Icons.refresh),
            label: const Text("Retry"),
          ),
        ],
      );
    }

    // Idle State
    return Column(
      children: [
        Icon(Icons.cloud_download, size: 48, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        const Text(
          "No Data Loaded",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "Tap 'Load Data' to fetch user information",
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

// ============================================================================
// SHARED WIDGETS
// ============================================================================

Widget _buildInfoCard({
  required String title,
  required String description,
  required String codeExample,
}) {
  return Card(
    color: Colors.indigo.shade50,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.indigo,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(description),
          const SizedBox(height: 12),
          ExpansionTile(
            title: const Text("View Code", style: TextStyle(fontSize: 14)),
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  codeExample,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: Colors.greenAccent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
