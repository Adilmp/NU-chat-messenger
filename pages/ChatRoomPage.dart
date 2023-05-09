import 'dart:developer';
import 'dart:io';
import 'package:chatapp/main.dart';
import 'package:chatapp/models/ChatRoomModel.dart';
import 'package:chatapp/models/MessageModel.dart';
import 'package:chatapp/models/UserModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:video_player/video_player.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User firebaseUser;

  const ChatRoomPage({Key? key, required this.targetUser, required this.chatroom, required this.userModel, required this.firebaseUser}) : super(key: key);

  @override
  _ChatRoomPageState createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  bool isTyping = false;
VideoPlayerController? _videoPlayerController;

  TextEditingController messageController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final ImagePicker _videoPicker = ImagePicker();

  Future<String?> _uploadFile(File file) async {
    String fileName = Uuid().v4();
    Reference storageReference =
        FirebaseStorage.instance.ref().child('chat_files/$fileName');
    UploadTask uploadTask = storageReference.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadURL = await taskSnapshot.ref.getDownloadURL();
    return downloadURL;
  }

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedImage =
        await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      String? imageUrl = await _uploadFile(imageFile);

      if (imageUrl != null) {
        sendMessage(msg: imageUrl);
      }
    }
  }

Future<void> _pickVideoFromGallery() async {
  final XFile? pickedVideo =
      await _videoPicker.pickVideo(source: ImageSource.gallery);

  if (pickedVideo != null) {
    File videoFile = File(pickedVideo.path);
    String? videoUrl = await _uploadFile(videoFile);

    if (videoUrl != null) {
      _videoPlayerController = VideoPlayerController.network(videoUrl)
        ..initialize().then((_) {
          setState(() {}); // Trigger a rebuild to show the video
          _videoPlayerController!.play(); // Start playing the video
        });

      sendMessage(msg: videoUrl, isVideo: true);
    }
  }
}



  void sendMessage({String? msg, bool isVideo = false}) async {
    String messageText = msg ?? messageController.text.trim();
    messageController.clear();

    if (messageText.isNotEmpty) {
      // Send Message
      MessageModel newMessage = MessageModel(
        messageid: uuid.v1(),
        sender: widget.userModel.uid,
        createdon: DateTime.now(),
        text: messageText,
        seen: false,
        isVideo: isVideo,
      );

      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .collection("messages")
          .doc(newMessage.messageid)
          .set(newMessage.toMap());

      widget.chatroom.lastMessage = messageText;
      widget.chatroom.isTyping = false; // Set typing state to false
      FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(widget.chatroom.chatroomid)
          .set(widget.chatroom.toMap());

      log("Message Sent!");
    }
  }
@override
void dispose() {
  _videoPlayerController?.dispose();
  super.dispose();
}

Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[300],
            backgroundImage: NetworkImage(widget.targetUser.profilepic.toString()),
          ),
          SizedBox(width: 10,),
          Text(widget.targetUser.fullname.toString()),
        ],
      ),
    ),
    body: SafeArea(
      child: Container(
        child: Column(
          children: [
            if (widget.chatroom.isTyping == true)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  "Typing...",
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance.collection("chatrooms").doc(widget.chatroom.chatroomid).collection("messages").orderBy("createdon", descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if(snapshot.connectionState == ConnectionState.active) {
                      if(snapshot.hasData) {
                        QuerySnapshot dataSnapshot = snapshot.data as QuerySnapshot;

                        return ListView.builder(
                          reverse: true,
                          itemCount: dataSnapshot.docs.length,
                          itemBuilder: (context, index) {
                            MessageModel currentMessage = MessageModel.fromMap(dataSnapshot.docs[index].data() as Map<String, dynamic>);

                            if (currentMessage.text != null && currentMessage.text!.startsWith('http')) {
                              
                              
                              return Row(
                          mainAxisAlignment: (currentMessage.sender == widget.userModel.uid)
        ? MainAxisAlignment.end
        : MainAxisAlignment.start,
    children: [
      Container(
        margin: EdgeInsets.symmetric(vertical: 2),
        child: currentMessage.isVideo
            ? AspectRatio(
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController!),
              )
            : Image.network(
                currentMessage.text!,
                fit: BoxFit.cover,
                width: 200,
                height: 200,
              ),
      ),
    ],
  );
}else {
                              return Row(
                                mainAxisAlignment: (currentMessage.sender == widget.userModel.uid)
                                    ? MainAxisAlignment.end
                                    : MainAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (currentMessage.sender == widget.userModel.uid)
                                          ? Colors.grey
                                          : Theme.of(context).colorScheme.secondary,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      currentMessage.text.toString(),
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                          },
                        );
                      } else if(snapshot.hasError) {
                        return Center(
                          child: Text("An error occurred! Please check your internet connection."),
                        );
                      } else {
                        return Center(
                          child: Text("Say hi to your new friend"),
                        );
                      }
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ),
            Container(
              color: Colors.grey[200],
              padding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 5,
              ),
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: messageController,
                      maxLines: null,
                      onChanged: (text) {
                        setState(() {
                          isTyping = text.isNotEmpty;
                        });
                      },
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          onPressed: _pickImageFromGallery,
                          icon: Icon(Icons.photo),
                        ),
                        border: InputBorder.none,
                        hintText: "Enter message",
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: _pickVideoFromGallery, // Updated onPressed for video button
                      icon: Icon(
                        Icons.video_library, // Icon for video button
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  IconButton(
                    onPressed: () {
                      sendMessage();
                    },
                    icon: Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}