class GroupData {
  final String groupId;
  final String groupName;
  final String groupImage;

  GroupData({
    required this.groupId,
    required this.groupName,
    required this.groupImage,
  });

  // Create a factory method to convert a Map to a GroupData object
  factory GroupData.fromMap(Map<String, dynamic> map) {
    return GroupData(
      groupId: map['groupId'],
      groupName: map['groupName'],
      groupImage: map['groupImage'],
    );
  }
}
