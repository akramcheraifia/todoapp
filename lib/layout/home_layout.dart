// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoapp/modules/tasks/tasks_screen.dart';
import '../modules/archived/archived_screen.dart';
import '../modules/done/done_screen.dart';
import '../shared/components/componants.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    TasksScreen(),
    DoneTasksScreen(),
    ArchivedScreen(),
  ];

  final List<String> titles = const [
    'Tasks',
    'Completed',
    'Archived',
  ];

  var database;
  TextEditingController titleController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  bool isBottomShown = false;
  IconData fabIcon = Icons.edit;
  @override
  void initState() {
    super.initState();
    createDatabase();
  }

  void createDatabase() async {
    database = await openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) {
        print('database created');
        database
            .execute(
                'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT, status TEXT)')
            .then((value) {
          print('table created');
        }).catchError((error) {
          print('error when creating table ${error.toString()}');
        });
      },
      onOpen: (database) {
        print('database opened');
      },
    ).then((value) {
      print(value);
    });
  }

  void insertToDatabase() {
    try {
      database.transaction((txn) {
        txn
            .rawInsert(
                'INSERT INTO tasks (title,date,time,status) VALUES ("newtask","03333","13","new")')
            .then((value) => print('$value inserted succsesfully'));
      });
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text(titles[currentIndex]),
      ),
      body: screens[currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isBottomShown) {
            if (formKey.currentState!.validate()) {
              Navigator.pop(context);
              setState(() {
                fabIcon = Icons.edit;
              });
            }
          } else {
            scaffoldKey.currentState?.showBottomSheet((context) {
              return Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      defaultTextformfield(
                        Controller: titleController,
                        label: 'Task Title',
                        onSubmit: (value) {},
                        suffixPressed: () {},
                        onChange: (value) {},
                        type: TextInputType.text,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'title must not be empty';
                          }
                          return null;
                        },
                        isPassword: false,
                        prefix: Icons.title,
                        suffix: Icons.edit,
                      ),
                      const SizedBox(height: 10),
                      defaultTextformfield(
                        Controller: timeController,
                        label: 'Task Time',
                        suffixPressed: () {},
                        onTab: () {
                          showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          ).then((value) {
                            print(value);
                            timeController.text =
                                value!.format(context).toString();
                          });
                        },
                        type: TextInputType.datetime,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'time must not be empty';
                          }
                          return null;
                        },
                        isPassword: false,
                        prefix: Icons.watch_later_outlined,
                        suffix: Icons.edit,
                      ),
                      const SizedBox(height: 10),
                      defaultTextformfield(
                        Controller: dateController,
                        label: 'Task Date',
                        onSubmit: (value) {},
                        suffixPressed: () {},
                        type: TextInputType.datetime,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'date must not be empty';
                          }
                          return null;
                        },
                        onTab: () {
                          showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.parse('2024-08-30'),
                          ).then((value) {
                            print(DateFormat('yyyy-MM-dd').format(value!));
                            dateController.text =
                                DateFormat('yyyy-MM-dd').format(value);
                          });
                        },
                        isPassword: false,
                        prefix: Icons.calendar_today,
                        suffix: Icons.edit,
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              );
            });
            setState(() {
              fabIcon = Icons.add;
            });
          }
          isBottomShown = !isBottomShown;
        },
        child: Icon(fabIcon),
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.task),
              label: 'Tasks',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.done_all_rounded),
              label: 'Completed',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.archive),
              label: 'Archived',
            ),
          ]),
    );
  }
}
