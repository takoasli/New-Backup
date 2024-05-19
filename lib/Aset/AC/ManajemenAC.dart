import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:projek_skripsi/Aset/AC/AddAC.dart';
import 'package:projek_skripsi/Aset/AC/DetailAC.dart';
import 'package:projek_skripsi/Aset/AC/editAC.dart';
import 'package:projek_skripsi/baca%20data/baca_ac.dart';

import '../../komponen/style.dart';


class ManajemenAC extends StatefulWidget {
  const ManajemenAC({super.key});

  @override
  State<ManajemenAC> createState() => _ManajemenAC();
}

class _ManajemenAC extends State<ManajemenAC> {
  late List<String> DokAC = [];
  final berhasil = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: 'SUCCESS',
      message: 'Data AC berhasil Dihapus!',
      contentType: ContentType.success,
    ),
  );

  Future<void> getAC() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance.collection('Aset').get();
    setState(() {
      DokAC = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    getAC();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.green,
      appBar: AppBar(
        backgroundColor: const Color(0xFF61BF9D),
        title: const Text(
          'Manajemen AC',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Warna.white,
                hintText: 'Cari AC...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: BorderSide.none
                ),
              ),

              // onChanged: (value) {
              //   performSearch(value);
              // },
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Warna.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(20),
              child: ListView.builder(
                itemCount: DokAC.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      borderRadius: BorderRadius.circular(10),
                      elevation: 1,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          // Action when tapped
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: BacaAC(
                                  dokumenAC: DokAC[index],
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UpdateAC(
                                        dokumenAC: DokAC[index],
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.lightBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 25, right: 10),
              child: SpeedDial(
                child: Icon(Icons.more_horiz,
                    color: Warna.white),
                backgroundColor: Warna.green,
                activeIcon: Icons.close,
                curve: Curves.bounceIn,
                children: [
                  SpeedDialChild(
                    elevation: 0,
                    child: const Icon(Icons.add,
                        color: Warna.white),
                    labelWidget: const Text("Add",
                        style: TextStyle(color: Warna.green)
                    ),
                    backgroundColor: Warna.green,
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddAC()),
                      );
                    },
                  ),

                  SpeedDialChild(
                    elevation: 0,
                    child: const Icon(Icons.create_new_folder,
                        color: Warna.white),
                    labelWidget: const Text("Manage AC",
                        style: TextStyle(color: Warna.green)
                    ),
                    backgroundColor: Warna.green,
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ManajemenAC()),
                      );
                    },
                  ),

                  SpeedDialChild(
                    elevation: 0,
                    child: const Icon(Icons.ac_unit,
                        color: Warna.white),
                    labelWidget: const Text("Detail AC",
                        style: TextStyle(color: Warna.green)
                    ),
                    backgroundColor: Warna.green,
                    onTap: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DetailAC()),
                      );
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
