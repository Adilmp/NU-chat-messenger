class MessageModel {
  String? messageid;
  String? sender;
  String? text;
  bool? seen;
  late bool isVideo;
  DateTime? createdon;

  MessageModel({
    this.messageid,
    this.sender,
    this.text,
    this.seen,
    this.isVideo = false,
    this.createdon,
  });

  MessageModel.fromMap(Map<String, dynamic> map) {
    messageid = map["messageid"];
    sender = map["sender"];
    text = map["text"];
    seen = map["seen"];
    isVideo = map["isVideo"] ?? false;
    createdon = map["createdon"].toDate();
  }

  Map<String, dynamic> toMap() {
    return {
      "messageid": messageid,
      "sender": sender,
      "text": text,
      "seen": seen,
      "isVideo": isVideo,
      "createdon": createdon,
    };
  }
}
