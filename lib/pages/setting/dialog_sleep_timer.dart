import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:muse/material/circle_ring.dart';
import 'package:muse_player/muse_player.dart';

class DialogSleepTimer extends StatelessWidget {
  final MusicPlayer player = MusicPlayer();

  static void show(BuildContext context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => DialogSleepTimer());
  }


  Widget actionView(BuildContext context, AsyncSnapshot snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasError) {
        // 请求失败，显示错误
        return Text("Error: ${snapshot.error}");
      } else {
        // 请求成功，显示数据
        if (snapshot.data > 0) {
          return TimerCountDownWidget(
              duration: snapshot.data,
              onTimerFinish: () => Navigator.pop(context),
              onTimerStop: () => player.setSleepTimer(0));
        } else {
          List<int> entries = [0, 15, 30, 45, 60];
          List<String> titles = ["关闭", "15分钟后", "30分钟后", "45分钟后", "1小时后"];
          return ListView.builder(
              itemCount: entries.length,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(titles[index]),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  onTap: () {
                    player.setSleepTimer(entries[index] * 60 * 1000).then((value) => Navigator.pop(context));
                  },
                );
              });
        }
      }
    }
    return Text("Error: ${snapshot.connectionState}");
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Material(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              child: Text("🕓 Sleep Timer", style: Theme.of(context).textTheme.headline6),
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
            FutureBuilder<int>(
              future: player.getSleepTimer(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return  Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return actionView(context, snapshot);
              },
            ),
            Padding(padding: EdgeInsets.only(top: 16))
          ],
        ),
      ),
    );
  }
}


typedef BoolFunction = Future<bool> Function();

class TimerCountDownWidget extends StatefulWidget {
  final int duration;
  final Function onTimerFinish;
  final BoolFunction onTimerStop;

  TimerCountDownWidget({this.duration, this.onTimerFinish, this.onTimerStop}) : super();

  @override
  _TimerState createState() => _TimerState();
}

class _TimerState extends State<TimerCountDownWidget> {
  Timer _timer;
  int _countdownTime;


  @override
  void initState() {
    super.initState();
    _countdownTime = widget.duration;
    startCountdownTimer();
  }

  @override
  void dispose() {
    super.dispose();
    if (_timer != null) {
      _timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child:Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Text("${(_countdownTime ~/ 60).toString().padLeft(2, '0')}:${(_countdownTime % 60).toString().padLeft(2, '0')}",
                    style: Theme.of(context).textTheme.headline6),
                SizedBox(
                  height: 156,
                  child: CircleProgressBar(
                    foregroundColor: Colors.pink,
                    value: _countdownTime / widget.duration,
                  ),
                )
              ],
            )
        ),
        OutlineButton(child: Text("STOP"), onPressed: () async {
          if (await widget.onTimerStop()) {
            _timer.cancel();
            widget.onTimerFinish();
          }
        })
      ],
    );
  }

  void startCountdownTimer() {
    _timer = Timer.periodic(
        Duration(seconds: 1),
            (Timer timer) => {
          setState(() {
            if (_countdownTime < 1) {
              widget.onTimerFinish();
              _timer.cancel();
            } else {
              _countdownTime = _countdownTime - 1;
            }
          })
        });
  }
}