import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:groupchat_firebase/pages/groupgridpage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  Future<String> getRandomImageForDate(DateTime date) async {
    DatabaseReference historyRef =
        FirebaseDatabase.instance.reference().child('history_posts');
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);

    DatabaseEvent event = await historyRef
        .orderByChild('createdAt')
        .startAt(formattedDate)
        .endAt(formattedDate + "\uf8ff")
        .once();

    if (event.snapshot.exists && event.snapshot.value is Map) {
      Map<dynamic, dynamic> historyMap =
          Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      List<String> imageUrls = [];

      historyMap.forEach((groupKey, groupValue) {
        if (groupValue is Map) {
          Map<dynamic, dynamic> historyData =
              Map<dynamic, dynamic>.from(groupValue);

          if (historyData.containsKey('createdAt') &&
              historyData['createdAt'].startsWith(formattedDate)) {
            if (historyData.containsKey('imageBackPath') &&
                historyData['imageBackPath'] != null) {
              imageUrls.add(historyData['imageBackPath']);
            }
          }
        }
      });

      if (imageUrls.isNotEmpty) {
        int randomIndex = Random().nextInt(imageUrls.length);
        return imageUrls[randomIndex];
      }
    }
    return ''; // Return an empty string if no image is found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar View'),
        backgroundColor:
            Colors.black, // AppBar background color to match the page
        elevation: 0, // Remove shadow for a seamless appearance
      ),
      body: TableCalendar(
        firstDay: DateTime.utc(2010, 10, 16),
        lastDay: DateTime.utc(2030, 3, 14),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        calendarFormat: _calendarFormat,
        onDaySelected: (selectedDay, focusedDay) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupGridPage(selectedDate: selectedDay),
            ),
          );

          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
        ),
        calendarBuilders: CalendarBuilders(
          selectedBuilder: (context, date, _) {
            return FutureBuilder<String>(
              future: getRandomImageForDate(date),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData &&
                    snapshot.data!.isNotEmpty) {
                  return _buildDateCellWithImage(date, snapshot.data!);
                } else {
                  return _buildDateCell(date);
                }
              },
            );
          },
          todayBuilder: (context, date, _) {
            return FutureBuilder<String>(
              future: getRandomImageForDate(date),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData &&
                    snapshot.data!.isNotEmpty) {
                  return _buildDateCellWithImage(date, snapshot.data!);
                } else {
                  return _buildDateCell(date);
                }
              },
            );
          },
          defaultBuilder: (context, date, _) {
            return FutureBuilder<String>(
              future: getRandomImageForDate(date),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData &&
                    snapshot.data!.isNotEmpty) {
                  return _buildDateCellWithImage(date, snapshot.data!);
                } else {
                  return _buildDateCell(date);
                }
              },
            );
          },
        ),
      ),
      backgroundColor: Colors.black,
    );
  }

  Widget _buildDateCell(DateTime date) {
    return Container(
      margin: const EdgeInsets.all(4.0), // Adjust margins as needed
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        shape: BoxShape.circle,
      ),
      width: 25, // Smaller size for the background circle
      height: 25, // Smaller size for the background circle
      child: Text(
        date.day.toString(),
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildDateCellWithImage(DateTime date, String imageUrl) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 30, // Adjust the square size
          height: 40, // Adjust the square size
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (BuildContext context, Object exception,
                StackTrace? stackTrace) {
              debugPrint(
                  'Failed to load image for ${date.toString()}: $exception');
              return _buildDateCell(date);
            },
          ),
        ),
        Text(
          date.day.toString(),
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
