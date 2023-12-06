import 'package:flutter/material.dart';
import 'package:lab_extension/account.dart';
import 'dart:math';

class NavBar extends StatelessWidget {
  NavBar({Key? key, required this.account}) : super(key: key);
  Account account;
  var generatedColor = Colors.primaries[Random().nextInt(Colors.primaries.length)];
  late Color pfp = generatedColor;
  late Color bg = darken(generatedColor);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Remove padding
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(account.userLongName!),
            accountEmail: Text(account.userShortName!),
            currentAccountPicture: CircleAvatar(
              backgroundColor: pfp,
              radius: 25.0,
              child: Text(
                // Uses the first letter of userLongName it in the user's icon
                account.userLongName![0],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: bg,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Favorites'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Friends'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share'),
            onTap: () {},
          ),
          const ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Request'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Policies'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            title: const Text('Exit'),
            leading: const Icon(Icons.exit_to_app),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

Color darken(Color color, [double amount = .2]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}