// import 'package:flutter/material.dart';
// import 'package:timer_widget/timer_widget.dart';

// class TestPkg extends StatelessWidget {
//   const TestPkg({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
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
//         title: const Text("TimerWidgetController Demo"),
//         backgroundColor: Colors.orange,
//         foregroundColor: Colors.white,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // ==========================================
//             // Info Card
//             // ==========================================
//             Card(
//               color: Colors.orange.shade50,
//               child: const Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "🎮 Global Controller - No passing needed!",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       "Just give widget an 'id' and control from ANYWHERE:\n"
//                       "TimerWidgetController.start('otp_button');\n"
//                       "TimerWidgetController.stop('submit');",
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 24),

//             // ==========================================
//             // 4 BUTTONS - Each with unique id
//             // ==========================================
//             const Text(
//               "4 Independent Timers (just give id!)",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 12),

//             // Button 1: OTP Timer
//             _buildTimerCard(
//               id: "otp_button",
//               label: "OTP Button",
//               icon: Icons.sms,
//               color: Colors.blue,
//               timerType: TimerType.cooldown,
//               seconds: 10,
//             ),

//             // Button 2: Submit Timer
//             _buildTimerCard(
//               id: "submit_button",
//               label: "Submit Form",
//               icon: Icons.send,
//               color: Colors.green,
//               timerType: TimerType.countdown,
//               seconds: 5,
//             ),

//             // Button 3: Refresh Timer
//             _buildTimerCard(
//               id: "refresh_button",
//               label: "Refresh Data",
//               icon: Icons.refresh,
//               color: Colors.purple,
//               timerType: TimerType.countdown,
//               seconds: 8,
//             ),

//             // Button 4: Download Timer
//             _buildTimerCard(
//               id: "download_button",
//               label: "Download",
//               icon: Icons.download,
//               color: Colors.red,
//               timerType: TimerType.countdown,
//               seconds: 6,
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
//                       "🕹️ Control from ANYWHERE",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       "No controller needed! Just use static methods:",
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                     const SizedBox(height: 16),

//                     // Control specific timers
//                     Wrap(
//                       spacing: 8,
//                       runSpacing: 8,
//                       children: [
//                         _buildControlButton("Start OTP", () {
//                           TimerWidgetController.start("otp_button");
//                         }),
//                         _buildControlButton("Stop OTP", () {
//                           TimerWidgetController.stop("otp_button");
//                         }),
//                         _buildControlButton("Start Submit", () {
//                           TimerWidgetController.start("submit_button");
//                         }),
//                         _buildControlButton("Pause Refresh", () {
//                           TimerWidgetController.pause("refresh_button");
//                         }),
//                         _buildControlButton("Resume Refresh", () {
//                           TimerWidgetController.resume("refresh_button");
//                         }),
//                       ],
//                     ),

//                     const Divider(height: 32),

//                     const Text(
//                       "Bulk Actions:",
//                       style: TextStyle(color: Colors.grey),
//                     ),
//                     const SizedBox(height: 12),

//                     Wrap(
//                       spacing: 8,
//                       runSpacing: 8,
//                       children: [
//                         FilledButton.icon(
//                           onPressed: () => TimerWidgetController.startAll(),
//                           icon: const Icon(Icons.play_arrow),
//                           label: const Text("Start All"),
//                         ),
//                         FilledButton.icon(
//                           onPressed: () => TimerWidgetController.stopAll(),
//                           icon: const Icon(Icons.stop),
//                           label: const Text("Stop All"),
//                           style: FilledButton.styleFrom(
//                             backgroundColor: Colors.red,
//                           ),
//                         ),
//                         FilledButton.icon(
//                           onPressed: () => TimerWidgetController.pauseAll(),
//                           icon: const Icon(Icons.pause),
//                           label: const Text("Pause All"),
//                           style: FilledButton.styleFrom(
//                             backgroundColor: Colors.orange,
//                           ),
//                         ),
//                         FilledButton.icon(
//                           onPressed: () => TimerWidgetController.resetAll(),
//                           icon: const Icon(Icons.restart_alt),
//                           label: const Text("Reset All"),
//                           style: FilledButton.styleFrom(
//                             backgroundColor: Colors.grey,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 24),

//             // ==========================================
//             // Code Example
//             // ==========================================
//             Card(
//               color: Colors.grey.shade900,
//               child: const Padding(
//                 padding: EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "💻 Super Simple!",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     SizedBox(height: 12),
//                     SelectableText(
//                       '''// Just give an ID - that's it!
// TimerWidget(
//   id: "otp_button",
//   timerType: TimerType.cooldown,
//   timeOutInSeconds: 30,
//   builder: (context, state) { ... },
// )

// // Control from ANYWHERE - no passing!
// TimerWidgetController.start("otp_button");
// TimerWidgetController.stop("otp_button");
// TimerWidgetController.pause("otp_button");
// TimerWidgetController.resume("otp_button");

// // Get state
// TimerWidgetController.isCounting("otp_button");
// TimerWidgetController.remainingSeconds("otp_button");

// // Bulk
// TimerWidgetController.stopAll();''',
//                       style: TextStyle(
//                         fontFamily: 'monospace',
//                         fontSize: 12,
//                         color: Colors.greenAccent,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 24),

//             // ==========================================
//             // Test from another class
//             // ==========================================
//             ElevatedButton(
//               onPressed: () {
//                 // This simulates controlling from a data provider/service class
//                 DataService.loadData();
//               },
//               child: const Text("Test: Call from DataService class"),
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
//             // Icon
//             CircleAvatar(
//               backgroundColor: color.withValues(alpha: 0.2),
//               child: Icon(icon, color: color),
//             ),
//             const SizedBox(width: 16),

//             // Label & ID
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     label,
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   Text(
//                     'id: "$id"',
//                     style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//                   ),
//                 ],
//               ),
//             ),

//             // Timer Widget - just give id!
//             TimerWidget(
//               id: id,
//               timerType: timerType,
//               timeOutInSeconds: seconds,
//               buttonType: ButtonType.elevated,
//               buttonStyle: ElevatedButton.styleFrom(backgroundColor: color),
//               builder: (context, state) {
//                 if (state.isCounting) {
//                   return Text(
//                     "${state.remainingSeconds}s",
//                     style: const TextStyle(color: Colors.white),
//                   );
//                 }
//                 return Text(
//                   timerType == TimerType.cooldown ? "Send" : "Start",
//                   style: const TextStyle(color: Colors.white),
//                 );
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
// }

// // ============================================================================
// // EXAMPLE: Control from a separate class (like a data provider/service)
// // ============================================================================

// class DataService {
//   // You can control timers from ANY class - no context needed!
//   static void loadData() {
//     debugPrint("DataService: Starting OTP timer...");
//     TimerWidgetController.start("otp_button");

//     debugPrint("DataService: Stopping submit timer...");
//     TimerWidgetController.stop("submit_button");

//     // Check state
//     if (TimerWidgetController.isCounting("otp_button")) {
//       debugPrint("OTP timer is running!");
//     }

//     debugPrint("Registered timers: ${TimerWidgetController.allIds}");
//   }
// }
