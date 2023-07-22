import 'package:equatable/equatable.dart';

class GroupChat extends Equatable {
  String? key;
  final String groupName;
  final int participantCount;
  final DateTime createdAt;
  final DateTime? expiryDate;
  Duration? remainingTime;
  List<String>
      participantIds; // List of user IDs participating in the group chat

  GroupChat({
    this.key,
    required this.groupName,
    required this.participantCount,
    required this.createdAt,
    this.expiryDate,
    this.participantIds = const [], // Initialize with an empty list
  });

  factory GroupChat.fromJson(Map<String, dynamic> json) {
    return GroupChat(
      key: json['key'],
      groupName: json['groupName'],
      participantCount: json['participantCount'],
      createdAt: DateTime.parse(json['createdAt']),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      participantIds: json['participantIds'] != null
          ? List<String>.from(json['participantIds'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'groupName': groupName,
      'participantCount': participantCount,
      'createdAt': createdAt.toUtc().toString(),
      'expiryDate': expiryDate?.toUtc().toString(),
      'participantIds': participantIds,
    };
  }

  void updateRemainingTime() {
    if (expiryDate != null) {
      final now = DateTime.now();
      if (now.isBefore(expiryDate!)) {
        remainingTime = expiryDate!.difference(now);
      } else {
        remainingTime = Duration.zero;
      }
    } else {
      remainingTime = null;
    }
  }

  @override
  List<Object?> get props =>
      [key, groupName, participantCount, createdAt, expiryDate, participantIds];
}
