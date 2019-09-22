// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import './category_tile.dart';
import './unit.dart';
import 'api.dart';
import 'backdrop.dart';
import 'category.dart';
import 'converter_screen.dart';
import 'util.dart';

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

class _CategoryScreenState extends State<CategoryScreen> {
  Category _defaultCategory;
  Category _currentCategory;
  final _categories = <Category>[];





  //We use didChangeDependencies() so that we can
  //wait for our JSON asset to be loaded in (async).
  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    // We have static unit conversions located in our
    // assets/data/regular_units.json
    if (_categories.isEmpty) {
      await _retrieveLocalCategories();
      await _retrieveApiCategories();
    }
  }

  /// Retrieves a list of [Categories] and their [Unit]s
  Future<void> _retrieveLocalCategories() async {
    // Consider omitting the types for local variables. For more details on Effective
    // Dart Usage, see https://www.dartlang.org/guides/language/effective-dart/usage
    final json = DefaultAssetBundle.of(context)
        .loadString('assets/data/regular_units.json');
    final data = JsonDecoder().convert(await json);
    if (data is! Map) {
      throw ('Data retrieved from API is not a Map');
    }
    var categoryIndex = 0;
    for (var key in data.keys) {
      final List<Unit> units =
          data[key].map<Unit>((dynamic data) => Unit.fromJson(data)).toList();
      var category = Category(
        name: key,
        color: Util.baseColors[categoryIndex],
        iconLocation: Util.iconLocation[categoryIndex],
        units: units,
      );
      setState(() {
        if (categoryIndex == 0) {
          _defaultCategory = category;
        }
        _categories.add(category);
      });
      categoryIndex += 1;
    }
  }

  Future<void> _retrieveApiCategories() async {
    setState(() {
      _categories.add(Category(name: 'Currency', color: Util.baseColors.last, units: [], iconLocation: Util.iconLocation.last));
    });
    final jsonUnits = await Api().getUnits('currency');
    // If the API errors out or we have no internet connection, this category
    // remains in placeholder mode (disabled)
    if (jsonUnits != null) {
      final units = <Unit>[];
      for (var unit in jsonUnits) {
        units.add(Unit.fromJson(unit));
      }
      setState(() {
        _categories.removeLast();
        _categories.add(Category(
          name: 'Currency',
          units: units,
          color: Util.baseColors.last,
          iconLocation: Util.iconLocation.last,
        ));
      });
    }
  }
  // Function to call when a [Category] is tapped.
  void _onCategoryTap(Category category) {
    setState(() {
      _currentCategory = category;
    });
  }

  /// For portrait, we construct a [ListView] from the list of category widgets.
  Widget _buildCategoryWidgets(Orientation deviceOrientation) {
    if (deviceOrientation == Orientation.portrait) {
      return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return CategoryTile(
              category: _categories[index],
              onTap: (_categories[index].name == 'Currency' && _categories[index].units.isEmpty)? null : _onCategoryTap);
        },
        itemCount: _categories.length,
      );
    } else {
      return GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 3,
        children: _categories.map((Category cat) {
          return CategoryTile(
            category: cat,
            onTap: _onCategoryTap,
          );
        }).toList(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_categories.isEmpty) {
      return Center(
        child: Container(
          height: 180,
          width: 180,
          child: CircularProgressIndicator(),
        ),
      );
    }

    assert(debugCheckHasMediaQuery(context));
    final listView = Padding(
      padding: EdgeInsets.only(
        left: 8.0,
        right: 8.0,
        bottom: 48.0,
      ),
      child: _buildCategoryWidgets(MediaQuery.of(context).orientation),
    );

    return Backdrop(
      currentCategory:
          _currentCategory == null ? _defaultCategory : _currentCategory,
      frontPanel: _currentCategory == null
          ? ConverterScreen(category: _defaultCategory)
          : ConverterScreen(category: _currentCategory),
      backPanel: listView,
      frontTitle: Text('Unit Converter'),
      backTitle: Text('Select a Category'),
    );
  }
}
