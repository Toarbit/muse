import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:muse/pages/welcome/login_sub_navigation.dart';

class PageLoginWithEmail extends StatefulWidget {
  @override
  _PageLoginWithEmailState createState() => _PageLoginWithEmailState();
}

class _PageLoginWithEmailState extends State<PageLoginWithEmail> {
  final _emailInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailInputController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _emailInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('邮箱登录'),
        leading: IconButton(
          icon: const BackButtonIcon(),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          onPressed: () {
            Navigator.of(context, rootNavigator: true).maybePop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: _PhoneInput(controller: _emailInputController),
            ),
            _ButtonNextStep(controller: _emailInputController),
          ],
        ),
      ),
    );
  }
}

class _PhoneInput extends StatelessWidget {
  final TextEditingController controller;

  _PhoneInput({Key key, this.controller}) : super(key: key);

  Color _textColor(BuildContext context) {
    if (controller.text.isEmpty) {
      return Theme.of(context).disabledColor;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.body1.copyWith(
      fontSize: 16,
      color: _textColor(context),
    );
    return DefaultTextStyle(
      style: style,
      child: TextField(
        controller: controller,
        style: style,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Email',
        ),
      ),
    );
  }
}

class _ButtonNextStep extends StatelessWidget {
  final TextEditingController controller;

  const _ButtonNextStep({Key key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: Theme.of(context).primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      textColor: Theme.of(context).primaryTextTheme.body1.color,
      child: Text('下一步'),
      onPressed: () async {
        final text = controller.text;
        if (text.isEmpty) {
          toast('请输入邮箱');
          return;
        }
        Navigator.pushNamed(context, pageLoginPassword, arguments: {'phone': text});
      },
    );
  }
}
