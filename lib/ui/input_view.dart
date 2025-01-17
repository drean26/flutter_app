import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/generated/i18n.dart';
import 'package:rxdart/rxdart.dart';

import '../page_index.dart';

class TextFieldView extends StatelessWidget {
  final EdgeInsets margin;
  final IconData icon;
  final String hintText;
  final TextStyle style;
  final TextStyle hintStyle;
  final TextEditingController controller;
  final Color bgColor;
  final FocusNode focusNode;
  final TextInputType keyboardType;
  final BoxBorder border;

  TextFieldView({
    Key key,
    this.margin: const EdgeInsets.symmetric(horizontal: 28),
    this.icon,
    this.hintText,
    this.style,
    this.hintStyle: const TextStyle(fontSize: 14, color: Colors.grey),
    this.controller,
    this.bgColor,
    this.focusNode,
    this.keyboardType,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      margin: margin,
      decoration: BoxDecoration(
        color: bgColor ?? Theme.of(context).scaffoldBackgroundColor,
        border: border ?? Border.all(color: Color(0xff0000ff), width: 0.5),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 22),
          Gaps.hGap12,
          Expanded(
            child: TextField(
              controller: controller,
              style: style,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: hintStyle,
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final int maxLength;
  final bool autoFocus;
  final TextInputType keyboardType;
  final String hintText;
  final FocusNode focusNode;
  final FocusNode nextFocusNode;
  final bool isInputPwd;
  final Function getVCode;
  final Widget prefixIcon;
  final TextStyle hintTextStyle;

  CustomTextField({
    Key key,
    @required this.controller,
    this.maxLength: 16,
    this.autoFocus: false,
    this.keyboardType: TextInputType.text,
    this.hintText: "",
    this.focusNode,
    this.nextFocusNode,
    this.isInputPwd: false,
    this.getVCode,
    this.prefixIcon,
    this.hintTextStyle,
  }) : super(key: key);

  @override
  createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isShowPwd = false;
  bool _isShowDelete = true;
  bool _isClick = true;

  /// 倒计时秒数
  final int second = 30;

  /// 当前秒数
  int s;
  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    //监听输入改变
    widget.controller.addListener(() {
      setState(() {
        _isShowDelete = widget.controller.text.isEmpty;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.centerRight, children: <Widget>[
      TextField(
        focusNode: widget.focusNode,
        maxLength: widget.maxLength,

        /// 键盘动作按钮点击之后执行的代码： 光标切换到指定的输入框
        onEditingComplete: widget.nextFocusNode == null
            ? null
            : () => FocusScope.of(context).requestFocus(widget.nextFocusNode),
        obscureText: widget.isInputPwd ? !_isShowPwd : false,
        autofocus: widget.autoFocus,
        controller: widget.controller,
        textInputAction: TextInputAction.done,
        keyboardType: widget.keyboardType,
        // 数字、手机号限制格式为0到9(白名单)， 密码限制不包含汉字（黑名单）
        inputFormatters: (widget.keyboardType == TextInputType.number ||
                widget.keyboardType == TextInputType.phone)
            ? [WhitelistingTextInputFormatter(RegExp("[0-9]"))]
            : [BlacklistingTextInputFormatter(RegExp("[\u4e00-\u9fa5]"))],
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
          hintText: widget.hintText,
          hintStyle: widget.hintTextStyle ?? TextStyles.textGreyC14,
          counterText: "",
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blueAccent, width: 0.8)),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFEEEEEE), width: 0.8)),
          prefixIcon: widget.prefixIcon,
        ),
      ),
      Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
        Offstage(
            offstage: _isShowDelete,
            child: InkWell(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: Icon(Icons.close, size: 18.0),
                onTap: () => setState(() => widget.controller.text = ""))),
        Offstage(
            offstage: !widget.isInputPwd,
            child: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    child: Icon(
                        _isShowPwd
                            ? CustomIcon.show_password
                            : CustomIcon.hidden_password,
                        size: 18.0),
                    onTap: () {
                      setState(() => _isShowPwd = !_isShowPwd);
                    }))),
        Offstage(
            offstage: widget.getVCode == null,
            child: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Container(
                    height: 26.0,
                    width: 76.0,
                    child: FlatButton(
                        onPressed: _isClick
                            ? () {
                                widget.getVCode();
                                setState(() {
                                  s = second;
                                  _isClick = false;
                                });
                                _subscription = Observable.periodic(
                                        Duration(seconds: 1), (i) => i)
                                    .take(second)
                                    .listen((i) => setState(() {
                                          s = second - i - 1;
                                          _isClick = s < 1;
                                        }));
                              }
                            : null,
                        padding: const EdgeInsetsDirectional.only(
                            start: 8.0, end: 8.0),
                        textColor: Colors.blueAccent,
                        color: Colors.transparent,
                        disabledTextColor: Colors.white,
                        disabledColor: Color(0xFFcccccc),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(1.0),
                            side: BorderSide(
                                color: _isClick
                                    ? Colors.blueAccent
                                    : Color(0xFFcccccc),
                                width: 0.8)),
                        child: Text(
                            _isClick ? "${S.of(context).get_v_code}" : "（$s s）",
                            style: TextStyle(fontSize: Dimens.font_sp12))))))
      ])
    ]);
  }
}

class TextFieldItem extends StatelessWidget {
  final TextEditingController controller;
  final String title;
  final String hintText;
  final TextInputType keyboardType;
  final FocusNode focusNode;
  final FocusNode nextFocusNode;
  final int maxLines;
  final int maxLength;

  const TextFieldItem(
      {Key key,
      this.controller,
      @required this.title,
      this.keyboardType: TextInputType.text,
      this.hintText: "",
      this.focusNode,
      this.nextFocusNode,
      this.maxLines: 1,
      this.maxLength})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: maxLines == 1 ? 55.0 : maxLines * 55.0 * 0.75,
        margin: const EdgeInsets.only(left: 16.0, right: 16),
        width: double.infinity,
        child: Row(
            crossAxisAlignment: maxLines == 1
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                  height: 50,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(title, style: TextStyles.textDark14)),
              Expanded(
                  child: TextField(
                      maxLength: maxLength,
                      style: TextStyles.textDark14,
                      maxLines: maxLines,
                      focusNode: focusNode,
                      keyboardType: keyboardType,
                      inputFormatters: (keyboardType == TextInputType.number ||
                              keyboardType == TextInputType.phone)
                          ? [WhitelistingTextInputFormatter(RegExp("[0-9]"))]
                          : keyboardType ==
                                  TextInputType.numberWithOptions(decimal: true)
                              ? [UsNumberTextInputFormatter()]
                              : [BlacklistingTextInputFormatter(RegExp(""))],
                      controller: controller,
                      onEditingComplete: nextFocusNode == null
                          ? null
                          : () => FocusScope.of(context)
                              .requestFocus(nextFocusNode),
                      decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 16.0),
                          hintText: hintText,
                          counterText: "",
                          border: InputBorder.none,
                          hintStyle: TextStyles.textGreyC14)))
            ]));
  }
}

/// 只允许输入小数
class UsNumberTextInputFormatter extends TextInputFormatter {
  static const defaultDouble = 0.001;

  static double strToFloat(String str, [double defaultValue = defaultDouble]) {
    try {
      return double.parse(str);
    } catch (e) {
      return defaultValue;
    }
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String value = newValue.text;
    int selectionIndex = newValue.selection.end;
    if (value == ".") {
      value = "0.";
      selectionIndex++;
    } else if (value != "" &&
        value != defaultDouble.toString() &&
        strToFloat(value, defaultDouble) == defaultDouble) {
      value = oldValue.text;
      selectionIndex = oldValue.selection.end;
    }
    return TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}

class CTextField extends StatelessWidget {
  CTextField({
    this.controller,
    this.hintText,
    this.obscure: false,
    this.icon,
    this.focusNode,
  });

  final TextEditingController controller;
  final String hintText;
  final bool obscure;
  final IconData icon;
  final focusNode;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      child: Row(
        children: <Widget>[
          Icon(icon, color: Colors.yellow[900]),
          SizedBox(width: width / 30),
          Expanded(
            child: TextField(
              focusNode: focusNode,
              controller: controller,
              obscureText: obscure,
              decoration: InputDecoration.collapsed(
                hintText: hintText,
                hintStyle: TextStyle(fontSize: 16, color: Colors.white54),
              ),
            ),
          ),
        ],
      ),
      padding: EdgeInsets.only(bottom: 4.0),
      margin: EdgeInsets.only(top: 40, right: 20, left: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.yellow[900]),
        ),
      ),
    );
  }
}
