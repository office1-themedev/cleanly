import 'dart:convert';
import 'package:cleanly_dashboard/service/auth.dart';
import 'package:cleanly_dashboard/pages/include/refund.dart';
import 'package:cleanly_dashboard/pages/include/dashboard.dart';
import 'package:cleanly_dashboard/pages/include/history.dart';
import 'package:cleanly_dashboard/pages/include/booking.dart';
import 'package:cleanly_dashboard/pages/include/sale.dart';
import 'package:cleanly_dashboard/pages/include/due.dart';
import 'package:cleanly_dashboard/pages/include/deposit.dart';
import 'package:cleanly_dashboard/pages/include/income.dart';
import 'package:cleanly_dashboard/pages/include/tax.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';


class CleanlyHome extends StatefulWidget {
  const CleanlyHome({Key ? key}) : super(key: key);

  @override
  _CleanlyHomeState createState() => _CleanlyHomeState();
}

String ? baseUrl;
String ? apiKey;
String appData = '';
String ? appName = 'Cleanly Booking';
String? appDetails = 'Cleaning booking plugin';
String? appLogo = '';

Map appDataJson = {};

class _CleanlyHomeState extends State<CleanlyHome>{

  // call Auth method
  CleanlyAuth authClass = CleanlyAuth();

  // snackbar alert message
  CleanlySnackBar(message,context){
    return ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message))
    );
  }

  @override
  void initState() {
    super.initState();
    checkLoginData();
  }

  checkLoginData() async {
    baseUrl = await authClass.getStorage('base_url');
    apiKey = await authClass.getStorage('api_key');
    appData = await authClass.getStorage('app_data');
    if(appData != null){
      appDataJson = jsonDecode(appData);
      appName = (appDataJson['apps_name']) ?? '';
      appDetails = (appDataJson['apps_details']) ?? '';
      appLogo = (appDataJson['apps_logo']['url']) ?? '';
    }
  }

  int _selectedIndex = 0;
  Widget _selectWidget = const CleanlyDashboard();
  String _selectAppTitle = 'Dashboard';

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context){
    //print(appName);
    return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: '${_selectAppTitle}'.text.fontFamily('Bricolage').bold.make(),
            // style: TextStyle(
            //   fontFamily: 'Bricolage',
            // ),
            titleSpacing: 10,
            toolbarHeight: 60,
            toolbarOpacity: 1,
            elevation: 0,
            backgroundColor: Colors.lightBlue,
            centerTitle: true,
            foregroundColor: Colors.white,
            shadowColor: Colors.cyan,
            actions: [
              IconButton(
                onPressed: (){
                  authClass.deleteAllStorage(context);
                },
                icon: Icon(Icons.logout),
              ),
            ],
          ),
          drawer: Drawer(
            backgroundColor: Colors.white,
            child: ListView(
              children: [
                DrawerHeader(
                    padding: EdgeInsets.all(0),
                    margin: EdgeInsets.all(0),
                    child: UserAccountsDrawerHeader(
                      decoration: BoxDecoration(color: Colors.blue,gradient: LinearGradient(colors: [Colors.blue.shade900,Colors.lightBlueAccent])),
                      accountName: Text('${appName}', style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontFamily: 'Bricolage'),),
                      accountEmail: Text('${appDetails}', style: TextStyle(color: Colors.white60,fontFamily: 'Bricolage',fontSize: 12),),
                      currentAccountPicture: Image.network(
                        appLogo!,
                        width: 80,
                        fit: BoxFit.contain,
                      ),
                      /*onDetailsPressed: (){
                        CleanlySnackBar("Account Details", context);
                      },*/
                    )
                ),
                ListTile(
                  //leading: Icon(Icons.dashboard_outlined),
                  leading: Image.asset('assets/images/dashboard.png',height: 25,width: 25,),
                  title: Text("Dashboard",style: TextStyle(fontFamily: 'Bricolage',fontWeight: FontWeight.bold,),),
                  onTap: (){
                    setState(() {
                      _selectWidget = const CleanlyDashboard();
                      _selectAppTitle = 'Dashboard';
                      _selectedIndex = 0;
                    },
                    );
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  //leading: Icon(Icons.summarize_outlined),
                  leading: Image.asset('assets/images/booking.png',height: 25,width: 25,),
                  title: Text("Booking Summery",style: TextStyle(fontFamily: 'Bricolage',fontWeight: FontWeight.bold,),),
                  onTap: (){
                    setState(() {
                      _selectWidget = const CleanlyBooking();
                      _selectAppTitle = 'Booking Summery';
                      _selectedIndex = 2;
                     }
                    );
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  //leading: Icon(Icons.sell_outlined),
                  leading: Image.asset('assets/images/sale.png',height: 25,width: 25,),
                  title: Text("Sale Reports",style: TextStyle(fontFamily: 'Bricolage',fontWeight: FontWeight.bold,),),
                  onTap: (){
                    setState(() {
                      _selectAppTitle = 'Sale reports';
                      _selectWidget = const CleanlySale();
                      _selectedIndex = 1;
                      }
                    );
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  //leading: Icon(Icons.pending_actions),
                  leading: Image.asset('assets/images/due.png',height: 25,width: 25,),
                  title: Text("Due Reports",style: TextStyle(fontFamily: 'Bricolage',fontWeight: FontWeight.bold,),),
                  onTap: (){
                    setState(() {
                      _selectAppTitle = 'Due reports';
                      _selectWidget = const CleanlyDue();
                      _selectedIndex = 0;
                      }
                    );
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  //leading: Icon(Icons.done_all_sharp),
                  leading: Image.asset('assets/images/deposit.png',height: 25,width: 25,),
                  title: Text("Deposit Reports",style: TextStyle(fontFamily: 'Bricolage',fontWeight: FontWeight.bold,),),
                  onTap: (){
                    setState(() {
                      _selectAppTitle = 'Deposit reports';
                      _selectWidget = const CleanlyDeposit();
                      _selectedIndex = 0;
                      }
                    );
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  //leading: Icon(Icons.monetization_on_outlined),
                  leading: Image.asset('assets/images/income.png',height: 25,width: 25,),
                  title: Text("Income Reports",style: TextStyle(fontFamily: 'Bricolage',fontWeight: FontWeight.bold,),),
                  onTap: (){
                    setState(() {
                      _selectAppTitle = 'Income reports';
                      _selectWidget = const CleanlyIncome();
                      _selectedIndex = 0;
                      }
                    );
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  //leading: Icon(Icons.call_to_action_outlined),
                  leading: Image.asset('assets/images/tax.png',height: 25,width: 25,),
                  title: Text("Tax Reports",style: TextStyle(fontFamily: 'Bricolage',fontWeight: FontWeight.bold,),),
                  onTap: (){
                    setState(() {
                      _selectAppTitle = 'Tax reports';
                      _selectWidget = const CleanlyTax();
                      _selectedIndex = 0;
                      }
                    );
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  //leading: Icon(Icons.refresh),
                  leading: Image.asset('assets/images/refund.png',height: 25,width: 25,),
                  title: Text("Refund History",style: TextStyle(fontFamily: 'Bricolage',fontWeight: FontWeight.bold,),),
                  onTap: (){
                    setState(() {
                      _selectAppTitle = 'Refund History';
                      _selectWidget = const CleanlyRefund();
                      _selectedIndex = 0;
                    }
                    );
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  //leading: Icon(Icons.list),
                  leading: Image.asset('assets/images/history.png',height: 25,width: 25,),
                  title: Text("Order History",style: TextStyle(fontFamily: 'Bricolage',fontWeight: FontWeight.bold,),),
                  onTap: (){
                    setState(() {
                      _selectWidget = const CleanlyHistory();
                      _selectAppTitle = 'Order History';
                      _selectedIndex = 3;
                      },
                    );
                    Navigator.pop(context);
                  },
                ),
                // ListTile(
                //   leading: Icon(Icons.settings_outlined),
                //   title: Text("Settings",style: TextStyle(fontFamily: 'Bricolage'),),
                //   onTap: (){
                //      setState(() {
                //        _selectAppTitle = 'Settings';
                //        _selectedIndex = 0;
                //       }
                //      );
                //      Navigator.pop(context);
                //   },
                // ),
              ],
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            //backgroundColor: Colors.blue,
            iconSize: 20,
            elevation: 10.0,
            selectedFontSize: 13,
            selectedLabelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,fontFamily: 'Bricolage'),
            showSelectedLabels: true,
            showUnselectedLabels: true,
            unselectedItemColor: Colors.black,
            items: [
              BottomNavigationBarItem(icon: Image.asset('assets/images/dashboard-black.png',height: 25,width: 25,), label: 'Dashboard', backgroundColor: Colors.grey[200],),
              BottomNavigationBarItem(icon: Image.asset('assets/images/sale-black.png',height: 25,width: 25,), label: 'Sale'),
              BottomNavigationBarItem(icon: Image.asset('assets/images/booking-black.png',height: 25,width: 25,),label: 'booking'),
              BottomNavigationBarItem(icon: Image.asset('assets/images/history-black.png',height: 25,width: 25,),label: 'History')
            ],
            selectedItemColor: Colors.blue[600],
            
            onTap: (int index){
              if(index == 0){
                _selectWidget = const CleanlyDashboard();
                _selectAppTitle = 'Dashboard';
              }else if( index == 1){
                _selectWidget = const CleanlySale();
                _selectAppTitle = 'Sale Reports';
              }else if( index == 2){
                _selectWidget = const CleanlyBooking();
                _selectAppTitle = 'Booking Summery';
              }else if( index == 3){
                _selectWidget = const CleanlyHistory();
                _selectAppTitle = 'Order History';
              }
              setState(() {
                  _selectedIndex = index;
                },
              );
            },
          ),
          body: _selectWidget,
        )
    );
  }

}
