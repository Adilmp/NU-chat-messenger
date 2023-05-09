class ChatRoomModel {
  String? chatroomid;
  Map<String, bool>? participants;
  String? lastMessage;
  bool? isTyping;
  String? typingUser; // New field

  ChatRoomModel({
    this.chatroomid,
    this.participants,
    this.lastMessage,
    this.isTyping,
    this.typingUser, // New field
  });

  ChatRoomModel.fromMap(Map<String, dynamic> map) {
    chatroomid = map['chatroomid'];
    participants = (map['participants'] as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, value as bool));
    lastMessage = map['lastMessage'];
    isTyping = map['isTyping'];
    typingUser = map['typingUser']; // New field
  }

  Map<String, dynamic> toMap() {
    return {
      'chatroomid': chatroomid,
      'participants': participants,
      'lastMessage': lastMessage,
      'isTyping': isTyping,
      'typingUser': typingUser, // New field
    };
  }
}
