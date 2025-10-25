import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

// Models
class Medicine {
  String id;
  String name;
  String type;
  int timesPerDay;
  String? dosage;
  List<String> times;
  bool beforeFood;
  bool afterFood;
  int quantity;
  int quantityLeft;
  DateTime createdAt;

  Medicine({
    required this.id,
    required this.name,
    required this.type,
    required this.timesPerDay,
    this.dosage,
    required this.times,
    this.beforeFood = false,
    this.afterFood = false,
    required this.quantity,
    required this.quantityLeft,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'timesPerDay': timesPerDay,
      'dosage': dosage,
      'times': times,
      'beforeFood': beforeFood,
      'afterFood': afterFood,
      'quantity': quantity,
      'quantityLeft': quantityLeft,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Medicine.fromMap(Map<dynamic, dynamic> map) {
    return Medicine(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      timesPerDay: map['timesPerDay'],
      dosage: map['dosage'],
      times: List<String>.from(map['times']),
      beforeFood: map['beforeFood'] ?? false,
      afterFood: map['afterFood'] ?? false,
      quantity: map['quantity'],
      quantityLeft: map['quantityLeft'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('medicines');
  runApp(const MedicineReminderApp());
}

class MedicineReminderApp extends StatelessWidget {
  const MedicineReminderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicine Reminder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final box = Hive.box('medicines');
  String selectedPeriod = 'This Month';

  List<Medicine> getMedicines() {
    final medicineList = box.get('medicineList', defaultValue: []);
    return (medicineList as List)
        .map((e) => Medicine.fromMap(e))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final medicines = getMedicines();
    final now = DateTime.now();
    final todayMedicines = medicines.where((m) {
      return m.createdAt.year == now.year &&
          m.createdAt.month == now.month &&
          m.createdAt.day == now.day;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF7ECCC8),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.menu, color: Colors.white),
                  const Text(
                    'Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Color(0xFF7ECCC8)),
                  ),
                ],
              ),
            ),

            // Main Content Card
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Medicine Reminder',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Period Selector
                          Row(
                            children: [
                              _buildPeriodChip('This Month'),
                              const SizedBox(width: 10),
                              _buildPeriodChip('This Week'),
                              const SizedBox(width: 10),
                              _buildPeriodChip('This Year'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Day Selector
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: 7,
                        itemBuilder: (context, index) {
                          final day = now.add(Duration(days: index - 3));
                          final isToday = index == 3;
                          return _buildDayChip(day, isToday);
                        },
                      ),
                    ),

                    // Medicine Grid
                    Expanded(
                      child: medicines.isEmpty
                          ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.medical_services_outlined,
                                size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              'No medicines added yet',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                          : GridView.builder(
                        padding: const EdgeInsets.all(20),
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: medicines.length,
                        itemBuilder: (context, index) {
                          return _buildMedicineCard(medicines[index]);
                        },
                      ),
                    ),

                    // Add Button
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddMedicinePage(),
                              ),
                            ).then((_) => setState(() {}));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7ECCC8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'ADD MEDICINE',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label) {
    final isSelected = selectedPeriod == label;
    return GestureDetector(
      onTap: () => setState(() => selectedPeriod = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7ECCC8) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDayChip(DateTime day, bool isToday) {
    final dayName = DateFormat('EEE').format(day);
    return Container(
      width: 60,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: isToday ? const Color(0xFF7ECCC8) : Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dayName.length > 3 ? dayName.substring(0, 3) : dayName,
            style: TextStyle(
              color: isToday ? Colors.white : Colors.grey[600],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            day.day.toString(),
            style: TextStyle(
              color: isToday ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineCard(Medicine medicine) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReminderDetailPage(medicine: medicine),
          ),
        ).then((_) => setState(() {}));
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF7ECCC8),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _getMedicineIcon(medicine.type),
              color: Colors.white,
              size: 40,
            ),
            const Spacer(),
            Text(
              medicine.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 5),
            Text(
              '${medicine.timesPerDay} Times Today',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getMedicineIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pills':
      case 'capsules':
        return Icons.medication;
      case 'syrup':
        return Icons.local_drink;
      case 'injection':
        return Icons.vaccines;
      default:
        return Icons.medical_services;
    }
  }
}

class AddMedicinePage extends StatefulWidget {
  const AddMedicinePage({Key? key}) : super(key: key);

  @override
  State<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final _nameController = TextEditingController();
  final _daysController = TextEditingController(text: '28');
  String selectedType = 'Pills';
  bool beforeFood = false;
  bool afterFood = false;
  final List<TimeOfDay> notificationTimes = [const TimeOfDay(hour: 7, minute: 0)];
  int quantity = 224;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Plan',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Medicine Name',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: '4 Pills'),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: TextField(
                    controller: _daysController,
                    decoration: InputDecoration(
                      hintText: '28 Days',
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Food & Pills',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFoodOption('Before Dinner', beforeFood, (val) {
                  setState(() => beforeFood = val);
                }),
                _buildFoodOption('After Dinner', afterFood, (val) {
                  setState(() => afterFood = val);
                }),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'Notification',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ...notificationTimes.map((time) => _buildTimeChip(
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} am',
                  true,
                )),
                _buildTimeChip('10:00 am', false),
                _buildTimeChip('11:00 am', false),
                _buildAddTimeButton(),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quantity',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  '$quantity Drops',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveMedicine,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7ECCC8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'DONE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodOption(String label, bool value, Function(bool) onChanged) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant, color: Colors.grey[400]),
            const SizedBox(width: 5),
            Icon(Icons.medication, color: Colors.grey[400]),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
        Checkbox(
          value: value,
          onChanged: (val) => onChanged(val ?? false),
          activeColor: const Color(0xFF7ECCC8),
        ),
      ],
    );
  }

  Widget _buildTimeChip(String time, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF7ECCC8) : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        time,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildAddTimeButton() {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time != null) {
          setState(() => notificationTimes.add(time));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.add, color: Color(0xFF7ECCC8)),
      ),
    );
  }

  void _saveMedicine() {
    if (_nameController.text.isEmpty) return;

    final box = Hive.box('medicines');
    final medicines = box.get('medicineList', defaultValue: []) as List;

    final medicine = Medicine(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      type: selectedType,
      timesPerDay: notificationTimes.length,
      times: notificationTimes
          .map((t) => '${t.hour}:${t.minute}')
          .toList(),
      beforeFood: beforeFood,
      afterFood: afterFood,
      quantity: quantity,
      quantityLeft: quantity,
      createdAt: DateTime.now(),
    );

    medicines.add(medicine.toMap());
    box.put('medicineList', medicines);

    Navigator.pop(context);
  }
}

class ReminderDetailPage extends StatelessWidget {
  final Medicine medicine;

  const ReminderDetailPage({Key? key, required this.medicine}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Reminder',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(
                        Icons.medication,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          medicine.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'Next Dose',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const Text(
                          '6 pm',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'This Month',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildCalendarGrid(),
                  const SizedBox(height: 30),
                  const Text(
                    'Dose',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${medicine.timesPerDay} Times - 11 am, 6 pm, 8, 12 pm',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Quantity',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Total ${medicine.quantity} Capsules - ${medicine.quantityLeft} Capsules Left',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7ECCC8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  'CHANGE SCHEDULE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: daysInMonth,
      itemBuilder: (context, index) {
        final day = index + 1;
        final isPast = day < now.day;
        return Container(
          decoration: BoxDecoration(
            color: isPast ? const Color(0xFF7ECCC8) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              day.toString(),
              style: TextStyle(
                color: isPast ? Colors.white : Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }
}