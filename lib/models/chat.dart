class Chat {
  String? key;
  String senderId;
  String? message;
  bool? seen;
  String? createdAt;
  String? timeStamp;
  String senderName;
  String receiverId;
  String? image;
  String? gif;
  String? audio;
  int likeCount;

  Chat(
      {this.key,
      required this.senderId,
      this.message,
      required this.seen,
      this.createdAt,
      required this.receiverId,
      required this.senderName,
      this.timeStamp,
      this.image,
      this.gif,
      this.audio,
      required this.likeCount});

  factory Chat.fromJson(Map<dynamic, dynamic> json) => Chat(
      key: json["key"],
      senderId: json["sender_id"],
      message: json["message"],
      seen: json["seen"] ?? false,
      createdAt: json["created_at"],
      timeStamp: json['timeStamp'],
      senderName: json["senderName"],
      receiverId: json["receiverId"],
      image: json["image"],
      gif: json["gif"],
      audio: json["audio"],
      likeCount: json["likes"]);

  Map<String, dynamic> toJson() => {
        "key": key,
        "sender_id": senderId,
        "message": message,
        "receiverId": receiverId,
        "seen": seen ?? false,
        "created_at": createdAt,
        "senderName": senderName,
        "timeStamp": timeStamp,
        "image": image,
        "gif": gif,
        "audio": audio,
        "likes": likeCount
      };
}
