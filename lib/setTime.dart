import 'package:flutter/material.dart';
import 'package:natureslink/setDoctor.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:intl/intl.dart';
import 'package:natureslink/home.dart';
import 'package:mongo_dart/mongo_dart.dart' as M;
import 'package:natureslink/dbHelper/MongoDbModel.dart';
import 'package:natureslink/dbHelper/mongodb.dart';
import 'package:natureslink/globals.dart' as globals;

class setTime extends StatefulWidget {
  const setTime({Key? key}) : super(key: key);

  @override
  State<setTime> createState() => _setTimeState();
}

class _setTimeState extends State<setTime> {
  static Future<List<Map<String, dynamic>>> fetchAppointments() async {
    print(globals.objuidString);
    var arrData = await chatAppointments.chatAppointCollection.find({
      'uid': globals.objuidString,
      'status': 'APPROVED',
    }).toList();

    if (arrData.toString().replaceAll('[]', '') == '') {
      // print('test');
      var arrData2 = await chatAppointments.chatAppointCollection.find({
        'uid': globals.objuidString,
        'status': 'PENDING',
      }).toList();

      arrData = arrData2;
    }

    print(arrData);
    return arrData;
  }

  String? timeSelected = '';

  bool AM = false;
  bool PM = false;
  bool doc = false;

  void morning() {
    setState(() {
      AM = true;
      PM = false;
    });
  }

  void afternoon() {
    setState(() {
      AM = false;
      PM = true;
    });
  }

  bool online = false;
  bool onsite = false;
  bool datesu = false;

  void appointmentTypesu(type) {
    if (type == 'Online Appointment') {
      setState(() {
        afternoon();
        online = true;
        onsite = false;
        datesu = true;
        doc = true;
        PM = true;
        globals.servicesu = 'CWD';

        selectedDateController = new TextEditingController();
        globals.objduidString = '';
        globals.selectedAppointedDoctorName = '';
        globals.selectedDoctor = '';
        globals.selectedTime = '';
      });
    } else if (type == 'Physical Appointment') {
      morning();
      online = false;
      onsite = true;
      datesu = true;
      AM = true;
      globals.servicesu = '';
      selectedDateController = new TextEditingController();
      globals.objduidString = '';
      globals.selectedAppointedDoctorName = '';
      globals.selectedDoctor = '';
      globals.selectedTime = '';
    } else {
      online = false;
      onsite = false;
      datesu = false;
      AM = false;
      PM = false;
      selectedDateController = new TextEditingController();
      globals.servicesu = '';
      globals.objduidString = '';
      globals.selectedAppointedDoctorName = '';
      globals.selectedDoctor = '';
      globals.selectedTime = '';
    }
  }

  var selectedDateController = new TextEditingController();
  DateTime selectedDate = DateTime.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2101),
        builder: (context, child) {
          return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.greenAccent, // <-- SEE HERE
                  onPrimary: Colors.black, // <-- SEE HERE
                  onSurface: Colors.black, // <-- SEE HERE
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    primary: Colors.green, // button text color
                  ),
                ),
              ),
              child: child!);
        });
    if (picked != null && picked != selectedDate) {
      DateTime now = picked;
      DateTime date = DateTime(now.year, now.month, now.day);
      var formatsu = DateFormat('MM-dd-yyyy');
      setState(() {
        selectedDate = picked;
        globals.selectedDate = selectedDate;
        // print(globals.selectedDate);
        selectedDateController.text = "${formatsu.format(date)}";
        // print(selectedDateController.text);
      });
    }
  }

  Future<void> _insertAppointment(
    M.ObjectId id,
    String duid,
    String uid,
    String title,
    String email,
    String service,
    String patient,
    DateTime date,
    String appointmentTime,
  ) async {
    var formatter = DateFormat('yyyy-MM-dd');
    var selectedDatesu = formatter.format(date);
    final data = appointmentModel(
        id: id,
        duid: duid,
        uid: uid,
        title: title,
        email: globals.email!,
        service: globals.servicesu!,
        approver: globals.selectedAppointedDoctorName!,
        patient: patient,
        date: selectedDatesu.toString(),
        appointmentTime: appointmentTime,
        backgroundColor: 'green',
        status: 'APPROVED',
        postDate: DateTime.now());

    globals.servicesu = '';
    globals.objduidString = '';
    globals.selectedAppointedDoctorId = null;
    var result = await chatAppointments.insertCA(data);
  }

  Widget dateCard() => Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          child: Column(
            children: <Widget>[
              Container(
                child: Column(
                  children: <Widget>[
                    Text(
                      'Schedule Appointment',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                    Container(
                        child: Row(
                      children: [
                        Flexible(
                            child: TextField(
                          decoration: InputDecoration(labelText: "Date"),
                          enabled: false,
                          controller: selectedDateController,
                        )),
                        GestureDetector(
                          onTap: () => {_selectDate(context)},
                          child: Icon(Icons.calendar_month_outlined),
                        ),
                      ],
                    )),
                  ],
                ),
              )
            ],
          ),
        ),
      );

  String dropdownvalue2 = 'Services';
  var items2 = [
    'Services',
    'PMT - Pain Management Therapy',
    'DAC - Detoxification and Cleansing',
    'BET - Bio Energy Therapy',
    'AC1 - Acupuncture',
    'AC2 - Acupressure',
    'IMT - Immuno Therapy',
    'HOM - Homeopathy',
    'NFR - Natural Facial Rejuvination'
  ];

  String afternoontime = '1:00 PM';
  var PMtime = [
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
  ];

  String appointmenttype = 'Please Select Appointment';
  var items3 = [
    'Please Select Appointment',
    'Online Appointment',
    'Physical Appointment',
  ];

  Future<void> checkerAppointment(
      String approver, DateTime date, String time) async {
    var dateformat = DateFormat('yyyy-MM-dd');
    var something = dateformat.format(date);
    var getinfo;
    if (approver.isNotEmpty) {
      // print('with approver');
      getinfo = await chatAppointments.chatAppointCollection.find({
        'status': 'APPROVED',
        'appointmentTime': time,
        'approver': approver,
        'date': something.toString()
      }).toList();
    } else {
      // print('without approver');
      // getinfo = await chatAppointments.chatAppointCollection.find(
      //     {'appointmentTime': time, 'date': something.toString()}).toList();
    }
    // print(something);
    // print(time);
    // print(approver);
    var anything = getinfo.toString();
    var therefore = anything.replaceAll("[]", "");

    final List<dynamic> dataList = getinfo;
    var dataListToString = dataList.toString();
    var dataListReady = dataListToString.replaceAll("[]", "");
    // print(globals.servicesu);
    // print(doctor);
    // print(globals.selectedDateToString);
    // print(time);

    String checkDate = date.toString();
    if(afternoontime == '1:00 PM'){
      globals.selectedTime = '1PM';
      time = '1PM';
    }else if(afternoontime == '2:00 PM'){
      globals.selectedTime = '2PM';
      time = '2PM';
    }else if(afternoontime == '3:00 PM'){
      globals.selectedTime = '3PM';
      time = '3PM';
    }else if(afternoontime == '4:00 PM'){
      globals.selectedTime = '4PM';
      time = '4PM';
    }else {
      globals.selectedTime = '5PM';
      time = '5PM';
    }

    if (checkDate.isEmpty || time.isEmpty || approver.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please complete the form")));
      print(checkDate);
      print(time);
      print(approver);
    } else {
      print('test');
      if (dataListReady.isEmpty) {
        // print('test');
        print(globals.selectedAppointedDoctorId);
        if (globals.objduidString == '' || globals.objduidString == null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Please select a doctor")));
          // _insertAppointment(
          //     M.ObjectId(),
          //     globals.objduidString!,
          //     globals.objuidString!,
          //     globals.titlesu!,
          //     globals.email!,
          //     globals.servicesu!,
          //     globals.fName!,
          //     globals.selectedDate!,
          //     globals.selectedTime!);
        } else {
          print(globals.objduidString);
          print("im here!");
          //
          // _insertAppointment(
          //     M.ObjectId(),
          //     globals.objduidString!,
          //     globals.objuidString!,
          //     globals.titlesu!,
          //     globals.email!,
          //     globals.servicesu!,
          //     globals.fName!,
          //     globals.selectedDate!,
          //     globals.selectedTime!);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Appointed Schedule: " +
                  selectedDateController.text
                      .toString()
                      .replaceAll(RegExp(r'00:00:00.000'), '') +
                  " " +
                  globals.selectedTime!)));
          selectedDateController = new TextEditingController();
          globals.objduidString = '';
          globals.selectedDate = null;
          globals.selectedAppointedDoctorName = '';
          globals.selectedDoctor = '';
          globals.selectedTime = '';
        }

        // Navigator.push(
        //     context, MaterialPageRoute(builder: (context) => Home()));
      } else {
        // print(dataListReady);
        final item = dataList[0];
        if (item['approver'] == approver ||
            item['date'] == something &&
                item['appointmentTime'] == globals.selectedTime) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text("Schedule is Taken, Please choose Another Time")));
        } else {
          //
          // _insertAppointment(
          //     M.ObjectId(),
          //     globals.objduidString!,
          //     globals.objuidString!,
          //     globals.titlesu!,
          //     globals.email!,
          //     globals.servicesu!,
          //     globals.fName!,
          //     globals.selectedDate!,
          //     globals.selectedTime!);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            Container(
              child: Column(
                children: <Widget>[
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: <Widget>[
                          DropdownButton(
                            alignment: Alignment.centerLeft,
                            iconSize: 30,
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.black,
                            ),

                            // Initial Value
                            value: appointmenttype,

                            // Down Arrow Icon
                            icon: const Icon(Icons.keyboard_arrow_down),

                            // Array list of items
                            items: items3.map((String items) {
                              return DropdownMenuItem(
                                value: items,
                                child: Text(items),
                              );
                            }).toList(),
                            // After selecting the desired option,it will
                            // change button value to selected value
                            onChanged: (String? newValue) {
                              setState(() {
                                appointmenttype = newValue!;
                                appointmentTypesu(appointmenttype);
                                print(appointmenttype);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Visibility(child: dateCard(), visible: datesu),
                  Column(
                    children: <Widget>[
                      // ToggleSwitch(
                      //   minWidth: 50.0,
                      //   initialLabelIndex: 0,
                      //   cornerRadius: 10.0,
                      //   activeFgColor: Colors.white,
                      //   inactiveBgColor: Colors.greenAccent,
                      //   inactiveFgColor: Colors.white,
                      //   totalSwitches: 2,
                      //   labels: ['AM', 'PM'],
                      //   activeBgColors: [
                      //     [Colors.greenAccent],
                      //     [Colors.greenAccent],
                      //   ],
                      //   onToggle: (index) {
                      //     if (index == 1) {
                      //       afternoon();
                      //     } else {
                      //       morning();
                      //     }
                      //   },
                      // ),
                      SizedBox(
                        height: 10,
                      ),
                      Visibility(
                          visible: AM,
                          child: Column(
                            children: [
                              Text(
                                'Time Available',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              ToggleSwitch(
                                minWidth: 90.0,
                                initialLabelIndex: 0,
                                cornerRadius: 30.0,
                                activeFgColor: Colors.white,
                                inactiveBgColor: Colors.grey,
                                inactiveFgColor: Colors.white,
                                totalSwitches: 3,
                                labels: ['9:00 AM', '10:00 AM', '11:00 AM'],
                                activeBgColors: [
                                  [Colors.greenAccent],
                                  [Colors.greenAccent],
                                  [Colors.greenAccent]
                                ],
                                onToggle: (index) {
                                  if (index == 2) {
                                    timeSelected = "11AM";
                                    globals.selectedTime = timeSelected;
                                  } else if (index == 1) {
                                    timeSelected = "10AM";
                                    globals.selectedTime = timeSelected;
                                  } else {
                                    timeSelected = "9AM";
                                    globals.selectedTime = timeSelected;
                                  }
                                  print('switched to: $timeSelected');
                                },
                              ),
                            ],
                          )),

                      Visibility(
                        visible: PM,
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),

                          child: DropdownButton(

                            padding: EdgeInsets.symmetric(horizontal: 100),

                            alignment: Alignment.centerLeft,
                            iconSize: 30,
                            style: TextStyle(
                              fontSize: 25,
                              color: Colors.black,
                            ),


                            underline: Container(),
                            iconEnabledColor: Colors.green,
                            // Initial Value
                            value: afternoontime,
                            // Down Arrow Icon
                            icon: const Icon(Icons.keyboard_arrow_down),

                            // Array list of items
                            items: PMtime.map((String items) {
                              return DropdownMenuItem(
                                value: items,
                                child: Text(items,),
                              );
                            }).toList(),
                            // After selecting the desired option,it will
                            // change button value to selected value
                            onChanged: (String? newValue) {
                              setState(() {
                                globals.titlesu = 'CWD - Chat With Doctor' + " " + globals.selectedTime!;
                                // timeSelected = afternoontime;
                                afternoontime = newValue!;
                                print(afternoontime);
                              });
                            },
                          ),
                            elevation: 2.5,
                            margin: EdgeInsets.all(10)
                        ),
                      ),
                      // Visibility(
                      //   visible: PM,
                      //   child: ToggleSwitch(
                      //     minWidth: 90.0,
                      //     initialLabelIndex: 0,
                      //     cornerRadius: 30.0,
                      //     activeFgColor: Colors.white,
                      //     inactiveBgColor: Colors.grey,
                      //     inactiveFgColor: Colors.white,
                      //     totalSwitches: 3,
                      //     labels: ['1:00 PM', '2:00 PM', '3:00 PM'],
                      //     activeBgColors: [
                      //       [Colors.greenAccent],
                      //       [Colors.greenAccent],
                      //       [Colors.greenAccent]
                      //     ],
                      //     onToggle: (index) {
                      //       if (index == 2) {
                      //         timeSelected = "3PM";
                      //         globals.selectedTime = timeSelected;
                      //       } else if (index == 1) {
                      //         timeSelected = "2PM";
                      //         globals.selectedTime = timeSelected;
                      //       } else {
                      //         timeSelected = "1PM";
                      //         globals.selectedTime = timeSelected;
                      //       }
                      //       print('switched to: $timeSelected');
                      //     },
                      //   ),
                      // ),
                      //
                      // DropdownButton(
                      //   alignment: Alignment.centerLeft,
                      //   iconSize: 30,
                      //   style: TextStyle(
                      //     fontSize: 16,
                      //     color: Colors.black54,
                      //   ),
                      //
                      //   // Initial Value
                      //   value: dropdownvalue,
                      //
                      //   // Down Arrow Icon
                      //   icon: const Icon(Icons.keyboard_arrow_down),
                      //
                      //   // Array list of items
                      //   items: items1.map((String items) {
                      //     return DropdownMenuItem(
                      //       value: items,
                      //       child: Text(items),
                      //     );
                      //   }).toList(),
                      //   // After selecting the desired option,it will
                      //   // change button value to selected value
                      //   onChanged: (String? newValue) {
                      //     setState(() {
                      //       dropdownvalue2 = newValue!;
                      //     });
                      //   },
                      // ),
                      SizedBox(
                        height: 10,
                      ),
                      Visibility(
                          visible: onsite,
                          child: Column(
                            children: [
                              Card(
                                  child: DropdownButton(
                                    alignment: Alignment.centerLeft,
                                    iconSize: 30,
                                    style: TextStyle(
                                      fontSize: 19,
                                      color: Colors.black,
                                    ),

                                    // Initial Value
                                    value: dropdownvalue2,

                                    // Down Arrow Icon
                                    icon: const Icon(Icons.keyboard_arrow_down),

                                    // Array list of items
                                    items: items2.map((String items) {
                                      return DropdownMenuItem(
                                        value: items,
                                        child: Text(items),
                                      );
                                    }).toList(),
                                    // After selecting the desired option,it will
                                    // change button value to selected value
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        dropdownvalue2 = newValue!;
                                        globals.selectedAppointedDoctorName =
                                            '';
                                        globals.titlesu = dropdownvalue2 +
                                            " " +
                                            timeSelected!;

                                        if (dropdownvalue2 ==
                                            'PMT - Pain Management Therapy') {
                                          globals.servicesu = 'PMT';
                                          doc = true;
                                        } else if (dropdownvalue2 ==
                                            'DAC - Detoxification and Cleansing') {
                                          globals.servicesu = 'DAC';
                                          doc = true;
                                        } else if (dropdownvalue2 ==
                                            'BET - Bio Energy Therapy') {
                                          globals.servicesu = 'BET';
                                          doc = true;
                                        } else if (dropdownvalue2 ==
                                            'AC1 - Acupuncture') {
                                          globals.servicesu = 'AC1';
                                          doc = true;
                                        } else if (dropdownvalue2 ==
                                            'AC2 - Acupressure') {
                                          globals.servicesu = 'AC2';
                                          doc = true;
                                        } else if (dropdownvalue2 ==
                                            'IMT - Immuno Therapy') {
                                          globals.servicesu = 'IMT';
                                          doc = true;
                                        } else if (dropdownvalue2 ==
                                            'HOM - Homeopathy') {
                                          globals.servicesu = 'HOM';
                                          doc = true;
                                        } else if (dropdownvalue2 ==
                                            'NFR - Natural Facial Rejuvination') {
                                          globals.servicesu = 'NFR';
                                          doc = true;
                                        } else {
                                          globals.servicesu = "";
                                          doc = false;
                                        }
                                      });
                                    },
                                  ),
                                  elevation: 2.5,
                                  margin: EdgeInsets.all(10))
                            ],
                          )),

                      Visibility(
                          visible: doc,
                          child: Column(
                            children: [
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.green),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => setDoctor()));
                                },
                                child: Text('List of doctors'),
                              ),
                            ],
                          )),

                      Visibility(
                        visible: datesu,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.green),
                          ),
                          onPressed: () {
                            String checkDate = globals.selectedDate.toString();
                            // print(checkDate);
                            if (checkDate == 'null') {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text("Please choose date")));
                            } else {
                              globals.selectedDoctor = '';
                              checkerAppointment(
                                  globals.selectedAppointedDoctorName!,
                                  globals.selectedDate!,
                                  globals.selectedTime!);
                              setState(() {});
                            }
                          },
                          child: const Text("Appoint"),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
