import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cleanly_dashboard/pages/login.dart';
import 'package:cleanly_dashboard/pages/home.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CleanlyAuth{

  // Create storage
  final storage = new FlutterSecureStorage();
  late String _output;

  // snackbar alert message
  CleanlySnackBar(message,context){
    return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message))
    );
  }

  String stringResponse = '';
  String returnType = 'error';
  Map mapResponse = {};
  // login function
  Future<void> login(BuildContext context, String base, String apikey) async {
    showDialog(context: context, builder: (context){
      return Center(child: CircularProgressIndicator(backgroundColor: Colors.transparent,color: Colors.blue,));
    });

    if( base == null || base.isEmpty || !base.contains('http')){
      CleanlySnackBar('Please enter valid base URL', context);
    }
    if( apikey == null || apikey.isEmpty){
      CleanlySnackBar('Please enter valid API Key', context);
    }

    try{
      http.Response response = await http.post(
          Uri.parse('${base}cleanly/v1/appdata'),
          body: {
            'key': apikey,
          }
      );
      if( response.statusCode == 200){
        mapResponse = json.decode(response.body);
        returnType = (mapResponse['type']) ?? 'error';
        var data = (mapResponse['data']) ?? [];
        stringResponse = data.toString();
        if( returnType == 'success'){
          await saveStorage('base_url', base);
          await saveStorage('api_key', apikey);
          await saveStorage('app_data', jsonEncode(data));


          Navigator.of(context).pop();
          // load home page
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (builder) => CleanlyHome()), (route) => false
          );

          CleanlySnackBar('Successfully authentication', context);
        } else{
          CleanlySnackBar(stringResponse, context);
        }
      } else{
        CleanlySnackBar('Failed authentication', context);
      }
    } catch(e){
      CleanlySnackBar(e.toString(), context);
    }

    //var url = dotenv.get('BASE_URL', fallback: 'No found');
  }

  // save storage function
  Future<void> saveStorage(String key, String value) async{
    // Write value
    await storage.write(key: key, value: value);
  }

  // get storage function
  Future<String> getStorage(String key) async{
    // Write value
    String? _output = (await storage.read(key: key))!;
    return _output;
  }

  // delete storage function
  Future<void> deleteStorage(String key) async{
    // delete value
    await storage.delete(key: key);
  }

  // delete all storage function
  Future<void> deleteAllStorage(BuildContext context) async{
    // delete all value
    await storage.deleteAll();
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (builder) => ApiScreen()), (route) => false
    );
  }

}
