import 'package:flutter/material.dart';
import 'package:final_project/account.dart';
import 'package:final_project/settings.dart';
import 'dart:math';

// Swipe from the left to see the cool Drawer!
class NavBar extends StatefulWidget {
  // Needs currently signed-in account.
  NavBar({Key? key, required this.account}) : super(key: key);
  final Account account;

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late Color pfp;
  late Color bg;

  // To default, gets a random color for the profile picture and the
  // background of the drawer (which is a bit darker. Looks nice).
  @override
  void initState() {
    super.initState();
    int colorIndex = widget.account.userLongName!.codeUnitAt(0) % Colors.primaries.length;
    pfp = Colors.primaries[colorIndex];
    bg = darken(pfp);
  }

  // Builds drawer
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero, // Remove padding
        children: [
          UserAccountsDrawerHeader(
            // Gets signed-in account Username and @.
            accountName: Text(widget.account.userLongName!),
            accountEmail: Text('@${widget.account.userShortName!}'),

            // Checks if signed-in account has profile picture or not.
            // If not, uses a Google-style circle with letter.
            currentAccountPicture: widget.account.imageURL != null
                ? CircleAvatar(
              backgroundImage: NetworkImage(widget.account.imageURL!),
              radius: 25.0,
            )
                : CircleAvatar(
              backgroundColor: pfp,
              radius: 25.0,
              child: Text(
                widget.account.userLongName![0],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
            ),

            // Colors behind profile picture
            decoration: BoxDecoration(
              color: bg,
            ),
          ),

          // Lists a bunch of different options in the drawer.
          // Most of them don't do anything yet.
          ListTile(
            leading: const Icon(Icons.favorite),
            title: const Text('Likes'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Following'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              setState(() {
                _openSettings(context, widget.account);
              });
            },
          ),
        ],
      ),
    );
  }
}

// Darkens a provided color by a percentage amount.
Color darken(Color color, [double amount = .2]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

// Retrieves the form for the settings.
Future _openSettings(BuildContext context, Account account) async {
  await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SettingsForm(account: account)
  ));
}