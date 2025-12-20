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
    GlobalControlExample(),
  ];

  final List<String> _titles = const [
    'Countdown',
    'Cooldown',
    'Debounce',
    'Async',
    'Global Control',
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
          NavigationDestination(
            icon: Icon(Icons.gamepad_outlined),
            selectedIcon: Icon(Icons.gamepad),
            label: 'Global',
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// EXAMPLE 1: COUNTDOWN TIMER
// ============================================================================

class CountdownExample extends StatefulWidget {
  const CountdownExample({super.key});

  @override
  State<CountdownExample> createState() => _CountdownExampleState();
}

class _CountdownExampleState extends State<CountdownExample> {
  String message = "Press the button to start countdown";

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoCard(
            title: "TimerType.countdown",
            description:
                "A simple countdown timer. Just give it an 'id' and control from anywhere!",
            codeExample: '''
TimerWidget(
  id: "my_timer",  // Just give an ID!
  timerType: TimerType.countdown,
  timeOutInSeconds: 5,
  builder: (context, state) {
    return Text(state.isCounting ? "\${state.remainingSeconds}s" : "Start");
  },
)

// Control from ANYWHERE:
TimerWidgetController.start("my_timer");
TimerWidgetController.stop("my_timer");''',
          ),
          const SizedBox(height: 24),
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
          Center(
            child: TimerWidget(
              id: "countdown_demo",
              timerType: TimerType.countdown,
              timeOutInSeconds: 5,
              buttonType: ButtonType.elevated,
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Control via TimerWidgetController",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonal(
                        onPressed: () =>
                            TimerWidgetController.start("countdown_demo"),
                        child: const Text("Start"),
                      ),
                      FilledButton.tonal(
                        onPressed: () =>
                            TimerWidgetController.pause("countdown_demo"),
                        child: const Text("Pause"),
                      ),
                      FilledButton.tonal(
                        onPressed: () =>
                            TimerWidgetController.resume("countdown_demo"),
                        child: const Text("Resume"),
                      ),
                      FilledButton.tonal(
                        onPressed: () {
                          TimerWidgetController.stop("countdown_demo");
                          setState(() => message = "Timer stopped");
                        },
                        child: const Text("Stop"),
                      ),
                    ],
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
// EXAMPLE 2: COOLDOWN BUTTON (OTP/Resend)
// ============================================================================

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
          _buildInfoCard(
            title: "TimerType.cooldown",
            description:
                "Perfect for OTP resend buttons. Button is disabled during cooldown.",
            codeExample: '''
TimerWidget(
  id: "otp_button",
  timerType: TimerType.cooldown,
  timeOutInSeconds: 30,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (index) => Container(
                        width: 50,
                        height: 50,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.shade300, width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text("•", style: TextStyle(fontSize: 24)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TimerWidget(
                    id: "otp_cooldown",
                    timerType: TimerType.cooldown,
                    timeOutInSeconds: 10,
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
                        onPressed: null,
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

class DebounceExample extends StatefulWidget {
  const DebounceExample({super.key});

  @override
  State<DebounceExample> createState() => _DebounceExampleState();
}

class _DebounceExampleState extends State<DebounceExample> {
  List<String> submissions = [];

  Future<void> _submitForm() async {
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
          _buildInfoCard(
            title: "TimerType.debounce",
            description:
                "Prevents rapid button clicks. Shows loading during async operation.",
            codeExample: '''
TimerWidget<void>(
  id: "submit_btn",
  timerType: TimerType.debounce,
  debounceMs: 500,
  asyncOperation: () async => await submitForm(),
  builder: (context, state) {
    if (state.isLoading) return Text("Submitting...");
    return Text("Submit");
  },
)''',
          ),
          const SizedBox(height: 24),
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
                  TimerWidget<void>(
                    id: "debounce_submit",
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
                        "No submissions yet. Try clicking rapidly!",
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

class AsyncLoaderExample extends StatefulWidget {
  const AsyncLoaderExample({super.key});

  @override
  State<AsyncLoaderExample> createState() => _AsyncLoaderExampleState();
}

class _AsyncLoaderExampleState extends State<AsyncLoaderExample> {
  bool shouldFail = false;

  Future<Map<String, dynamic>> _fetchUserData() async {
    await Future.delayed(const Duration(seconds: 2));
    if (shouldFail) {
      throw Exception("Network error");
    }
    return {
      "name": "John Doe",
      "email": "john@example.com",
      "role": "Developer",
    };
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoCard(
            title: "TimerType.asyncLoader",
            description: "Load data with auto-retry support.",
            codeExample: '''
TimerWidget<UserData>(
  id: "user_loader",
  timerType: TimerType.asyncLoader,
  asyncOperation: () => fetchUser(),
  retryCount: 2,
  builder: (context, state) {
    if (state.isLoading) return CircularProgressIndicator();
    if (state.isError) return Text("Error!");
    if (state.isSuccess) return Text("\${state.data}");
    return Text("Tap to load");
  },
)

// Control from anywhere:
TimerWidgetController.execute("user_loader");
TimerWidgetController.retry("user_loader");''',
          ),
          const SizedBox(height: 24),
          Card(
            color: shouldFail ? Colors.red.shade50 : Colors.green.shade50,
            child: SwitchListTile(
              title: Text(
                shouldFail ? "Simulate Failure" : "Simulate Success",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              value: shouldFail,
              onChanged: (value) => setState(() => shouldFail = value),
            ),
          ),
          const SizedBox(height: 24),
          TimerWidget<Map<String, dynamic>>(
            id: "async_loader_demo",
            timerType: TimerType.asyncLoader,
            asyncOperation: _fetchUserData,
            retryCount: 2,
            retryDelay: const Duration(seconds: 1),
            autoStart: false,
            buttonType: ButtonType.none,
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
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () =>
                      TimerWidgetController.execute("async_loader_demo"),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Load Data"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      TimerWidgetController.reset("async_loader_demo"),
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
    if (state.isLoading) {
      return const Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text("Loading..."),
        ],
      );
    }

    if (state.isSuccess && state.data != null) {
      final data = state.data as Map<String, dynamic>;
      return Column(
        children: [
          const Icon(Icons.check_circle, size: 48, color: Colors.green),
          const SizedBox(height: 16),
          Text(data["name"] ?? "",
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(data["email"] ?? ""),
        ],
      );
    }

    if (state.isError) {
      return Column(
        children: [
          const Icon(Icons.error, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text("${state.error}", style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => TimerWidgetController.retry("async_loader_demo"),
            child: const Text("Retry"),
          ),
        ],
      );
    }

    return Column(
      children: [
        Icon(Icons.cloud_download, size: 48, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        const Text("Tap 'Load Data' to fetch"),
      ],
    );
  }
}

// ============================================================================
// EXAMPLE 5: GLOBAL CONTROL - Multiple timers controlled from anywhere!
// ============================================================================

class GlobalControlExample extends StatelessWidget {
  const GlobalControlExample({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoCard(
            title: "Global TimerWidgetController",
            description:
                "Control ANY timer from ANYWHERE! Just give widgets an 'id' and use static methods.",
            codeExample: '''
// Give widgets unique IDs
TimerWidget(id: "timer1", ...)
TimerWidget(id: "timer2", ...)

// Control from ANYWHERE - no passing needed!
TimerWidgetController.start("timer1");
TimerWidgetController.stop("timer2");
TimerWidgetController.pauseAll();
TimerWidgetController.stopAll();''',
          ),

          const SizedBox(height: 24),

          // Multiple timer widgets
          _buildTimerRow("button_1", "Timer 1", Colors.blue),
          _buildTimerRow("button_2", "Timer 2", Colors.green),
          _buildTimerRow("button_3", "Timer 3", Colors.orange),
          _buildTimerRow("button_4", "Timer 4", Colors.purple),

          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Global Control Panel",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: () => TimerWidgetController.startAll(),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text("Start All"),
                      ),
                      FilledButton.icon(
                        onPressed: () => TimerWidgetController.stopAll(),
                        icon: const Icon(Icons.stop),
                        label: const Text("Stop All"),
                        style:
                            FilledButton.styleFrom(backgroundColor: Colors.red),
                      ),
                      FilledButton.icon(
                        onPressed: () => TimerWidgetController.pauseAll(),
                        icon: const Icon(Icons.pause),
                        label: const Text("Pause All"),
                        style: FilledButton.styleFrom(
                            backgroundColor: Colors.orange),
                      ),
                      FilledButton.icon(
                        onPressed: () => TimerWidgetController.resetAll(),
                        icon: const Icon(Icons.restart_alt),
                        label: const Text("Reset All"),
                        style: FilledButton.styleFrom(
                            backgroundColor: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerRow(String id, String label, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(Icons.timer, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('id: "$id"',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            TimerWidget(
              id: id,
              timerType: TimerType.countdown,
              timeOutInSeconds: 5,
              buttonType: ButtonType.elevated,
              buttonStyle: ElevatedButton.styleFrom(backgroundColor: color),
              builder: (context, state) {
                if (state.isCounting) {
                  return Text("${state.remainingSeconds}s",
                      style: const TextStyle(color: Colors.white));
                }
                return const Text("Start",
                    style: TextStyle(color: Colors.white));
              },
            ),
          ],
        ),
      ),
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
          const SizedBox(height: 12),
          Text(description),
          const SizedBox(height: 12),
          ExpansionTile(
            title: const Text("View Code", style: TextStyle(fontSize: 14)),
            tilePadding: EdgeInsets.zero,
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
