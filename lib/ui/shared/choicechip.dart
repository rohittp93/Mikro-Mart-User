import 'package:flutter/material.dart';
import 'package:userapp/core/models/store.dart';
import 'package:userapp/ui/shared/colors.dart';

class choiceChipWidget extends StatefulWidget {
  final List<Store> storesList;
  final Function(Store store) onStoreSelected;

  choiceChipWidget({
   @required this.storesList,
    @required  this.onStoreSelected,
  });

  @override
  _choiceChipWidgetState createState() => new _choiceChipWidgetState();
}

class _choiceChipWidgetState extends State<choiceChipWidget> {
  Store selectedChoice;

  @override
  void initState() {
    super.initState();
    if (widget.storesList != null && widget.storesList.length != 0) {
      selectedChoice = widget.storesList[0];
    }
  }

  _buildChoiceList() {
    List<Widget> choices = [];
    widget.storesList.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(2.0),
        child: ChoiceChip(
          label: Text(item.category_name),
          labelStyle: TextStyle(
              color: selectedChoice == item
                  ? Colors.white
                  : MikroMartColors.colorPrimary,
              fontSize: 14.0,
              fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          backgroundColor: Color(0xffededed),
          selectedColor: MikroMartColors.colorPrimary,
          selected: selectedChoice == item,
          onSelected: (selected) {
            setState(() {
              selectedChoice = item;
            });
            widget.onStoreSelected(selectedChoice);
          },
        ),
      ));
    });
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: _buildChoiceList(),
    );
  }
}
