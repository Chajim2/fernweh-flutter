import 'package:fernweh/providers/user_provider.dart';
import 'package:fernweh/common/common_widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF1E1E1E);
    const accentColor = Color(0xFFFFB74D); // warm amber

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Top-left Logout
            Positioned(
              top: 10,
              left: 10,
              child: IconButton(
                onPressed: () {
                  // Might wanna reconsider if leaving the app alltogether would be smoother here
                  Provider.of<UserProvider>(context, listen: false).logOut();
                  Navigator.pushNamed(context, '/login');
                },
                icon: Icon(Icons.logout),
                color: accentColor,
              ),
            ),

            // Top-right profile icon
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/profile');
                },
                icon: const Icon(Icons.person),
                color: accentColor,
              ),
            ),

            // Centered buttons
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommonButton(
                    text: 'journal',
                    onPressed: () => Navigator.pushNamed(context, "/diary"),
                  ),
                  const SizedBox(height: 20),
                  CommonButton(
                    text: 'insights',
                    onPressed: () => Navigator.pushNamed(context, "/posts"),
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
