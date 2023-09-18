import 'dart:convert';
import 'package:cleanly_dashboard/service/auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:velocity_x/velocity_x.dart';

class CleanlyIncome extends StatefulWidget {
  const CleanlyIncome({Key ? key}) : super(key: key);

  @override
  _CleanlyIncomeState createState() => _CleanlyIncomeState();
}


String ? baseUrl;
String ? apiKey;
String appData = '';

Map appDataJson = {};
List dateData = [];

class _CleanlyIncomeState extends State<CleanlyIncome>{
  // call Auth method
  CleanlyAuth authClass = CleanlyAuth();

  // data table
  String dropdownValue = 'this_month';
  String titleReport = 'Income Reports';
  String periodReport = 'Reporting Period:';
  String bodyMessage = '';
  List thead = ['Order No.', 'Total', 'Deposit', 'Due', 'Income'];
  List tbody = [];
  List tfoot = [];

  // api response
  String stringResponse = '';
  String returnType = 'error';
  Map mapResponse = {};

  Future<void> getApi(String period) async {
    showDialog(context: context, builder: (context){
      return Center(child: CircularProgressIndicator(backgroundColor: Colors.transparent,color: Colors.blue,));
    });
    try{
      http.Response response = await http.post(
          Uri.parse('${baseUrl}cleanly/v1/income'),
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
              thead = (data['thead']) ?? [];
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
      cards.add(
        VxBox(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: tbody[i]['orders'][0]
                        .toString()
                        .text.size(12).center
                        .fontFamily('Bricolage')
                        .make(),
                  ),
                  Expanded(flex: 2, child: tbody[i]['orders'][1]
                      .toString()
                      .text.center.tight
                      .size(11)
                      .fontFamily('Bricolage')
                      .make(),),
                  Expanded(flex: 1, child: tbody[i]['total']
                      .toString()
                      .text
                      .center.tight
                      .size(12)
                      .fontFamily('Bricolage')
                      .make()),
                  Expanded(flex: 1, child: tbody[i]['deposit']
                      .toString()
                      .text
                      .center.tight
                      .size(12)
                      .fontFamily('Bricolage')
                      .make()),
                  Expanded(flex: 1, child: tbody[i]['due']
                      .toString()
                      .text
                      .center.tight
                      .size(12)
                      .fontFamily('Bricolage')
                      .make()),
                  Expanded(flex: 1, child: tbody[i]['income']
                      .toString()
                      .text
                      .center
                      .size(12)
                      .fontFamily('Bricolage')
                      .make())
                ],
              ),
            )
        ).white
            .neumorphic(elevation: 3)
            .margin(EdgeInsets.all(0))
            .p1
            .make(),
      );
      // }
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
                      flex: 4,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(flex: 1, child: tfoot[1]
                                  .toString()
                                  .text
                                  .center.bold.tight
                                  .size(12)
                                  .fontFamily('Bricolage')
                                  .make()),
                              Expanded(flex: 1, child: tfoot[2]
                                  .toString()
                                  .text
                                  .center.bold.tight
                                  .size(12)
                                  .fontFamily('Bricolage')
                                  .make()),
                              Expanded(flex: 1, child: tfoot[3]
                                  .toString()
                                  .text
                                  .center.bold.tight
                                  .size(12)
                                  .fontFamily('Bricolage')
                                  .make()),
                              Expanded(flex: 1, child: tfoot[4]
                                  .toString()
                                  .text
                                  .center.bold.tight
                                  .size(12)
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
                    Expanded(flex:1, child: 'ID'.text.center.size(12).bold.fontFamily('Bricolage').make(),),
                    Expanded(flex:2, child: 'Date'.text.center.size(12).bold.fontFamily('Bricolage').make(),),
                    Expanded(flex:1,child: 'Total'.text.center.size(12).bold.fontFamily('Bricolage').make(),),
                    Expanded(flex:1,child: 'Deposit'.text.size(12).center.bold.fontFamily('Bricolage').make(),),
                    Expanded(flex:1,child: 'Due'.text.size(12).center.bold.fontFamily('Bricolage').make(),),
                    Expanded(flex:1,child: 'Income'.text.size(12).center.bold.fontFamily('Bricolage').make(),),
                  ],
                )
            ).white.topRounded(value: 15).neumorphic(elevation: 3).margin(EdgeInsets.only(bottom: 3,top: 5)).p3.make(),
            SingleChildScrollView(
              child: Column(children: cards+foot),
            )
          ]
      ),

    );
  }

}