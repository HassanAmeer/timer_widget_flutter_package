import 'package:flutter/material.dart';
import 'package:timer_widget/timer_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Timer Widget Demo',
        theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TimerWidgetController timerController = TimerWidgetController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timer Widget Demo')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TimerWidget(
              timeOutInSeconds: 5,
              onPressed:
                  () {}, // or can be handle from outside of the widget by controller
              controller:
                  timerController, // handle by this out side of the widget
              buttonType: ButtonType.none, // for custom Widget
              //  ButtonType.icon,
              //  ButtonType.outline,
              //  ButtonType.elavated,
              // buttonStyle: ButtonStyle(
              //     backgroundColor:
              //         MaterialStateProperty.all(Colors.orangeAccent)),
              builder: (context, seconds, isCounting) {
                if (isCounting) {
                  // show any widget when time count Down
                  return const CircularProgressIndicator();
                } else {
                  // show before on press any widget
                  return const Icon(Icons.ads_click);
                }
              }),
          Text(
              "Example On Call Api from outside Of Timer Widget or in logic part of code can be hanlde by the controller"),
          ElevatedButton(
              onPressed: loadApiData,
              child: Text("Proceed Any Future Function")),
          ElevatedButton(
              onPressed: () {
                if (timerController.isCounting) {
                  timerController.stopTimer();
                }
              },
              child: Text("Check if Timer Widget Counting Then Stop")),
        ],
      ),
    );
  }

  ///////////// load rom api
  loadApiData() async {
    //-------- data
    //-------- data
    timerController.startTimer();
    // after load data
    timerController.stopTimer();
  }
}
