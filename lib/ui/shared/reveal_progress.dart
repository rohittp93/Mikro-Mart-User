import 'package:flutter/material.dart';
import 'package:userapp/ui/shared/progress_button.dart';
import 'package:userapp/ui/shared/reveal_progress_button_painter.dart';

class RevealProgressButton extends StatefulWidget {
  final Function onPressed;
  bool isValid;
  bool keepStack;
  int buttonAnimationState;
  String intentWidgetRoute;
  String buttonText;

  RevealProgressButton(
      {@required this.isValid,
      @required this.onPressed,
      @required this.buttonAnimationState,
      @required this.intentWidgetRoute,
      @required this.buttonText,
      @required this.keepStack});

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
          widget.buttonAnimationState, widget.buttonText),
    );
  }

  @override
  void deactivate() {
    reset();
    super.deactivate();
  }

  @override
  dispose() {
    if (_controller != null) _controller.dispose();
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
          /*Navigator.of(context).pushReplacement(new PageRouteBuilder(
              pageBuilder: (BuildContext context, _, __) {
            return widget.intentWidget;
          }, transitionsBuilder:
                  (_, Animation<double> animation, __, Widget child) {
            return new FadeTransition(opacity: animation, child: child);
          }));*/
          print('animation cmpleted'); _controller.dispose();
          Navigator.of(context)
              .pushNamedAndRemoveUntil(widget.intentWidgetRoute, (Route<dynamic> route) => widget.keepStack);
        }
      });
    _controller.forward();
  }

  void reset() {
    _fraction = 0.0;
  }
}
