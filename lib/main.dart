import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adoption & Travel Planner',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PlanManagerScreen(),
    );
  }
}

// Plan model
class Plan {
  String name;
  String description;
  DateTime date;
  bool isCompleted;
  String priority; // For extra task (graduate students)

  Plan({
    required this.name,
    required this.description,
    required this.date,
    this.isCompleted = false,
    this.priority = 'Medium', // Default priority
  });
}

class PlanManagerScreen extends StatefulWidget {
  const PlanManagerScreen({super.key});

  @override
  _PlanManagerScreenState createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  List<Plan> plans = [];

  // Method to add a new plan
  void _addPlan(
    String name,
    String description,
    DateTime date,
    String priority,
  ) {
    setState(() {
      plans.add(
        Plan(
          name: name,
          description: description,
          date: date,
          priority: priority,
        ),
      );
      _sortPlansByPriority(); // Sort after adding (for extra task)
    });
  }

  // Method to update a plan
  void _updatePlan(
    int index,
    String name,
    String description,
    DateTime date,
    String priority,
  ) {
    setState(() {
      plans[index].name = name;
      plans[index].description = description;
      plans[index].date = date;
      plans[index].priority = priority;
      _sortPlansByPriority(); // Sort after updating (for extra task)
    });
  }

  // Method to toggle completion status
  void _toggleCompletion(int index) {
    setState(() {
      plans[index].isCompleted = !plans[index].isCompleted;
    });
  }

  // Method to delete a plan
  void _deletePlan(int index) {
    setState(() {
      plans.removeAt(index);
    });
  }

  // Sort plans by priority (High > Medium > Low)
  void _sortPlansByPriority() {
    setState(() {
      plans.sort((a, b) {
        const priorityOrder = {'High': 0, 'Medium': 1, 'Low': 2};
        return priorityOrder[a.priority]!.compareTo(priorityOrder[b.priority]!);
      });
    });
  }

  // Show modal to create or edit a plan
  void _showPlanModal({Plan? plan, int? index}) {
    final isEditing = plan != null;
    final nameController = TextEditingController(text: plan?.name ?? '');
    final descController = TextEditingController(text: plan?.description ?? '');
    DateTime selectedDate = plan?.date ?? DateTime.now();
    String selectedPriority = plan?.priority ?? 'Medium';

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Plan Name'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Date: '),
                  TextButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (pickedDate != null) {
                        setState(() => selectedDate = pickedDate);
                      }
                    },
                    child: Text('${selectedDate.toLocal()}'.split(' ')[0]),
                  ),
                ],
              ),
              DropdownButton<String>(
                value: selectedPriority,
                items:
                    ['Low', 'Medium', 'High']
                        .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                        .toList(),
                onChanged: (value) {
                  setState(() => selectedPriority = value!);
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty) {
                    if (isEditing && index != null) {
                      _updatePlan(
                        index,
                        nameController.text,
                        descController.text,
                        selectedDate,
                        selectedPriority,
                      );
                    } else {
                      _addPlan(
                        nameController.text,
                        descController.text,
                        selectedDate,
                        selectedPriority,
                      );
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(isEditing ? 'Update Plan' : 'Create Plan'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Adoption & Travel Planner')),
      body: Column(
        children: [
          // Placeholder for drag-and-drop calendar (to be implemented)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('Interactive Calendar (Drag Plans Here)'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: plans.length,
              itemBuilder: (context, index) {
                final plan = plans[index];
                return Dismissible(
                  key: Key(plan.name + index.toString()), // Ensure unique key
                  confirmDismiss: (direction) async {
                    // Toggle completion status instead of dismissing
                    _toggleCompletion(index);
                    return false; // Prevent the Dismissible from being removed
                  },
                  background: Container(
                    color: Colors.green,
                    child: const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Icon(Icons.check, color: Colors.white),
                      ),
                    ),
                  ),
                  secondaryBackground: Container(
                    color: Colors.green,
                    child: const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: Icon(Icons.check, color: Colors.white),
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    onLongPress: () => _showPlanModal(plan: plan, index: index),
                    onDoubleTap: () => _deletePlan(index),
                    child: ListTile(
                      title: Text(
                        '${plan.name} [${plan.priority}]',
                        style: TextStyle(
                          color: plan.isCompleted ? Colors.grey : Colors.black,
                          decoration:
                              plan.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                        ),
                      ),
                      subtitle: Text(
                        '${plan.description} - ${plan.date.toLocal()}'.split(
                          ' ',
                        )[0],
                      ),
                      tileColor:
                          plan.isCompleted ? Colors.green[100] : Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPlanModal(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
