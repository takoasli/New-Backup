import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:projek_skripsi/textfield/textfields.dart';
import '../Aset/ControllerLogic.dart';
import '../komponen/style.dart';

class ExportCatatans extends StatefulWidget {
  const ExportCatatans({Key? key}) : super(key: key);

  @override
  State<ExportCatatans> createState() => _ExportCatatanState();
}

class _ExportCatatanState extends State<ExportCatatans> {
  String selectedWaktu = "";
  int totalCatatan = 0;
  List<String> kategoriTerpilih = [];
  late List<String> DokCatatanEX = [];
  final namaFile = TextEditingController();
  final List<String> Waktu = [
    "Bulan ini",
    "Tahun ini",
    "Semua",
  ];

  void hitungTotalCatatan(List<String> dataCatatan) {
    setState(() {
      totalCatatan = dataCatatan.length;
    });
  }

  Future<void> getCatatan(List<String> selectedCategories) async {
    if (selectedCategories.contains('Semua')) {
      await getAllCatatan();
      return;
    }

    if (selectedCategories.contains('Bulan ini')) {
      await getCatatanBulanIni();
      return;
    }

    if (selectedCategories.contains('Tahun ini')) {
      await getCatatanTahunIni();
      return;
    }
  }

  Future<void> getAllCatatan() async {
    Query<Map<String, dynamic>> query =
    FirebaseFirestore.instance.collection('Catatan Servis');

    setState(() {
      DokCatatanEX = [];
    });

    final QuerySnapshot<Map<String, dynamic>> snapshot = await query.get();

    setState(() {
      DokCatatanEX = snapshot.docs.map((doc) => doc.id).toList();
      hitungTotalCatatan(DokCatatanEX);
    });
  }

  Future<void> getCatatanBulanIni() async {
    DateTime now = DateTime.now();
    Timestamp startDate = Timestamp.fromDate(DateTime(now.year, now.month, 1));
    Timestamp endDate = Timestamp.fromDate(DateTime(now.year, now.month + 1, 0));

    await getCatatanByDateRange(startDate, endDate);
    hitungTotalCatatan(DokCatatanEX);
  }

  Future<void> getCatatanTahunIni() async {
    DateTime now = DateTime.now();
    Timestamp startDate = Timestamp.fromDate(DateTime(now.year, 1, 1));
    Timestamp endDate = Timestamp.fromDate(DateTime(now.year, 12, 31));

    await getCatatanByDateRange(startDate, endDate);
    hitungTotalCatatan(DokCatatanEX);
  }

  Future<void> getCatatanByDateRange(
      Timestamp startDate, Timestamp endDate) async {
    Query<Map<String, dynamic>> query =
    FirebaseFirestore.instance.collection('Catatan Servis');

    final QuerySnapshot<Map<String, dynamic>> snapshot = await query
        .where('Tanggal Dilakukan Servis', isGreaterThanOrEqualTo: startDate)
        .where('Tanggal Dilakukan Servis', isLessThanOrEqualTo: endDate)
        .get();

    setState(() {
      DokCatatanEX = snapshot.docs.map((doc) => doc.id).toList();
      hitungTotalCatatan(DokCatatanEX);
    });
  }

  @override
  void initState() {
    super.initState();
    getCatatan(kategoriTerpilih);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.green,
      appBar: AppBar(
        backgroundColor: const Color(0xFF61BF9D),
        title: const Text(
          'Export Catatan',
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
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 55),
              child: Image.asset(
                'gambar/gambar file.png',
                fit: BoxFit.contain,
                width: 217,
                height: 217,
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Container(
                decoration: BoxDecoration(
                  color: Warna.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 4,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 30, right: 30),
                              child: Icon(
                                Icons.download_for_offline,
                                size: 55,
                                color: Warna.green,
                              ),
                            ),

                            // Ini dropdown menu
                            Container(
                              width: 263,
                              decoration: BoxDecoration(
                                color: Warna.white,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.blueGrey.shade500.withOpacity(0.2),
                                    spreadRadius: 2,
                                    blurRadius: 3,
                                    offset: const Offset(0, 2), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: DropdownSearch<String>(
                                popupProps: const PopupProps.menu(
                                  showSelectedItems: true,
                                ),
                                items: Waktu,
                                dropdownDecoratorProps: DropDownDecoratorProps(
                                  dropdownSearchDecoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                      hintText: "Pilih...",
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                      )
                                  ),
                                ),
                                onChanged: (selectedValue){
                                  print(selectedValue);
                                  setState(() {
                                    selectedWaktu = selectedValue ?? "";
                                    if (selectedWaktu.isNotEmpty) {
                                      if (selectedWaktu == "Semua") {
                                        kategoriTerpilih = ["Semua"];
                                      } else if (selectedWaktu == "Bulan ini") {
                                        kategoriTerpilih = ["Bulan ini"];
                                      } else if (selectedWaktu == "Tahun ini") {
                                        kategoriTerpilih = ["Tahun ini"];
                                      }
                                      getCatatan(kategoriTerpilih);
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 35, bottom: 10),
                            child: Text("Total item: ",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 5, bottom: 10),
                            child: Text(
                              totalCatatan.toString(),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                        ],
                      ),


                      Column(
                        children: [
                          MyTextField(
                                textInputType: TextInputType.text,
                                hint: 'Nama File...',
                                textInputAction: TextInputAction.done,
                                controller: namaFile),

                          Padding(
                            padding: const EdgeInsets.only(top: 25),
                            child: Align(
                              alignment: Alignment.center,
                              child: ElevatedButton(
                                onPressed: (){
                                  exportExcel(
                                      dokumenCatatan: DokCatatanEX,
                                      namafile: namaFile.text,
                                      context: context);
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Warna.green,
                                    minimumSize: const Size(150, 40),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25))
                                ),
                                child: SizedBox(
                                  width: 200,
                                  child: Center(
                                    child: Text(
                                      'Export',
                                      style: TextStyles.title
                                          .copyWith(fontSize: 18, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                            ],
                          ),
                        ],
                      ),
                ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
