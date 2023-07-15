import 'package:equatable/equatable.dart';

class GroupChat extends Equatable {
  final String groupName;
  final Duration timeRemaining;
  final int participantCount;

  GroupChat({
    required this.groupName,
    required this.timeRemaining,
    required this.participantCount,
  });

  // Add a factory method to deserialize from JSON
  factory GroupChat.fromJson(Map<String, dynamic> json) {
    return GroupChat(
      groupName: json['groupName'],
      timeRemaining: Duration(milliseconds: json['timeRemaining']),
      participantCount: json['participantCount'],
    );
  }

  // Implement the toJson method to serialize to JSON
  Map<String, dynamic> toJson() {
    return {
      'groupName': groupName,
      'timeRemaining': timeRemaining.inMilliseconds,
      'participantCount': participantCount,
    };
  }

  @override
  List<Object?> get props => [groupName, timeRemaining, participantCount];
}
