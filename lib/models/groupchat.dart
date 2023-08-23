import 'package:equatable/equatable.dart';

class GroupChat extends Equatable {
  String? key;
  final String creatorId;
  final String groupName;
  final int participantCount;
  final DateTime createdAt;
  final DateTime? expiryDate;
  Duration? remainingTime;
  List<String> participantIds;
  List<String> participantFcmTokens;
  String? firstPost;
  String? imageBackPath;

  GroupChat(
      {this.key,
      required this.creatorId,
      required this.groupName,
      required this.participantCount,
      required this.createdAt,
      required this.expiryDate,
      required this.participantIds,
      required this.participantFcmTokens,
      this.firstPost,
      this.imageBackPath});

  factory GroupChat.fromJson(Map<String, dynamic> json) {
    return GroupChat(
      key: json['key'],
      firstPost: json['firstPost'],
      imageBackPath: json['imageBackPath'],
      creatorId: json["creatorId"],
      groupName: json['groupName'],
      participantCount: json['participantCount'],
      createdAt: DateTime.parse(json['createdAt']),
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'])
          : null,
      participantFcmTokens: json["participantFcmTokens"] != null
          ? List<String>.from(json['participantFcmTokens'])
          : [],
      participantIds: json['participantIds'] != null
          ? List<String>.from(json['participantIds'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'firstPost': firstPost,
      'imageBackPath': imageBackPath,
      'creatorId': creatorId,
      'groupName': groupName,
      'participantCount': participantCount,
      'createdAt': createdAt.toUtc().toString(),
      'expiryDate': expiryDate?.toUtc().toString(),
      'participantIds': participantIds,
      'participantFcmTokens': participantFcmTokens
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
  List<Object?> get props => [
        key,
        creatorId,
        groupName,
        participantCount,
        createdAt,
        expiryDate,
        participantIds,
        participantFcmTokens
      ];
}
