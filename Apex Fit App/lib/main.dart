import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_screen.dart';
import 'notification_service.dart';
import 'splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  runApp(const ApexFitApp());
}

class ApexFitApp extends StatelessWidget {
  const ApexFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Apex Fit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F6FB),
      ),
      home: const SplashScreen(),
    );
  }
}

class MainHomePage extends StatefulWidget {
  const MainHomePage({super.key});

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  int selectedIndex = 0;
  final UserData userData = UserData();
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    await userData.loadFromPrefs();
    setState(() {
      isLoaded = true;
    });
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = [
      DashboardScreen(userData: userData, onDataChanged: refresh),
      ProfileScreen(userData: userData, onDataChanged: refresh),
      MealsScreen(userData: userData, onDataChanged: refresh),
      HabitsScreen(userData: userData, onDataChanged: refresh),
      WorkoutPlanScreen(userData: userData, onDataChanged: refresh),
      InsightsScreen(userData: userData, onDataChanged: refresh),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.bolt, size: 24),
            SizedBox(width: 8),
            Text(
              'Apex Fit',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          NavigationDestination(icon: Icon(Icons.restaurant), label: 'Meals'),
          NavigationDestination(icon: Icon(Icons.check_circle), label: 'Habits'),
          NavigationDestination(icon: Icon(Icons.fitness_center), label: 'Workout'),
          NavigationDestination(icon: Icon(Icons.auto_graph), label: 'Reports'),
        ],
      ),
    );
  }
}

class UserData {
  String name = 'User';
  int age = 20;
  String gender = 'Male';
  double heightCm = 175;
  double weightKg = 72;
  String activityLevel = 'Moderate';
  String goal = 'Cutting';
  String workoutMode = 'Gym';

  int waterGlasses = 5;
  double sleepHours = 7.0;
  int steps = 6000;
  int proteinIntake = 60;

  bool workoutDone = false;
  bool dietFollowed = false;

  int gymDaysHit = 0;
  int cardioDaysHit = 0;
  int perfectDays = 0;
  int totalSavedDays = 0;

  final List<MealItem> meals = [
    MealItem(name: 'Breakfast - Oats', calories: 300),
    MealItem(name: 'Lunch - Rice and Paneer', calories: 650),
  ];

  final List<HabitItem> habits = [
    HabitItem(title: 'Workout Completed', completed: false),
    HabitItem(title: 'Diet Followed', completed: false),
    HabitItem(title: '2L Water Intake', completed: false),
    HabitItem(title: '8 Hours Sleep', completed: false),
  ];

  String normalizeName(String raw) {
    final trimmed = raw.trim().toLowerCase();
    if (trimmed.isEmpty) return 'User';
    return trimmed
        .split(' ')
        .where((e) => e.isNotEmpty)
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    name = prefs.getString('name') ?? 'User';
    age = prefs.getInt('age') ?? 20;
    gender = prefs.getString('gender') ?? 'Male';
    heightCm = prefs.getDouble('heightCm') ?? 175;
    weightKg = prefs.getDouble('weightKg') ?? 72;
    activityLevel = prefs.getString('activityLevel') ?? 'Moderate';
    goal = prefs.getString('goal') ?? 'Cutting';
    workoutMode = prefs.getString('workoutMode') ?? 'Gym';
    waterGlasses = prefs.getInt('waterGlasses') ?? 5;
    sleepHours = prefs.getDouble('sleepHours') ?? 7.0;
    steps = prefs.getInt('steps') ?? 6000;
    proteinIntake = prefs.getInt('proteinIntake') ?? 60;
    workoutDone = prefs.getBool('workoutDone') ?? false;
    dietFollowed = prefs.getBool('dietFollowed') ?? false;
    gymDaysHit = prefs.getInt('gymDaysHit') ?? 0;
    cardioDaysHit = prefs.getInt('cardioDaysHit') ?? 0;
    perfectDays = prefs.getInt('perfectDays') ?? 0;
    totalSavedDays = prefs.getInt('totalSavedDays') ?? 0;

    habits[0].completed = workoutDone;
    habits[1].completed = dietFollowed;
    habits[2].completed = waterGlasses >= 8;
    habits[3].completed = sleepHours >= 8;
  }

  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('name', name);
    await prefs.setInt('age', age);
    await prefs.setString('gender', gender);
    await prefs.setDouble('heightCm', heightCm);
    await prefs.setDouble('weightKg', weightKg);
    await prefs.setString('activityLevel', activityLevel);
    await prefs.setString('goal', goal);
    await prefs.setString('workoutMode', workoutMode);
    await prefs.setInt('waterGlasses', waterGlasses);
    await prefs.setDouble('sleepHours', sleepHours);
    await prefs.setInt('steps', steps);
    await prefs.setInt('proteinIntake', proteinIntake);
    await prefs.setBool('workoutDone', workoutDone);
    await prefs.setBool('dietFollowed', dietFollowed);
    await prefs.setInt('gymDaysHit', gymDaysHit);
    await prefs.setInt('cardioDaysHit', cardioDaysHit);
    await prefs.setInt('perfectDays', perfectDays);
    await prefs.setInt('totalSavedDays', totalSavedDays);
  }

  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  double get bmr {
    if (gender == 'Male') {
      return 10 * weightKg + 6.25 * heightCm - 5 * age + 5;
    }
    return 10 * weightKg + 6.25 * heightCm - 5 * age - 161;
  }

  double get activityMultiplier {
    switch (activityLevel) {
      case 'Low':
        return 1.2;
      case 'Moderate':
        return 1.55;
      case 'High':
        return 1.725;
      default:
        return 1.55;
    }
  }

  double get tdee => bmr * activityMultiplier;

  int get targetCalories {
    switch (goal) {
      case 'Bulking':
        return (tdee + 350).round();
      case 'Cutting':
        return (tdee - 400).round();
      case 'Maintenance':
        return tdee.round();
      default:
        return tdee.round();
    }
  }

  int get proteinTarget {
    if (goal == 'Bulking') return (weightKg * 2.0).round();
    if (goal == 'Cutting') return (weightKg * 2.2).round();
    return (weightKg * 1.8).round();
  }

  int get consumedCalories =>
      meals.fold(0, (sum, meal) => sum + meal.calories);

  int get remainingCalories => targetCalories - consumedCalories;

  bool get caloriesHit {
    if (goal == 'Bulking') {
      return consumedCalories >= targetCalories;
    }
    return consumedCalories >= targetCalories - 100 &&
        consumedCalories <= targetCalories + 100;
  }

  double get adherenceScore =>
      habits.isEmpty ? 0 : (habits.where((h) => h.completed).length / habits.length) * 100;

  String get aiSmartPlan {
    if (goal == 'Bulking') {
      return 'Eat high protein meals like eggs, paneer, chicken, milk, and rice. Focus on heavy gym lifts today.';
    } else if (goal == 'Cutting') {
      return 'Keep calories controlled. Add cardio today. Avoid sugary and fried foods. Prioritize protein.';
    } else {
      return 'Maintain balance. Do a moderate workout, eat clean, and keep recovery strong.';
    }
  }

  String get mealSuggestion {
    if (goal == 'Bulking') {
      return 'High calorie ideas: Paneer rice bowl, peanut butter banana oats, chicken sandwich with milk.';
    } else if (goal == 'Cutting') {
      return 'Low calorie ideas: Grilled paneer salad, boiled eggs with toast, yogurt fruit bowl.';
    }
    return 'Balanced ideas: Dal rice, paneer wrap, oats with fruit and nuts.';
  }

  List<String> fixedCalorieMeals(int target) {
    if (target <= 350) {
      return [
        'Greek yogurt + fruit bowl (~300 cal)',
        'Egg sandwich (~320 cal)',
        'Oats with milk (~340 cal)',
      ];
    } else if (target <= 550) {
      return [
        'Paneer rice bowl (~500 cal)',
        'Chicken sandwich + milk (~520 cal)',
        'Peanut butter banana oats (~510 cal)',
      ];
    } else {
      return [
        'Chicken rice meal (~650 cal)',
        'Paneer paratha combo (~700 cal)',
        'Pasta + yogurt combo (~680 cal)',
      ];
    }
  }

  Future<void> saveTodayProgress() async {
    totalSavedDays++;
    if (caloriesHit && workoutDone) perfectDays++;
    if (workoutDone && workoutMode == 'Gym') gymDaysHit++;
    if (workoutDone && workoutMode == 'Cardio') cardioDaysHit++;
    await saveToPrefs();
  }

  String get dailySummary {
    return 'Calories: $consumedCalories/$targetCalories kcal | Protein: $proteinIntake/$proteinTarget g | Workout: ${workoutDone ? 'Done' : 'Not done'}';
  }

  String get monthlyReport {
    return '''
Monthly Report for $name

Goal: $goal
Workout Type: $workoutMode
BMI: ${bmi.toStringAsFixed(1)} ($bmiCategory)
Target Calories: $targetCalories kcal
Protein Target: $proteinTarget g

Saved Days: $totalSavedDays
Perfect Days: $perfectDays
Gym Days Completed: $gymDaysHit
Cardio Days Completed: $cardioDaysHit
Adherence Score: ${adherenceScore.toStringAsFixed(0)}%

Suggestions:
- $aiSmartPlan
- $mealSuggestion
- Improve sleep and hydration consistency
- Keep tracking daily progress for a stronger monthly report
''';
  }
}

class MealItem {
  final String name;
  final int calories;

  MealItem({required this.name, required this.calories});
}

class HabitItem {
  final String title;
  bool completed;

  HabitItem({required this.title, required this.completed});
}

class DashboardScreen extends StatelessWidget {
  final UserData userData;
  final VoidCallback onDataChanged;

  const DashboardScreen({
    super.key,
    required this.userData,
    required this.onDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    final calorieProgress =
        (userData.consumedCalories / userData.targetCalories).clamp(0.0, 1.0);
    final proteinProgress =
        (userData.proteinIntake / userData.proteinTarget).clamp(0.0, 1.0);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF4F6FB), Color(0xFFE8ECF8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GradientHeroCard(
              title: 'Welcome, ${userData.name}',
              subtitle: 'Goal: ${userData.goal} • ${userData.workoutMode}',
              icon: Icons.local_fire_department,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'BMI',
                    value: userData.bmi.toStringAsFixed(1),
                    subtitle: userData.bmiCategory,
                    icon: Icons.monitor_weight,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Calories',
                    value: '${userData.targetCalories}',
                    subtitle: 'Target/day',
                    icon: Icons.restaurant_menu,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Protein',
                    value: '${userData.proteinTarget}g',
                    subtitle: 'Target/day',
                    icon: Icons.egg_alt,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Adherence',
                    value: '${userData.adherenceScore.toStringAsFixed(0)}%',
                    subtitle: 'Habits score',
                    icon: Icons.auto_graph,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ProgressCard(
              title: 'Daily Calorie Progress',
              valueText:
                  '${userData.consumedCalories} / ${userData.targetCalories} kcal',
              progress: calorieProgress,
            ),
            const SizedBox(height: 12),
            ProgressCard(
              title: 'Daily Protein Progress',
              valueText: '${userData.proteinIntake} / ${userData.proteinTarget} g',
              progress: proteinProgress,
            ),
            const SizedBox(height: 16),
            InfoCard(
              title: 'AI Suggestion',
              icon: Icons.auto_awesome,
              child: Text(
                userData.aiSmartPlan,
                style: const TextStyle(height: 1.5),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                NotificationService.showNotification(
                  'Apex Fit Reminder',
                  'Time to hit your ${userData.workoutMode.toLowerCase()} session today 💪',
                );
              },
              icon: const Icon(Icons.notifications_active),
              label: const Text('Test Notification'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  final UserData userData;
  final VoidCallback onDataChanged;

  const ProfileScreen({
    super.key,
    required this.userData,
    required this.onDataChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController nameController;
  late final TextEditingController ageController;
  late final TextEditingController heightController;
  late final TextEditingController weightController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.userData.name);
    ageController = TextEditingController(text: widget.userData.age.toString());
    heightController =
        TextEditingController(text: widget.userData.heightCm.toString());
    weightController =
        TextEditingController(text: widget.userData.weightKg.toString());
  }

  @override
  Widget build(BuildContext context) {
    final userData = widget.userData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GradientHeroCard(
            title: 'Setup Your Profile',
            subtitle: 'Your name and profile stay saved after reopening app',
            icon: Icons.person,
          ),
          const SizedBox(height: 16),
          InfoCard(
            title: 'Profile Details',
            icon: Icons.badge,
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: userData.gender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                  ],
                  onChanged: (value) async {
                    if (value != null) {
                      setState(() {
                        userData.gender = value;
                      });
                      await userData.saveToPrefs();
                      widget.onDataChanged();
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Height (cm)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: userData.activityLevel,
                  decoration: const InputDecoration(
                    labelText: 'Activity Level',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Low', child: Text('Low')),
                    DropdownMenuItem(value: 'Moderate', child: Text('Moderate')),
                    DropdownMenuItem(value: 'High', child: Text('High')),
                  ],
                  onChanged: (value) async {
                    if (value != null) {
                      setState(() {
                        userData.activityLevel = value;
                      });
                      await userData.saveToPrefs();
                      widget.onDataChanged();
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: userData.goal,
                  decoration: const InputDecoration(
                    labelText: 'Goal',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Bulking', child: Text('Bulking')),
                    DropdownMenuItem(value: 'Cutting', child: Text('Cutting')),
                    DropdownMenuItem(value: 'Maintenance', child: Text('Maintenance')),
                  ],
                  onChanged: (value) async {
                    if (value != null) {
                      setState(() {
                        userData.goal = value;
                      });
                      await userData.saveToPrefs();
                      widget.onDataChanged();
                    }
                  },
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () async {
                    setState(() {
                      userData.name = userData.normalizeName(nameController.text);
                      userData.age =
                          int.tryParse(ageController.text) ?? userData.age;
                      userData.heightCm =
                          double.tryParse(heightController.text) ??
                              userData.heightCm;
                      userData.weightKg =
                          double.tryParse(weightController.text) ??
                              userData.weightKg;
                    });

                    await userData.saveToPrefs();
                    widget.onDataChanged();

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile saved successfully')),
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Profile'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MealsScreen extends StatefulWidget {
  final UserData userData;
  final VoidCallback onDataChanged;

  const MealsScreen({
    super.key,
    required this.userData,
    required this.onDataChanged,
  });

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  final TextEditingController mealNameController = TextEditingController();
  final TextEditingController mealCaloriesController = TextEditingController();
  final TextEditingController proteinController = TextEditingController();
  final TextEditingController fixedCalorieController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userData = widget.userData;
    final fixedValue = int.tryParse(fixedCalorieController.text.trim()) ?? 0;
    final fixedSuggestions =
        fixedValue > 0 ? userData.fixedCalorieMeals(fixedValue) : <String>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GradientHeroCard(
            title: 'Nutrition Tracker',
            subtitle: 'Track meals, calories, and daily protein intake',
            icon: Icons.restaurant,
          ),
          const SizedBox(height: 16),
          InfoCard(
            title: 'Meal Suggestions',
            icon: Icons.tips_and_updates,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userData.mealSuggestion),
                const SizedBox(height: 12),
                TextField(
                  controller: fixedCalorieController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Enter meal calories (example 500)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                if (fixedSuggestions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...fixedSuggestions.map((e) => Text('• $e')),
                ]
              ],
            ),
          ),
          const SizedBox(height: 16),
          InfoCard(
            title: 'Add Meal',
            icon: Icons.add_circle,
            child: Column(
              children: [
                TextField(
                  controller: mealNameController,
                  decoration: const InputDecoration(
                    labelText: 'Meal Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: mealCaloriesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Calories',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {
                    final mealName = mealNameController.text.trim();
                    final calories =
                        int.tryParse(mealCaloriesController.text.trim());

                    if (mealName.isEmpty || calories == null) return;

                    setState(() {
                      userData.meals.add(
                        MealItem(name: mealName, calories: calories),
                      );
                      mealNameController.clear();
                      mealCaloriesController.clear();
                    });

                    widget.onDataChanged();
                  },
                  child: const Text('Add Meal'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          InfoCard(
            title: 'Daily Protein Intake',
            icon: Icons.egg_alt,
            child: Column(
              children: [
                TextField(
                  controller: proteinController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Protein intake today (grams)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () async {
                    final protein = int.tryParse(proteinController.text.trim());
                    if (protein == null) return;

                    setState(() {
                      userData.proteinIntake = protein;
                      proteinController.clear();
                    });

                    await userData.saveToPrefs();
                    widget.onDataChanged();
                  },
                  child: const Text('Save Protein Intake'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          InfoCard(
            title: 'Meal List',
            icon: Icons.list_alt,
            child: ListView.builder(
              itemCount: userData.meals.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final meal = userData.meals[index];
                return ListTile(
                  leading: const Icon(Icons.fastfood),
                  title: Text(meal.name),
                  subtitle: Text('${meal.calories} kcal'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      setState(() {
                        userData.meals.removeAt(index);
                      });
                      widget.onDataChanged();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HabitsScreen extends StatefulWidget {
  final UserData userData;
  final VoidCallback onDataChanged;

  const HabitsScreen({
    super.key,
    required this.userData,
    required this.onDataChanged,
  });

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  @override
  Widget build(BuildContext context) {
    final userData = widget.userData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GradientHeroCard(
            title: 'Daily Habit Tracker',
            subtitle: 'Track water, sleep, steps, diet, and workout completion',
            icon: Icons.track_changes,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InfoInputCard(
                  title: 'Water',
                  value: '${userData.waterGlasses} glasses',
                  icon: Icons.water_drop,
                  onIncrease: () async {
                    setState(() {
                      userData.waterGlasses++;
                      userData.habits[2].completed = userData.waterGlasses >= 8;
                    });
                    await userData.saveToPrefs();
                    widget.onDataChanged();
                  },
                  onDecrease: () async {
                    if (userData.waterGlasses > 0) {
                      setState(() {
                        userData.waterGlasses--;
                        userData.habits[2].completed = userData.waterGlasses >= 8;
                      });
                      await userData.saveToPrefs();
                      widget.onDataChanged();
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoInputCard(
                  title: 'Steps',
                  value: '${userData.steps}',
                  icon: Icons.directions_walk,
                  onIncrease: () async {
                    setState(() {
                      userData.steps += 500;
                    });
                    await userData.saveToPrefs();
                    widget.onDataChanged();
                  },
                  onDecrease: () async {
                    if (userData.steps >= 500) {
                      setState(() {
                        userData.steps -= 500;
                      });
                      await userData.saveToPrefs();
                      widget.onDataChanged();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InfoCard(
            title: 'Sleep and Routine',
            icon: Icons.bedtime,
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.hotel),
                  title: Text(
                    'Sleep Hours: ${userData.sleepHours.toStringAsFixed(1)}',
                  ),
                  subtitle: Slider(
                    min: 0,
                    max: 12,
                    divisions: 24,
                    value: userData.sleepHours,
                    onChanged: (value) async {
                      setState(() {
                        userData.sleepHours = value;
                        userData.habits[3].completed = value >= 8;
                      });
                      await userData.saveToPrefs();
                      widget.onDataChanged();
                    },
                  ),
                ),
                SwitchListTile(
                  value: userData.workoutDone,
                  title: const Text('Workout Completed'),
                  onChanged: (value) async {
                    setState(() {
                      userData.workoutDone = value;
                      userData.habits[0].completed = value;
                    });
                    await userData.saveToPrefs();
                    widget.onDataChanged();
                  },
                ),
                SwitchListTile(
                  value: userData.dietFollowed,
                  title: const Text('Diet Followed'),
                  onChanged: (value) async {
                    setState(() {
                      userData.dietFollowed = value;
                      userData.habits[1].completed = value;
                    });
                    await userData.saveToPrefs();
                    widget.onDataChanged();
                  },
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: () async {
                    await userData.saveTodayProgress();
                    widget.onDataChanged();

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Today progress added to monthly report'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Save Today Progress'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WorkoutPlanScreen extends StatefulWidget {
  final UserData userData;
  final VoidCallback onDataChanged;

  const WorkoutPlanScreen({
    super.key,
    required this.userData,
    required this.onDataChanged,
  });

  @override
  State<WorkoutPlanScreen> createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  int selectedDays = 3;
  final List<String?> chosenSplits = List<String?>.filled(6, null);

  final List<String> splitOptions = const [
    'Chest + Tricep',
    'Back + Bicep',
    'Shoulders',
    'Legs',
    'Arms + Core',
    'Full Body',
    'Cardio Focus',
  ];

  final Map<String, String> exerciseMap = const {
    'Chest + Tricep':
        'Bench Press 4x8\nIncline DB Press 4x10\nCable Fly 3x12\nTricep Pushdown 4x12',
    'Back + Bicep':
        'Lat Pulldown 4x10\nBarbell Row 4x8\nSeated Row 3x12\nHammer Curl 3x12',
    'Shoulders':
        'Shoulder Press 4x8\nLateral Raise 4x12\nFront Raise 3x12\nRear Delt Fly 3x15',
    'Legs':
        'Squat 4x8\nLeg Press 4x12\nLunges 3x12\nCalf Raises 4x15',
    'Arms + Core':
        'EZ Curl 4x10\nTricep Extension 4x10\nPlank 3x45 sec\nCable Crunch 3x15',
    'Full Body':
        'Deadlift 3x6\nPush-ups 3 sets\nPull-ups 3 sets\nGoblet Squat 3x15',
    'Cardio Focus':
        'Brisk walk 30 min\nHIIT 10 rounds\nCycling 20 min',
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GradientHeroCard(
            title: 'Weekly Workout Planner',
            subtitle: 'Choose days and pick your split',
            icon: Icons.fitness_center,
          ),
          const SizedBox(height: 16),
          InfoCard(
            title: 'Workout Setup',
            icon: Icons.settings,
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: widget.userData.workoutMode,
                  decoration: const InputDecoration(
                    labelText: 'Workout Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Gym', child: Text('Gym')),
                    DropdownMenuItem(value: 'Cardio', child: Text('Cardio')),
                  ],
                  onChanged: (value) async {
                    if (value != null) {
                      setState(() {
                        widget.userData.workoutMode = value;
                      });
                      await widget.userData.saveToPrefs();
                      widget.onDataChanged();
                    }
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: selectedDays,
                  decoration: const InputDecoration(
                    labelText: 'Workout days per week',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 3, child: Text('3 days')),
                    DropdownMenuItem(value: 4, child: Text('4 days')),
                    DropdownMenuItem(value: 5, child: Text('5 days')),
                    DropdownMenuItem(value: 6, child: Text('6 days')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedDays = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(selectedDays, (index) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Day ${index + 1}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: chosenSplits[index],
                      decoration: const InputDecoration(
                        labelText: 'Select split',
                        border: OutlineInputBorder(),
                      ),
                      items: splitOptions
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          chosenSplits[index] = value;
                        });
                      },
                    ),
                    if (chosenSplits[index] != null) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          exerciseMap[chosenSplits[index]!] ?? '',
                          style: const TextStyle(height: 1.5),
                        ),
                      )
                    ]
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class InsightsScreen extends StatelessWidget {
  final UserData userData;
  final VoidCallback onDataChanged;

  const InsightsScreen({
    super.key,
    required this.userData,
    required this.onDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    final adherence = userData.adherenceScore / 100;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          GradientHeroCard(
            title: 'Reports & Summary',
            subtitle: 'Daily summary and monthly performance report',
            icon: Icons.analytics,
          ),
          const SizedBox(height: 16),
          InfoCard(
            title: 'Progress Overview',
            icon: Icons.trending_up,
            child: Column(
              children: [
                buildProgressLine(
                  'Adherence Score',
                  '${userData.adherenceScore.toStringAsFixed(0)}%',
                  adherence,
                ),
                buildProgressLine(
                  'Water Goal',
                  '${userData.waterGlasses}/8 glasses',
                  (userData.waterGlasses / 8).clamp(0.0, 1.0),
                ),
                buildProgressLine(
                  'Protein Goal',
                  '${userData.proteinIntake}/${userData.proteinTarget} g',
                  (userData.proteinIntake / userData.proteinTarget)
                      .clamp(0.0, 1.0),
                ),
                buildProgressLine(
                  'Sleep Goal',
                  '${userData.sleepHours.toStringAsFixed(1)}/8 hrs',
                  (userData.sleepHours / 8).clamp(0.0, 1.0),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          InfoCard(
            title: 'Weekly Progress Chart',
            icon: Icons.show_chart,
            child: SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(show: true),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      spots: const [
                        FlSpot(0, 3),
                        FlSpot(1, 4),
                        FlSpot(2, 5),
                        FlSpot(3, 4.5),
                        FlSpot(4, 6),
                        FlSpot(5, 7),
                        FlSpot(6, 6.5),
                      ],
                      barWidth: 4,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          InfoCard(
            title: 'Daily Summary',
            icon: Icons.today,
            child: Text(
              userData.dailySummary,
              style: const TextStyle(height: 1.5),
            ),
          ),
          const SizedBox(height: 16),
          InfoCard(
            title: 'End of Month Report',
            icon: Icons.calendar_month,
            child: Text(
              userData.monthlyReport,
              style: const TextStyle(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProgressLine(String title, String value, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title - $value'),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }
}

class GradientHeroCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const GradientHeroCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B4BFF), Color(0xFF7B61FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData icon;

  const InfoCard({
    super.key,
    required this.title,
    required this.child,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class ProgressCard extends StatelessWidget {
  final String title;
  final String valueText;
  final double progress;

  const ProgressCard({
    super.key,
    required this.title,
    required this.valueText,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(height: 10),
            Text(
              valueText,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        height: 128,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon),
              const Spacer(),
              Text(title, style: TextStyle(color: Colors.grey.shade700)),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoInputCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  const InfoInputCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.onIncrease,
    required this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: onDecrease,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                IconButton(
                  onPressed: onIncrease,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
