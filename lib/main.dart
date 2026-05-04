import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'models/exercise.dart';
import 'models/week_schedule.dart';
import 'models/workout_log.dart';
import 'models/workout_set.dart';
import 'providers/gym_provider.dart';
import 'screens/calendar_screen.dart';
import 'screens/home_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/sets_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(WorkoutSetAdapter());
  Hive.registerAdapter(WeekScheduleAdapter());
  Hive.registerAdapter(WorkoutLogAdapter());

  runApp(
    ChangeNotifierProvider(
      create: (_) => GymProvider()..initialize(),
      child: const GymApp(),
    ),
  );
}

class GymApp extends StatelessWidget {
  const GymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym Tracker',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const _Root(),
    );
  }
}

class _Root extends StatefulWidget {
  const _Root();

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    CalendarScreen(),
    SetsScreen(),
    ScheduleScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final initialized = context.watch<GymProvider>().isInitialized;

    if (!initialized) {
      return const Scaffold(
        backgroundColor: kBg,
        body: Center(
          child: CircularProgressIndicator(
            color: kGreen,
            strokeWidth: 2,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: kBg,
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            label: 'Sets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.date_range),
            label: 'Schedule',
          ),
        ],
      ),
    );
  }
}
