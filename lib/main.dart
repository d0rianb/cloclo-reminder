import 'package:cloclo/NotificationManager.dart';
import 'package:flutter/material.dart';
import './NotificationManager.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloclo\'s reminder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      locale: Locale.fromSubtags(languageCode: 'fr'),
      debugShowCheckedModeBanner: false,
      home: HomePage('Reminder'),
    );
  }
}

class HomePage extends StatelessWidget {
  final String title;
  final NotificationManager notificationManager = new NotificationManager();

  HomePage(this.title);

  Future<String> getScheduledNotificationTime() async {
    var notificationScheduled = (await notificationManager.getScheduledNotifications())[0];
    String infos = notificationScheduled.title + notificationScheduled.body + notificationScheduled.payload + notificationScheduled.id.toString();
    print(infos);
    return notificationScheduled?.payload;
  }

  @override
//  Widget build(BuildContext context) {
//    ButtonStyle buttonTextStyle = TextButton.styleFrom(
//      enableFeedback: true,
//      textStyle: TextStyle(
//        fontSize: 20,
//      ),
//    );
//    return Scaffold(
//      appBar: AppBar(title: Text(title)),
//      body: Column(
//        children: [
//          Column(
//            mainAxisAlignment: MainAxisAlignment.center,
//            children: [
//              Center(
//                child: Padding(
//                  padding: const EdgeInsets.all(32.0),
//                  child: Column(
//                    mainAxisAlignment: MainAxisAlignment.center,
//                    children: [
//                      Text(
//                        'Cloclo prends ta pilule',
//                        style: TextStyle(fontSize: 30),
//                      ),
//                      Text('Rappel tous les jours à ${notificationTime?.hour}:${notificationTime?.minute}')
//                    ],
//                  ),
//                ),
//              ),
//              Row(
//                mainAxisAlignment: MainAxisAlignment.center,
//                children: [
//                  TextButton(
//                    child: Text('Configure'),
//                    style: buttonTextStyle,
//                    onPressed: () {
//                      showTimePicker(
//                        initialTime: TimeOfDay.now(),
//                        context: context,
//                      ).then((selectedTime) async {
//                        int hour = selectedTime.hour;
//                        int minute = selectedTime.minute;
//                        notificationManager.showNotificationDaily(0, 'Cloclo prends ta pilule !', 'Il faut que tu prennes ta pillule', hour, minute);
//                      });
//                    },
//                  ),
//                  TextButton(
//                    child: Text('Notify'),
//                    style: buttonTextStyle,
//                    onPressed: () {
//                      notificationManager.showNotification(0, 'Cloclo prends ta pilule', 'Il faut que tu prennes ta pillule');
//                    },
//                  ),
//                ],
//              )
//            ],
//          )
//        ],
//      ),
//    );
//  }

  @override
  Widget build(context) {
    ButtonStyle buttonTextStyle = TextButton.styleFrom(
      enableFeedback: true,
      textStyle: TextStyle(
        fontSize: 20,
      ),
    );

    return FutureBuilder<String>(
        future: getScheduledNotificationTime(),
        builder: (context, AsyncSnapshot<String> snapshot) {
          return Scaffold(
            appBar: AppBar(title: Text(title)),
            body: Column(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Cloclo prends ta pilule ! ',
                              style: TextStyle(fontSize: 30),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Dodo',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300,
                                ),
                                textAlign: TextAlign.end,
                                textWidthBasis: TextWidthBasis.parent,
                              ),
                            )
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
                              initialTime: TimeOfDay.now(),
                              context: context,
                            ).then((selectedTime) async {
                              if (selectedTime != null) {
                                int hour = selectedTime.hour;
                                int minute = selectedTime.minute;
                                notificationManager.showNotificationDaily(0, 'Cloclo prends ta pilule !', 'Il faut que tu prennes ta pillule', hour, minute);
                              }
                            });
                          },
                        ),
                        TextButton(
                          child: Text('Notify'),
                          style: buttonTextStyle,
                          onPressed: () {
                            print('Notify');
                            notificationManager.showNotification(0, 'Cloclo prends ta pilule', 'Il faut que tu prennes ta pillule');
                          },
                        ),
                      ],
                    )
                  ],
                )
              ],
            ),
          );
        });
  }
}
