import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todoproject/layout/home_layout.dart';
import 'package:todoproject/shared/bloc_observer.dart';



void main() {
  Bloc.observer = MyBlocObserver();
  runApp(MyApp());
}

class MyApp extends StatelessWidget
{
  @override
  Widget build(BuildContext context)
  {
     return MaterialApp(
       debugShowCheckedModeBanner: false,
       //theme: ThemeData.dark(),
        home: HomeLayout(),
     );
  }
}