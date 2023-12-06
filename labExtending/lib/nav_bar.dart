import 'package:flutter/material.dart';
import 'package:lab_extension/account.dart';
import 'package:lab_extension/settings.dart';
import 'dart:math';

class NavBar extends StatefulWidget {
  NavBar({Key? key, required this.account}) : super(key: key);
  final Account account;

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  late Color pfp;
  late Color bg;

  @override
  void initState() {
    super.initState();
    var generatedColor = Colors.primaries[Random().nextInt(Colors.primaries.length)];
    pfp = generatedColor;
    bg = darken(generatedColor);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        // Remove padding
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(widget.account.userLongName!),
            accountEmail: Text(widget.account.userShortName!),
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
            decoration: BoxDecoration(
              color: bg,
            ),
          ),
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

Color darken(Color color, [double amount = .2]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

Future _openSettings(BuildContext context, Account account) async {
  await Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => SettingsForm(account: account)
  ));
}