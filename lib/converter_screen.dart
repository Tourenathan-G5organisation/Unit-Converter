import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import './unit.dart';

/// Converter screen where users can input amounts to convert.

class ConverterScreen extends StatefulWidget {
  /// Units for this [Category].
  final List<Unit> units;
  final ColorSwatch color;

  /// This [ConverterRoute] requires the color and units to not be null.
  const ConverterScreen({
    @required this.units,
    @required this.color,
  })  : assert(units != null),
        assert(color != null);

  @override
  State<StatefulWidget> createState() {
    return new _ConverterScreenState();
  }
}

class _ConverterScreenState extends State<ConverterScreen> {
  @override
  Widget build(BuildContext context) {
    final _input = Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Directionality(
            child: TextField(
              keyboardType: TextInputType.number,
              style: Theme.of(context).textTheme.display1,
              decoration: InputDecoration(
                  labelText: "Input",
                  labelStyle: Theme.of(context).textTheme.display1,
                  errorText:
                      _showValidationError() ? "Invalid number entered" : null,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0))),
            ),
            textDirection: TextDirection.ltr,
          ),
          _createDropDown(widget.units),
        ],
      ),
    );

    final _arrow = RotatedBox(
      quarterTurns: 1,
      child: Icon(
        Icons.compare,
        size: 40,
      ),
    );

    final _output = Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Directionality(
            child: TextField(
              keyboardType: TextInputType.number,
              style: Theme.of(context).textTheme.display1,
              decoration: InputDecoration(
                  labelText: "Output",
                  labelStyle: Theme.of(context).textTheme.display1,
                  errorText:
                      _showValidationError() ? "Invalid number entered" : null,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0))),
            ),
            textDirection: TextDirection.ltr,
          ),
          _createDropDown(widget.units),
        ],
      ),
    );

    return Container(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            _input,
            _arrow,
            _output,
          ],
        ),
      ),
    );

    /*
       final unitWidgets = widget.units.map((Unit unit) {

      return Container(
        margin: EdgeInsets.all(8.0),
        padding: EdgeInsets.all(16.0),
        color: widget.color,
        child: Column(
          children: <Widget>[
            Text(
              unit.name,
              style: Theme.of(context).textTheme.headline,
            ),
            Text(
              'Conversion: ${unit.conversion}',
              style: Theme.of(context).textTheme.subhead,
            ),
          ],
        ),
      );
    }).toList();
    }
    return ListView(
      children: unitWidgets,
    );
    */
  }

  bool _showValidationError() {
    return false;
  }

  Widget _createDropDown(List<Unit> units) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
      child: DropdownButton<String>(
        value: units[0].name,
        onChanged: (String newValue){},
        items: units.map((Unit unit) {
          return DropdownMenuItem<String>(
            value: unit.name,
            child: Text(unit.name),
          );
        }).toList(),
      ),
    );
  }
}
