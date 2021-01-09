import 'package:flutter/material.dart';
import 'dart:async';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flushbar/flushbar.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  static const String _title = 'Flutter Code Sample';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Pomodoro(),
    );
  }
}

class Pomodoro extends StatefulWidget {
  @override
  _PomodoroState createState() => _PomodoroState();
}

  int pomodoros = 0;//the number of study circles
  bool breaks = false;//points can u have a break
  bool works = false;//points are u studying at the moment
  double percent = 0;//percents on the circle
  int Seconds = 0;//what u see in the circle
  Timer timer = null;

  String b = "Stop Timer";//default value for button 4
  String c = "Start a Break";//default value for button 2
  int pressed = 0;//how many times have u pressed the button 2
  

class _PomodoroState extends State<Pomodoro>{
  static int Minutes = 25;//work minutes
  int Time = Minutes * 60;//time for work

  bool f = true;
  bool s = false;
  bool t = false;
  bool fo = false;//booleans for blocking the buttons

  //all voids
  Flushbar flush_1, flush_2;//attention messages
   void start_flushbar(BuildContext context) {
    flush_1 = Flushbar<bool>(
      title: 'You started your $pomodoros pomodoro',
      message: 'That is the spirit! ',
      icon: Icon(
        Icons.info_outline,
        size: 20,
        color: Colors.blue.shade300,
      ),
      mainButton: FlatButton(
        onPressed: (){
          flush_1.dismiss(true);
        },
        child: Text("OK", style: TextStyle(color: Colors.amber),)
      ),
      leftBarIndicatorColor: Colors.blue.shade300,
      duration: Duration(seconds: 20),
    )..show(context);
  }//message that u have started ur pomodoro

  void reset_flushbar(BuildContext context) {
    flush_2 = Flushbar<bool>(
      title: 'Do you really want to reset the timer?',
      message: 'Your current pomodoro will die',
      icon: Icon(
        Icons.announcement_outlined,
        size: 20,
        color: Colors.blue.shade300,
      ),
      mainButton: FlatButton(
        onPressed: () {
          setState(() {
              percent = 0;
              Minutes = 25;
              Seconds = 0;
              Time = 25 * 60;
              timer.cancel();
              b = "Stop Timer";
              works = false;
              setState(() {
                pomodoros--;
              });
              timer = null;
              flush_2.dismiss(true);
              f = true;
              s = false;
              t = false;
              fo = false;
          });
        },
        child: Text(
          "Yes",
          style: TextStyle(color: Colors.amber),
        ),
      ),
      leftBarIndicatorColor: Colors.blue.shade300,
      duration: Duration(seconds: 5),
    )..show(context);
  }//message that wants u to confirm timer reset
  
  _StartTimer(){//start or continue studying 
    f = false;
    s = false;
    t = true;
    fo = true;
    double SecPercent = (25*60/100);
    works = true;
    if (timer == null){
      start_flushbar(context);
    }
    timer = Timer.periodic(Duration(seconds: 0), (timer) {
      if(Seconds == 0){
        Minutes--;
      }
      setState(() {
        if(Time > 0){
          Time--;
          Seconds = Time % 60;
          if(Time % SecPercent == 0){
            if(percent < 1){
              percent += 0.01;
            }
            else {
              percent = 1;
            }
          }
        }
        else {
          timer.cancel();
          breaks = true;
          works = false;
          timer = null;
          percent = 0;
          Minutes = 5;
          Time = 5 * 60;
          s = true;
          t = false;
          fo = false;
        }
      });
    });
  } 
  
  _StartBreak(){
    f = false;
    t = false;
    s = true;
    fo = true;
    double SecPercent = (5 * 60/100);
    // breaks = true;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if(Seconds == 0){
        Minutes--;
      }
      setState(() {
        if(Time > 0){
          Time--;
          Seconds = Time % 60;

          if(Time % SecPercent == 0){
            if(percent < 1){
              percent += 0.01;
            }
            else {
              percent = 1;
            }
          }
        }
        else {
          timer.cancel();
          breaks = false;
          timer = null;
          percent = 0;
          Minutes = 25;
          Time = 25 * 60;
          c = "Start a Break";
          f = false;
          s = false;
          t = true;
          fo = true;
        }
      });
    });
  }

  _onPressed(){//onpressed button 1
    if (!f){
      print ("i am returning 0");
      return 0; 
    }
    setState(() {
      pomodoros +=1;
    });
    _StartTimer();
  }

  _onPressed_Break(){//onpressed button 2
    if(!s) return 0;
    setState(() {
      //offreset = true;//if break is running then block the reset button
      c = "Skip a Break";
      pressed += 1;
      print(pressed);
      if(!breaks){
        print ("i am returning 0");
        return 0;
      }
      if ((pressed % 2) == 0){//means that the break is skipped
        breaks = false;
        works = false;
        percent = 0;
        Minutes = 25;
        Seconds = 0;
        Time = 25 * 60;
        c = "Start a Break";
        f = true;
        s = false;
        t = false;
        fo = false;
        timer.cancel();
      }
      else {
        _StartBreak();
      }
    });
  }

  _ResetTimer(){//onpressed button 3
    if(!t) return 0;
    if((timer != null)){
      reset_flushbar(context);
    }
  }

  _StopTimer(){//onpressed button 4
    setState(() {
      if(!fo) return 0;
      if (timer.isActive){
        b = "Continue";
        timer.cancel();
      }
      else{
        b = "Stop Timer";
        timer.cancel();
        if(timer != null){
          if(breaks)
          _StartBreak();
          else 
          _StartTimer();          
        }
      } 
    });
  }

  @override
  Widget build(BuildContext context){
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(title: Text(
                "Pomodoro Timer",
                style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
            )),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xff1542bf),Color(0xff51a8ff)],
                  begin: FractionalOffset(0.5, 1)
                )
              ),
              width: double.infinity,
              child: Column(
                children: <Widget>[
                  Expanded(
                    child: new CircularPercentIndicator(
                      radius: 200.0,
                      lineWidth: 13.0,
                      percent: percent,
                      circularStrokeCap: CircularStrokeCap.round,
                      center: Text(
                        "$Minutes:$Seconds", 
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 60.0,
                        ),
                      ),
                      progressColor: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 10.0),
                  
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20.0),
                            topLeft: Radius.circular(20.0),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(1.0),
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            "Study Time",
                                            style: TextStyle(
                                              fontSize: 20.0,
                                            ),
                                          ),
                                          SizedBox(height: 10.0),
                                          Text(
                                            "25",
                                            style: TextStyle(
                                              fontSize: 50.0,
                                            ),
                                          )
                                        ],
                                      )
                                  ),
                                  Expanded(
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            "Break Time",
                                            style: TextStyle(
                                              fontSize: 20.0,
                                            ),
                                          ),
                                          SizedBox(height: 10.0),
                                          Text(
                                            "5",
                                            style: TextStyle(
                                              fontSize: 50.0,
                                            ),
                                          )
                                        ],
                                      )
                                  )
                                ],
                              ),
                            ),
                            Container(
                              height: 18.00,
                                child: Expanded(
                                  child: Text("The number of your pomodoros is $pomodoros"),
                                )
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 28.0),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    height: 80.00,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: RaisedButton(
                                            onPressed: _onPressed,
                                            color: f ? Colors.blue : Colors.grey,
                                            textColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(100.00),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(20.0),
                                              child: Text(
                                                "Start Studying"
                                              )
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 1.0,),
                                        Expanded(
                                          child: RaisedButton(
                                            onPressed: _onPressed_Break,
                                            color: s ? Colors.blue : Colors.grey,
                                            textColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(100.00),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.all(20.0),
                                              child: Text(
                                                  "$c"
                                              )
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 60.00,
                                    width: 300.00,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: RaisedButton(
                                            onPressed: _ResetTimer, 
                                            color: t ? Colors.red : Colors.grey,
                                            textColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(100.00),
                                            ),
                                            child: Padding(
                                                padding: EdgeInsets.all(20.0),
                                                child: Text(
                                                    "Reset Timer"
                                                )
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 1.0,),
                                        Expanded(
                                          child: RaisedButton(
                                            onPressed: _StopTimer,
                                            color: fo ? Colors.blue : Colors.grey,
                                            textColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(200.00),
                                            ),
                                            child: Padding(
                                                padding: EdgeInsets.all(20.0),
                                                child: Text(
                                                    "$b"
                                                )
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  ),
                                ],
                              )
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ),
    );
  }
}
