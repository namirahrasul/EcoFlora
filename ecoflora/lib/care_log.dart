// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables, use_super_parameters, library_private_types_in_public_api

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:cron/cron.dart';



class CheckList extends ConsumerStatefulWidget {
  const CheckList({Key? key}) : super(key: key);

  @override
  _CheckListState createState() => _CheckListState();
}

class _CheckListState extends ConsumerState<CheckList> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final todoList = ref.watch(todoListProvider);
    final completedPercentage =
        ref.watch(completedPercentageProvider).toStringAsFixed(2);
    final averageCompletedPercentage =
        ref.watch(averageCompletedPercentageProvider).toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(title: Text('Daily Care Log')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 83, 113, 234),
              Color.fromARGB(255, 43, 230, 192)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Enter new task',
                        hintStyle: TextStyle(fontFamily: 'Anek Bangla'),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 8.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        final newTask = _controller.text.trim();
                        if (newTask.isNotEmpty) {
                          ref.read(todoListProvider.notifier).add(newTask);
                          _controller.clear();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                margin: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.only(bottom: 8.0),
                    //   child: Text(
                    //     'Overview',
                    //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    //   ),
                    // ),
                    Text(
                      'Completed todos',
                      style: TextStyle(fontSize: 18,
                        fontFamily: 'Anek Bangla',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: LinearProgressIndicator(
                        value: double.parse(completedPercentage) / 100,
                        minHeight: 10,
                        backgroundColor: Colors.grey[300],
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      'Performance in last 7 days',
                      style: TextStyle(fontFamily: 'Anek Bangla', fontSize: 18),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: LinearProgressIndicator(
                        value: double.parse(averageCompletedPercentage) / 100,
                        minHeight: 10,
                        backgroundColor: Colors.grey[300],
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: todoList.length,
                itemBuilder: (context, index) {
                  final todo = todoList[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Dismissible(
                       key: Key(todo.id.toString()),
                      onDismissed: (direction) {
                        ref.read(todoListProvider.notifier).remove(todo);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('${todo.description} dismissed')),
                        );
                      },
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        color: Colors.white.withOpacity(0.9),
                        child: ListTile(
                          title: Text(todo.description,style: TextStyle(fontFamily: 'Anek Bangla'),
                          ),
                          trailing: Checkbox(
                            value: todo.completed,
                            onChanged: (value) {
                              ref.read(todoListProvider.notifier).toggle(todo.id);
                              ref
                                  .read(averageCompletedPercentageProvider.notifier)
                                  .addCompletedPercentage(
                                      _calculateCompletedPercentage(todoList));
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final todoListProvider = StateNotifierProvider<TodoList, List<Todo>>((ref) {
  final todoList = TodoList(ref);
  todoList.loadTodos(); // Load todos when the provider initializes
  return todoList;
});

final completedPercentageProvider = Provider<double>((ref) {
  final todoList = ref.watch(todoListProvider);
  return _calculateCompletedPercentage(todoList);
});

final averageCompletedPercentageProvider =
    StateNotifierProvider<CumulativeNotifier, double>((ref) {
  final notifier = CumulativeNotifier(ref);
  notifier
      .loadAverageCompletedPercentage(); // Load averages when the provider initializes
  return notifier;
});

class Todo {
  Todo({
    required this.description,
    required this.id,
    this.completed = false,
  });

  final String id;
  final String description;
  bool completed;

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'completed': completed,
      };

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      description: json['description'],
      completed: json['completed'],
    );
  }
}

class TodoList extends StateNotifier<List<Todo>> {
  TodoList(this.ref) : super([]);

  final Ref ref;
  final cron = Cron();

  void add(String description) {
    state = [
      ...state,
      Todo(id: _uuid.v4(), description: description),
    ];
    saveTodos();
  }

  void toggle(String id) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          Todo(
            id: todo.id,
            completed: !todo.completed,
            description: todo.description,
          )
        else
          todo,
    ];
    saveTodos();
  }

  void edit({required String id, required String description}) {
    state = [
      for (final todo in state)
        if (todo.id == id)
          Todo(
            id: todo.id,
            completed: todo.completed,
            description: description,
          )
        else
          todo,
    ];
    saveTodos();
  }

  void remove(Todo target) {
    state = state.where((todo) => todo.id != target.id).toList();
    saveTodos();
  }

  void loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('todos');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      state = jsonList.map((json) => Todo.fromJson(json)).toList();
    } else {
      // If there are no saved todos, generate a default list
      state = [
        Todo(
          id: _uuid.v4(),
          description: 'Water all the plants in your garden.',
        ),
      ];
    }
  }

  void saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(state.map((todo) => todo.toJson()).toList());
    prefs.setString('todos', jsonString);
  }

  void scheduleDailyReset() {
    cron.schedule(Schedule.parse('0 45 * * *'), () {
      print('Regenerating todo list and updating cumulative data...');
      ref
          .read(averageCompletedPercentageProvider.notifier)
          .addCompletedPercentage(_calculateCompletedPercentage(state));
      state = generateDailyTodoList(); // Clear current todos
      saveTodos();
    });
  }

  List<Todo> generateDailyTodoList() {
    return [
      for (final todo in state)
        Todo(
          id: todo.id,
          description: todo.description,
          completed: false,
        )
    ];
  }
}

class CumulativeNotifier extends StateNotifier<double> {
  CumulativeNotifier(this.ref) : super(0) {
    loadAverageCompletedPercentage(); // Load averages when the notifier initializes
  }

  final Ref ref;
  final List<double> _percentages = [];

  void addCompletedPercentage(double percentage) {
    _percentages.add(percentage);
    if (_percentages.length > 7) {
      _percentages.removeAt(0);
    }
    state = calculateAverage(_percentages);
    saveAverageCompletedPercentage();
  }

  double calculateAverage(List<double> percentages) {
    if (percentages.isEmpty) return 0;
    final sum = percentages.reduce((a, b) => a + b);
    return sum / percentages.length;
  }

  void reset() {
    _percentages.clear();
    state = 0;
    saveAverageCompletedPercentage();
  }

  Future<void> loadAverageCompletedPercentage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('averageCompletedPercentage');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      _percentages.addAll(jsonList.map((e) => e as double).toList());
      state = calculateAverage(_percentages);
    }
  }

  Future<void> saveAverageCompletedPercentage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(_percentages);
    prefs.setString('averageCompletedPercentage', jsonString);
  }
}

const _uuid = Uuid();

double _calculateCompletedPercentage(List<Todo> todos) {
  if (todos.isEmpty) return 0;
  final completedTodos = todos.where((todo) => todo.completed).length;
  return (completedTodos / todos.length) * 100;
}
