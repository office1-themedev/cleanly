import 'dart:convert';
import 'package:cleanly_dashboard/service/auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:velocity_x/velocity_x.dart';
import 'dashboard.dart';

class CleanlyHistory extends StatefulWidget {
  const CleanlyHistory({Key ? key}) : super(key: key);

  @override
  _CleanlyHistoryState createState() => _CleanlyHistoryState();
}
String ? baseUrl;
String ? apiKey;
String appData = '';

Map appDataJson = {};
List dateData = [];

List<Widget> _buildRowWidgets(BuildContext context,int limit,List data) {
  List<Widget> rows =[]; // Add an empty Container as a default widget
  for (int k = 0; k < limit-1; k++) {
    //print(data[0]['data'][k]['status']);
    rows.add(
      Column(
        children: [
            Container(
              decoration: BoxDecoration(
                border: Border.symmetric(horizontal: BorderSide(width: 0.1)),
              ),
              padding: EdgeInsets.all(3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            data[0]['data'][k]['status'].toString().split(' - ')[0].toString().text.fontFamily('Bricolage').make(),
                            // ' - '.text.fontFamily('Bricolage').make(),
                            // data[0]['data'][k]['status'].toString().split(' - ')[1].toString().text.fontFamily('Bricolage').make(),
                          ],
                        ),
                        data[0]['data'][k]['status'].toString().split(' - ')[1].toString().text.fontFamily('Bricolage').make(),
                        data[0]['data'][k]['status'].toString().split(' - ')[2].toString().text.tight.size(AdaptiveTextSize().getadaptiveTextSize(context, 12)).fontFamily('Bricolage').make(),
                      ],
                    ),
                  ),
                  Expanded(flex:1,child: data[0]['data'][k]['subtoal'].toString().text.center.tight.size(AdaptiveTextSize().getadaptiveTextSize(context, 12)).fontFamily('Bricolage').make()),
                  Expanded(flex:1,child: data[0]['data'][k]['discount'].toString().text.center.tight.size(AdaptiveTextSize().getadaptiveTextSize(context, 12)).fontFamily('Bricolage').make()),
                  Expanded(flex:1,child: data[0]['data'][k]['tax'].toString().text.center.tight.size(AdaptiveTextSize().getadaptiveTextSize(context, 12)).fontFamily('Bricolage').make()),
                  Expanded(flex:1,child: data[0]['data'][k]['total'].toString().text.center.tight.size(AdaptiveTextSize().getadaptiveTextSize(context, 12)).fontFamily('Bricolage').make()),
                  Expanded(flex:1,child: data[0]['data'][k]['deposit'].toString().text.center.tight.size(AdaptiveTextSize().getadaptiveTextSize(context, 12)).fontFamily('Bricolage').make()),
                  Expanded(flex:1,child: data[0]['data'][k]['due'].toString().text.center.tight.size(AdaptiveTextSize().getadaptiveTextSize(context, 12)).fontFamily('Bricolage').make()),
                ],
              ),
            )
        ],
      ) // ending bracket of container
    ); // ending bracket of add function
  } // ending bracket of for loop
  return rows;
}

class _CleanlyHistoryState extends State<CleanlyHistory>{

// call Auth method
  CleanlyAuth authClass = CleanlyAuth();

  // data table
  String dropdownValue = 'this_month';
  String titleReport = 'History Reports';
  String periodReport = 'Reporting Period:';
  String bodyMessage = '';
  List<dynamic> tbody = [];
  List tfoot = [];

  // api response
  String stringResponse = '';
  String returnType = 'error';
  Map mapResponse = {};

  Future<void> getApi(String period) async {
    showDialog(context: context, builder: (context){
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(backgroundColor: Colors.transparent,color: Colors.blue,),
            // SizedBox(height: 20,),
            // Text('Rotate device horizontally for better view...',style: TextStyle(fontFamily: 'Bricolage',color: Colors.white,fontSize:16,),)
          ],
        ),
      );
    });
    try{
      http.Response response = await http.post(
          Uri.parse('${baseUrl}cleanly/v1/history'),
          body: {
            'key': apiKey,
            'period': period,
          }
      );
      if( response.statusCode == 200){
        mapResponse = json.decode(response.body);
        returnType = (mapResponse['type']) ?? 'error';
        var data = (mapResponse['data']) ?? [];
        stringResponse = data.toString();
        if( returnType == 'success') {

          setState(() {
            bodyMessage = '';
            //titleReport = (data['title']) ?? '';
            periodReport = (data['period']).split('Reporting Period: ')[1].toString() ?? '';

            if(data.containsKey('thead')){
              //thead = (data['thead']) ?? [];
              tbody = (data['tbody']) ?? [];
              tfoot = (data['tfoot']) ?? [];
            }else{
              bodyMessage = 'Not Found any Data';
              tbody = [];
              tfoot = [];
            }

          });
        } else{
          setState(() {
            bodyMessage = stringResponse;
          });
        }
      } else{
        setState(() {
          bodyMessage = 'Failed API Request';
        });
      }
    } catch(e){
      //
    }
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    dropdownValue = 'this_month';
    checkLoginData();
  }

  checkLoginData() async {
    baseUrl = await authClass.getStorage('base_url');
    apiKey = await authClass.getStorage('api_key');
    appData = await authClass.getStorage('app_data');
    if (appData != null) {
      appDataJson = jsonDecode(appData);
      dateData = (appDataJson['period']) ?? [];

      // load api
      getApi(dropdownValue);
    }
  }

  @override
  Widget build(BuildContext context){
    ScrollController verticalController = ScrollController();
    ScrollController horizontalController = ScrollController();

    List<Widget> cards = [];
    List<Widget> foot = [];

    for (int i = 0; i < tbody.length; i++) {
      // else {
      //print(tbody[0]);
      //print(tbody[2][0]['data'][0]['status']);
      cards.add(
        VxBox(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            tbody[i][0]['order_no']
                                .toString()
                                .text.tight.size(AdaptiveTextSize().getadaptiveTextSize(context, 12)).center
                                .fontFamily('Bricolage')
                                .make(),
                            tbody[i][0]['date']
                                .toString()
                                .text.center
                                .tight.size(AdaptiveTextSize().getadaptiveTextSize(context, 12))
                                .fontFamily('Bricolage')
                                .make(),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 8,
                        child: Column(
                          children: _buildRowWidgets(context,tbody[i][0]['rows'],tbody[i]),
                        ),
                      )

                    ],
                  ),
                ]
              ),
            )
        ).white
            .neumorphic(elevation: 3)
            .margin(EdgeInsets.all(0))
            .p1
            .make(),
      );
      }

    if (cards.length == tbody.length && cards.length > 0) {
      foot.add(
        VxBox(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 3,
                    child: tfoot[0]
                        .toString()
                        .text.center.bold
                        .fontFamily('Bricolage')
                        .make(),
                  ),
                  Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(flex: 1, child: tfoot[1]
                                  .toString()
                                  .text
                                  .center.bold
                                  .size(AdaptiveTextSize().getadaptiveTextSize(context, 12)).tight
                                  .fontFamily('Bricolage')
                                  .make()),
                              Expanded(flex: 1, child: tfoot[2]
                                  .toString()
                                  .text
                                  .center.bold
                                  .size(AdaptiveTextSize().getadaptiveTextSize(context, 12)).tight
                                  .fontFamily('Bricolage')
                                  .make()),
                              Expanded(flex: 1, child: tfoot[3]
                                  .toString()
                                  .text
                                  .center.bold
                                  .size(AdaptiveTextSize().getadaptiveTextSize(context, 12)).tight
                                  .fontFamily('Bricolage')
                                  .make()),
                              Expanded(flex: 1, child: tfoot[4]
                                  .toString()
                                  .text
                                  .center.bold
                                  .size(AdaptiveTextSize().getadaptiveTextSize(context, 12)).tight
                                  .fontFamily('Bricolage')
                                  .make()),
                              Expanded(flex: 1, child: tfoot[5]
                                  .toString()
                                  .text
                                  .center.bold
                                  .size(AdaptiveTextSize().getadaptiveTextSize(context, 12)).tight
                                  .fontFamily('Bricolage')
                                  .make()),
                              Expanded(flex: 1, child: tfoot[6]
                                  .toString()
                                  .text
                                  .center.bold
                                  .size(AdaptiveTextSize().getadaptiveTextSize(context, 12)).tight
                                  .fontFamily('Bricolage')
                                  .make()),
                            ],
                          ),
                        ],
                      ))
                ],
              ),
            )
        ).gray100
            .neumorphic(elevation: 1).bottomRounded(value: 15)
            .margin(EdgeInsets.all(0))
            .p1
            .make(),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child:
                    Padding(
                        padding: const EdgeInsets.all(10.0),
                        child:
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(titleReport, style: TextStyle( fontWeight: FontWeight.w500,fontFamily: 'Bricolage', fontSize: 18, color: Colors.black)),
                            Text(periodReport, style: TextStyle( fontWeight: FontWeight.w400,fontFamily: 'Bricolage', fontSize: 13, color: Colors.black)),
                          ],
                        )
                    ),
                  ),
                ),
                Align(
                    alignment: Alignment.topRight,
                    child:
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child:
                      DropdownMenu<String>(
                        initialSelection: dropdownValue,
                        onSelected: (String? value) {
                          // This is called when the user selects an item.
                          setState(() {
                            dropdownValue = value!;
                            getApi(dropdownValue);
                          });
                        },
                        width: 200,
                        hintText: 'Date Period',
                        dropdownMenuEntries: dateData.map<DropdownMenuEntry<String>>((list){
                          return DropdownMenuEntry<String>(value: list['id'], label: list['value']);
                        }).toList(),
                      ),
                    )
                ),
              ],
            ),

            Align(
              alignment: Alignment.center,
              child:
              Padding(
                  padding: const EdgeInsets.all(5.0),
                  child:
                  Column(
                    children: [
                      Text(bodyMessage!, style: TextStyle( fontWeight: FontWeight.w500,fontFamily: 'Bricolage', fontSize: 18, color: Colors.black)),
                    ],
                  )
              ),
            ),
            VxBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(flex:1, child: 'ID & Date'.text.center.tight.size(AdaptiveTextSize().getadaptiveTextSize(context, 12)).bold.fontFamily('Bricolage').make(),),
                    SizedBox(width: 5,),
                    Expanded(flex:2, child: 'Status'.text.start.tight.size(AdaptiveTextSize().getadaptiveTextSize(context, 12)).bold.fontFamily('Bricolage').make(),),
                    Expanded(flex:1,child: 'Subtotal'.text.center.tight.size(AdaptiveTextSize().getadaptiveTextSize(context, 12)).bold.fontFamily('Bricolage').make(),),
                    Expanded(flex:1,child: 'Discount'.text.tight.size(AdaptiveTextSize().getadaptiveTextSize(context, 12)).center.bold.fontFamily('Bricolage').make(),),
                    Expanded(flex:1,child: 'Tax'.text.tight.size(AdaptiveTextSize().getadaptiveTextSize(context, 12)).center.bold.fontFamily('Bricolage').make(),),
                    Expanded(flex:1,child: 'Net Total'.text.tight.size(AdaptiveTextSize().getadaptiveTextSize(context, 12)).center.bold.fontFamily('Bricolage').make(),),
                    Expanded(flex:1,child: 'Deposit'.text.tight.size(AdaptiveTextSize().getadaptiveTextSize(context, 12)).center.bold.fontFamily('Bricolage').make(),),
                    Expanded(flex:1,child: 'Due'.text.tight.size(AdaptiveTextSize().getadaptiveTextSize(context, 12)).center.bold.fontFamily('Bricolage').make(),),
                  ],
                )
            ).white.topRounded(value: 15).neumorphic(elevation: 3).margin(EdgeInsets.only(bottom: 3,top: 5)).p3.make(),
            Container(
              child: Column(children: cards+foot),
            )
          ]
      ),

    );
  }

}