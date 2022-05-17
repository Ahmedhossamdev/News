import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todoproject/shared/cubit/states.dart';
import '../../modules/archive_tasks/archive_tasks_screen.dart';
import '../../modules/done_tasks/done_tasks_screen.dart';
import '../../modules/new_tasks/new_tasks_screen.dart';
import '../components/constants.dart';

class AppCubit extends Cubit<AppStates> {
  late Database database;

  AppCubit() : super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);
  int currentIndex = 0;
  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];
  List<String> titles = [
    'New Tasks',
    'Done Tasks',
    'Archived Tasks',
  ];
  List<Map> newTasks = [];
  List<Map> doneTasks = [];
  List<Map> archivedTasks  = [];

  void changeIndex(int index) {
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }

  void createDatabase() {
    openDatabase('todo.dp', version: 1, onCreate: (database, version) {
      print('database created');
      database
          .execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT, time TEXT,status TEXT)')
          .then((value) {
        print('table created');
      }).catchError((error) {
        print('Error When Creating Table ${error.toString}');
      });
    }, onOpen: (database) {
      getFromDatabase(database);
      print('database opened');
    }).then((value) {
      database = value;
      emit(AppCreateDatabaseState());
    });
  }

   insertToDatabase(String title, String time, String date) async {
    await database.transaction((txn) {
     return txn.rawInsert(
        'INSERT INTO tasks(title, date , time, status) VALUES("$title", "$date" , "$time" ,"new")',
      ).then((value) {
        print('$value inserted successfully');
        emit(AppInsertDatabaseState());
        getFromDatabase(database);
      }).catchError((error) {
        print('Error When Inserting New Record ${error.toString()}');
      });
    });
  }
  void getFromDatabase(database) {
    newTasks = [];
    archivedTasks = [];
    doneTasks = [];
    emit(AppGetDatabaseStateLoadingScreen());
    database.rawQuery('SELECT * FROM tasks').then((value) {
      value.forEach((element){
        if(element['status'] == 'new') {newTasks.add(element);}
        else if(element['status'] == 'done'){doneTasks.add(element);}
        else if (element['status']=='archive'){ archivedTasks.add(element);}
      });
      emit(AppGetDatabaseState());
    });
  }
  void updateData({required String status, required int id}) {
    database.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?',
        [status, id]).then((value) {
      getFromDatabase(database);
      emit(AppUpdateDatabaseState());
    });
  }
  void deleteData({required int id}) {
    database.rawDelete('DELETE FROM tasks WHERE id = ?', [id]).then((value) {
      getFromDatabase(database);
      emit(AppDeleteDatabaseState());
    });
  }
    bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;
  void changeBottomSheetState({
    required bool isShow,
    required IconData icon,
  })
  {
    isBottomSheetShown = isShow;
    fabIcon = icon;
    emit(AppChangeIcon());
  }
}
