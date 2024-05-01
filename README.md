


  - ### Fully Customized
    - ### can be used as a widget OR Button


## Features
 - Timer Widget can wrapped on any type of widget fully customized
  - can be used on any type of button
  - can make custom button
  - can used on any widget
  - can be manage by controller
  
## Usage
   ### ScreenShot
   <img src="https://github.com/HassanAmeer/timer_widget_flutter_package/blob/master/screenshots/timer_widget.png" style="width:50%">
   <hr>

   ### Example
```dart
   
   TimerWidget(
                   timeOutInSeconds: 5,
                   onPressed: () {},
                   controller: timerController, //handle by this out side of the widget
                   buttonType: ButtonType.outline,
                   buttonStyle: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                Colors.orangeAccent)),
                   builder: (context, seconds, isCounting) {
                     if(isRunning){
                       // show any widget when time count Down
                         return const CircularProgressIndicator();
                     }else{
                       // show before on press any widget
                         return const Icon(Icons.ads_click);
                     }
                   }),
   `_______________________________________________`
   // handle by controller from another widget OR by Function
   TimerWidgetController timerController = TimerWidgetController(); // Make Controlleer before widget building
   timerController.startTimer();
   timerController.stopTimer();
   timerController.isCounting;

```
## Additional information

Easy to customized can be wrapped on any type of widget or controlled by controller used as a button or any others type of widgets. 
  - available for all platforms
Need Any Other Packages or issues can contact
