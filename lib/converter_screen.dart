import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import './unit.dart';
import 'api.dart';
import 'category.dart';

/// Converter screen where users can input amounts to convert.

class ConverterScreen extends StatefulWidget {
  /// The current [Category] for unit conversion.
  final Category category;

  /// This [ConverterRoute] requires the color and units to not be null.
  const ConverterScreen({
    @required this.category,
  }) : assert(category != null);

  @override
  State<StatefulWidget> createState() {
    return new _ConverterScreenState();
  }
}

class _ConverterScreenState extends State<ConverterScreen> {

  Unit _fromValue;
  Unit _toValue;
  double _inputValue;
  String _convertedValue = '';
  List<DropdownMenuItem> _unitMenuItems;
  bool _showValidationError = false;
  final _inputKey = GlobalKey(debugLabel: 'inputText');
  bool _showErrorOnUI = false;

  void _createDropDownMenuItem() {
    var newItems = <DropdownMenuItem>[];
    for (var unit in widget.category.units) {
      newItems.add(DropdownMenuItem(
        value: unit.name,
        child: Container(
          child: Text(
            unit.name,
            softWrap: true,
          ),
        ),
      ));
    }
    setState(() {
      _unitMenuItems = newItems;
    });
  }

  @override
  void initState() {
    super.initState();
    _createDropDownMenuItem();
    _setDefaults();
  }

  @override
  void didUpdateWidget(ConverterScreen old) {
    super.didUpdateWidget(old);
    // We update our [DropdownMenuItem] units when we switch [Categories].
    if (old.category != widget.category) {
      _createDropDownMenuItem();
      _setDefaults();
    }
  }

  void _setDefaults() {
    if(!widget.category.units.isEmpty) {
      setState(() {
        _fromValue = widget.category.units[0];
        _toValue = widget.category.units[1];
      });
    }
  }

  /// Clean up conversion; trim trailing zeros, e.g. 5.500 -> 5.5, 10.0 -> 10
  String _format(double conversion) {
    var outputNum = conversion.toStringAsPrecision(7);
    if (outputNum.contains('.') && outputNum.endsWith('0')) {
      var i = outputNum.length - 1;
      while (outputNum[i] == '0') {
        i -= 1;
      }
      outputNum = outputNum.substring(0, i + 1);
    }
    if (outputNum.endsWith('.')) {
      return outputNum.substring(0, outputNum.length - 1);
    }
    return outputNum;
  }

  Future<void> _updateConversion() async{
    if (widget.category.name == 'Currency') {
      final conversion = await Api().convert('currency',
          _inputValue.toString(), _fromValue.name, _toValue.name);
      if(conversion == null){
        setState(() {
          _showErrorOnUI = true; // This indicate an error occured
        });
        return;
      }
      setState(() {
        _convertedValue = _format(conversion);
      });
    }else{
      // For local units
      setState(() {
        _convertedValue =
            _format(_inputValue * (_toValue.conversion / _fromValue.conversion));
      });
    }

  }

  void _updateInputValue(String input) {
    setState(() {
      if (input == null || input.isEmpty) {
        _convertedValue = '';
      } else {
        // Even though we are using the numerical keyboard, we still have to check
        // for non-numerical input such as '5..0' or '6 -3'
        try {
          final inputDouble = double.parse(input);
          _showValidationError = false;
          _inputValue = inputDouble;
          _updateConversion();
        } on Exception catch (e) {
          print('Error: $e');
          _showValidationError = true;
        }
      }
    });
  }

  Unit _getUnit(String unitName) {
    return widget.category.units.firstWhere(
          (Unit unit) {
        return unit.name == unitName;
      },
      orElse: null,
    );
  }

  void _updateFromConversion(dynamic unitName) {
    setState(() {
      _fromValue = _getUnit(unitName);
    });
    if (_inputValue != null) {
      _updateConversion();
    }
  }

  void _updateToConversion(dynamic unitName) {
    setState(() {
      _toValue = _getUnit(unitName);
    });
    if (_inputValue != null) {
      _updateConversion();
    }
  }

  Widget _createDropdown(String currentValue, ValueChanged<dynamic> onChanged) {
    return Container(
      margin: EdgeInsets.only(top: 16.0),
      decoration: BoxDecoration(
        // This sets the color of the [DropdownButton] itself
        color: Colors.grey[50],
        border: Border.all(
          color: Colors.grey[400],
          width: 1.0,
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Theme(
        // This sets the color of the [DropdownMenuItem]
        data: Theme.of(context).copyWith(
          canvasColor: Colors.grey[50],
        ),
        child: DropdownButtonHideUnderline(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton(
              value: currentValue,
              items: _unitMenuItems,
              onChanged: onChanged,
              style: Theme
                  .of(context)
                  .textTheme
                  .title,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if(widget.category.name == 'Currency' || widget.category.units == null && _showErrorOnUI){
      return SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(16.0),
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.0), color: widget.category.color['error'],),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.error_outline, size: 150.0, color: Colors.white,),
              Text('Error: Unable to connect, please check your internet connection.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline.copyWith(fontSize: 20.0, color: Colors.white),
              )
            ],
          ),
        ),
      );
    }
    final _input = Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Directionality(
            child: TextField(
              key: _inputKey,
              keyboardType: TextInputType.number,
              style: Theme
                  .of(context)
                  .textTheme
                  .display1,
              onChanged: _updateInputValue,
              decoration: InputDecoration(
                  labelText: "Input",
                  labelStyle: Theme
                      .of(context)
                      .textTheme
                      .display1,
                  errorText:
                  _showValidationError ? "Invalid number entered" : null,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(0.0))),
            ),
            textDirection: TextDirection.ltr,
          ),
          _createDropdown(_fromValue.name, _updateFromConversion),
        ],
      ),
    );

    final _arrows = RotatedBox(
      quarterTurns: 1,
      child: Icon(
        Icons.compare_arrows,
        size: 40.0,
      ),
    );

    final _output = Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          InputDecorator(
            child: Text(
              _convertedValue,
              style: Theme
                  .of(context)
                  .textTheme
                  .display1,
            ),
            decoration: InputDecoration(
              labelText: 'Output',
              labelStyle: Theme
                  .of(context)
                  .textTheme
                  .display1,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(0.0),
              ),
            ),
          ),
          _createDropdown(_toValue.name, _updateToConversion),
        ],
      ),
    );

    final converter = ListView(
      children: [
        _input,
        _arrows,
        _output,
      ],
    );
    return Container(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: OrientationBuilder(
            builder: (BuildContext context, Orientation orientation) {
              if (orientation == Orientation.portrait) {
                return converter;
              }
              else {
                return Center(
                  child: Container(width: 450.0, child: converter,),);
              }
            }),

      ),
    );
  }

}
