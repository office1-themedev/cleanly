import 'dart:convert';
//import 'dart:js_util';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


void main() {
  runApp(const CleanlyApp());
}


class CleanlyApp extends StatelessWidget {
  const CleanlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CleanlyHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

String stringResponse = '';
Map mapResponse = {};
List listResponse = [];

class CleanlyHome extends StatefulWidget{
  @override
  _CleanlyHomeState createState() => _CleanlyHomeState();
}

class _CleanlyHomeState extends State<CleanlyHome>{

  //snackBar function
  CleanlySnackBar(message,context){
    return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message))
    );
  }

  // order list api
  Future CleanlyOrderList() async{
    http.Response response;
    response = await http.get(Uri.parse("https://reqres.in/api/users?page=2"));
    if( response.statusCode == 200){
      setState((){
        stringResponse = response.body;
        mapResponse = json.decode(response.body);
        listResponse = (mapResponse['data']) ?? [];
      });
    }
  }

  @override
  void initState() {
    CleanlyOrderList();
    super.initState();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cleanly Home'),
        titleSpacing: 10,
        // centerTitle: true,
        toolbarHeight: 60,
        toolbarOpacity: 1,
        elevation: 6,
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            onPressed: (){CleanlySnackBar("Settings", context);},
            icon: Icon(Icons.settings),
          ),
          IconButton(
              onPressed: (){},
              icon: Icon(Icons.home)
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          elevation: 10,
          child: Icon(Icons.add),
          backgroundColor: Colors.blue,
          onPressed: (){
            CleanlySnackBar("Action Button", context);
          }
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Order"),
        ],
        onTap: (int index){
          if(index == 0){
            CleanlySnackBar("Home Bottom Action", context);
          }else if( index == 1){
            CleanlySnackBar("Settings Bottom Action", context);
          }else if( index == 2){
            CleanlySnackBar("Order Bottom Action", context);
          }
        },
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
                padding: EdgeInsets.all(0),
                child: UserAccountsDrawerHeader(
                  decoration: BoxDecoration(color: Colors.blue),
                  accountName: Text("Cleanly Admin", style: TextStyle(color: Colors.white),),
                  accountEmail: Text("Info@themedev.net"),
                  currentAccountPicture: Image.network("https://docs.flutter.dev/cookbook/img-files/effects/split-check/Avatar1.jpg"),
                  onDetailsPressed: (){CleanlySnackBar("Account Details", context);},
                )
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: (){
                CleanlySnackBar("List Home", context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: (){
                CleanlySnackBar("List Settings", context);
              },
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text("Order"),
              onTap: (){
                CleanlySnackBar("List Order", context);
              },
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: (listResponse == null) ? 0 : listResponse.length,
        itemBuilder: (context, index) {
          return Container(
            child: Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.network(listResponse[index]['avatar'])
                  ),
                  Text(listResponse[index]['id'].toString()),
                  Text(listResponse[index]['email'].toString()),
                  Text(listResponse[index]['first_name'].toString()),
                  Text(listResponse[index]['last_name'].toString()),
                ]
            ),
          );
        },

      ),

    );
  }
}