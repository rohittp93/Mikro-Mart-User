import 'package:flutter/material.dart';

class DoubleHolder {
  double value = 0.0;
}

class StatefulGridView extends StatefulWidget {
  final DoubleHolder offset = new DoubleHolder();

  StatefulGridView(this._itemCount, this._indexedWidgetBuilder, {Key key})
      : super(key: key);

  double getOffsetMethod() {
    return offset.value;
  }

  void setOffsetMethod(double val) {
    offset.value = val;
  }

  final int _itemCount;
  final IndexedWidgetBuilder _indexedWidgetBuilder;

  @override
  _StatefulGridViewState createState() =>
      _StatefulGridViewState(_itemCount, _indexedWidgetBuilder);
}

class _StatefulGridViewState extends State<StatefulGridView> {
  ScrollController scrollController;
  final int _itemCount;
  final IndexedWidgetBuilder _itemBuilder;

  _StatefulGridViewState(this._itemCount, this._itemBuilder);

  @override
  void initState() {
    super.initState();
    scrollController =
        new ScrollController(initialScrollOffset: widget.getOffsetMethod());
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    final double itemWidth = size.width / 2;
    final double itemHeight = (itemWidth) + 100;

    return new GridView.builder(
          controller: scrollController,
        padding: EdgeInsets.only(
            left: 16, right: 16, bottom: 50),
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: itemWidth / itemHeight, crossAxisCount: 2),
          itemCount: _itemCount,
          itemBuilder: _itemBuilder);
  }
}
