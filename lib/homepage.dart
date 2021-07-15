import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:userattendence/date_time_picker/customdatetimepicker.dart';
import 'package:intl/intl.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String? useridno;
  CustomPicker? _customPicker;
  String attendence = "P";
  String attendence2 = "A";
  var date = DateTime.now();
  bool autoclick = true;
  int fixedtime = 11;

  List<String> monthname = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  CollectionReference users =
      FirebaseFirestore.instance.collection('attendence');

  Future<Void>? addattendence(
      {required String userid,
      required String year,
      required String month,
      required String dayname,
      required String date}) {
    FirebaseFirestore.instance
        .collection('attendence')
        .doc(userid)
        .collection('year')
        .doc(year)
        .collection('month')
        .doc(month)
        .collection('date')
        .doc("${dayname},${date}")
        .set({
      "attendence": "P",
      "userid": userid,
      "year": year,
      "month": month,
      "dayname": dayname,
      "date": date,
    }).then((va) {
      print("added succesfull");
    });
  }

  Future<Void>? addattendencefield(
      {required String userid,
      required String year,
      required String month,
      required String dayname,
      required String date}) {
    FirebaseFirestore.instance.collection('attendence').doc(userid).set({
      "attendence": "P",
      "userid": userid,
      "year": year,
      "month": month,
      "dayname": dayname,
      "date": date,
    }).then((va) {
      print("added succesfull");
    });
  }

  Future getuserid() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var email = sharedPreferences.getString('email');
    setState(() {
      useridno = email!;
    });
  }

  bodydata(String _userid, _year, _month, _day) => StreamBuilder<QuerySnapshot>(
      stream: users
          .doc(_userid)
          .collection('year')
          .doc(_year)
          .collection('month')
          .doc(_month)
          .collection("date")
          .orderBy("date", descending: false)
          .snapshots(),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.hasData) {
          return DataTable(
            columns: [
              DataColumn(label: Text("User Id")),
              DataColumn(label: Text("Date")),
              DataColumn(label: Text("Attendence")),
            ],
            rows: asyncSnapshot.data!.docs
                .map((e) => DataRow(cells: [
                      DataCell(Text(e['userid'])),
                      DataCell(Text("${e['date']}, ${e['dayname']}")),
                      DataCell(Text(e['attendence'])),
                    ]))
                .toList(),
          );
        } else if (asyncSnapshot.hasError) {
          return Text('There was an error...');
        } else {
          return Container(child: Center(child: CircularProgressIndicator()));
        }
      });

  @override
  void initState() {
    super.initState();
    getuserid();
    _customPicker = CustomPicker();
  }

  @override
  Widget build(BuildContext context) {
    String year = _customPicker!.currentTime.year.toString();
    String month = monthname[_customPicker!.currentTime.month - 1];
    String day = _customPicker!.currentTime.day.toString();
    String dayname = DateFormat('EEEE').format(date);
    String dateanddayname = "${dayname},${day}";
    int time = _customPicker!.currentTime.hour;
    String userid = useridno!;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.indigoAccent,
        centerTitle: true,
        title: Text("Attendence"),
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 60.0,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 40.0,
                    decoration: BoxDecoration(
                        color: Colors.indigoAccent,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20.0),
                          bottomRight: Radius.circular(20.0),
                        )),
                  ),
                  Positioned(
                    top: 15.0,
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    child: Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.symmetric(horizontal: 20.0),
                      width: double.infinity,
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        "${month}, ${day}, ${dayname}",
                        style: TextStyle(
                            fontFamily: 'Balsamiq Sans', fontSize: 16),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50.0),
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "Your Attendence Sheet:",
                    style:
                        TextStyle(fontFamily: 'Balsamiq Sans', fontSize: 18.0),
                  ),
                ),
              ],
            ),
            Container(
                height: MediaQuery.of(context).size.height - 270.0,
                width: double.infinity,
                child: Card(
                  child: Container(
                    child: ListView(
                      children: [
                        bodydata(userid, year, month, day),
                      ],
                    ),
                  ),
                )),
            SizedBox(
              height: 30.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () {
                    addattendence(
                      userid: userid,
                      date: day,
                      dayname: dayname,
                      month: month,
                      year: year,
                    );
                    addattendencefield(
                      userid: userid,
                      date: day,
                      dayname: dayname,
                      month: month,
                      year: year,
                    );
                  },
                  child: Text("Attendence"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
