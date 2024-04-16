import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projek_skripsi/Catatan/Pilihan.dart';
import 'package:projek_skripsi/komponen/style.dart';

import '../komponen/scanQR.dart';
import '../manajemenUser.dart';
import '../pilihInfoAset.dart';
import '../profile.dart';
import '../settings/settings.dart';
import 'ListCatatan.dart';

class Dashboards extends StatefulWidget {
  Dashboards({super.key});
  final pengguna = FirebaseAuth.instance.currentUser!;

  @override
  State<Dashboards> createState() => _DashboardsState();
}

class _DashboardsState extends State<Dashboards> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: 190,
            child: AppBar(
              backgroundColor: Warna.green,
              title: Text('Aset Management'),
              elevation: 0,
              actions: [
                IconButton(
                  icon: Icon(Icons.person),
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Profiles()),
                    );
                  },
                ),

                IconButton(
                  icon: Icon(Icons.transfer_within_a_station),
                  onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ExportCatatan()),
                    );
                  },
                ),

                IconButton(
                    onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Settings()),
                      );
                    },
                    icon: Icon(Icons.settings)
                ),
                
                Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: IconButton(
                    icon: Icon(Icons.logout),
                    onPressed: logout,
                  ),
                ),
              ],
              centerTitle: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0), // Sesuaikan nilai sesuai keinginan Anda
              ),
              child: _kotak(),
              margin: EdgeInsets.fromLTRB(14, 0, 14, 410),
              elevation: 5,
            ),
          )

        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: ScanQR(),
    );
  }

  _kotak() {
    return GridView.count(crossAxisCount:3,
    children: [
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PilihInfoAset()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            elevation: 3,
            shadowColor: Warna.green,
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: Warna.green,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home_repair_service,
                    size: 50,
                    color: Warna.white,
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Aset Info",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),


      GestureDetector(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ListCatatan()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            elevation: 3,
            shadowColor: Warna.green,
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: Warna.green,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_alt,
                    size: 50,
                    color: Warna.white,
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Catatan",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      GestureDetector(
        onTap: (){
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ManageAcc()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            elevation: 3,
            shadowColor: Warna.green,
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: Warna.green,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_box,
                    size: 50,
                    color: Warna.white,
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Manage User",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
    );
  }

  void logout() {
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacement;
    FirebaseAuth.instance.signOut();
  }
}
