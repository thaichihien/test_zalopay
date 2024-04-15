import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import '../utils/theme.dart';

class Home extends StatefulWidget {
  final String title;

  const Home({super.key, required this.title});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static const EventChannel eventChannel =
      EventChannel('flutter.native/eventPayOrder');
  static const MethodChannel platform =
      MethodChannel('flutter.native/channelPayOrder');
  final textStyle = const TextStyle(color: Colors.black54);
  final valueStyle = const TextStyle(
      color: AppColor.accentColor, fontSize: 18.0, fontWeight: FontWeight.w400);
  String zpTransToken = "";
  String payResult = "";
  String orderId = "10000";
  bool showResult = false;
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      eventChannel.receiveBroadcastStream().listen(_onEvent, onError: _onError);
    }
  }

  void _onEvent(dynamic event) {
    debugPrint("_onEvent: '$event'.");
    var res = Map<String, dynamic>.from(event as Map<dynamic, dynamic>);
    setState(() {
      if (res["errorCode"] == 1) {
        payResult = "Thanh toán thành công";
      } else if (res["errorCode"] == 4) {
        payResult = "User hủy thanh toán";
      } else {
        payResult = "Giao dịch thất bại";
      }
    });
  }

  void _onError(Object error) {
    debugPrint("_onError: '$error'.");
    setState(() {
      payResult = "Giao dịch thất bại";
    });
  }

  Widget _btnCreateOrder(String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        child: GestureDetector(
          onTap: () async {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                });


            // TODO gọi api mua sản phẩm ở đây là nhận về zp_trans_token

            Navigator.pop(context);
            zpTransToken = value;
            setState(() {
              zpTransToken = value;
              showResult = true;
            });
          },
          child: Container(
              height: 50.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Text("Create Order",
                  style: TextStyle(color: Colors.white, fontSize: 20.0))),
        ),
      );

  Widget _btnPay(String zpToken) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
      child: Visibility(
        visible: showResult,
        child: GestureDetector(
          onTap: () async {
            String response = "";

            logger.i("Start...");

            try {
              final String result =
                  await platform.invokeMethod('payOrder', {"zptoken": zpToken});

              logger.i(result);
              
              response = result;
              debugPrint("payOrder Result: '$result'.");
            } on PlatformException catch (e) {
              debugPrint("Failed to Invoke: '${e.message}'.");
              logger.i(e.message);
              response = "Thanh toán thất bại";
            }
            debugPrint(response);
            setState(() {
              payResult = response;
            });
          },
          child: Container(
              height: 50.0,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Text("Pay",
                  style: TextStyle(color: Colors.white, fontSize: 20.0))),
        ),
      ));

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _quickConfig,
        TextFormField(
          decoration: const InputDecoration(
            hintText: 'Order Id',
            icon: Icon(Icons.filter_frames),
          ),
          initialValue: orderId,
          onChanged: (value) {
            setState(() {
              orderId = value;
            });
          },
          keyboardType: TextInputType.text,
        ),
        _btnCreateOrder(orderId),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Visibility(
            visible: showResult,
            child: Text(
              "zptranstoken:",
              style: textStyle,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Text(
            zpTransToken,
            style: valueStyle,
          ),
        ),
        _btnPay(zpTransToken),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Visibility(
              visible: showResult,
              child: Text("Transaction status:", style: textStyle)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Text(
            payResult,
            style: valueStyle,
          ),
        ),
      ],
    );
  }
}

// Build Info App
Widget _quickConfig = Container(
  margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: const Text("AppID: 2554"),
          ),
        ],
      ),
      // _btnQuickEdit,
    ],
  ),
);
