import 'package:chatapp/models/ChatRoomModel.dart';
import 'package:chatapp/models/FirebaseHelper.dart';
import 'package:chatapp/models/UserModel.dart';
import 'package:chatapp/pages/ChatRoomPage.dart';
import 'package:chatapp/pages/LoginPage.dart';
import 'package:chatapp/pages/SearchPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class HomePage extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const HomePage({Key? key, required this.userModel, required this.firebaseUser}) : super(key: key);

  Future<void> _selectMedia() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Handle the selected media file (e.g., send it to the chat room)
      File mediaFile = File(pickedFile.path);
      // Implement the logic to send the media file
    }
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("NU messenger"),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return LoginPage();
                  },
                ),
              );
            },
            icon: Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("chatrooms").where("participants.${widget.userModel.uid}", isEqualTo: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot chatRoomSnapshot = snapshot.data!;
                  List<ChatRoomModel> normalChats = [];
                  List<ChatRoomModel> mutualChats = [];
                  List<UserModel> otherUsers = []; // Added list to store other registered users

                  // Separate normal chats and mutual chats
                  for (var doc in chatRoomSnapshot.docs) {
                    ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(doc.data() as Map<String, dynamic>);
                    Map<String, dynamic> participants = chatRoomModel.participants!;
                    List<String> participantKeys = participants.keys.toList();
                    participantKeys.remove(widget.userModel.uid);

                    // Check if the participant keys contain the current user's ID
                    if (participantKeys.contains(widget.userModel.uid)) {
                      mutualChats.add(chatRoomModel);
                    } else {
                      normalChats.add(chatRoomModel);
                    }
                  }

                  return ListView(
                    children: [
                      // Mutual Chats Section
                      if (mutualChats.isNotEmpty) ...[
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                'Mutual Chats',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: mutualChats.length,
                              itemBuilder: (context, index) {
                                ChatRoomModel chatRoomModel = mutualChats[index];
                                Map<String, dynamic> participants = chatRoomModel.participants!;
                                List<String> participantKeys = participants.keys.toList();
                                participantKeys.remove(widget.userModel.uid);

                                // Retrieve the UserModel for the other participant
                                return FutureBuilder<UserModel?>(
                                  future: FirebaseHelper.getUserModelById(participantKeys[0]),
                                  builder: (context, userData) {
                                    if (userData.connectionState == ConnectionState.done) {
                                      if (userData.hasData && userData.data != null) {
                                        UserModel targetUser = userData.data!;

                                        return ListTile(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) {
                                                return ChatRoomPage(
                                                  chatroom: chatRoomModel,
                                                  firebaseUser: widget.firebaseUser,
                                                  userModel: widget.userModel,
                                                  targetUser: targetUser,
                                                );
                                              }),
                                            );
                                          },
                                          leading: CircleAvatar(
                                            backgroundImage: NetworkImage(targetUser.profilepic.toString()),
                                          ),
                                          title: Text(targetUser.fullname!),
                                          subtitle: (chatRoomModel.lastMessage != null && chatRoomModel.lastMessage!.isNotEmpty)
                                              ? Text(chatRoomModel.lastMessage!)
                                              : Text(
                                                  "Message me",
                                                  style: TextStyle(
                                                    color: Theme.of(context).colorScheme.secondary,
                                                  ),
                                                ),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    } else {
                                      return Container();
                                    }
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ],

                      // Normal Chats Section
                      if (normalChats.isNotEmpty) ...[
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                'Normal Chats',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: normalChats.length,
                              itemBuilder: (context, index) {
                                ChatRoomModel chatRoomModel = normalChats[index];
                                Map<String, dynamic> participants = chatRoomModel.participants!;
                                List<String> participantKeys = participants.keys.toList();
                                participantKeys.remove(widget.userModel.uid);

                                // Retrieve the UserModel for the other participant
                                return FutureBuilder<UserModel?>(
                                  future: FirebaseHelper.getUserModelById(participantKeys[0]),
                                  builder: (context, userData) {
                                    if (userData.connectionState == ConnectionState.done) {
                                      if (userData.hasData && userData.data != null) {
                                        UserModel targetUser = userData.data!;

                                        return ListTile(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (context) {
                                                return ChatRoomPage(
                                                  chatroom: chatRoomModel,
                                                  firebaseUser: widget.firebaseUser,
                                                  userModel: widget.userModel,
                                                  targetUser: targetUser,
                                                );
                                              }),
                                            );
                                          },
                                          leading: CircleAvatar(
                                            backgroundImage: NetworkImage(targetUser.profilepic.toString()),
                                          ),
                                          title: Text(targetUser.fullname!),
                                          subtitle: (chatRoomModel.lastMessage != null && chatRoomModel.lastMessage!.isNotEmpty)
                                              ? Text(chatRoomModel.lastMessage!)
                                              : Text(
                                                  "Message me",
                                                  style: TextStyle(
                                                    color: Theme.of(context).colorScheme.secondary,
                                                  ),
                                                ),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    } else {
                                      return Container();
                                    }
                                 
                                },
                              );
                }),
                          ],
                        ),
                      ],

                      // Other Users Section
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Text(
                              'Recommended',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance.collection('users').snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                QuerySnapshot userSnapshot = snapshot.data!;
                                List<UserModel> users = [];

                                for (var doc in userSnapshot.docs) {
                                  if (doc.id != widget.userModel.uid) {
                                    UserModel user = UserModel.fromMap(doc.data() as Map<String, dynamic>);
                                    users.add(user);
                                  }
                                }

                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: users.length,
                                  itemBuilder: (context, index) {
                                    UserModel user = users[index];
                                    return ListTile(
                                      onTap: () {
                                        // Handle user selection
                                      },
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(user.profilepic.toString()),
                                      ),
                                      title: Text(user.fullname!),
                                    );
                                  },
                                );
                              } else {
                                return Container();
                              }
                            },
                ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Center(
                    child: Text("No Chats"),
                  );
                }
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return SearchPage(userModel: widget.userModel, firebaseUser: widget.firebaseUser);
            }),
          );
        },
        child: Icon(Icons.search),
      ),
    );
  }
}
