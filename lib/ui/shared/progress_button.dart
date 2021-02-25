import 'dart:async';

import 'package:flutter/material.dart';
import 'package:userapp/ui/shared/colors.dart';

class ProgressButton extends StatefulWidget {
  final Function callback;
  final Function onPressed;
  int buttonAnimationState;
  bool isValid = false;
  String buttonText;

  ProgressButton(this.callback, this.isValid, this.onPressed,
      this.buttonAnimationState, this.buttonText);

  @override
  State<StatefulWidget> createState() => ProgressButtonState();
}

class ProgressButtonState extends State<ProgressButton>
    with TickerProviderStateMixin {
  bool _animatingReveal = false;
  double _width = double.infinity;
  Animation _animation;
  GlobalKey _globalKey = GlobalKey();
  AnimationController _controller;
  final GlobalKey<ScaffoldState> _scaffoldkey = new GlobalKey<ScaffoldState>();

  @override
  void deactivate() {
    reset();
    super.deactivate();
  }

  @override
  dispose() {
    if(_controller!=null)_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (/*widget.phoneValidated &&*/
        widget.buttonAnimationState != null &&
        widget.buttonAnimationState == 2) {
      taskComplete();
    } else if (widget.buttonAnimationState != null &&
        widget.buttonAnimationState == 0 &&
        _controller != null) {
      taskFailed();
    } else {}

    return ClipRRect(
      borderRadius: BorderRadius.circular(40.0),
      child: Container(
          color: MikroMartColors.colorPrimary,
          child: Container(
            key: _globalKey,
            height: 48.0,
            width: _width,
            child: InkWell(
              onTap: () {
                setState(() {
                  if (widget.buttonAnimationState == 0) {
                    widget.onPressed();
                    if (widget.isValid) {
                      print('Animation Started');
                      animateButton();
                    } else {}
                    //
                  }
                });
              },
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40.0),
                  child: Container(
                    padding: EdgeInsets.all(0.0),
                    color: widget.buttonAnimationState == 2
                        ? MikroMartColors.colorPrimary
                        : MikroMartColors.colorPrimary,
                    child: buildButtonChild(),
                  ),
                ),
              ),
            ),
          )),
    );
  }

  void animateButton() {
    double initialWidth = _globalKey.currentContext.size.width;

    _controller =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {
          _width = initialWidth - ((initialWidth - 48.0) * _animation.value);
        });
      });
    _controller.forward();

  }

  void taskComplete() {
    Timer(Duration(milliseconds: 500), () {
      _animatingReveal = true;
      widget.callback();
      _controller.dispose();
    });
  }

  void taskFailed() {
    _controller.reverse();
  }

  Widget buildButtonChild() {
    if (widget.buttonAnimationState == 0) {
      return Text(
        widget.buttonText,
        style: TextStyle(color: Colors.white,fontSize: 18, fontFamily: 'Mulish',fontWeight: FontWeight.bold),
      );
    } else if (widget.buttonAnimationState == 1) {
      return SizedBox(
        height: 36.0,
        width: 36.0,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          value: null,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else if (widget.buttonAnimationState == 2) {
      return Icon(Icons.check, color: Colors.white);
    } else {
      return Container();
    }
  }

  void reset() {
    _width = double.infinity;
    _animatingReveal = false;
    widget.buttonAnimationState = 0;
  }
}
