import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:projek_skripsi/komponen/style.dart';

import '../MenuBoxContent.dart';
import '../komponen/scanQR.dart';
import '../profile.dart';
import '../settings/settings.dart' as setts;

class Dashboards extends StatefulWidget {
  Dashboards({super.key});
  final pengguna = FirebaseAuth.instance.currentUser!;

  @override
  State<Dashboards> createState() => _DashboardsState();
}

class _DashboardsState extends State<Dashboards> {
  String selectedKategori = "";
  late List<String> DokAC = [];
  late List<String> DokPC = [];
  late List<String> DokLaptop = [];
  late List<String> DokMotor = [];
  late List<String> DokMobil = [];
  List<String> DokStatus = [];
  List<String> kategoriTerpilih = [];
  final List<String> Kategori = [
    "AC",
    "PC",
    "Laptop",
    "Motor",
    "Mobil"
  ];

  //get data database things
  //ac
  Future<void> getAC() async {
    Query<Map<String, dynamic>> query =
    FirebaseFirestore.instance.collection('Aset');

    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    setState(() {
      DokAC = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  //pc
  Future<void> getPC() async {
    Query<Map<String, dynamic>> query =
    FirebaseFirestore.instance.collection('PC');

    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    setState(() {
      DokPC = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  //laptop
  Future<void> getLaptop() async {
    Query<Map<String, dynamic>> query =
    FirebaseFirestore.instance.collection('Laptop');

    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    setState(() {
    DokLaptop = snapshot.docs.map((doc) => doc.id).toList();
    });
  }


  //motor
  Future<void> getMotor() async {
    Query<Map<String, dynamic>> query =
    FirebaseFirestore.instance.collection('Motor');

    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    setState(() {
    DokMotor = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  //mobil
  Future<void> getMobil() async {
    Query<Map<String, dynamic>> query =
    FirebaseFirestore.instance.collection('Mobil');

    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();
    setState(() {
    DokMobil = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  Future<void> getStatus(List<String> selectedKategori) async {
    DokStatus.clear(); // Bersihkan list DokStatus
    for (String kategori in selectedKategori) {
      switch (kategori) {
        case 'AC':
          await getAC();
          DokStatus.addAll(DokAC);
          break;
        case 'PC':
          await getPC();
          DokStatus.addAll(DokPC);
          break;
        case 'Laptop':
          await getLaptop();
          DokStatus.addAll(DokLaptop);
          break;
        case 'Motor':
          await getMotor();
          DokStatus.addAll(DokMotor);
          break;
        case 'Mobil':
          await getMobil();
          DokStatus.addAll(DokMobil);
          break;
        default:
          break;
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.green,
      appBar: AppBar(
        backgroundColor: Warna.green,
        title: const Text('Aset Management'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Profiles()),
              );
            },
          ),

          IconButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const setts.Settings()),
                );
              },
              icon: const Icon(Icons.settings)
          ),

          Padding(
            padding: const EdgeInsets.only(right: 7),
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: logout,
            ),
          ),
        ],
        centerTitle: false,
      ),

      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 20, top: 10),
              child: BoxMenuContent(),
            ),

            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text('Activity View',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: Warna.white
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Warna.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    DropdownSearch<String>(
                      popupProps: const PopupProps.menu(
                        showSelectedItems: true,
                      ),
                      items: Kategori,
                      dropdownDecoratorProps: const DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            hintText: "Pilih...",
                            border: InputBorder.none
                        ),
                      ),
                      onChanged: (selectedValue){
                        print(selectedValue);
                        setState(() {
                          selectedKategori = selectedValue ?? "";
                          if (selectedKategori.isNotEmpty) {
                            if (selectedKategori == "AC") {
                              kategoriTerpilih = ["AC"];

                            } else if (selectedKategori == "Laptop") {
                              kategoriTerpilih = ["Laptop"];


                            } else if (selectedKategori == "PC") {
                              kategoriTerpilih = ["PC"];

                            } else if (selectedKategori == "Motor"){
                              kategoriTerpilih = ["Motor"];

                            }else if (selectedKategori == "Mobil"){
                              kategoriTerpilih = ["Mobil"];
                            }
                            getStatus(kategoriTerpilih);
                          }else{
                            const Text('Isi Kosong',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: Warna.white
                            ),);
                          }
                        });
                      },
                    ),

                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Warna.white,
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                        ),
                        padding: const EdgeInsets.all(20),
                        child: DokStatus.isEmpty
                            ? const Center(
                          child: Text(
                            'Tidak ada catatan terkait aset yang dipilih',
                            style: TextStyle(
                              fontSize: 16,
                              color: Warna.black,
                              // Sesuaikan gaya teks sesuai kebutuhan
                            ),
                          ),
                        )
                            : ListView.builder(
                          itemCount: DokStatus.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    children: [
                                      // Expanded(
                                      //   child: BacaCatatan(
                                      //     dokumenCatatan: DokCatatan[index],
                                      //   ),
                                      // ),
                                    ],
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
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: ScanQR(),
    );
  }
  void logout() {
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacement;
    FirebaseAuth.instance.signOut();
  }
}

