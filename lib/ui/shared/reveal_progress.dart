import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:userapp/ui/shared/progress_button.dart';
import 'package:userapp/ui/shared/reveal_progress_button_painter.dart';
import 'package:userapp/ui/views/PhonenumberRegister.dart';
import 'package:userapp/ui/views/mainHome.dart';

class RevealProgressButton extends StatefulWidget {
  final Function onPressed;
  bool isValid;
  int buttonAnimationState;
  bool phoneValidated;

  RevealProgressButton(
      {@required this.isValid,
      this.onPressed,
      @required this.buttonAnimationState,
      @required this.phoneValidated});

  @override
  State<StatefulWidget> createState() => _RevealProgressButtonState();
}

class _RevealProgressButtonState extends State<RevealProgressButton>
    with TickerProviderStateMixin {
  Animation<double> _animation;
  AnimationController _controller;
  double _fraction = 0.0;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter:
          RevealProgressButtonPainter(_fraction, MediaQuery.of(context).size),
      child: ProgressButton(reveal, widget.isValid, widget.onPressed,
          widget.buttonAnimationState, widget.phoneValidated),
    );
  }

  @override
  void deactivate() {
    reset();
    super.deactivate();
  }

  @override
  dispose() {
    _controller.dispose();
    super.dispose();
  }

  void reveal() {
    _controller = AnimationController(
        duration: const Duration(milliseconds: 200), vsync: this);
    _animation = Tween(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {
          _fraction = _animation.value;
        });
      })
      ..addStatusListener((AnimationStatus state) {
        if (state == AnimationStatus.completed) {
          Navigator.of(context).pushReplacement(
              new PageRouteBuilder(
                  pageBuilder: (BuildContext context, _, __) {
                    return !widget.phoneValidated ? PhoneNumberRegister() : MainHome(); ;
                  },
                  transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
                    return new FadeTransition(
                        opacity: animation,
                        child: child
                    );
                  }
              )
          );
        }
      });
    _controller.forward();
  }

  void reset() {
    _fraction = 0.0;
  }
}
