// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import './category.dart';
import './unit.dart';


const _categoryIcon = Icons.cake;
final _backgroundColor = Colors.green[100];

/// Category Screen (screen).
///
/// This is the 'home' screen of the Unit Converter. It shows a header and
/// a list of [Categories].
///


class CategoryScreen extends StatefulWidget {
  const CategoryScreen();

  @override
  State<StatefulWidget> createState() {
    return new _CategoryScreenState();
  }
}

class _CategoryScreenState extends State<CategoryScreen>{

 static const _categoryNames = <String>[
    'Length',
    'Area',
    'Volume',
    'Mass',
    'Time',
    'Digital Storage',
    'Energy',
    'Currency',
  ];

  static const _baseColors = <Color>[
    Colors.teal,
    Colors.orange,
    Colors.pinkAccent,
    Colors.blueAccent,
    Colors.yellow,
    Colors.greenAccent,
    Colors.purpleAccent,
    Colors.red,
  ];

  /// For portrait, we construct a [ListView] from the list of category widgets.
  Widget _buildCategoryWidgets(List<Widget> categories) {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) => categories[index],
      itemCount: categories.length,
    );
  }

  Widget _buildList() => ListView(
        children: <Widget>[
          for(int i=0; i<_categoryNames.length; i++) Category(
                name: _categoryNames[i],
                color: _baseColors[i],
                iconLocation: _categoryIcon),
        ],

      );

  /// Returns a list of mock [Unit]s.
  List<Unit> _retrieveUnitList(String categoryName) {
    return List.generate(10, (int i) {
      i += 1;
      return Unit(
        name: '$categoryName Unit $i',
        conversion: i.toDouble(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Create a list of the eight Categories, using the names and colors
    // from above. Use a placeholder icon, such as `Icons.cake` for each
    // Category. We'll add custom icons later.

    final categories = <Category>[];

    for (var i = 0; i < _categoryNames.length; i++) {
      categories.add(Category(
        name: _categoryNames[i],
        color: _baseColors[i],
        iconLocation: Icons.cake,
        units: _retrieveUnitList(_categoryNames[i]),
      ));
    }
    final listView = Container(child: _buildCategoryWidgets(categories), color: _backgroundColor, padding: EdgeInsets.symmetric(horizontal: 8.0),);

    
    final appBar = AppBar(
      elevation: 0.0,
      title: Text("Unit Conveter",
      style: TextStyle(fontSize: 30.0, color: Colors.black, ),),
      backgroundColor: _backgroundColor,
      centerTitle: true,

    );

    return Scaffold(
      appBar: appBar,
      body: listView,
    );
  }
}
