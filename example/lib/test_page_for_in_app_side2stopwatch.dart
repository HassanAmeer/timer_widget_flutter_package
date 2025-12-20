// import 'package:flutter/material.dart';
// import 'package:timer_widget/timer_widget.dart';

// class TestPkg extends StatelessWidget {
//   const TestPkg({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
//         useMaterial3: true,
//       ),
//       home: const HomePage(),
//     );
//   }
// }

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("TimerWidget Stopwatch Test"),
//         backgroundColor: Colors.orange,
//         foregroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // ==========================================
//             // Stopwatch Type Card
//             // ==========================================
//             Card(
//               color: Colors.blue.shade50,
//               child: const Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "⏱️ NEW: TimerType.stopwatch",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       "An infinite count-up timer. Excellent for showing elapsed time during long API calls. Starts at 0 and increments every second.",
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 24),

//             // ==========================================
//             // Stopwatch Implementation
//             // ==========================================
//             const Text(
//               "Stopwatch Demo (Count-up)",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),

//             _buildStopwatchCard(
//               id: "test_stopwatch",
//               label: "API Sync Task",
//               icon: Icons.sync,
//               color: Colors.blue,
//             ),

//             const SizedBox(height: 24),

//             // ==========================================
//             // External Control Panel
//             // ==========================================
//             Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       "🕹️ Global Controller",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Wrap(
//                       spacing: 8,
//                       runSpacing: 8,
//                       children: [
//                         _buildControlButton("Start", () {
//                           TimerWidgetController.start("test_stopwatch");
//                         }),
//                         _buildControlButton("Stop", () {
//                           TimerWidgetController.stop("test_stopwatch");
//                         }),
//                         _buildControlButton("Pause", () {
//                           TimerWidgetController.pause("test_stopwatch");
//                         }),
//                         _buildControlButton("Resume", () {
//                           TimerWidgetController.resume("test_stopwatch");
//                         }),
//                         _buildControlButton("Reset", () {
//                           TimerWidgetController.reset("test_stopwatch");
//                         }),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 24),

//             // Other timer types for comparison
//             const Text(
//               "Standard Types",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),

//             _buildTimerCard(
//               id: "countdown_test",
//               label: "Standard Countdown",
//               icon: Icons.timer,
//               color: Colors.green,
//               timerType: TimerType.countdown,
//               seconds: 10,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStopwatchCard({
//     required String id,
//     required String label,
//     required IconData icon,
//     required Color color,
//   }) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             Row(
//               children: [
//                 CircleAvatar(
//                   backgroundColor: color.withValues(alpha: 0.2),
//                   child: Icon(icon, color: color),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Text(label,
//                       style: const TextStyle(fontWeight: FontWeight.bold)),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             TimerWidget<String>(
//               id: id,
//               timerType: TimerType.stopwatch,
//               asyncOperation: () async {
//                 await Future.delayed(const Duration(seconds: 5));
//                 return "Sync Complete!";
//               },
//               autoStart: false,
//               builder: (context, state) {
//                 return Column(
//                   children: [
//                     Text(
//                       _formatTime(state.remainingSeconds),
//                       style: const TextStyle(
//                           fontSize: 36,
//                           fontWeight: FontWeight.bold,
//                           fontFamily: 'monospace'),
//                     ),
//                     if (state.isLoading) const Text("Syncing data..."),
//                     if (state.isSuccess) Text("Result: ${state.data}"),
//                   ],
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTimerCard({
//     required String id,
//     required String label,
//     required IconData icon,
//     required Color color,
//     required TimerType timerType,
//     required int seconds,
//   }) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Row(
//           children: [
//             CircleAvatar(
//               backgroundColor: color.withValues(alpha: 0.2),
//               child: Icon(icon, color: color),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Text(label,
//                   style: const TextStyle(fontWeight: FontWeight.bold)),
//             ),
//             TimerWidget(
//               id: id,
//               timerType: timerType,
//               timeOutInSeconds: seconds,
//               buttonType: ButtonType.elevated,
//               buttonStyle: ElevatedButton.styleFrom(backgroundColor: color),
//               builder: (context, state) {
//                 if (state.isCounting) {
//                   return Text("${state.remainingSeconds}s",
//                       style: const TextStyle(color: Colors.white));
//                 }
//                 return const Text("Start",
//                     style: TextStyle(color: Colors.white));
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildControlButton(String label, VoidCallback onPressed) {
//     return OutlinedButton(onPressed: onPressed, child: Text(label));
//   }

//   String _formatTime(int seconds) {
//     final minutes = (seconds / 60).floor();
//     final remainingSecs = seconds % 60;
//     return "${minutes.toString().padLeft(2, '0')}:${remainingSecs.toString().padLeft(2, '0')}";
//   }
// }
