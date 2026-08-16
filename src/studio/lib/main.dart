import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/records_cubit.dart';
import 'router.dart';
import 'theme.dart';

void main() {
  runApp(const QtcloudHealthApp());
}

class QtcloudHealthApp extends StatelessWidget {
  const QtcloudHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => RecordsCubit()..load()),
      ],
      child: MaterialApp.router(
        title: '量潮健康云',
        theme: buildTheme(),
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
