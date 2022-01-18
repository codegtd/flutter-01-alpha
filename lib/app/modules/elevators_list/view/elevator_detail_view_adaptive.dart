import 'dart:io';

import 'package:animated_neumorphic/animated_neumorphic.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_01_alpha/app/core/components/modal/i_adaptive_modal.dart';
import 'package:flutter_01_alpha/app/core/properties.dart';
import 'package:flutter_01_alpha/app/core/text/labels.dart';
import 'package:flutter_01_alpha/app/core/text/message_labels.dart';
import 'package:flutter_01_alpha/app/modules/elevators_list/entity/elevator.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../elevator_list_controller.dart';

class ElevatorDetailViewAdaptive extends StatelessWidget {
  Elevator? elevator;

  ElevatorDetailViewAdaptive({this.elevator});

  final _messages = Get.find<MessageLabels>();
  final _properties = Get.find<Properties>();
  final _labels = Get.find<Labels>();
  final _controller = Get.find<ElevatorListController>();
  final _modal = Get.find<IAdaptiveModal>(tag: Platform.operatingSystem);

  @override
  Widget build(BuildContext context) {
    elevator ?? Get.arguments();
    _controller.buttonLabelStatusObs.value = elevator!.status;

    return PlatformScaffold(
        appBar: PlatformAppBar(title: Text("Elevator ID: ${elevator!.id.toString()}")),
        body: Center(
            child: Column(children: [
          Flexible(fit: FlexFit.tight, child: _elevatorInfoPanel()),
          Flexible(
              fit: FlexFit.tight,
              child: Container(
                  alignment: Alignment.center,
                  color: Colors.transparent,
                  child: Obx(
                    () => GestureDetector(
                      child: _animatedContainerStatusButton(context),
                      onTap: () async {
                        await _triggerChangeStatus(context);
                      },
                    ),
                  )))
        ])));
  }

  Future<void> _adaptiveModalConfirmation(context) async {
    return _modal.create(
      context,
      _messages.confirmation,
      _labels.yes,
      _labels.no,
      () async {
        await _controller
            .updateElevatorStatus(elevator!.id.toString())
            .then((elevatorStatus) async {
          if (elevatorStatus == 'online') await _updateSucess(elevatorStatus);
          if (elevatorStatus == 'error') _updateFail();
        });
      },
      () {
        _controller.elevatorStatusButtonAnimation(color: Colors.red, blur: 0);
        Get.back();
        // _controller.buttonColorObs.value == Colors.red;
        // _controller.buttonShadowBlurObs.value == 0;
      },
    );
  }

  AnimatedContainer _animatedContainerStatusButton(context) {
    return AnimatedContainer(
        duration: const Duration(milliseconds: 1000),
        margin: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.12,
        width: MediaQuery.of(context).size.width * 0.85,
        alignment: Alignment.center,
        curve: Curves.ease,
        decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: _controller.buttonColorObs.value,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: _controller.buttonColorObs.value,
                  blurRadius: _controller.buttonShadowBlurObs.value)
            ]),
        child: DefaultTextStyle(
            style: GoogleFonts.roboto(
                textStyle: const TextStyle(fontSize: 50, color: Colors.white)),
            child: AnimatedTextKit(
                totalRepeatCount: 20,
                animatedTexts: [
                  RotateAnimatedText(_controller.buttonLabelStatusObs.value)
                ],
                onTap: () async => await _triggerChangeStatus(context))));
  }

  Future<void> _triggerChangeStatus(context) async {
    _controller.elevatorStatusButtonAnimation(color: Colors.green, blur: 30);
    await Future.delayed(Duration(milliseconds: 1000));
    _adaptiveModalConfirmation(context);
  }

  Container _elevatorInfoPanel() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(30),
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _richTextLine("S/N: ", elevator!.serialNumber),
          _richTextLine("MODEL: ", elevator!.model.toUpperCase()),
          _richTextLine("TYPE: ", elevator!.types.toUpperCase()),
          _richTextLine("CREATED AT: ", elevator!.created_at.substring(0, 10)),
        ],
      ),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: Colors.white,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
                color: Colors.grey,
                spreadRadius: 3,
                offset: Offset(1.0, 1.0),
                blurRadius: 5.0)
          ]),
    );
  }

  Widget _richTextLine(String label, String content) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 20.0),
        child: RichText(
            text: TextSpan(
                text: label,
                style: GoogleFonts.lato(
                    textStyle: const TextStyle(
                        color: Colors.blue, fontSize: 25, fontWeight: FontWeight.bold)),
                children: <TextSpan>[
              TextSpan(
                  text: content,
                  style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold, color: Colors.red)))
            ])));
  }

  void _updateFail() {
    Get.back();
    Get.snackbar(_labels.ops, _messages.errorUpdateTryAgain,
        backgroundColor: Colors.red, colorText: Colors.white);
  }

  Future<void> _updateSucess(String elevatorStatus) async {
    Get.back();
    elevator!.status = elevatorStatus;
    await Future.delayed(Duration(milliseconds: _properties.delayStatusElevator))
        .then((value) =>
            _controller.elevatorStatusButtonAnimation(color: Colors.red, blur: 0))
        .whenComplete(() => Get.back());
  }

  Widget _neumorphicButton({
    required Color color,
    required child,
    double depth = 1.0,
    double width = 60.0,
    double height = 60.0,
    double radius = 16.0,
    // int milliseconds = 500,
  }) {
    return GestureDetector(
      onTap: () =>
          _controller.neum_isActiveObs.value = !_controller.neum_isActiveObs.value,
      child: AnimatedNeumorphicContainer(
        duration: Duration(milliseconds: 500),
        depth: _controller.neum_isActiveObs.value ? 0.0 : depth,
        color: color,
        width: width,
        height: height,
        radius: radius,
        child: child,
      ),
    );
  }
// _neumorphicButton(
//     depth: 0.1,
//     color: _controller.buttonColorObs.value,
//     height: MediaQuery.of(context).size.height * 0.12,
//     width: MediaQuery.of(context).size.width * 0.85,
//     child: Center(
//       child: Text(_controller.buttonLabelStatusObs.value,
//           softWrap: true,
//           textAlign: TextAlign.center,
//           style: GoogleFonts.roboto(
//               textStyle: const TextStyle(
//                   fontSize: 50, color: Colors.white))),
//     ))
}