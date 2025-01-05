import 'package:family_finance/page/polic.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Stack(
        children: [
          // Background Gradient
          _buildBackgroundGradient(),

          // Drawer Content
          ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              _buildHeader(context),
              _buildPolicy(context),
              Divider(color: Colors.white54),
              _buildAboutAppTile(context),
              Divider(color: Colors.white54),
              _buildSupportDeveloperTile(context),
              Divider(color: Colors.white54),
              _buildContactChannelsTile(),
              Divider(color: Colors.white54),
            ],
          ),

          // Footer
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildBackgroundGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade800,
            Colors.purple.shade600,
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/header_bg.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 37,
              backgroundImage: AssetImage('images/profile.jpg'),
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Taidev',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutAppTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.info, color: Colors.white),
      title: Text(
        'About App',
        style: TextStyle(color: Colors.white),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('About Family Finance App'),
            content: Text(
              'Family Finance helps your family manage income and expenses effectively.\n' +
                  'Version: 2.0.0\n' +
                  'Developed by: Mendaka Developer',
            ),
            actions: [
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSupportDeveloperTile(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.qr_code, color: Colors.white),
      title: Text(
        'Support Developer',
        style: TextStyle(color: Colors.white),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Support the Developer'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'You can support the developer by scanning the QR Code below.',
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Image.asset(
                  'images/promptpay_qr.png',
                  width: 200,
                  height: 200,
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPolicy(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.policy, color: Colors.white),
      title: Text(
        'Policy',
        style: TextStyle(color: Colors.white),
      ),
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => PolicyScreen()));
      },
    );
  }

  Widget _buildContactChannelsTile() {
    return ListTile(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Contact Channels',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconButton(
                FontAwesomeIcons.envelope,
                'mailto:hseng2018@gmail.com',
                'Email',
              ),
              _buildIconButton(
                FontAwesomeIcons.github,
                'https://github.com/mendaka',
                'GitHub',
              ),
              _buildIconButton(
                FontAwesomeIcons.facebook,
                'https://facebook.com/mendaka.dev',
                'Facebook',
              ),
              _buildIconButton(
                FontAwesomeIcons.tiktok,
                'https://www.tiktok.com/@seng2114',
                'TikTok',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          '© 2024 Family Finance\nDeveloped by Taidev',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, String url, String tooltip) {
    return IconButton(
      icon: FaIcon(icon, color: Colors.white),
      onPressed: () => openLink(url),
      tooltip: tooltip,
    );
  }
}

Future<void> openLink(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'Could not launch $url';
  }
}
