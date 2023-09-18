import 'dart:convert';
import 'package:cleanly_dashboard/pages/include/dashboard.dart';
import 'package:cleanly_dashboard/service/auth.dart';
import 'package:d_chart/commons/data_model.dart';
import 'package:d_chart/ordinal/bar.dart';
import 'package:d_chart/ordinal/pie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:row_item/row_item.dart';
import 'package:d_chart/d_chart.dart';
import 'package:velocity_x/velocity_x.dart';

//for text resizing according to screen size
class AdaptiveTextSize {
  const AdaptiveTextSize();

  getadaptiveTextSize(BuildContext context, dynamic value) {
    // 720 is medium screen height
    return (value / 720) * MediaQuery.of(context).size.width;
  }
}

class CleanlyDashboard extends StatefulWidget {
  const CleanlyDashboard({Key ? key}) : super(key: key);

  @override
  _CleanlyDashboardState createState() => _CleanlyDashboardState();
}

String ? baseUrl;
String ? apiKey;
String appData = '';

Map appDataJson = {};
List dateData = [];



class _CleanlyDashboardState extends State<CleanlyDashboard>{
  // call Auth method
  CleanlyAuth authClass = CleanlyAuth();
  //Function for splitting String for Booking History
  List SplitString (String raw,String pattern){
    return raw.split(pattern);
  }
  // data table
  String dropdownValue = 'this_month';
  String titleReport = 'Tax Reports';
  String periodReport = 'Reporting Period:';
  String bodyMessage = '';
  Map history = {};
  Map summeryPie = {};
  Map orderSummery = {};
  Map getwayData = {};

  // api response
  String stringResponse = '';
  String returnType = 'error';
  Map mapResponse = {};

  Future<void> getApiDashboard() async {
    showDialog(context: context, builder: (context){
      return Center(child: CircularProgressIndicator(backgroundColor: Colors.transparent,color: Colors.blue,));
    });
    try{
      http.Response response = await http.post(
          Uri.parse('${baseUrl}cleanly/v1/dashboard'),
          body: {
            'key': apiKey,
          },
      );
      if( response.statusCode == 200){
        mapResponse = json.decode(response.body);
        returnType = (mapResponse['type']) ?? 'error';
        var data = (mapResponse['data']) ?? [];
        stringResponse = data.toString();
        if( returnType == 'success') {
          setState(() {
            history = data['history'] as Map;
            summeryPie = data['summery_pie'] as Map;
            orderSummery = data['order_summery']  as Map;
            getwayData = data['getway'] as Map;
          });
        } else{
          bodyMessage = stringResponse;
        }
      } else{
        bodyMessage = stringResponse;
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
    checkLoginDash();
  }

  checkLoginDash() async {
    baseUrl = await authClass.getStorage('base_url');
    apiKey = await authClass.getStorage('api_key');
    appData = await authClass.getStorage('app_data');
    if (appData != null) {
      appDataJson = jsonDecode(appData);
      dateData = (appDataJson['period']) ?? [];
      // load api
      getApiDashboard();
    }
  }


  Widget get _spacer => const SizedBox(height: 12);
  Widget get _cardSpacer => const SizedBox(height: 4);

  Widget _buildRecent(BuildContext context, List<dynamic> row){
    if(row.isEmpty){
      return Container(
        child: Column(
          children: [
            Text('Not found'),
          ],
        ),
      );
    }

    List<Widget> items= [];
    for (int i = 0; i < row.length; i++) {
      List temp =[];
      temp = SplitString(row[i]['name'].toString(),' - ');
      items.add(
          Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          temp[1].toString().text.fontFamily('Bricolage').xl.black.make(),
                          Row(
                            children: [
                              Icon(Icons.mail,color: Colors.grey,size: 15,),
                              SizedBox(width: 5),
                              temp[0].toString().text.gray600.size(10).fontFamily('Bricolage').tight.thin.make(),
                            ],
                          ),
                        ],
                      ),
                      //Text((SplitString(row[i]['name'].toString()))[1].toString()),
                      //SizedBox(width: 10),
                      //Text((SplitString(row[i]['name'].toString()))[0].toString(),textAlign: TextAlign.center,),
                      Expanded(
                          child: Text(row[i]['amount'].toString(),textAlign: TextAlign.right, style: TextStyle( fontWeight: FontWeight.bold,fontFamily: 'Bricolage', fontSize: 18, color: Colors.blue,))),
                    ],
                  ),
                )
              ]
          )
      );
    }
    return Container(
        child: Wrap(
          spacing: 10.0,
          runSpacing: 10.0,
          direction: Axis.horizontal,
          crossAxisAlignment: WrapCrossAlignment.center,
          children:items,
        )
    );
  }

  Widget _buildGetways(BuildContext context, List<dynamic> row){
    if(row.isEmpty){
      return Container(
        child: Column(
          children: [
            Text('Not found'),
          ],
        ),
      );
    }

    List<Widget> items= [];
    for (int i = 0; i < row.length; i++) {
      items.add(
          Card(
            elevation: 2,
              child:
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
                children: [
              Center(child: row[i]['title'].toString().text.fontFamily('Bricolage').bold.make()),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  'Quantity'.text.fontFamily('Bricolage').make(),
                  Text(row[i]['total'].toString(), style: TextStyle( fontWeight: FontWeight.bold,fontFamily:'Bricolage', fontSize: 16, color: Colors.blue)),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  'Amount'.text.fontFamily('Bricolage').make(),
                  Text(row[i]['amount'].toString(), style: TextStyle( fontWeight: FontWeight.bold,fontFamily:'Bricolage', fontSize: 16, color: Colors.blue)),
                ],
              ),
            ]),
          ))
      );
    }
    return Container(
        child: Wrap(
          spacing: 10.0,
          runSpacing: 10.0,
          direction: Axis.horizontal,
          crossAxisAlignment: WrapCrossAlignment.center,
          children:items,
        )
    );
  }

  @override
  Widget build(BuildContext context){
    //ScrollController verticalController = ScrollController();
    //ScrollController horizontalController = ScrollController();

    String totalTitle = '';
    String totalOrderAmount = '';
    String incomeTitle = '';
    String incomeAmount = '';
    Map recentOrders = {};

    String recentTitle = '';
    List recentPosts = [];

    if( history.containsKey('total_order')){
      // total
      totalTitle = history['total_order']['title'];
      totalTitle += ' ' + history['total_order']['total'].toString();
      totalOrderAmount = history['total_order']['amount'];
      // income
      incomeTitle = history['total_income']['title'];
      incomeTitle += ' ' + history['total_income']['total'].toString();
      incomeAmount = history['total_income']['amount'];

      recentOrders = history['recent_orders'];
      recentTitle = history['recent_orders']['title'];
      recentPosts = history['recent_orders']['posts'];
    }

    // order summery
    String summeryTitle = '';
    String currentTitle = '';
    String currentTotal = '';
    String currentAmount = '';
    String currentIncome = '';
    String todayTitle = '';
    String todayTotal = '';
    String todayAmount = '';
    String todayIncome = '';
    String lastTitle = '';
    String lastTotal = '';
    String lastAmount = '';
    String lastIncome = '';
    String alltimeTitle = '';
    String alltimeTotal = '';
    String alltimeAmount = '';
    String alltimeIncome = '';

    if( orderSummery.containsKey('current')){
      summeryTitle = orderSummery['title'];
      //current
      currentTitle = orderSummery['current']['title'];
      currentTotal = orderSummery['current']['total'].toString();
      currentAmount = orderSummery['current']['amount'];
      currentIncome = orderSummery['current']['income'];
      //today
      todayTitle = orderSummery['today']['title'];
      todayTotal = orderSummery['today']['total'].toString();
      todayAmount = orderSummery['today']['amount'];
      todayIncome = orderSummery['today']['income'];
      //last_month
      lastTitle = orderSummery['last_month']['title'];
      lastTotal = orderSummery['last_month']['total'].toString();
      lastAmount = orderSummery['last_month']['amount'];
      lastIncome = orderSummery['last_month']['income'];
      //all_time
      alltimeTitle = orderSummery['all_time']['title'];
      alltimeTotal = orderSummery['all_time']['total'].toString();
      alltimeAmount = orderSummery['all_time']['amount'];
      alltimeIncome = orderSummery['all_time']['income'];
    }


    // getway
    String getwayTitle = 'Payment Getways';
    List getWays = [];
    if( getwayData.containsKey('title')){
      getwayTitle = getwayData['title'];
      getWays = getwayData['data'];
    }
    String  quantity='';
    Future.delayed(Duration(seconds: 1),(){quantity = SplitString(totalTitle,': ')[1].toString();});
    List totalOrder = SplitString(totalTitle,': ');
    List totalIncome = SplitString(incomeTitle,': ');

    //pie summery
    String pieTitle = 'Total summary';
    String pieTotalTitle = 'Total Amount';
    String pieTotalLabel = '';
    double? pieTotalAmount = 0;

    String pieDepositTitle = 'Total Deposit';
    String pieDepositLabel = '';
    double pieDepositAmount = 0;

    String pieDueTitle = 'Total Due';
    String pieDueLabel = '';
    double pieDueAmount = 0;

    String pieTaxTitle = 'Total Tax';
    String pieTaxLabel = '';
    double pieTaxAmount = 0;

    String pieIncomeTitle = 'Total Income';
    String pieIncomeLabel = '';
    double pieIncomeAmount = 0;
    
    if( summeryPie.containsKey('title')){
      pieTitle = summeryPie['title'];
      pieTotalTitle = summeryPie['total']['title'];
      pieTotalLabel = summeryPie['total']['label'];
      var tkd = summeryPie['total']['amunt'];
      pieTotalAmount = double.parse( tkd );

      pieDepositTitle = summeryPie['deposit']['title'];
      pieDepositLabel = summeryPie['deposit']['label'];
      var tkd1 = summeryPie['deposit']['amunt'];
      pieDepositAmount = double.parse( tkd1 );

      pieDueTitle = summeryPie['due']['title'];
      pieDueLabel = summeryPie['due']['label'];
      var tkd2 = summeryPie['due']['amunt'];
      pieDueAmount = double.parse( tkd2 );

      pieTaxTitle = summeryPie['tax']['title'];
      pieTaxLabel = summeryPie['tax']['label'];
      var tkd3 = summeryPie['tax']['amunt'];
      pieTaxAmount = double.parse( tkd3 );

      pieIncomeTitle = summeryPie['income']['title'];
      pieIncomeLabel = summeryPie['income']['label'];
      var tkd4 = summeryPie['income']['amunt'];
      pieIncomeAmount = double.parse( tkd4 );
    }
    //print(summeryPie);

    List<OrdinalData> ordinalDataList = [
      OrdinalData(domain: pieTotalTitle, measure: pieTotalAmount, color: Colors.blue,),
      OrdinalData(domain: pieDepositTitle, measure: pieDepositAmount, color: Colors.green),
      OrdinalData(domain: pieDueTitle, measure: pieDueAmount, color: Colors.purple),
      OrdinalData(domain: pieTaxTitle, measure: pieTaxAmount, color: Colors.pink),
      OrdinalData(domain: pieIncomeTitle, measure: pieIncomeAmount, color: Colors.grey),
    ];
    List<Widget> list = [
      SizedBox(
        width: 360,
        child: Card(
          margin: EdgeInsets.only(bottom: 15),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Column(children: [
              Align(
                  child:
                  Container(
                    margin: EdgeInsets.all(0),
                    padding: EdgeInsets.all(2.0),
                    /*decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey, width: 1),
                            )
                        ),*/
                    child: Column(
                      children: [
                        Text(currentTitle, style: const TextStyle( fontWeight: FontWeight.bold,fontFamily: ('Bricolage'), fontSize: 18, color: Colors.black)),
                        _spacer,
                        RowItem.text(
                            'Order',
                            currentTotal,
                            titleStyle: const TextStyle(color: Colors.black, fontFamily: 'Bricolage'),
                            descriptionStyle: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18 , fontFamily: 'Bricolage')
                        ),
                        _spacer,
                        RowItem.text(
                            'Amount',
                            currentAmount,
                            titleStyle: const TextStyle(color: Colors.black, fontFamily: 'Bricolage'),
                            descriptionStyle: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Bricolage')
                        ),
                        _spacer,
                        RowItem.text(
                            'Income',
                            currentIncome,
                            titleStyle: const TextStyle(color: Colors.black, fontFamily: 'Bricolage'),
                            descriptionStyle: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Bricolage')
                        ),
                      ],
                    )
                  )
              ),
            ]),
          ),
        ),
      ),
      SizedBox(
        width: 360,
        child: Card(
          margin: EdgeInsets.only(bottom: 15),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Column(children: [
              Align(
                  child:
                  Container(
                      margin: EdgeInsets.all(0),
                      padding: EdgeInsets.all(2.0),
                      /*decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey, width: 1),
                            )
                        ),*/
                      child: Column(
                        children: [
                          Text(todayTitle, style: const TextStyle( fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black)),
                          RowItem.text(
                              'Order:',
                              todayTotal,
                              titleStyle: const TextStyle(color: Colors.black, fontFamily: 'Bricolage'),
                              descriptionStyle: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Bricolage')
                          ),
                          _spacer,
                          RowItem.text(
                              'Amount:',
                              todayAmount,
                              titleStyle: const TextStyle(color: Colors.black, fontFamily: 'Bricolage'),
                              descriptionStyle: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18,fontFamily: 'Bricolage')
                          ),
                          _spacer,
                          RowItem.text(
                              'Income:',
                              todayIncome,
                              titleStyle: const TextStyle(color: Colors.black,fontFamily: 'Bricolage'),
                              descriptionStyle: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18,fontFamily: 'Bricolage')
                          ),
                        ],
                      )
                  )
              ),
            ]),
          ),
        ),
      ),
      SizedBox(
        width: 360,
        child: Card(
          margin: EdgeInsets.only(bottom: 15),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Column(children: [
              Align(
                  child:
                  Container(
                      margin: EdgeInsets.all(0),
                      padding: EdgeInsets.all(2.0),
                      child: Column(
                        children: [
                          Text(lastTitle, style: const TextStyle( fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black,fontFamily: 'Bricolage')),
                          _spacer,
                          RowItem.text(
                              'Order:',
                              lastTotal,
                              titleStyle: const TextStyle(color: Colors.black,fontFamily: 'Bricolage'),
                              descriptionStyle: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18,fontFamily: 'Bricolage')
                          ),
                          _spacer,
                          RowItem.text(
                              'Amount:',
                              lastAmount,
                              titleStyle: const TextStyle(color: Colors.black,fontFamily: 'Bricolage'),
                              descriptionStyle: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18,fontFamily: 'Bricolage')
                          ),
                          _spacer,
                          RowItem.text(
                              'Income:',
                              lastIncome,
                              titleStyle: const TextStyle(color: Colors.black,fontFamily: 'Bricolage'),
                              descriptionStyle: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18,fontFamily: 'Bricolage')
                          ),
                        ],
                      )
                  )
              ),
            ]),
          ),
        ),
      ),
      SizedBox(
        width: 360,
        child: Card(
          margin: EdgeInsets.only(bottom: 15),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Column(children: [
              Align(
                  child:
                  Container(
                      margin: EdgeInsets.all(0),
                      padding: EdgeInsets.all(2.0),
                      child: Column(
                        children: [
                          Text(alltimeTitle, style: const TextStyle( fontWeight: FontWeight.bold,fontFamily: 'Bricolage', fontSize: 18, color: Colors.black)),
                          _spacer,
                          RowItem.text(
                              'Order:',
                              alltimeTotal,
                              titleStyle: const TextStyle(color: Colors.black,fontFamily: 'Bricolage'),
                              descriptionStyle: const TextStyle(color: Colors.blue,fontFamily: 'Bricolage', fontWeight: FontWeight.bold, fontSize: 18)
                          ),
                          _spacer,
                          RowItem.text(
                              'Amount:',
                              alltimeAmount,
                              titleStyle: const TextStyle(color: Colors.black,fontFamily: 'Bricolage'),
                              descriptionStyle: const TextStyle(color: Colors.blue,fontFamily: 'Bricolage', fontWeight: FontWeight.bold, fontSize: 18)
                          ),
                          _spacer,
                          RowItem.text(
                              'Income:',
                              alltimeIncome,
                              titleStyle: const TextStyle(color: Colors.black,fontFamily: 'Bricolage'),
                              descriptionStyle: const TextStyle(color: Colors.blue,fontFamily: 'Bricolage', fontWeight: FontWeight.bold, fontSize: 18)
                          ),
                        ],
                      )
                  )
              ),
            ]),
          ),
        ),
      ),
    ];


    return ListView(
      padding: const EdgeInsets.all(8.0),

      children: [
        Column(children: [
          Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child:
                    Container(
                      margin: EdgeInsets.all(0),
                      padding: EdgeInsets.all(3.0),
                      /*decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey, width: 1),
                          )
                      ),*/
                      child: Center(child: 'Booking History'.text.fontFamily('Bricolage').bold.xl.make()),
                    )
                ),
                _spacer,
                _spacer,
                RowItem.text(
                  'Quantity',
                  todayTitle = alltimeTotal,
                  titleStyle: const TextStyle(color: Colors.black,fontFamily: 'Bricolage', fontWeight: FontWeight.w500,fontSize: 16),
                  descriptionStyle: const TextStyle(color: Colors.blue,fontFamily: 'Bricolage',fontWeight: FontWeight.bold, fontSize: 18),
                ),
                _spacer,
                RowItem.text(
                  totalTitle=totalOrder[0],
                  totalOrderAmount,
                  titleStyle: const TextStyle(color: Colors.black,fontFamily: 'Bricolage', fontWeight: FontWeight.w500,fontSize: 16),
                  descriptionStyle: const TextStyle(color: Colors.blue,fontFamily: 'Bricolage',fontWeight: FontWeight.bold, fontSize: 18),
                ),
                _spacer,
                RowItem.text(
                  incomeTitle = totalIncome[0],
                  incomeAmount,
                  titleStyle: const TextStyle(color: Colors.black,fontFamily: 'Bricolage', fontWeight: FontWeight.w500,fontSize: 16),
                  descriptionStyle: const TextStyle(color: Colors.blue,fontFamily: 'Bricolage',fontWeight: FontWeight.bold, fontSize: 18),
                ),

              ]),
            ),
          ),
           _cardSpacer,
           _cardSpacer,
          Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(children: [
                Align(
                    alignment: Alignment.centerLeft,
                    child:
                    Container(
                      margin: EdgeInsets.all(0),
                      padding: EdgeInsets.all(3.0),
                      /*decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey, width: 1),
                          )
                      ),*/
                      child: Center(child: 'Recent Orders'.text.fontFamily('Bricolage').bold.xl.make()),
                    )
                ),
                _spacer,
                _buildRecent(context, recentPosts),
              ]),
            ),
          ),
          _cardSpacer,
          _cardSpacer,
          _cardSpacer,
          'Order Summary'.text.fontFamily('Bricolage').center.bold.xl.make(),
          _cardSpacer,
          _cardSpacer,
          VxSwiper(
          height: 205,
          scrollDirection: Axis.horizontal,
          scrollPhysics: BouncingScrollPhysics(),
          autoPlay: true,
          reverse: false,
          pauseAutoPlayOnTouch: Duration(seconds: 3),
          initialPage: 0,
          isFastScrollingEnabled: true,
          enlargeCenterPage: true,
          autoPlayCurve: Curves.ease,
          items: list
          ),
          _cardSpacer,
          Card(
            elevation: 5,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                    children: [
                  Center(
                    child: Container(
                      margin: EdgeInsets.all(0),
                      padding: EdgeInsets.only(top: 3.0),
                      child: Text(pieTitle, style: TextStyle( fontWeight: FontWeight.bold, fontSize: 18,fontFamily: 'Bricolage', color: Colors.black)),
                    ),
                  ),
                  _spacer,
                  _spacer,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.45,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: AspectRatio(
                            aspectRatio: 10 / 8,
                            child: DChartPieO(
                              data: ordinalDataList,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.45,
                        child: Column(
                          children: [
                            RowItem.text(
                                pieTotalTitle,
                                pieTotalLabel,
                                titleStyle: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w500,fontFamily: 'Bricolage', fontSize: 13),
                                descriptionStyle: const TextStyle(color: Colors.blue,fontFamily: 'Bricolage',fontWeight: FontWeight.bold, fontSize: 15)
                            ),
                            RowItem.text(
                                pieDepositTitle,
                                pieDepositLabel,
                                titleStyle: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500,fontFamily: 'Bricolage', fontSize: 13),
                                descriptionStyle: const TextStyle(color: Colors.green,fontFamily: 'Bricolage',fontWeight: FontWeight.bold, fontSize: 15)
                            ),
                            RowItem.text(
                                pieDueTitle,
                                pieDueLabel,
                                titleStyle: const TextStyle(color: Colors.purple, fontWeight: FontWeight.w500,fontFamily: 'Bricolage', fontSize: 13),
                                descriptionStyle: const TextStyle(color: Colors.purple,fontFamily: 'Bricolage',fontWeight: FontWeight.bold, fontSize: 15)
                            ),
                            RowItem.text(
                                pieTaxTitle,
                                pieTaxLabel,
                                titleStyle: const TextStyle(color: Colors.pink, fontWeight: FontWeight.w500,fontFamily: 'Bricolage', fontSize: 13),
                                descriptionStyle: const TextStyle(color: Colors.pink,fontFamily: 'Bricolage',fontWeight: FontWeight.bold, fontSize: 15)
                            ),
                            RowItem.text(
                                pieIncomeTitle,
                                pieIncomeLabel,
                                titleStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500,fontFamily: 'Bricolage', fontSize: 13),
                                descriptionStyle: const TextStyle(color: Colors.grey,fontFamily: 'Bricolage',fontWeight: FontWeight.bold, fontSize: 15)
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ),
          _cardSpacer,
          _cardSpacer,
          Card(
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                Container(
                  margin: EdgeInsets.all(0),
                  padding: EdgeInsets.all(3.0),
                  child: Text(getwayTitle, style: TextStyle( fontWeight: FontWeight.bold, fontSize: 18,fontFamily: 'Bricolage', color: Colors.black)),
                ),
                _spacer,
                _spacer,
                _buildGetways(context, getWays),
              ]),
            ),
          ),
        ]),
      ],
    );
  }

}
