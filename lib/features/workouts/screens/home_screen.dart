import 'package:fit_track_pro/core/storage/local_storage_service.dart';
import 'package:fit_track_pro/features/auth/screens/login_screen.dart';
import 'package:fit_track_pro/features/workouts/screens/add_workout_screen.dart';
import 'package:fit_track_pro/features/workouts/services/local_workout_service.dart';
import 'package:fit_track_pro/features/workouts/models/workout_model.dart';
import 'package:fit_track_pro/features/weight/screens/weight_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocalWorkoutService _dbService = LocalWorkoutService();

  List<WorkoutModel> _workouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    setState(() async {
      _isLoading = true;
    });

    final workouts = await _dbService.getWorkouts();

    setState(() {
      _workouts = workouts;
      _isLoading = false;
    });
  }

  void _logout() async {
    final storage = LocalStorageService();
    await storage.clearToken();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  // void _showAddWorkoutDialog() {
  //   final titleController = TextEditingController();
  //   final categoryController = TextEditingController();
  //   final durationMinutesController = TextEditingController();

  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text('Nueva rutina'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           TextField(
  //             controller: titleController,
  //             decoration: InputDecoration(labelText: "Nombre"),
  //           ),
  //           TextField(
  //             controller: categoryController,
  //             decoration: InputDecoration(labelText: "Categoria"),
  //           ),
  //           TextField(
  //             controller: durationMinutesController,
  //             decoration: InputDecoration(labelText: "Duración (minutos)"),
  //             keyboardType: TextInputType.number,
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text("Cancelar"),
  //         ),
  //         ElevatedButton(
  //           onPressed: () async {
  //             if (titleController.text.isNotEmpty &&
  //                 durationMinutesController.text.isNotEmpty &&
  //                 titleController.text.isNotEmpty) {
  //               final newWorkout = WorkoutModel(
  //                 title: titleController.text,
  //                 category: categoryController.text,
  //                 durationMinutes: int.parse(durationMinutesController.text),
  //               );
  //               await _dbService.insertWorkout(newWorkout);

  //               if (mounted) {
  //                 Navigator.pop(context);
  //                 _loadWorkouts();
  //               }
  //             }
  //           },
  //           child: Text("Guardar"),
  //         ),
  //       ],
  //     ),
  //   );
  // }

Future <void> _navigateToAddWorkoutScreen() async {
    final newWorkout = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddWorkoutScreen()),
    );

    if (newWorkout != null && newWorkout is WorkoutModel) {
      await _dbService.insertWorkout(newWorkout);
      _loadWorkouts();

      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Rutina agregada: ${newWorkout.title}")),
        );
      }
    }
  }

  Future<void> _deleteWorkout(int localId) async {
    await _dbService.deleteWorkout(localId);
    if (mounted) {
      _loadWorkouts();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Rutina eliminada: $localId")));
    }
  }
  //al presionar la card de la rutina se abre un dialogo para editar la rutina
  //ademas ya esta implementada la edicion en local_workout_service.dart
  void _showEditWorkoutDialog(WorkoutModel workout) {
    final titleController = TextEditingController(text: workout.title);
    final categoryController = TextEditingController(text: workout.category);
    final durationMinutesController =
        TextEditingController(text: workout.durationMinutes.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar rutina'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Nombre"),
            ),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(labelText: "Categoria"),
            ),
            TextField(
              controller: durationMinutesController,
              decoration: InputDecoration(labelText: "Duración (minutos)"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty &&
                  durationMinutesController.text.isNotEmpty &&
                  titleController.text.isNotEmpty) {
                final updatedWorkout = WorkoutModel(
                  localId: workout.localId,
                  title: titleController.text,
                  category: categoryController.text,
                  durationMinutes:
                      int.parse(durationMinutesController.text),
                );
                await _dbService.updateWorkout(updatedWorkout);

                if (mounted) {
                  Navigator.pop(context);
                  _loadWorkouts();
                }
              }
            },
            child: Text("Guardar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mis entrenamientos"),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: (){
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Cerrar sesión"),
                  content: Text("¿Estás seguro de que quieres cerrar sesión?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancelar"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _logout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text("Cerrar sesión", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _workouts.isEmpty
          ? Center(child: Text('No tienes rutinas creadas'))
          : ListView.builder(
              itemCount: _workouts.length,
              itemBuilder: (context, index) {
                final workout = _workouts[index];
                return GestureDetector(
                  onTap: () => _showEditWorkoutDialog(workout),
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(child: Icon(Icons.fitness_center)),
                      title: Text(
                        workout.title,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        onPressed: () => _deleteWorkout(workout.localId!),
                        icon: Icon(Icons.delete, color: Colors.red),
                      ),
                      subtitle: Text(
                        '${workout.category} - ${workout.durationMinutes} min',
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'fabPeso',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const WeightScreen()),
              );
            },
            child: Icon(Icons.monitor_weight),
          ),
          SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'fabRutina',
            onPressed: _navigateToAddWorkoutScreen,
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
