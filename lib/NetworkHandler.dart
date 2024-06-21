import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class Networkhandler {
  String baseurl = "http://192.168.31.153:5000";

  Future<dynamic> get(String url) async {
    url = formater(url);
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200 || response.statusCode == 201) {
      log(response.body);
      return jsonDecode(response.body);
    } else {
      log(response.body);
      log(response.statusCode.toString());
    }
  }

  Future<dynamic> post(String url, Map<String, String> body) async {
    url = formater(url);
    var response = await http.post(Uri.parse(url),
        headers: {"Content-type": "application/json"}, body: jsonEncode(body));
    if (response.statusCode == 200 || response.statusCode == 201) {
      log(response.body);
      return response;
    }
    log(response.body);
    log(response.statusCode.toString());
  }

  String formater(String url) {
    return baseurl + url;
  }
}
