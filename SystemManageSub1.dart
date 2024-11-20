import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../Database/GlobalVariable.dart';
import '../Design/Palette.dart';
import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';

import '../Database/SystemInfoStructure.dart';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:file_picker/file_picker.dart'; // FilePicker 패키지

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart'; // for kIsWeb


import 'dart:typed_data';
import 'dart:convert';
import 'dart:io'; // File 클래스를 사용하려면 추가
import 'package:http/http.dart' as http;




class SystemManageSubPage extends StatefulWidget {
  final WebSocketChannel socket;
  final SystemInfo itsInfo;

  const SystemManageSubPage(
      {super.key, required this.socket, required this.itsInfo});

  @override
  State<StatefulWidget> createState() => SystemManageSubPageState();
}


class SystemManageSubPageState extends State<SystemManageSubPage> {
  String password = '';

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {}

  @override
  void dispose() {
    super.dispose();
  }

  static const headerStyle = TextStyle(
      color: Palette.baseTextColor, fontSize: 18, fontWeight: FontWeight.bold);
  static const contentStyleHeader = TextStyle(
      color: Color(0xff999999), fontSize: 14, fontWeight: FontWeight.w700);
  static const contentStyle = TextStyle(
      color: Color(0xff999999), fontSize: 14, fontWeight: FontWeight.normal);

  final _formKeyDevice = GlobalKey<FormState>();
  final _formKeyNetwork = GlobalKey<FormState>();

  void _tryValidationDevice() {
    final isValid = _formKeyDevice.currentState!.validate();
    if (isValid) {
      _formKeyDevice.currentState!.save();
      List<String> arr = [];

      for (Map<String, dynamic> element in widget.itsInfo.outputs) {
        arr.add('${element['name']}');
      }
      final String msg = '<SAVEBTN>${arr.join(',')}</SAVEBTN>';
      widget.socket.sink.add(msg);

      var fon = context.read<GlobalStore>().deviceSetting[3];
      if (fon == '100') {
        context.read<GlobalStore>().deviceSetting[4] = "수동제어";
      }
      var hon = context.read<GlobalStore>().deviceSetting[5];
      if (hon == '100') {
        context.read<GlobalStore>().deviceSetting[6] = "수동제어";
      }
      final String msg2 =
          "<SAVEUSER>${context.read<GlobalStore>().deviceSetting.sublist(1).join(',')}</SAVEUSER>";
      widget.socket.sink.add(msg2);

      final String msg4 =
          "<LOGINID>${context.read<GlobalStore>().deviceSetting[0]}</LOGINID>";

      widget.socket.sink.add(msg4);
      if (password.isNotEmpty) {
        final String msg5 = "<LOGINPW>$password</LOGINPW>";
        widget.socket.sink.add(msg5);
      }
    }
  }

  void _tryValidationNetwork() {
    final isValid = _formKeyNetwork.currentState!.validate();
    if (isValid) {
      _formKeyNetwork.currentState!.save();
      final String msg =
          "<SAVENET>${context.read<GlobalStore>().networkSetting.join(',')}</SAVENET>";
      widget.socket.sink.add(msg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.themePrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.navigate_before,
            color: Palette.baseIconColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          tooltip: '이전으로',
        ),
        title: Text('Settings', style: Palette.appBarTextStyle),
        centerTitle: true,
        backgroundColor: Palette.themePrimary,
        elevation: 0.0,
        automaticallyImplyLeading: false,
      ),
      body: Accordion(
        headerBorderColor: Colors.blueGrey,
        headerBorderColorOpened: Colors.transparent,
        // headerBorderWidth: 1,
        headerBackgroundColorOpened: Colors.green,
        contentBackgroundColor: Colors.white,
        contentBorderColor: Colors.green,
        contentBorderWidth: 3,
        contentHorizontalPadding: 20,
        scaleWhenAnimating: false,
        openAndCloseAnimation: true,
        headerPadding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
        sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
        sectionClosingHapticFeedback: SectionHapticFeedback.light,
        children: [
          AccordionSection(
              isOpen: false,
              leftIcon: const Icon(Icons.devices, color: Palette.baseIconColor),
              headerBackgroundColor: Palette.themeSecondary,
              headerBackgroundColorOpened: Palette.themeSecondary,
              headerBorderWidth: 1,
              contentBackgroundColor: Palette.themeTertiary,
              contentBorderWidth: 0,
              contentVerticalPadding: 30,
              header: const Text('장치 설정', style: headerStyle),
              content: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Form(
                    key: _formKeyDevice,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          initialValue:
                              context.watch<GlobalStore>().deviceSetting[0],
                          style: const TextStyle(color: Palette.baseTextColor),
                          key: const ValueKey(111),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '아이디를 입력해주세요.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            context.read<GlobalStore>().deviceSetting[0] =
                                value;
                          },
                          onChanged: (value) {
                            context.read<GlobalStore>().deviceSetting[0] =
                                value;
                          },
                          decoration: const InputDecoration(
                              label: Text(
                                '로그인ID',
                                style: TextStyle(
                                    color: CupertinoColors.lightBackgroundGray,
                                    fontSize: 20),
                              ),
                              prefixIcon: Icon(
                                Icons.person,
                                color: Palette.baseIconColor,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1.5,
                                    color: CupertinoColors.lightBackgroundGray),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(35.0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: CupertinoColors.lightBackgroundGray),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(35.0),
                                ),
                              ),
                              errorStyle: TextStyle(
                                  fontSize: 15, color: Colors.redAccent),
                              hintText: '영,숫자 32문자이내',
                              hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: CupertinoColors.lightBackgroundGray),
                              contentPadding: EdgeInsets.all(10)),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          obscureText: true,
                          style: const TextStyle(color: Palette.baseTextColor),
                          key: const ValueKey(112),
                          validator: (value) {
                            if (value!.isNotEmpty && value.length > 16) {
                              return "ID를 16문자 이내로 입력하세요.";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            if (value!.isNotEmpty) {
                              password = value.toString();
                            }
                          },
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              password = value.toString();
                            }
                          },
                          decoration: const InputDecoration(
                              label: Text(
                                '비밀번호',
                                style: TextStyle(
                                    color: CupertinoColors.lightBackgroundGray,
                                    fontSize: 20),
                              ),
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Palette.baseIconColor,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1.5,
                                    color: CupertinoColors.lightBackgroundGray),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(35.0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: CupertinoColors.lightBackgroundGray),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(35.0),
                                ),
                              ),
                              errorStyle: TextStyle(
                                  fontSize: 15, color: Colors.redAccent),
                              hintText: '영,숫자 32문자이내',
                              hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: CupertinoColors.lightBackgroundGray),
                              contentPadding: EdgeInsets.all(10)),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          initialValue:
                              context.watch<GlobalStore>().deviceSetting[1],
                          style: const TextStyle(color: Palette.baseTextColor),
                          key: const ValueKey(1),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '아이디를 입력해주세요.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            context.read<GlobalStore>().deviceSetting[1] =
                                value;
                          },
                          onChanged: (value) {
                            context.read<GlobalStore>().deviceSetting[1] =
                                value;
                          },
                          decoration: const InputDecoration(
                              label: Text(
                                '서버통신ID',
                                style: TextStyle(
                                    color: CupertinoColors.lightBackgroundGray,
                                    fontSize: 20),
                              ),
                              prefixIcon: Icon(
                                Icons.person,
                                color: Palette.baseIconColor,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1.5,
                                    color: CupertinoColors.lightBackgroundGray),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(35.0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: CupertinoColors.lightBackgroundGray),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(35.0),
                                ),
                              ),
                              errorStyle: TextStyle(
                                  fontSize: 15, color: Colors.redAccent),
                              hintText: '영,숫자 32문자이내',
                              hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: CupertinoColors.lightBackgroundGray),
                              contentPadding: EdgeInsets.all(10)),
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          initialValue:
                              context.watch<GlobalStore>().deviceSetting[2],
                          style: const TextStyle(color: Palette.baseTextColor),
                          key: const ValueKey(2),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '장비명을 입력해주세요.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            context.read<GlobalStore>().deviceSetting[2] =
                                value;
                          },
                          onChanged: (value) {
                            context.read<GlobalStore>().deviceSetting[2] =
                                value;
                          },
                          decoration: const InputDecoration(
                              label: Text(
                                '장비명',
                                style: TextStyle(
                                    color: CupertinoColors.lightBackgroundGray,
                                    fontSize: 20),
                              ),
                              prefixIcon: Icon(
                                Icons.devices,
                                color: Palette.baseIconColor,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1.5,
                                    color: CupertinoColors.lightBackgroundGray),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(35.0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: CupertinoColors.lightBackgroundGray),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(35.0),
                                ),
                              ),
                              errorStyle: TextStyle(
                                  fontSize: 15, color: Colors.redAccent),
                              hintText: '영,숫자 32문자이내',
                              hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: CupertinoColors.lightBackgroundGray),
                              contentPadding: EdgeInsets.all(10)),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          '팬 온도범위(수동제어는 켜는온도를 100)',
                          style: TextStyle(
                              color: Palette.baseTextColor,
                              fontWeight: Palette.font1,
                              fontSize: 20),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: TextFormField(
                                initialValue: context
                                    .watch<GlobalStore>()
                                    .deviceSetting[3],
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                style: const TextStyle(
                                    color: Palette.baseTextColor),
                                key: const ValueKey(3),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return '온도를 입력해주세요.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  context.read<GlobalStore>().deviceSetting[3] =
                                      value;
                                },
                                onChanged: (value) {
                                  context.read<GlobalStore>().deviceSetting[3] =
                                      value;
                                },
                                decoration: const InputDecoration(
                                    label: Text(
                                      '켜는온도',
                                      style: TextStyle(
                                          color: CupertinoColors
                                              .lightBackgroundGray,
                                          fontSize: 20),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.thermostat_sharp,
                                      color: Palette.baseIconColor,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1.5,
                                          color: CupertinoColors
                                              .lightBackgroundGray),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35.0),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: CupertinoColors
                                              .lightBackgroundGray),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35.0),
                                      ),
                                    ),
                                    errorStyle: TextStyle(
                                        fontSize: 15, color: Colors.redAccent),
                                    contentPadding: EdgeInsets.all(10)),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: TextFormField(
                                initialValue: context
                                    .watch<GlobalStore>()
                                    .deviceSetting[4],
                                style: const TextStyle(
                                    color: Palette.baseTextColor),
                                key: const ValueKey(4),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return '온도를 입력해주세요.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  context.read<GlobalStore>().deviceSetting[4] =
                                      value;
                                },
                                onChanged: (value) {
                                  context.read<GlobalStore>().deviceSetting[4] =
                                      value;
                                },
                                decoration: const InputDecoration(
                                    label: Text(
                                      '끄는온도',
                                      style: TextStyle(
                                          color: CupertinoColors
                                              .lightBackgroundGray,
                                          fontSize: 20),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.device_thermostat_sharp,
                                      color: Palette.baseIconColor,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1.5,
                                          color: CupertinoColors
                                              .lightBackgroundGray),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35.0),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: CupertinoColors
                                              .lightBackgroundGray),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35.0),
                                      ),
                                    ),
                                    errorStyle: TextStyle(
                                        fontSize: 15, color: Colors.redAccent),
                                    contentPadding: EdgeInsets.all(10)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          '히터 온도범위(수동제어는 켜는온도를 100)',
                          style: TextStyle(
                              color: Palette.baseTextColor,
                              fontWeight: Palette.font1,
                              fontSize: 20),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: TextFormField(
                                initialValue: context
                                    .watch<GlobalStore>()
                                    .deviceSetting[5],
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                style: const TextStyle(
                                    color: Palette.baseTextColor),
                                key: const ValueKey(5),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return '온도를 입력해주세요.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  context.read<GlobalStore>().deviceSetting[5] =
                                      value;
                                },
                                onChanged: (value) {
                                  context.read<GlobalStore>().deviceSetting[5] =
                                      value;
                                },
                                decoration: const InputDecoration(
                                    label: Text(
                                      '켜는온도',
                                      style: TextStyle(
                                          color: CupertinoColors
                                              .lightBackgroundGray,
                                          fontSize: 20),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.thermostat_sharp,
                                      color: Palette.baseIconColor,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1.5,
                                          color: CupertinoColors
                                              .lightBackgroundGray),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35.0),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: CupertinoColors
                                              .lightBackgroundGray),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35.0),
                                      ),
                                    ),
                                    errorStyle: TextStyle(
                                        fontSize: 15, color: Colors.redAccent),
                                    contentPadding: EdgeInsets.all(10)),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: TextFormField(
                                initialValue: context
                                    .watch<GlobalStore>()
                                    .deviceSetting[6],
                                style: const TextStyle(
                                    color: Palette.baseTextColor),
                                key: const ValueKey(6),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return '온도를 입력해주세요.';
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  context.read<GlobalStore>().deviceSetting[6] =
                                      value;
                                },
                                onChanged: (value) {
                                  context.read<GlobalStore>().deviceSetting[6] =
                                      value;
                                },
                                decoration: const InputDecoration(
                                    label: Text(
                                      '끄는온도',
                                      style: TextStyle(
                                          color: CupertinoColors
                                              .lightBackgroundGray,
                                          fontSize: 20),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.device_thermostat_sharp,
                                      color: Palette.baseIconColor,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1.5,
                                          color: CupertinoColors
                                              .lightBackgroundGray),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35.0),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: CupertinoColors
                                              .lightBackgroundGray),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35.0),
                                      ),
                                    ),
                                    errorStyle: TextStyle(
                                        fontSize: 15, color: Colors.redAccent),
                                    contentPadding: EdgeInsets.all(10)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          '출력설정 (출력 이름 및 초기 켜짐 설정)',
                          style: TextStyle(
                              color: Palette.baseTextColor,
                              fontWeight: Palette.font1,
                              fontSize: 20),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          itemCount: widget.itsInfo.outputs.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, //1 개의 행에 보여줄 item 개수
                            childAspectRatio: 7 / 1, //item 의 가로 1, 세로 1 의 비율
                            mainAxisSpacing: 10, //수평 Padding
                            crossAxisSpacing: 5, //수직 Padding
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            // return Text(index.toString());
                            return Row(
                              children: <Widget>[
                                Flexible(
                                  child: TextFormField(
                                    initialValue: widget.itsInfo.outputs[index]
                                        ['name'],
                                    style: const TextStyle(
                                        color: Palette.baseTextColor),
                                    key: ValueKey(7 + index),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return '출력 이름을 입력해 주세요.';
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      widget.itsInfo.outputs[index]['name'] =
                                          value;
                                    },
                                    onChanged: (value) {
                                      widget.itsInfo.outputs[index]['name'] =
                                          value;
                                    },
                                    decoration: InputDecoration(
                                        label: Text(
                                          '출력 ${index + 1}',
                                          style: const TextStyle(
                                              color: CupertinoColors
                                                  .lightBackgroundGray,
                                              fontSize: 20),
                                        ),
                                        prefixIcon: const Icon(
                                          Icons.output,
                                          color: Palette.baseIconColor,
                                        ),
                                        enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1.5,
                                              color: CupertinoColors
                                                  .lightBackgroundGray),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(35.0),
                                          ),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: CupertinoColors
                                                  .lightBackgroundGray),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(35.0),
                                          ),
                                        ),
                                        errorStyle: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.redAccent),
                                        contentPadding:
                                            const EdgeInsets.all(10)),
                                  ),
                                ),
                              ],
                            );
                          },
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _tryValidationDevice();
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: CupertinoColors.systemGreen),
                    icon: const Icon(
                      Icons.save_alt,
                      size: 18,
                      color: Palette.baseIconColor,
                    ),
                    label: Text(
                      '저장',
                      style: TextStyle(
                          color: Palette.baseTextColor,
                          fontWeight: Palette.font1,
                          fontSize: 15),
                    ),
                  ),
                ],
              )),
          AccordionSection(
              isOpen: false,
              leftIcon:
                  const Icon(Icons.network_cell, color: Palette.baseIconColor),
              headerBackgroundColor: Palette.themeSecondary,
              headerBackgroundColorOpened: Palette.themeSecondary,
              headerBorderWidth: 1,
              contentBackgroundColor: Palette.themeTertiary,
              contentBorderWidth: 0,
              contentVerticalPadding: 30,
              header: const Text('IP 설정', style: headerStyle),
              content: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Form(
                    key: _formKeyNetwork,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'IP',
                          style: TextStyle(
                              color: Palette.baseTextColor,
                              fontWeight: Palette.font1,
                              fontSize: 20),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          itemCount: 4,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4, //1 개의 행에 보여줄 item 개수
                            childAspectRatio: 4 / 1, //item 의 가로 1, 세로 1 의 비율
                            mainAxisSpacing: 10, //수평 Padding
                            crossAxisSpacing: 5, //수직 Padding
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            // return Text(index.toString());
                            return Row(
                              children: <Widget>[
                                Flexible(
                                  child: TextFormField(
                                    initialValue: context
                                        .watch<GlobalStore>()
                                        .networkSetting[index],
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    style: const TextStyle(
                                        color: Palette.baseTextColor),
                                    key: ValueKey(index),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'IP를 입력해 주세요.';
                                      } else if (int.parse(value) < 0 ||
                                          int.parse(value) > 255) {
                                        return "IP를 0~255 사이에서 입력하세요.";
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      context
                                          .read<GlobalStore>()
                                          .networkSetting[index] = value;
                                    },
                                    onChanged: (value) {
                                      context
                                          .read<GlobalStore>()
                                          .networkSetting[index] = value;
                                    },
                                    decoration: const InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.signal_cellular_alt,
                                          color: Palette.baseIconColor,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1.5,
                                              color: CupertinoColors
                                                  .lightBackgroundGray),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(35.0),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: CupertinoColors
                                                  .lightBackgroundGray),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(35.0),
                                          ),
                                        ),
                                        errorStyle: TextStyle(
                                            fontSize: 15,
                                            color: Colors.redAccent),
                                        contentPadding: EdgeInsets.all(10)),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'NetMask',
                          style: TextStyle(
                              color: Palette.baseTextColor,
                              fontWeight: Palette.font1,
                              fontSize: 20),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          itemCount: 4,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4, //1 개의 행에 보여줄 item 개수
                            childAspectRatio: 4 / 1, //item 의 가로 1, 세로 1 의 비율
                            mainAxisSpacing: 10, //수평 Padding
                            crossAxisSpacing: 5, //수직 Padding
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            // return Text(index.toString());
                            return Row(
                              children: <Widget>[
                                Flexible(
                                  child: TextFormField(
                                    initialValue: context
                                        .watch<GlobalStore>()
                                        .networkSetting[index + 4],
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    style: const TextStyle(
                                        color: Palette.baseTextColor),
                                    key: ValueKey(index + 4),
                                    validator: (value) {
                                      int x = int.parse(value!);
                                      if (value.isEmpty) {
                                        return 'NetMask를 입력해 주세요.';
                                      } else if (x != 0 &&
                                          x != 255 &&
                                          x != 254 &&
                                          x != 252 &&
                                          x != 248 &&
                                          x != 240 &&
                                          x != 224 &&
                                          x != 192 &&
                                          x != 128) {
                                        return "Netmask를 0, 128, 192, 224, \n240, 248, 252, 254, 255 중에서 입력하세요.";
                                      } else if (index > 0 &&
                                          int.parse(context
                                                      .read<GlobalStore>()
                                                      .networkSetting[
                                                  4 + index - 1]) !=
                                              255 &&
                                          x != 0) {
                                        return "Netmask가 잘못되었습니다.\n앞자리수가 255가 아니면 \n뒤에는 전부 0이어야 합니다.";
                                      } else if (index == 3 && x == 255) {
                                        return "Netmask가 잘못되었습니다.\n마지막자리는 255가 올 수 없습니다.";
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      context
                                          .read<GlobalStore>()
                                          .networkSetting[index + 4] = value;
                                    },
                                    onChanged: (value) {
                                      context
                                          .read<GlobalStore>()
                                          .networkSetting[index + 4] = value;
                                    },
                                    decoration: const InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.signal_cellular_alt,
                                          color: Palette.baseIconColor,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1.5,
                                              color: CupertinoColors
                                                  .lightBackgroundGray),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(35.0),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: CupertinoColors
                                                  .lightBackgroundGray),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(35.0),
                                          ),
                                        ),
                                        errorStyle: TextStyle(
                                            fontSize: 15,
                                            color: Colors.redAccent),
                                        contentPadding: EdgeInsets.all(10)),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'GateWay',
                          style: TextStyle(
                              color: Palette.baseTextColor,
                              fontWeight: Palette.font1,
                              fontSize: 20),
                        ),
                        GridView.builder(
                          shrinkWrap: true,
                          itemCount: 4,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4, //1 개의 행에 보여줄 item 개수
                            childAspectRatio: 4 / 1, //item 의 가로 1, 세로 1 의 비율
                            mainAxisSpacing: 10, //수평 Padding
                            crossAxisSpacing: 5, //수직 Padding
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            // return Text(index.toString());
                            return Row(
                              children: <Widget>[
                                Flexible(
                                  child: TextFormField(
                                    initialValue: context
                                        .read<GlobalStore>()
                                        .networkSetting[index + 8],
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    style: const TextStyle(
                                        color: Palette.baseTextColor),
                                    key: ValueKey(index + 8),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Gateway를 입력해 주세요.';
                                      }
                                      if (int.parse(value) < 0 ||
                                          int.parse(value) > 255) {
                                        return "Gateway를 0~255 사이에서 입력하세요.";
                                      }
                                      return null;
                                    },
                                    onSaved: (value) {
                                      context
                                          .read<GlobalStore>()
                                          .networkSetting[index + 8] = value;
                                    },
                                    onChanged: (value) {
                                      context
                                          .read<GlobalStore>()
                                          .networkSetting[index + 8] = value;
                                    },
                                    decoration: const InputDecoration(
                                        prefixIcon: Icon(
                                          Icons.signal_cellular_alt,
                                          color: Palette.baseIconColor,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1.5,
                                              color: CupertinoColors
                                                  .lightBackgroundGray),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(35.0),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: CupertinoColors
                                                  .lightBackgroundGray),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(35.0),
                                          ),
                                        ),
                                        errorStyle: TextStyle(
                                            fontSize: 15,
                                            color: Colors.redAccent),
                                        contentPadding: EdgeInsets.all(10)),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          '서버주소',
                          style: TextStyle(
                              color: Palette.baseTextColor,
                              fontWeight: Palette.font1,
                              fontSize: 20),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          initialValue:
                              context.watch<GlobalStore>().networkSetting[12],
                          style: const TextStyle(color: Palette.baseTextColor),
                          key: const ValueKey(12),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return '서버주소를 입력하세요.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            context.read<GlobalStore>().networkSetting[12] =
                                value;
                          },
                          onChanged: (value) {
                            context.read<GlobalStore>().networkSetting[12] =
                                value;
                          },
                          decoration: const InputDecoration(
                              label: Text(
                                '서버주소',
                                style: TextStyle(
                                    color: CupertinoColors.lightBackgroundGray,
                                    fontSize: 20),
                              ),
                              prefixIcon: Icon(
                                Icons.computer,
                                color: Palette.baseIconColor,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1.5,
                                    color: CupertinoColors.lightBackgroundGray),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(35.0),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: CupertinoColors.lightBackgroundGray),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(35.0),
                                ),
                              ),
                              errorStyle: TextStyle(
                                  fontSize: 15, color: Colors.redAccent),
                              contentPadding: EdgeInsets.all(10)),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: TextFormField(
                                initialValue: context
                                    .watch<GlobalStore>()
                                    .networkSetting[13],
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                style: const TextStyle(
                                    color: Palette.baseTextColor),
                                key: const ValueKey(13),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return '포트를 입력해주세요.';
                                  }
                                  if (int.parse(value) < 0 ||
                                      int.parse(value) > 65534) {
                                    return "포트를 0~65534 사이에서 입력하세요.";
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  context
                                      .read<GlobalStore>()
                                      .networkSetting[13] = value;
                                },
                                onChanged: (value) {
                                  context
                                      .read<GlobalStore>()
                                      .networkSetting[13] = value;
                                },
                                decoration: const InputDecoration(
                                    label: Text(
                                      '포트',
                                      style: TextStyle(
                                          color: CupertinoColors
                                              .lightBackgroundGray,
                                          fontSize: 20),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.wifi_tethering,
                                      color: Palette.baseIconColor,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1.5,
                                          color: CupertinoColors
                                              .lightBackgroundGray),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35.0),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: CupertinoColors
                                              .lightBackgroundGray),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35.0),
                                      ),
                                    ),
                                    errorStyle: TextStyle(
                                        fontSize: 15, color: Colors.redAccent),
                                    contentPadding: EdgeInsets.all(10)),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: TextFormField(
                                initialValue: context
                                    .watch<GlobalStore>()
                                    .networkSetting[14],
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                style: const TextStyle(
                                    color: Palette.baseTextColor),
                                key: const ValueKey(14),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return '업로드간격을 입력해주세요.';
                                  }
                                  if (int.parse(value) < 0 ||
                                      int.parse(value) > 65534) {
                                    return "업로드간격을 0~65534 사이에서 입력하세요.";
                                  }
                                  return null;
                                },
                                onSaved: (value) {
                                  context
                                      .read<GlobalStore>()
                                      .networkSetting[14] = value;
                                },
                                onChanged: (value) {
                                  context
                                      .read<GlobalStore>()
                                      .networkSetting[14] = value;
                                },
                                decoration: const InputDecoration(
                                    label: Text(
                                      '업로드간격(초) [0은 업로드 안함]',
                                      style: TextStyle(
                                          color: CupertinoColors
                                              .lightBackgroundGray,
                                          fontSize: 20),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.timer,
                                      color: Palette.baseIconColor,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          width: 1.5,
                                          color: CupertinoColors
                                              .lightBackgroundGray),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35.0),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: CupertinoColors
                                              .lightBackgroundGray),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(35.0),
                                      ),
                                    ),
                                    errorStyle: TextStyle(
                                        fontSize: 15, color: Colors.redAccent),
                                    contentPadding: EdgeInsets.all(10)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      ElevatedButton.icon(
                        onPressed: () {
                          widget.socket.sink.add('up_test');
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: CupertinoColors.systemBlue),
                        icon: const Icon(
                          Icons.upload,
                          size: 18,
                          color: Palette.baseIconColor,
                        ),
                        label: Text(
                          '업로드 테스트',
                          style: TextStyle(
                              color: Palette.baseTextColor,
                              fontWeight: Palette.font1,
                              fontSize: 15),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          _tryValidationNetwork();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: CupertinoColors.systemGreen),
                        icon: const Icon(
                          Icons.save_alt,
                          size: 18,
                          color: Palette.baseIconColor,
                        ),
                        label: Text(
                          '저장',
                          style: TextStyle(
                              color: Palette.baseTextColor,
                              fontWeight: Palette.font1,
                              fontSize: 15),
                        ),
                      ),
                    ],
                  )
                ],
              )),
          AccordionSection(
            isOpen: false,
            leftIcon: const Icon(Icons.update, color: Palette.baseIconColor),
            headerBackgroundColor: Palette.themeSecondary,
            headerBackgroundColorOpened: Palette.themeSecondary,
            headerBorderWidth: 1,
            contentBackgroundColor: Palette.themeTertiary,
            contentBorderWidth: 0,
            contentVerticalPadding: 30,
            header: const Text('업데이트 설정  ', style: headerStyle),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning_amber,
                  size: 50,
                  color: CupertinoColors.systemRed,
                ),
                const SizedBox(
                  width: 20,
                ),
                Flexible(
                    child: Column(
                  children: <Widget>[
                    Text(
                      '서버설정을 변경하면 다시 시작해야 변경된 내용이 적용됩니다.',
                      style: TextStyle(
                          color: CupertinoColors.systemRed,
                          fontWeight: Palette.font1,
                          fontSize: 20),
                    ),
                    const SizedBox(
                      height: 15,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[


// 업데이트 시작 버튼
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            // 파일 선택
                            FilePickerResult? result = await FilePicker.platform.pickFiles();

                            if (result != null) {
                              PlatformFile file = result.files.first;
                              print("선택된 파일: ${file.name}, 크기: ${file.size} bytes");

                              // 파일을 서버로 전송
                              Uri url = Uri.parse("https://yourserver.com/upload"); // 서버 URL
                              int chunkSize = 1024; // 1KB
                              int totalChunks = (file.size / chunkSize).ceil();
                              int currentChunk = 0;

                              Uint8List fileBytes = file.bytes!; // 파일 데이터를 메모리에 로드

                              for (int i = 0; i < totalChunks; i++) {
                                // 청크 데이터 분리
                                Uint8List chunk = fileBytes.sublist(
                                  i * chunkSize,
                                  ((i + 1) * chunkSize > fileBytes.length) ? fileBytes.length : (i + 1) * chunkSize,
                                );

                                // HTTP POST 요청으로 전송
                                var request = http.MultipartRequest("POST", url);
                                request.fields['chunkIndex'] = '$i'; // 청크 번호
                                request.fields['totalChunks'] = '$totalChunks'; // 전체 청크 수
                                request.files.add(http.MultipartFile.fromBytes(
                                  'file', // 필드 이름
                                  chunk,
                                  filename: file.name,
                                ));

                                var response = await request.send();

                                if (response.statusCode == 200) {
                                  print("청크 $i 전송 성공");
                                } else {
                                  print("청크 $i 전송 실패: ${response.statusCode}");
                                  break;
                                }
                              }

                              print("파일 전송 완료");
                            } else {
                              print("파일 선택 취소됨");
                            }
                          } catch (e) {
                            print("파일 업로드 중 오류 발생: $e");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CupertinoColors.systemBlue,
                        ),
                        icon: const Icon(
                          Icons.upload,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text("파일 업로드"),
                      ),
// 업데이트 

                        const SizedBox(
                          width: 10,
                        ),
                        // 다시 시작 버튼
                        ElevatedButton.icon(
                          onPressed: () {
                            widget.socket.sink.add('RESTART'); // 다시 시작 메시지 전송
                            print("시스템 다시 시작 메시지 전송 완료");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CupertinoColors.systemBlue,
                          ),
                          icon: const Icon(
                            Icons.refresh,
                            size: 18,
                            color: Palette.baseIconColor,
                          ),
                          label: Text(
                            '다시 시작',
                            style: TextStyle(
                              color: Palette.baseTextColor,
                              fontWeight: Palette.font1,
                              fontSize: 15),
                          ),
                        ),
                      ],
                    )

                  ],
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
