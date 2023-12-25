import 'dart:io';

import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:projek_skripsi/Catatan/bacaCatatanExport.dart';
import 'package:projek_skripsi/komponen/style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projek_skripsi/textfield/textfields.dart';

class ExportCatatan extends StatefulWidget {
  const ExportCatatan({Key? key});

  @override
  State<ExportCatatan> createState() => _ExportCatatanState();
}

final List<String> kategoriWaktu = ['Bulan ini', 'Tahun ini', 'Semua'];
List<String> kategoriTerpilih = [];
late List<String> DokCatatanEX = [];

class _ExportCatatanState extends State<ExportCatatan> {


  Future <void> exportExcel() async{
    Excel eksel = Excel.createExcel();
    print('Tombol Export Ditekan!');
    eksel.rename(eksel.getDefaultSheet()!, 'Catatan Servis');

    Sheet sheet = eksel['Catatan Servis'];

    //isi tiap judul excell
    //judulnya
    var cellD1 = sheet.cell(CellIndex.indexByString("D1"));
    cellD1.value = TextCellValue('Catatan Servis');
    sheet.merge(CellIndex.indexByString("D1"), CellIndex.indexByString("H2"));
    cellD1.cellStyle = CellStyle(backgroundColorHex: "#C6E0B4", fontSize: 20);

    //nomor
    var cellA4 = sheet.cell(CellIndex.indexByString("A4"));
    cellA4.value = TextCellValue('No');
    sheet.merge(CellIndex.indexByString("A4"), CellIndex.indexByString("A5"));
    cellA4.cellStyle = CellStyle(backgroundColorHex: "#B4C3E8");

    //tanggal
    var cellB4 = sheet.cell(CellIndex.indexByString("B4"));
    cellB4.value = TextCellValue('Tanggal Dibuat');
    sheet.merge(CellIndex.indexByString("B4"), CellIndex.indexByString("B5"));
    cellB4.cellStyle = CellStyle(backgroundColorHex: "#B4C3E8");

    //nama aset
    var cellC4 = sheet.cell(CellIndex.indexByString("C4"));
    cellC4.value = TextCellValue('Nama Aset');
    sheet.merge(CellIndex.indexByString("C4"), CellIndex.indexByString("C5"));
    cellC4.cellStyle = CellStyle(backgroundColorHex: "#B4C3E8");

    //ID Aset
    var cellD4 = sheet.cell(CellIndex.indexByString("D4"));
    cellD4.value = TextCellValue('ID Aset');
    sheet.merge(CellIndex.indexByString("D4"), CellIndex.indexByString("D5"));
    cellD4.cellStyle = CellStyle(backgroundColorHex: "#B4C3E8");

    //jenis aset
    var cellE4 = sheet.cell(CellIndex.indexByString("E4"));
    cellE4.value = TextCellValue('Jenis Aset');
    sheet.merge(CellIndex.indexByString("E4"), CellIndex.indexByString("E5"));
    cellE4.cellStyle = CellStyle(backgroundColorHex: "#B4C3E8");

    //lokasi
    var cellF4 = sheet.cell(CellIndex.indexByString("F4"));
    cellF4.value = TextCellValue('Lokasi Aset');
    sheet.merge(CellIndex.indexByString("F4"), CellIndex.indexByString("F5"));
    cellF4.cellStyle = CellStyle(backgroundColorHex: "#B4C3E8");

    //keterangan
    var cellG4 = sheet.cell(CellIndex.indexByString("G4"));
    cellG4.value = TextCellValue('Keterangan');
    sheet.merge(CellIndex.indexByString("G4"), CellIndex.indexByString("G5"));
    cellG4.cellStyle = CellStyle(backgroundColorHex: "#B4C3E8");

    //kebutuhan
    var cellH4 = sheet.cell(CellIndex.indexByString("H4"));
    cellH4.value = TextCellValue('Kebutuhan');
    sheet.merge(CellIndex.indexByString("H4"), CellIndex.indexByString("I4"));
    cellH4.cellStyle = CellStyle(backgroundColorHex: "#B4C3E8");

    var cellH5 = sheet.cell(CellIndex.indexByString("H5"));
    cellH5.value = TextCellValue('Nama Kebutuhan');
    cellH5.cellStyle = CellStyle(backgroundColorHex: "#B4C3E8");

    var cellI5 = sheet.cell(CellIndex.indexByString("I5"));
    cellI5.value = TextCellValue('Status');
    cellI5.cellStyle = CellStyle(backgroundColorHex: "#B4C3E8");

    //Catatan biaya
    var cellJ4 = sheet.cell(CellIndex.indexByString("J4"));
    cellJ4.value = TextCellValue('Catatan Biaya');
    sheet.merge(CellIndex.indexByString("J4"), CellIndex.indexByString("K4"));
    cellJ4.cellStyle = CellStyle(backgroundColorHex: "#B4C3E8");

    var cellJ5 = sheet.cell(CellIndex.indexByString("J5"));
    cellJ5.value = TextCellValue('Nama Biaya');
    cellJ5.cellStyle = CellStyle(backgroundColorHex: "#B4C3E8");

    var cellK5 = sheet.cell(CellIndex.indexByString("K5"));
    cellK5.value = TextCellValue('Harga');
    cellK5.cellStyle = CellStyle(backgroundColorHex: "#B4C3E8");

    Directory? downloadsDirectory = await getDownloadsDirectory();
    if (downloadsDirectory != null) {
      String filePath = '${downloadsDirectory.path}/${namaFile.text}.xlsx';

      final File file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      await file.writeAsBytes(eksel.encode()!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export berhasil. File disimpan di $filePath'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error mengakses direktori unduhan.'),
        ),
      );
    }
  }

  final namaFile = TextEditingController();

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
    });
  }

  Future<void> getCatatanBulanIni() async {
    DateTime now = DateTime.now();
    Timestamp startDate = Timestamp.fromDate(DateTime(now.year, now.month, 1));
    Timestamp endDate = Timestamp.fromDate(DateTime(now.year, now.month + 1, 0));

    await getCatatanByDateRange(startDate, endDate);
  }

  Future<void> getCatatanTahunIni() async {
    DateTime now = DateTime.now();
    Timestamp startDate = Timestamp.fromDate(DateTime(now.year, 1, 1));
    Timestamp endDate = Timestamp.fromDate(DateTime(now.year, 12, 31));

    await getCatatanByDateRange(startDate, endDate);
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
    });
  }

  @override
  void initState() {
    super.initState();
    getCatatan(kategoriTerpilih);
  }

  @override
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
      body: Center(
        child: Container(
          width: 370,
          height: 570,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Wrap(
                  alignment: WrapAlignment.start,
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: List.generate(
                    kategoriWaktu.length,
                        (waktu) {
                      return FilterChip(
                        selected: kategoriTerpilih.contains(kategoriWaktu[waktu]),
                        showCheckmark: false,
                        label: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            kategoriWaktu[waktu],
                            style: TextStyle(
                              color: kategoriTerpilih.contains(
                                  kategoriWaktu[waktu])
                                  ? Warna.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                        backgroundColor: kategoriTerpilih.contains(
                            kategoriWaktu[waktu])
                            ? Warna.lightgreen // Warna kalo dipilih
                            : Warna.white,
                        // Warna kalo tidak dipilih
                        selectedColor: Warna.lightgreen,
                        // Warna latar belakang
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              kategoriTerpilih.clear();
                              kategoriTerpilih.add(kategoriWaktu[waktu]);
                            } else {
                              kategoriTerpilih.remove(kategoriWaktu[waktu]);
                            }
                            getCatatan(kategoriTerpilih);
                          });
                        },
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 250,
                  width: 320,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Warna.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: DokCatatanEX.length,
                            itemBuilder: (BuildContext context, int indeks) {
                              return Padding(
                                padding: const EdgeInsets.all(8),
                                child: Material(
                                  borderRadius: BorderRadius.circular(10),
                                  elevation: 5,
                                  child: Container(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: BacaCatatExport(
                                            dokumenCatatanEx: DokCatatanEX[indeks],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Nama File',
                              style: TextStyles.title.copyWith(fontSize: 17, color: Warna.darkgrey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        MyTextField(
                          textInputType: TextInputType.text,
                          hint: '',
                          textInputAction: TextInputAction.done,
                          controller: namaFile,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: (){
                          exportExcel();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Warna.green,
                            minimumSize: const Size(200, 50),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25))
                        ),
                        child: SizedBox(
                          width: 200,
                          child: Center(
                            child: Text(
                              'Export',
                              style: TextStyles.title
                                  .copyWith(fontSize: 20, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                  ],
            ),
          ),
        ),
      ),
    );
  }
}