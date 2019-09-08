import 'dart:async';
import 'dart:io';
import 'dart:convert' show utf8, json;
import 'unit.dart';

/**
 * APi class used to query data for conversion of one unit to another
 */
class Api{

  final _httpClient = HttpClient();
  final _url = 'flutter.udacity.com';

  /// Gets all the units and conversion rates for a given category.
  /// The `category` parameter is the name of the [Category] from which to
  /// retrieve units. We pass this into the query parameter in the API call.
  /// Returns a list. Returns null on error.
  Future<List> getUnits(String category) async{
    final uri = Uri.https(_url, '/$category');
    final jsonResponse = await _getJson(uri);
    if (jsonResponse == null || jsonResponse['units'] == null) {
      print('Error retrieving units.');
      return null;
    }
    return jsonResponse['units'];

  }

  /// Given two units, converts from one to another.
  /// Returns a double, which is the converted amount. Returns null on error.
  Future<double> convert(String categoryName, String amount, String unitFrom, String unitTo) async{
    final uri = Uri.https(_url, '$categoryName/convert', {'amount': amount, 'from': unitFrom, 'to': unitTo});
    final httpRequest = await _httpClient.getUrl(uri);
    final httpResponse = await httpRequest.close();
    if(httpResponse.statusCode != HttpStatus.ok){
      return null;
    }
    final responseBody = await httpResponse.transform(utf8.decoder).join();
    final jsonResponse = json.decode(responseBody);
    return jsonResponse['conversion'].toDouble();

  }


  /// Fetches and decodes a JSON object represented as a Dart [Map].
  ///
  /// Returns null if the API server is down, or the response is not JSON.
  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final httpRequest = await _httpClient.getUrl(uri);
      final httpResponse = await httpRequest.close();
      if (httpResponse.statusCode != HttpStatus.ok) {
        return null;
      }
      // The response is sent as a Stream of bytes that we need to convert to a
      // `String`.
      final responseBody = await httpResponse.transform(utf8.decoder).join();
      // Finally, the string is parsed into a JSON object.
      return json.decode(responseBody);
    } on Exception catch (e) {
      print('$e');
      return null;
    }
  }

}