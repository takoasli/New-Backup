import 'package:flutter/material.dart';
import 'package:projek_skripsi/settings/ExportAset.dart';
import 'package:projek_skripsi/settings/ExportCatatan.dart';
import 'package:projek_skripsi/settings/GantiPassword.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  double _listTileHeight = 70.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF61BF9D),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Card(
              elevation: 1,
              child: Container(
                height: _listTileHeight,
                child: ListTile(
                  dense: false,
                  title: Text('Export Catatan'),
                  subtitle: Text('Akan mengeksport Catatan Dalam Bentuk file Excel'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ExportCatatan()),
                    );
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Card(
              elevation: 1,
              child: Container(
                height: _listTileHeight,
                child: ListTile(
                  dense: false,
                  title: Text('Pengaturan Notifikasi'),
                  subtitle: Text('Mengatur Ketentuan Notifikasi'),
                  onTap: () {
                    // Action when 'Pengaturan Notifikasi' is tapped
                    // Add your logic here
                  },
                ),
              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Card(
              elevation: 1,
              child: Container(
                height: _listTileHeight,
                child: ListTile(
                  dense: false,
                  title: Text('Ganti Password'),
                  subtitle: Text('Mengganti Password pada akun yang sedang login saat ini'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GantiPass()),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


