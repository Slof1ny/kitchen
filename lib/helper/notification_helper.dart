// ignore_for_file: empty_catches

import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:efood_kitchen/common/models/notification_payload_model.dart';
import 'package:efood_kitchen/common/widgets/notification_dialog_widget.dart';
import 'package:efood_kitchen/features/order/controllers/order_controller.dart';
import 'package:efood_kitchen/features/order/screens/order_details_screen.dart';
import 'package:efood_kitchen/util/app_constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'responsive_helper.dart';

class NotificationHelper {

  static Future<void> initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
    var androidInitialize = const AndroidInitializationSettings('notification_icon');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializationsSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.initialize(
      initializationsSettings,
      onDidReceiveNotificationResponse: (NotificationResponse? notificationResponse) async {
      // TODO: Route
      try{
        if(notificationResponse?.payload != null) {
          // Get.toNamed(RouteHelper.getOrderDetailsRoute(int.parse(payload)));

        }
      }catch (e) {}
      return;
    },);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async{
      debugPrint('onMessage: ${message.data}');
      NotificationPayloadModel payloadModel = NotificationPayloadModel.fromJson(message.data);
      Get.find<OrderController>().getOrderList(1);
      Get.dialog(NotificationDialogWidget(title: payloadModel.title ?? '', body: payloadModel.body ?? '',  orderId: int.parse('${payloadModel.orderId}')));
    });


    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message)async{
      NotificationPayloadModel payloadModel = NotificationPayloadModel.fromJson(message.data);

      Get.find<OrderController>().getOrderList(1);

      try{
        if(ResponsiveHelper.isMobile(Get.context)){
          Get.to(OrderDetailsScreen(orderId: int.parse('${payloadModel.orderId}')));
        }else{
          Get.find<OrderController>().updateOrderStatusTabs(OrderStatusTabs.confirmed);
          Get.find<OrderController>().orderStatusUpdate(int.parse('${payloadModel.orderId}'), 'confirm');
          Get.find<OrderController>().setOrderIdForOrderDetails(int.parse('${payloadModel.orderId}'), 'confirm','');
          Get.find<OrderController>().getOrderDetails(int.parse('${payloadModel.orderId}'));

        }
      }catch (e) {}
    });
  }

  static Future<void> showNotification(RemoteMessage message, FlutterLocalNotificationsPlugin fln) async {
    String? title;
    String? body;
    String? orderID;
    String? image;

    title = message.data['title'];
    body = message.data['body'];
    orderID = message.data['order_id'];
    image = (message.data['image'] != null && message.data['image'].isNotEmpty)
        ? message.data['image'].startsWith('http') ? message.data['image']
        : '${AppConstants.baseUrl}/storage/app/public/notification/${message.data['image']}' : null;

    if(image != null && image.isNotEmpty) {
      try{
        await showBigPictureNotificationHiddenLargeIcon(title, body, orderID, image, fln);
      }catch(e) {
        await showBigTextNotification(title, body, orderID, fln);
      }
    }else {
      await showBigTextNotification(title, body, orderID, fln);
    }
  }

  static Future<void> showTextNotification(String title, String body, String orderID, FlutterLocalNotificationsPlugin fln) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      AppConstants.appName, AppConstants.appName, playSound: true,
      importance: Importance.max, priority: Priority.max, sound: RawResourceAndroidNotificationSound('notification'),
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: orderID);
  }

  static Future<void> showBigTextNotification(String? title, String? body, String? orderID, FlutterLocalNotificationsPlugin fln) async {
    BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      body!, htmlFormatBigText: true,
      contentTitle: title, htmlFormatContentTitle: true,
    );
    AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      AppConstants.appName, AppConstants.appName, importance: Importance.max,
      styleInformation: bigTextStyleInformation, priority: Priority.max, playSound: true,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: orderID);
  }

  static Future<void> showBigPictureNotificationHiddenLargeIcon(String? title, String? body, String? orderID, String image, FlutterLocalNotificationsPlugin fln) async {
    final String largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    final String bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath), hideExpandedLargeIcon: true,
      contentTitle: title, htmlFormatContentTitle: true,
      summaryText: body, htmlFormatSummaryText: true,
    );
    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      AppConstants.appName, AppConstants.appName,
      largeIcon: FilePathAndroidBitmap(largeIconPath), priority: Priority.max, playSound: true,
      styleInformation: bigPictureStyleInformation, importance: Importance.max,
      sound: const RawResourceAndroidNotificationSound('notification'),
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await fln.show(0, title, body, platformChannelSpecifics, payload: orderID);
  }

  static Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

}


@pragma('vm:entry-point')
Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.data}');

  NotificationPayloadModel payloadModel = NotificationPayloadModel.fromJson(message.data);
  if(payloadModel.isBackgroundSoundActive ?? false) {
    FlutterForegroundTask.initCommunicationPort();

    _initService();
    await _startService(payloadModel.orderId);

  }


}




@pragma('vm:entry-point')
Future<ServiceRequestResult> _startService(String? orderId) async {
  if (await FlutterForegroundTask.isRunningService) {

    return FlutterForegroundTask.restartService();

  } else {

    return FlutterForegroundTask.startService(
      serviceId: 256,
      notificationTitle: 'You got new order ($orderId)',
      notificationText: 'Open app to check order details.',
      callback: startCallback,
    );
  }
}

@pragma('vm:entry-point')
void _initService() {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'eFood',
      channelName: 'Foreground Service Notification',
      channelDescription: 'This notification appears when the foreground service is running.',
      onlyAlertOnce: false,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: false,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(5000),
      autoRunOnBoot: false,
      autoRunOnMyPackageReplaced: false,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );
}

// @pragma('vm:entry-point')
Future<ServiceRequestResult> stopService() async {
  _audioPlayer.dispose();
  return FlutterForegroundTask.stopService();
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

final AudioPlayer _audioPlayer = AudioPlayer();

class MyTaskHandler extends TaskHandler {

  void _playAudio(){
    try{
      _audioPlayer.play(AssetSource('notification.wav'));

    }catch(e){

    }
  }

  // Called when the task is started.
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _playAudio();
  }

  // Called by eventAction in [ForegroundTaskOptions].
  // - nothing() : Not use onRepeatEvent callback.
  // - once() : Call onRepeatEvent only once.
  // - repeat(interval) : Call onRepeatEvent at milliseconds interval.
  @override
  void onRepeatEvent(DateTime timestamp) {
    _playAudio();

  }

  // Called when the task is destroyed.
  @override
  Future<void> onDestroy(DateTime timestamp) async {
    stopService();
  }

  // Called when data is sent using [FlutterForegroundTask.sendDataToTask].
  @override
  void onReceiveData(Object data) {
    // if (data == incrementCountCommand) {
    //   // _incrementCount();
    // }
    _playAudio();
  }

  // Called when the notification button is pressed.
  @override
  void onNotificationButtonPressed(String id) {
    if(id == '0') {
      FlutterForegroundTask.launchApp('/');
    }
    stopService();
  }

  // Called when the notification itself is pressed.
  //
  // AOS: "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted
  // for this function to be called.
  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp('/');
    stopService();
  }

  // Called when the notification itself is dismissed.
  //
  // AOS: only work Android 14+
  // iOS: only work iOS 10+
  @override
  void onNotificationDismissed() {
    stopService();

    // FlutterForegroundTask.updateService(
    //   notificationTitle: 'Hello MyTaskHandler :)',
    //   notificationText: 'count: ',
    // );

  }


}