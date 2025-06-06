import 'package:flutter_modular/flutter_modular.dart';
import 'exercise_history_screen.dart';
import 'exercise_list_screen.dart';
import 'exercise_record_screen.dart';
import 'home_screen.dart';
import 'tmb_calculator_screen.dart';
import 'weight_record_screen.dart';
import 'tmb_history_screen.dart';
import 'profile_screen.dart';

class HomeModule extends Module {
  @override
  void routes(RouteManager r) {
    r.child('/', child: (context) => const HomeScreen());
    r.child('/tmb-history', child: (context) => const TMBHistoryScreen());
    r.child('/tmb-calculator', child: (context) => const TMBCalculatorScreen());
    r.child('/weight-record', child: (context) => const WeightRecordScreen());
    r.child('/exercise-list', child: (context) => const ExerciseListScreen());
    r.child('/exercise-record',
        child: (context) => const ExerciseRecordScreen());
    r.child('/exercise-history',
        child: (context) => const ExerciseHistoryScreen());
    r.child('/profile', child: (context) => const ProfileScreen());
  }
}
