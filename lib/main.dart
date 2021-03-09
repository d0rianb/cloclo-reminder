import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:fluttertoast/fluttertoast.dart';

import './NotificationManager.dart';

void main() async {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloclo\'s reminder',
      builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      locale: Locale.fromSubtags(languageCode: 'fr'),
      debugShowCheckedModeBanner: false,
      home: HomePage(title: 'Reminder'),
    );
  }
}

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({Key key, this.title}) : super(key: key);

  HomeState createState() => HomeState();
}

class HomeState extends State<HomePage> {
  final NotificationManager notificationManager = new NotificationManager();
  final NumberFormat timeFormatter = new NumberFormat('00');
  // ignore: non_constant_identifier_names
  String notificationTime;
  String name;
  String inputName;
  bool pillTaken = false;
  SharedPreferences prefs;
  PackageInfo packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  @override
  void initState() {
    super.initState();
    getPreferences();
    getAppInfos();
    notificationManager.registerNotificationCallback(() {
      setState(() {
        pillTaken = true;
        prefs?.setBool('PillTaken', true);
        prefs?.setString('PillTakenAt', DateTime.now().toString());
        toastAlert('All good');
      });
    });
  }

  Future<String> init() async {
    return '';
  }

  Future<void> getAppInfos() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      packageInfo = info;
    });
  }

  Future<void> getPreferences() async {
    prefs = await SharedPreferences.getInstance();
    notificationTime = prefs.getString('NotificationTime');
    setState(() {
      pillTaken = prefs.getBool('PillTaken') ?? false;
      var pillTakenAt = prefs.getString('PillTakenAt');
      if (pillTaken && pillTakenAt != null) {
        pillTaken = DateTime.parse(pillTakenAt).day == DateTime.now().day;
      }
    });
    if (notificationTime == null) {
      scheduleDailyNotification(9, 0); // default at 9:00
    }
  }

  void toastAlert(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
    );
  }

  String getNotificationTitle() {
    return '${name ?? prefs?.getString('Name') ?? 'Cloclo'} prends ta pilule !';
  }

  String getNotificationBody() {
    return 'Il faut que tu prennes ta pillule';
  }

  void scheduleDailyNotification(int hour, int minute) {
    notificationManager.showNotificationDaily(0, getNotificationTitle(), getNotificationBody(), hour, minute);
    setState(() {
      notificationTime = '${timeFormatter.format(hour)}:${timeFormatter.format(minute)}';
      prefs?.setString('NotificationTime', notificationTime);
    });
  }

  void timePickerCallback(selectedTime) async {
    if (selectedTime != null) {
      int hour = selectedTime.hour;
      int minute = selectedTime.minute;
      scheduleDailyNotification(hour, minute);
      toastAlert('La notification a bien été planifié pour ${timeFormatter.format(hour)}:${timeFormatter.format(minute)}');
    }
  }

  @override
  Widget build(context) {
    ButtonStyle buttonTextStyle = TextButton.styleFrom(
      enableFeedback: true,
      padding: EdgeInsets.all(12),
//      backgroundColor: Colors.white70,
      elevation: 0,
      textStyle: TextStyle(
        fontSize: 20,
      ),
    );

    TextStyle defaultStyle = TextStyle(color: Colors.grey, fontSize: 18.0);
    TextStyle linkStyle = TextStyle(color: Colors.indigo[400]);

    Widget _buildPopupDialog(BuildContext context) {
      return new AlertDialog(
        title: const Text('Paramètres'),
        content: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Enter your name',
              ),
              controller: TextEditingController()..text = name ?? prefs?.getString('Name') ?? '',
              onChanged: (value) {
                if (value.isEmpty) {
                  return 'Please enter a name';
                }
                setState(() {
                  inputName = value;
                });
                return null;
              },
            )
          ],
        ),
        actions: <Widget>[
          new FlatButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            textColor: Theme.of(context).primaryColor,
            child: const Text('Cancel'),
          ),
          new FlatButton(
            onPressed: () {
              prefs.setString('Name', inputName);
              notificationManager.showNotificationDaily(0, '${name ?? prefs?.getString('Name') ?? 'Cloclo'} prends ta pilule !', 'Il faut que tu prennes ta pillule',
                  int.parse(notificationTime.split(':')[0]), int.parse(notificationTime.split(':')[1]));
              setState(() {
                name = inputName;
                inputName = null;
              });
              Navigator.of(context).pop();
            },
            textColor: Theme.of(context).primaryColor,
            child: const Text('OK'),
          ),
        ],
      );
    }

    return FutureBuilder<String>(
        future: init(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          return Scaffold(
              appBar: AppBar(
                title: Text(widget.title),
                actions: [
                  IconButton(
                    icon: Icon(Icons.settings_outlined),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => _buildPopupDialog(context),
                      );
                    },
                  )
                ],
              ),
              body: Column(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text(
                              pillTaken ? 'C\'est bon pour aujourd\'hui 😊' : getNotificationTitle(),
                              style: TextStyle(fontSize: 30),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Dodo',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 18,
                                fontWeight: FontWeight.w300,
                              ),
                              textAlign: TextAlign.end,
                              textWidthBasis: TextWidthBasis.parent,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                            child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                              Checkbox(
                                  value: pillTaken,
                                  activeColor: Colors.green[600],
                                  onChanged: (value) {
                                    setState(() {
                                      setState(() {
                                        pillTaken = value;
                                        prefs.setBool('PillTaken', value);
                                        prefs.setString('PillTakenAt', DateTime.now().toString());
                                      });
                                    });
                                  }),
                              Text(
                                'J\'ai bien pris ma pillule',
                                style: TextStyle(fontSize: 20, color: pillTaken ? Colors.green[600] : Colors.grey[800]),
                              )
                            ]),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: RichText(
                                text: TextSpan(style: defaultStyle, children: <TextSpan>[
                                  TextSpan(text: 'Rappel tous les jours à '),
                                  TextSpan(
                                      text: notificationTime ?? prefs?.getString('NotificationTime') ?? 'unknown',
                                      style: linkStyle,
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          showTimePicker(
                                            initialTime: TimeOfDay(hour: 9, minute: 0),
                                            context: context,
                                            useRootNavigator: true,
                                          ).then(timePickerCallback);
                                        })
                                ]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        child: Text('Configure'),
                        style: buttonTextStyle,
                        onPressed: () {
                          showTimePicker(
                            initialTime: TimeOfDay(hour: 9, minute: 0),
                            context: context,
                            useRootNavigator: true,
                          ).then(timePickerCallback);
                        },
                      ),
                      TextButton(
                        child: Text('Notify'),
                        style: buttonTextStyle,
                        onPressed: () {
                          print('Notify');
                          notificationManager.showNotification(0, getNotificationTitle(), getNotificationBody());
                        },
                      ),
                    ],
                  ),
                ],
              ),
              bottomNavigationBar: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Text(
                      'Dorian&Co © ${packageInfo?.appName} -  v${packageInfo?.version}+${packageInfo.buildNumber}',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ),
                ],
              ));
        });
  }
}
