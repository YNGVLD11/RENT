// ignore_for_file: depend_on_referenced_packages, unused_import, unused_field, dead_code, file_names, avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:p/helpers/helpers.dart';
import 'package:p/helpers/message_exception.dart';
import 'package:p/helpers/size_config.dart';
import 'package:p/repository/firebase_auth.dart';
import 'package:p/theme/model_theme.dart';
import 'package:provider/provider.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:p/widgets/custom_snackBar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKeyRegister = GlobalKey<FormState>();
  int numScreen = 1;

  String _email = '';
  String _password = '';
  bool _obscurePassword = true;
  String _verificationID = '';
  bool codeSumbit = false;
  bool codeVerify = true;
  final _pinPutController = TextEditingController();
  final TextEditingController _phone = TextEditingController();

  getPage() {
    switch (numScreen) {
      case 1:
        return phoneForm();
        break;
      case 2:
        return emailForm();
        break;
      default:
    }
  }

  setPage(value) {
    setState(() {
      numScreen = value;
    });
  }

  void _validateAuth() async {
    final FormState? form = _formKey.currentState;
    if (_formKey.currentState!.validate()) {
      helpers.showProgress(
          context, 'Выполняется вход, пожалуйста подождите', false);
      form!.save();
      try {
        bool result = await fbAuth.auth(_email, _password);
        if (result) {
          helpers.hideProgress();
          print('Document exists on the database');
          Navigator.pushNamedAndRemoveUntil(
              context, 'tabNavigator', (Route<dynamic> route) => false);
        } else {
          helpers.hideProgress();
          Navigator.pushNamed(context, 'registrationScreen');
        }
      } on MessageException catch (e) {
        helpers.hideProgress();
        print(e);
        CustomSnackBar(context, Text(e.message), Colors.lightGreen);
      }
    }
  }

  _phoneAuth() async {
    print(_phone.text);
    try {
      await fbAuth.submitPhoneNumber(
          phoneNumber: _phone.text,
          func: (value) {
            setState(() {
              _verificationID = value;
            });
            CustomSnackBar(
                context, const Text('СМС код был выслан'), Colors.lightGreen);
            setState(() {
              codeSumbit = false;
              numScreen = 4;
            });
          },
          durationCode: () {
            setState(() {
              codeSumbit = true;
            });
          });
    } on MessageException catch (e) {
      CustomSnackBar(context, Text(e.message), Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size.height - 110;
    return Consumer<ModelTheme>(
        builder: (context, ModelTheme themeNotifier, child) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Авторизация'),
          actions: [
            IconButton(
                icon: Icon(themeNotifier.isDark
                    ? Icons.nightlight_round
                    : Icons.wb_sunny),
                onPressed: () {
                  themeNotifier.isDark
                      ? themeNotifier.isDark = false
                      : themeNotifier.isDark = true;
                })
          ],
        ),
        body: numScreen != 4
            ? Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    const Text('Вход в систему',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    getPage(),
                  ]))
            : Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Подтвердите ваш номер',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Container(
                        margin: EdgeInsets.only(
                            left: mediaQuery / 27.62,
                            right: mediaQuery / 27.62),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 15),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(5))),
                              child: Column(
                                children: [
                                  const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Введите полученный код',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 35,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        left:
                                            MediaQuery.of(context).size.width /
                                                10,
                                        right:
                                            MediaQuery.of(context).size.width /
                                                10),
                                    child: PinPut(
                                        onSubmit: (value) async {
                                          try {
                                            bool value =
                                                await fbAuth.submitCode(
                                                    code:
                                                        _pinPutController.text,
                                                    verificationId:
                                                        _verificationID,
                                                    context: context);
                                            if (!value) {
                                              setState(() {
                                                codeVerify = false;
                                              });
                                            }
                                          } on MessageException catch (e) {
                                            CustomSnackBar(context,
                                                Text(e.message), Colors.red);
                                          }
                                        },
                                        controller: _pinPutController,
                                        fieldsCount: 6,
                                        fieldsAlignment:
                                            MainAxisAlignment.spaceAround,
                                        animationDuration:
                                            const Duration(seconds: 0),
                                        textStyle: const TextStyle(
                                            fontSize: 28,
                                            color: Color(0xFF323232)),
                                        preFilledWidget: Container(
                                          width: 12,
                                          height: 2,
                                          color: const Color.fromRGBO(
                                              197, 206, 224, 1),
                                        )),
                                  ),
                                  if (!codeVerify)
                                    const Text('Неверный код',
                                        style: TextStyle(fontSize: 14)),
                                  const SizedBox(
                                    height: 74,
                                  ),
                                  ElevatedButton(
                                    onPressed: _phoneAuth,
                                    child: const Text('Отправить повторно'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
              ),
      );
    });
  }

  Widget _authButton(context,
      {required IconData iconName, required Function func}) {
    return SizedBox(
      height: 25,
      width: 25,
      child: TextButton(
          onPressed: () {
            func();
          },
          child: Icon(iconName)),
    );
  }

  Widget emailForm() {
    return Column(
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Вход по Email',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          padding:
              const EdgeInsets.only(top: 25, left: 10, right: 10, bottom: 20),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            color: Theme.of(context).cardColor,
          ),
          child: Form(
            key: _formKey,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                'Электронная почта',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                onSaved: (input) {
                  _email = input!;
                },
                validator: (value) {
                  if (value != null || value!.isNotEmpty) {
                    final RegExp regex = RegExp(
                        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)| (\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
                    if (!regex.hasMatch(value)) {
                      return 'Введите корректный email';
                    } else {
                      return null;
                    }
                  } else {
                    return 'Введите корректный email';
                  }
                },
                decoration: InputDecoration(
                  errorStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFFF0000)),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                  prefixIcon: Container(child: const Icon(Icons.email)),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFC5CEE0)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFC5CEE0)),
                  ),
                  hintText: 'Example@mail.com',
                  hintStyle: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              const Text(
                'Пароль',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                obscureText: _obscurePassword,
                onSaved: (input) => _password = input!,
                validator: (input) {
                  if (input!.isEmpty) {
                    return "Неверный пароль";
                  } else {
                    if (input.length < 6) {
                      return "Пароль слишком короткий";
                    } else {
                      return null;
                    }
                  }
                },
                decoration: InputDecoration(
                  errorStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFFF0000)),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
                  suffixIcon: InkWell(
                    onTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    child: const Icon(Icons.remove_red_eye),
                  ),
                  prefixIcon: Container(child: const Icon(Icons.password)),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFC5CEE0)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFFC5CEE0)),
                  ),
                  hintText: 'Введите пароль',
                  hintStyle: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(
                height: 25.0,
              ),
              const SizedBox(
                height: 25.0,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 20)),
                  onPressed: () {
                    _validateAuth();
                  },
                  child: const Text('Войти'),
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 1,
                color: const Color(0xFFE7EBF2),
              ),
              const SizedBox(
                height: 20,
              ),
              socialLink()
            ]),
          ),
        ),
      ],
    );
  }

  Widget phoneForm() {
    var maskFormatter = MaskTextInputFormatter(
        mask: '+7 (###) ###-##-##', filter: {"#": RegExp(r'[0-9]')});
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          padding:
              const EdgeInsets.only(top: 25, left: 10, right: 10, bottom: 20),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(5)),
            color: Theme.of(context).cardColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Номер телефона',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(
                height: 15,
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [maskFormatter],
                controller: _phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Поле не должно быть пустым';
                  } else {
                    return null;
                  }
                },
                decoration: const InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFC5CEE0))),
                    hintText: '+7 XXX XXX XX XX',
                    hintStyle: TextStyle(fontSize: 14)),
              ),
              const SizedBox(
                height: 25,
              ),
              const SizedBox(
                height: 25,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      textStyle: const TextStyle(fontSize: 20)),
                  onPressed: () {
                    _phoneAuth();
                  },
                  child: const Text('Войти'),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 1,
                color: const Color(0xFFE7EBF2),
              ),
              const SizedBox(
                height: 20,
              ),
              socialLink()
            ],
          ),
        ),
      ],
    );
  }

  Widget socialLink() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Войти с помощью',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(),
            if (Platform.isAndroid)
              numScreen == 1
                  ? _authButton(context,
                      iconName: Icons.email, func: () => setPage(2))
                  : _authButton(context,
                      iconName: Icons.phone, func: () => setPage(1)),
            Container()
          ],
        ),
      ],
    );
  }
}
