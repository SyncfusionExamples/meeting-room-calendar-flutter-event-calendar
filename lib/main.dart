import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math';
import 'package:syncfusion_flutter_calendar/calendar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: MeetingRoomCalendar(),
      ),
    );
  }
}

/// Widget class of shift scheduler calendar
class MeetingRoomCalendar extends StatefulWidget {
  /// Creates calendar of shift scheduler
  const MeetingRoomCalendar({Key? key}) : super(key: key);

  @override
  _MeetingRoomCalendarState createState() => _MeetingRoomCalendarState();
}

class _MeetingRoomCalendarState extends State<MeetingRoomCalendar> {
  final List<String> _subjectCollection = <String>[];
  final List<Color> _colorCollection = <Color>[];
  final List<Appointment> _meetingCollection = <Appointment>[];
  final List<CalendarResource> _meetingRoomCollection = <CalendarResource>[];
  final List<TimeRegion> _specialTimeRegions = <TimeRegion>[];
  final List<String> _nameCollection = <String>[];
  final List<String> _colorNames = <String>[];
  final List<Icon> icons = <Icon>[];

  final CalendarController _calendarController = CalendarController();

  final List<CalendarView> _allowedViews = <CalendarView>[
    CalendarView.timelineDay,
    CalendarView.timelineWeek,
    CalendarView.timelineWorkWeek,
    CalendarView.timelineMonth
  ];

  late _MeetingDataSource _events;
  late DateTime _minDate;
  DateTime? _visibleStartDate, _visibleEndDate;
  List<Appointment> _visibleAppointments = <Appointment>[];

  @override
  void initState() {
    _minDate = DateTime.now();
    _calendarController.view = CalendarView.timelineDay;

    icons.add(
        const Icon(Icons.people,color: Colors.white,));
    icons.add(
        const Icon(Icons.home_work,color: Colors.white));
    icons.add(
        const Icon(Icons.present_to_all_rounded,color: Colors.white,));
    icons.add(
        const Icon(Icons.people_outline,color: Colors.white,));
    icons.add(
        const Icon(Icons.people_alt_rounded,color: Colors.white,));

    _addAppointmentDetails();
    _addResourceDetails();
    _addResources();
    _addSpecialRegions();

    _addAppointments();
    _events = _MeetingDataSource(_meetingCollection, _meetingRoomCollection);
    super.initState();
  }

  void _onViewChanged(ViewChangedDetails visibleDatesChangedDetails) {
    if (_visibleStartDate != null && _visibleEndDate != null) {
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        setState(() {});
      });
    }
    _visibleStartDate = visibleDatesChangedDetails.visibleDates[0];
    _visibleEndDate = visibleDatesChangedDetails
        .visibleDates[visibleDatesChangedDetails.visibleDates.length - 1];
    _visibleAppointments = _events.getVisibleAppointments(
        _visibleStartDate!, '', _visibleEndDate!);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: _getMeetingRoomCalendar(_events, _onViewChanged),
      ),
    );
  }

  /// Creates the required resource details as list
  void _addResourceDetails() {
    _nameCollection.add('Jammy');
    _nameCollection.add('Tweety');
    _nameCollection.add('Nestle');
    _nameCollection.add('Phoenix');
    _nameCollection.add('Mission');
    _nameCollection.add('Emilia');
  }

  /// Creates the required appointment details as a list.
  void _addAppointmentDetails() {
    _subjectCollection.add('General Meeting');
    _subjectCollection.add('Plan Execution');
    _subjectCollection.add('Project Plan');
    _subjectCollection.add('Consulting');
    _subjectCollection.add('Support');
    _subjectCollection.add('Development Meeting');
    _subjectCollection.add('Scrum');
    _subjectCollection.add('Project Completion');
    _subjectCollection.add('Release updates');
    _subjectCollection.add('Performance Check');

    _colorCollection.add(const Color(0xFF0F8644));
    _colorCollection.add(const Color(0xFF8B1FA9));
    _colorCollection.add(const Color(0xFFD20100));
    _colorCollection.add(const Color(0xFFFC571D));
    _colorCollection.add(const Color(0xFF85461E));
    _colorCollection.add(const Color(0xFF36B37B));
    _colorCollection.add(const Color(0xFF3D4FB5));
    _colorCollection.add(const Color(0xFFE47C73));
    _colorCollection.add(const Color(0xFF636363));

    _colorNames.add('Green');
    _colorNames.add('Purple');
    _colorNames.add('Red');
    _colorNames.add('Orange');
    _colorNames.add('Caramel');
    _colorNames.add('Light Green');
    _colorNames.add('Blue');
    _colorNames.add('Peach');
    _colorNames.add('Gray');
  }

  /// Method that creates the resource collection for the calendar, with the
  /// required information.
  void _addResources() {
    final Random random = Random();
    for (int i = 0; i < _nameCollection.length; i++) {
      _meetingRoomCollection.add(CalendarResource(
        displayName: _nameCollection[i],
        id: '000' + i.toString(),
        color: _colorCollection[i],
      ));
    }
  }

  /// Method that creates the collection the time region for calendar, with
  /// required information.
  void _addSpecialRegions() {
    final DateTime date = DateTime.now();
    final Random random = Random();
    for (int i = 0; i < _meetingRoomCollection.length; i++) {
      _specialTimeRegions.add(TimeRegion(
          startTime: DateTime(date.year, date.month, date.day, 13, 0, 0),
          endTime: DateTime(date.year, date.month, date.day, 14, 0, 0),
          text: 'Lunch',
          color: Colors.grey.withOpacity(0.2),
          resourceIds: <Object>[_meetingRoomCollection[i].id],
          recurrenceRule: 'FREQ=DAILY;INTERVAL=1'));

      if (i.isEven) {
        continue;
      }

      final DateTime startDate = DateTime(
          date.year, date.month, date.day, 17 + random.nextInt(7), 0, 0);

      _specialTimeRegions.add(TimeRegion(
        startTime: startDate,
        endTime: startDate.add(const Duration(hours: 1)),
        text: 'Not Available',
        color: Colors.grey.withOpacity(0.2),
        enablePointerInteraction: false,
        resourceIds: <Object>[_meetingRoomCollection[i].id],
      ));
    }
  }

  /// Method that creates the collection the data source for calendar, with
  /// required information.
  void _addAppointments() {
    final Random random = Random();
    for (int i = 0; i < _meetingRoomCollection.length; i++) {
      final List<Object> _roomId = <Object>[_meetingRoomCollection[i].id];
      if (i == _meetingRoomCollection.length - 1 || i.isEven) {
        int index = random.nextInt(5);
        index = index == i ? index + 1 : index;
        final Object roomId = _meetingRoomCollection[index].id;
        if (roomId is String) {
          _roomId.add(roomId);
        }

      }

      for (int k = 0; k < 365; k++) {
        if (_roomId.length > 1 && k.isEven) {
          continue;
        }
        for (int j = 0; j < 10; j++) {

          final DateTime date = DateTime.now().add(Duration(days: k + j));
          int startHour = 9 + random.nextInt(6);
          startHour =
              startHour >= 13 && startHour <= 14 ? startHour + 1 : startHour;
          final DateTime _startTime =
              DateTime(date.year, date.month, date.day, startHour, 0, 0);
          if (_startTime.isBefore(_minDate)) {
            continue;
          }

          _meetingCollection.add(Appointment(
              startTime: _startTime,
              endTime: _startTime.add(const Duration(hours: 1)),
              subject: _subjectCollection[random.nextInt(8)],
              color: _meetingRoomCollection[i % 5].color,
              startTimeZone: '',
              endTimeZone: '',
              resourceIds: _roomId));
        }
      }
    }
  }
  /// Returns the widget for special time regions in the calendar.
  Widget _getSpecialRegionWidget(
      BuildContext context, TimeRegionDetails details) {
    if (details.region.text == 'Lunch') {
      return Container(
        color: details.region.color,
        alignment: Alignment.center,
        child: Icon(
          Icons.restaurant_menu,
          color: Colors.grey.withOpacity(0.5),
        ),
      );
    } else if (details.region.text == 'Not Available') {
      return Container(
        color: details.region.color,
        alignment: Alignment.center,
        child: Icon(
          Icons.block,
          color: Colors.grey.withOpacity(0.5),
        ),
      );
    }

    return Container(color: details.region.color);
  }

  /// Returns the calendar widget based on the properties passed
  SfCalendar _getMeetingRoomCalendar(
      [CalendarDataSource? _calendarDataSource, dynamic viewChangedCallback]) {
    return SfCalendar(
      showDatePickerButton: true,
      controller: _calendarController,
      allowDragAndDrop: true,
      allowedViews: _allowedViews,
      minDate: _minDate,
      timeRegionBuilder: _getSpecialRegionWidget,
      specialRegions: _specialTimeRegions,
      showNavigationArrow: true,
      dataSource: _calendarDataSource,
      onViewChanged: viewChangedCallback,
      resourceViewHeaderBuilder: _resourceHeaderBuilder,
    );
  }

  /// Returns the widget for resource header.
  Widget _resourceHeaderBuilder(
      BuildContext context, ResourceViewHeaderDetails details) {
    final Random random = Random();

    int capacity = 0;
    if (_visibleAppointments.isNotEmpty) {
      capacity = 0;
      for (int i = 0; i < _visibleAppointments.length; i++) {
        final Appointment visibleApp = _visibleAppointments[i];
        if (visibleApp.resourceIds != null &&
            visibleApp.resourceIds!.isNotEmpty &&
            visibleApp.resourceIds!.contains(details.resource.id)) {
          capacity++;
        }
      }
    }

    String capacityString = 'Events';
    if (capacity >= 5) {
      capacityString = 'Conference';
    }

    return Container(
      color: details.resource.color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          icons[random.nextInt(5).toInt()],
          Text(
            details.resource.displayName,
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'Events: ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
                Container(
                  child: Text(
                    capacity.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// An object to set the appointment collection data source to collection, which
/// used to map the custom appointment data to the calendar appointment, and
/// allows to add, remove or reset the appointment collection.
class _MeetingDataSource extends CalendarDataSource {
  _MeetingDataSource(
      List<Appointment> source, List<CalendarResource> resourceColl) {
    appointments = source;
    resources = resourceColl;
  }
}
