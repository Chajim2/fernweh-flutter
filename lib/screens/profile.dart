import 'package:fernweh/common/common_widgets.dart';
import 'package:fernweh/common/utils.dart';
import 'package:fernweh/providers/user_provider.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<String> friends = [];
  bool isLoading = true;
  List<String> friendRequests = [];
  bool isLoadingRequests = true;
  TextEditingController requestController = TextEditingController();
  

  @override
  void initState() {
    super.initState();
    fetchFriends();
    fetchFriendRequests();
  }

  Future<void> fetchFriendRequests() async {
    const url = 'https://chajim.pythonanywhere.com/get_requests';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: DEFAULT_HEADER,
        body: jsonEncode({
          "id": Provider.of<UserProvider>(context, listen: false).getJwtToken(),
        }),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> requestsJson = data['requests'] ?? [];
        final List<String> requestNames = requestsJson.map((name) => name as String).toList();

        setState(() {
          friendRequests = requestNames;
          isLoadingRequests = false;
        });
      } else {
        throw Exception('Failed to load requests');
      }
    } catch (e) {
      setState(() {
        isLoadingRequests = false;
      });
      print('Error fetching requests: $e');
    }
  }

  Future<void> fetchFriends() async {
    const url = 'https://chajim.pythonanywhere.com/get_friends';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: DEFAULT_HEADER,
        body: jsonEncode({
          "id": Provider.of<UserProvider>(context, listen: false).getJwtToken(),
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> friendsJson = data['friends'];
        final List<String> friendNames = friendsJson
            .map((friend) => friend['username'] as String)
            .toList();

        setState(() {
          friends = friendNames;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load friends');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching friends: $e');
    }
  }

  Future<void> acceptFriendRequest(String name) async{
    const url = 'https://chajim.pythonanywhere.com/accept_friend_request';
    final response = await http.post(
        Uri.parse(url),
        headers: DEFAULT_HEADER,
        body: jsonEncode({
          "id": Provider.of<UserProvider>(context, listen: false).getJwtToken(),
          'friend_name' : name,
        }),
      );
      showStyledAlert(context, "Friend request", jsonDecode(response.body)['message']);
      if(response.statusCode == 200) fetchFriendRequests();

  }
  Future<void> declineFriendRequest(String name) async{
    const url = 'https://chajim.pythonanywhere.com/decline_friend_request';
    final response = await http.post(
        Uri.parse(url),
        headers: DEFAULT_HEADER,
        body: jsonEncode({
          "id": Provider.of<UserProvider>(context, listen: false).getJwtToken(),
          'friend_name' : name,
        }),
      );
      showStyledAlert(context, "Friend request", jsonDecode(response.body)['message']);
      if(response.statusCode == 200) fetchFriendRequests();
  }
  
  void sendFriendRequest() async{
    String name = requestController.text;
    const url = 'https://chajim.pythonanywhere.com/send_friend_request';
     final response = await http.post(
        Uri.parse(url),
        headers: DEFAULT_HEADER,
        body: jsonEncode({
          "id": Provider.of<UserProvider>(context, listen: false).getJwtToken(),
          'friend_name' : name,
        }),
      );
      showStyledAlert(context, "Friend request", jsonDecode(response.body)['message']);
      if(response.statusCode == 200) fetchFriendRequests();
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF1E1E1E);
    const accentColor = Color(0xFFFFB74D);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Top-left back icon
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                color: accentColor,
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 60),
                  Text(
                    Provider.of<UserProvider>(
                      context,
                      listen: false,
                    ).getUsername(),
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'Georgia',
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  CommonTextInput(hintText: "enter friend's name", controller: requestController),
                  const SizedBox(height: 20,),
                  CommonButton(text: "send request", onPressed: () => sendFriendRequest()),
                  const SizedBox(height: 40),
                  //Friend Requests Section
                  const Text(
                    'Friend Requests',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Georgia',
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),

                  isLoadingRequests
                      ? const Center(
                          child: CircularProgressIndicator(color: accentColor),
                        )
                      : friendRequests.isEmpty
                      ? const Text(
                          'No friend requests.',
                          style: TextStyle(
                            color: Colors.white38,
                            fontFamily: 'Georgia',
                          ),
                        )
                      : Column(
                          children: friendRequests.map((name) {
                            return Card(
                              color: const Color(0xFF2A2A2A),
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                                side: const BorderSide(
                                  color: accentColor,
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Georgia',
                                        fontSize: 16,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          onPressed: () {
                                            acceptFriendRequest(name);
                                          },
                                          icon: const Icon(
                                            Icons.check,
                                            color: Colors.green,
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            declineFriendRequest(name);
                                          },
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                  const SizedBox(height: 40),
                  const Text(
                    'Friend List',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Georgia',
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Friends display
                  Expanded(
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: accentColor,
                            ),
                          )
                        : friends.isEmpty
                        ? const Text(
                            'No friends added yet.',
                            style: TextStyle(
                              color: Colors.white38,
                              fontFamily: 'Georgia',
                            ),
                          )
                        : ListView.builder(
                            itemCount: friends.length,
                            itemBuilder: (context, index) {
                              return FriendCard(
                                name: friends[index],
                                onTap: () {
                                  print('Tapped on ${friends[index]}');
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
