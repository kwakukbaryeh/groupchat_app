import 'package:equatable/equatable.dart';

class GroupChat extends Equatable {
  String? key;
  final String groupName;
  final int participantCount;
  final DateTime createdAt;
  final DateTime? expiryDate;

  GroupChat({
    this.key,
    required this.groupName,
    required this.participantCount,
    required this.createdAt,
    this.expiryDate,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'groupName': groupName,
      'participantCount': participantCount,
      'createdAt': createdAt.toUtc().toString(),
      'expiryDate': expiryDate?.toUtc().toString(),
    };
  }

  Duration? getRemainingTime() {
    if (expiryDate != null) {
      final now = DateTime.now();
      if (now.isBefore(expiryDate!)) {
        return expiryDate!.difference(now);
      }
    }
    return null;
  }

  @override
  List<Object?> get props =>
      [key, groupName, participantCount, createdAt, expiryDate];
}
