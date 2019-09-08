import 'package:flutter/material.dart';

import 'category.dart';
import 'converter_screen.dart';

final _rowHeight = 100.0;
final _borderRadius = BorderRadius.circular(_rowHeight / 2);

class CategoryTile extends StatelessWidget {
  final Category category;
  final ValueChanged<Category> onTap;

  /// The [CategoryTile] shows the name and color of a [Category] for unit
  /// conversions.

  /// Creates a [CategoryTile].

  /// Tapping on it brings you to the unit converter.
  const CategoryTile({
    Key key,
    @required this.category,
    @required this.onTap,
  })  : assert(category != null),
        super(key: key);

  /// Navigates to the ConverterScreen.
  void _navigateToConverter(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    Navigator
        .of(context)
        .push(MaterialPageRoute<Null>(builder: (context) =>
        Scaffold(
          resizeToAvoidBottomPadding: false,
          appBar: AppBar(
            title: Text(category.name, style: Theme.of(context).textTheme.display1,),
            centerTitle: true,
            backgroundColor: category.color,),
          body: ConverterScreen(category: category),
          // This prevents the attempt to resize the screen when the keyboard is opened
        resizeToAvoidBottomInset: false,),));

    }

  /// Builds a custom widget that shows [CategoryTile] information.
  ///
  /// This information includes the icon, name, and color for the [CategoryTile].
  @override
  Widget build(BuildContext context) {
    return Material(
      color:
      onTap == null ? Color.fromRGBO(50, 50, 50, 0.2) : Colors.transparent,
      child: Container(
        height: _rowHeight,
        child: InkWell(
            borderRadius: _borderRadius,
            highlightColor: category.color['highlight'],
            splashColor: category.color['splash'],
            // We can use either the () => function() or the () { function(); }
            // syntax.
            onTap: (onTap == null)? null :() {
              onTap(category);
            },
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: category.iconLocation != null?
                    Image.asset(category.iconLocation, width: 60.0,) : null,
                  ),
                  Center(
                    child: Text(
                      category.name,
                      textAlign: TextAlign.center,
                      style: Theme
                          .of(context)
                          .textTheme
                          .headline,
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }
}
