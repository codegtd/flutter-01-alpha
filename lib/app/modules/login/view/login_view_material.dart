import 'package:flutter/material.dart';
import 'package:flutter_01_alpha/app/core/properties.dart';
import 'package:flutter_01_alpha/app/core/text/labels.dart';
import 'package:flutter_01_alpha/app/modules/login/components/email_form_field/email_form_field_material.dart';
import 'package:flutter_01_alpha/app/modules/login/components/login_button.dart';
import 'package:flutter_01_alpha/app/modules/login/login_controller.dart';
import 'package:get/instance_manager.dart';

class LoginViewMaterial extends StatelessWidget {
  final _labels = Get.find<Labels>();
  final _properties = Get.find<Properties>();
  final _controller = Get.find<LoginController>();

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height * 0.12;
    var width = MediaQuery.of(context).size.width * 0.25;
    return Scaffold(
        appBar: AppBar(title: Text(_properties.appTitle)),
        body: SafeArea(
            child: Center(
                child: Column(children: [
          Flexible(
              fit: FlexFit.tight,
              child: Container(
                  width: double.infinity,
                  child: Image(image: AssetImage(_properties.appLogo)))),
          Flexible(
              fit: FlexFit.tight,
              child: Form(
                  key: _controller.loginFormKey,
                  child: SingleChildScrollView(
                      padding: EdgeInsets.all(16),
                      child: EmailFormFieldMaterial().field(
                        _controller,
                        hint: _labels.labelLoginFieldHint,
                        iconPrefix: Icons.mail,
                        iconSufix: Icons.close,
                      )))),
          Flexible(
              fit: FlexFit.tight,
              child: LoginButton().create(context, _controller, height, width))
        ]))));
  }
}