import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marketsystem/screens/reports/today_report.dart';
import 'package:marketsystem/shared/constant.dart';
import 'dart:io';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _report_item(context),
      ),
    );
  }

  _report_item(BuildContext context) => GestureDetector(
        onTap: () {
          //Get.to(TodayReportScreen());
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.45,
          height: MediaQuery.of(context).size.width * 0.45,
          color: defaultColor.shade300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.report,
                size: 60,
              ),
              SizedBox(
                height: 10,
              ),
              Text("Today Report"),
            ],
          ),
        ),
      );
}
