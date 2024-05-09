import 'dart:io';
import 'dart:math';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projek_skripsi/textfield/textfields.dart';

import '../../komponen/kotakDialog.dart';
import '../../komponen/style.dart';
import '../../textfield/imageField.dart';
import '../ControllerLogic.dart';
import 'ManajemenAC.dart';

class AddAC extends StatefulWidget {
  const AddAC({super.key});

  @override
  State<AddAC> createState() => _AddACState();
}

class KebutuhanModelAC {
  String namaKebutuhanAC;
  int masaKebutuhanAC;
  int randomID;

  KebutuhanModelAC(
      this.namaKebutuhanAC,
      this.masaKebutuhanAC,
      this.randomID
      );
}
enum ACStatus { aktif, rusak, hilang }
ACStatus selectedStatus = ACStatus.aktif;

class _AddACState extends State<AddAC> {
  final _formState = GlobalKey<FormState>();
  String selectedRuangan = "";
  String selectedKondisi = "";
  final MerekACController = TextEditingController();
  final idACController = TextEditingController();
  final wattController = TextEditingController();
  final PKController = TextEditingController();
  final MasaKebutuhanController = TextEditingController();
  final isiKebutuhanAC = TextEditingController();
  final ImagePicker _gambarACIndoor = ImagePicker();
  final ImagePicker _gambarACOutdoor = ImagePicker();
  final gambarAcIndoorController = TextEditingController();
  final gambarAcOutdoorController = TextEditingController();
  List Kebutuhan_AC = [];
  List<String> Ruangan = [
    "ADM FAKTURIS",
    "ADM INKASO",
    "ADM SALES",
    "ADM PRODUKSI",
    "LAB",
    "APJ",
    "DIGITAL MARKETING",
    "Ruangan EKSPOR",
    "KASIR",
    "HRD",
    "KEPALA GUDANG",
    "MANAGER MARKETING",
    "MANAGER PRODUKSI",
    "MANAGER QC-R&D",
    "MEETING",
    "STUDIO",
    "TELE SALES",
    "MANAGER EKSPORT"
  ];

  List<String> Status = [
    "Aktif",
    "Rusak",
    "Hilang",
  ];

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void PilihIndoor() async {
    final pilihIndoor =
        await _gambarACIndoor.pickImage(source: ImageSource.gallery);
    if (pilihIndoor != null) {
      setState(() {
        gambarAcIndoorController.text = pilihIndoor.path;
      });
    }
  }

  void PilihOutdoor() async {
    final pilihOutdoor =
        await _gambarACOutdoor.pickImage(source: ImageSource.gallery);
    if (pilihOutdoor != null) {
      setState(() {
        gambarAcOutdoorController.text = pilihOutdoor.path;
      });
    }
  }


  Future<String> unggahACIndoor(File indoor) async {
    try {
      if (!indoor.existsSync()) {
        print('File tidak ditemukan.');
        return '';
      }

      Reference penyimpanan = FirebaseStorage.instance
          .ref()
          .child('AC')
          .child(gambarAcIndoorController.text.split('/').last);

      UploadTask uploadGambar = penyimpanan.putFile(indoor);
      await uploadGambar;
      String fotoIndoor = await penyimpanan.getDownloadURL();
      return fotoIndoor;
    } catch (e) {
      print('$e');
      return '';
    }
  }

  Future<String> unggahACOutdoor(File outdoor) async {
    try {
      if (!outdoor.existsSync()) {
        print('File tidak ditemukan.');
        return '';
      }

      Reference penyimpanan = FirebaseStorage.instance
          .ref()
          .child('AC')
          .child(gambarAcOutdoorController.text.split('/').last);

      UploadTask uploadGambar = penyimpanan.putFile(outdoor);
      await uploadGambar;
      String fotoOutdoor = await penyimpanan.getDownloadURL();
      return fotoOutdoor;
    } catch (e) {
      print('$e');
      return '';
    }
  }

  void AlarmFunctionAC(int id) {
    // Lakukan tugas yang diperlukan saat alarm terpicu
    Notif.showTextNotif(
      judul: 'PT Dami Sariwana',
      body: 'Ada Aset PC yang jatuh tempo!',
      fln: flutterLocalNotificationsPlugin,
      id: id, // Menggunakan ID yang diberikan sebagai parameter
    );
  }

  void SimpanKebutuhan_AC() async {
    String masaKebutuhanText = MasaKebutuhanController.text.trim();
    int randomId = generateRandomId();
    print('Random ID: $randomId');
    if (masaKebutuhanText.isNotEmpty) {
      try {
        int masaKebutuhan = int.parse(masaKebutuhanText);

        Kebutuhan_AC.add(KebutuhanModelAC(
          isiKebutuhanAC.text,
          masaKebutuhan,
          randomId,
        ));

        isiKebutuhanAC.clear();
        MasaKebutuhanController.clear();

        setState(() {});
        await AndroidAlarmManager.oneShot(
          Duration(days: masaKebutuhan),
          randomId,
              () => AlarmFunctionAC(randomId),
          exact: true,
          wakeup: true,
        );


        print('Alarm berhasil diset');
        Navigator.of(context).pop();
        // SetAlarmLaptop(Kebutuhan_Laptop.last);
      } catch (error) {
        print('Error saat mengatur alarm: $error');
        // Lakukan penanganan kesalahan jika parsing gagal
      }
    } else {
      print('Input Masa Kebutuhan tidak boleh kosong');
      // Tindakan jika input kosong
    }
  }


  void tambahKebutuhan(){
    showDialog(
        context: context,
        builder: (context){
          return DialogBox(
            controller: isiKebutuhanAC,
            onAdd: SimpanKebutuhan_AC,
            onCancel: () => Navigator.of(context).pop(),
            TextJudul: 'Tambah Kebutuhan AC',
            JangkaKebutuhan: MasaKebutuhanController,
          );
        });
  }

  int generateRandomId() {
    Random random = Random();
    return random.nextInt(400) + 1;
  }


  void ApusKebutuhan(int index) {
    setState(() {
      Kebutuhan_AC.removeAt(index);
    });
  }

  void SimpanAC() async{
    try{
      String lokasiGambarIndoor = gambarAcIndoorController.text;
      String fotoIndoor = '';
      String lokasiGambarOutdoor = gambarAcOutdoorController.text;
      String fotoOutdoor = '';
      List<Map<String, dynamic>> ListKebutuhan_AC = Kebutuhan_AC.map((kebutuhan) {
        var timeKebutuhan = contTimeService(kebutuhan.masaKebutuhanAC);

        return {
          'Nama Kebutuhan AC': kebutuhan.namaKebutuhanAC,
          'Masa Kebutuhan AC': kebutuhan.masaKebutuhanAC,
          'Waktu Kebutuhan AC': timeKebutuhan.millisecondsSinceEpoch,
          'Hari Kebutuhan AC': daysBetween(DateTime.now(), timeKebutuhan),
          'ID' : kebutuhan.randomID
        };
      }).toList();

      if (lokasiGambarIndoor.isNotEmpty && lokasiGambarOutdoor.isNotEmpty ||
          lokasiGambarIndoor.isNotEmpty && lokasiGambarOutdoor.isEmpty) {
        File indoor = File(lokasiGambarIndoor);
        fotoIndoor = await unggahACIndoor(indoor);

        File outdoor = File(lokasiGambarOutdoor);
        fotoOutdoor = await unggahACOutdoor(outdoor);
      }

      await tambahAC(
        MerekACController.text.trim(),
        idACController.text.trim(),
        int.parse(wattController.text.trim()),
        int.parse(PKController.text.trim()),
        selectedRuangan,
        selectedKondisi,
        ListKebutuhan_AC,
        fotoIndoor,
        fotoOutdoor,
      );

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: 'Berhasil!',
        desc: 'Data AC Berhasil Ditambahkan',
        btnOkOnPress: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ManajemenAC()),
          );
        },
      ).show();
      print('Data AC Berhasil Ditambahkan');
    }catch(e){
      print("Error: $e");
    }
  }

  Future tambahAC(String merek, String ID, int watt, int pk, String selectedRuangan,
      String selectedKondisi,List<Map<String, dynamic>> kebutuhan, String UrlIndoor, String UrlOutdoor,) async{
    await FirebaseFirestore.instance.collection('Aset').add({
      'Merek AC' : merek,
      'ID AC' : ID,
      'Kapasitas Watt' : watt,
      'Kapasitas PK' : pk,
      'Ruangan' : selectedRuangan,
      'Kebutuhan AC' : kebutuhan,
      'Foto AC Indoor' : UrlIndoor,
      'Foto AC Outdoor' : UrlOutdoor,
      'Jenis Aset' : 'AC',
      'Status' : selectedKondisi
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.green,
      appBar: AppBar(
        backgroundColor: const Color(0xFF61BF9D),
        title: const Text(
          'Tambah Data AC',
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
          height: 580,
          decoration: BoxDecoration(
            color: Warna.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Form(
              key: _formState,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      'Merek AC',
                      style: TextStyles.title
                          .copyWith(fontSize: 15, color: Warna.darkgrey),
                    ),
                  ),
                  const SizedBox(height: 5),

                  MyTextField(
                      textInputType: TextInputType.text,
                      hint: '',
                      textInputAction: TextInputAction.next,
                      controller: MerekACController,
                    validator: (value){
                      if (value==''){
                        return "Isi kosong, Harap Diisi!";
                      }
                    },
                  ),
                  const SizedBox(height: 25),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      'ID AC',
                      style: TextStyles.title
                          .copyWith(fontSize: 15, color: Warna.darkgrey),
                    ),
                  ),
                  const SizedBox(height: 5),

                  MyTextField(
                      textInputType: TextInputType.text,
                      hint: '',
                      textInputAction: TextInputAction.next,
                      controller: idACController,
                    validator: (value){
                      if (value==''){
                        return "Isi kosong, Harap Diisi!";
                      }
                    },
                  ),
                  SizedBox(height: 25),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      'Status',
                      style: TextStyles.title
                          .copyWith(fontSize: 15, color: Warna.darkgrey),
                    ),
                  ),
                  const SizedBox(height: 5),

                  DropdownSearch<String>(
                    popupProps: PopupProps.menu(
                      showSelectedItems: true,
                    ),
                    items: Status,
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          hintText: "...",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)
                          )
                      ),
                    ),
                    onChanged: (selectedValue){
                      print(selectedValue);
                      setState(() {
                        selectedKondisi = selectedValue ?? "";
                      });
                    },
                  ),
                  const SizedBox(height: 25),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      'Kapasitas Watt',
                      style: TextStyles.title
                          .copyWith(fontSize: 15, color: Warna.darkgrey),
                    ),
                  ),
                  const SizedBox(height: 5),

                  MyTextField(
                      textInputType: TextInputType.number,
                      hint: '',
                      textInputAction: TextInputAction.next,
                      controller: wattController,
                    validator: (value){
                      if (value==''){
                        return "Isi kosong, Harap Diisi!";
                      }
                    },
                  ),
                  SizedBox(height: 25),

                  Padding(
                    padding: EdgeInsets.only(bottom: 3),
                    child: Text(
                      'kapasitas PK',
                      style: TextStyles.title
                          .copyWith(fontSize: 15, color: Warna.darkgrey),
                    ),
                  ),
                  const SizedBox(height: 5),

                  MyTextField(
                      textInputType: TextInputType.number,
                      hint: '',
                      textInputAction: TextInputAction.next,
                      controller: PKController,
                    validator: (value){
                      if (value==''){
                        return "Isi kosong, Harap Diisi!";
                      }
                    },
                  ),
                  SizedBox(height: 25),
                  Padding(
                    padding: EdgeInsets.only(bottom: 3),
                    child: Text(
                      'Ruangan',
                      style: TextStyles.title
                          .copyWith(fontSize: 15, color: Warna.darkgrey),
                    ),
                  ),
                  const SizedBox(height: 5),

                  DropdownSearch<String>(
                    popupProps: const PopupProps.menu(
                      showSelectedItems: true,
                    ),
                    items: Ruangan,
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          hintText: "...",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)
                          )
                      ),
                    ),
                    onChanged: (selectedValue){
                      print(selectedValue);
                      setState(() {
                        selectedRuangan = selectedValue ?? "";
                      });
                    },
                  ),
                  const SizedBox(height: 25),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      'Gambar AC Indoor',
                      style: TextStyles.title
                          .copyWith(fontSize: 15, color: Warna.darkgrey),
                    ),
                  ),
                  const SizedBox(height: 5),

                  FieldImage(
                    controller: gambarAcIndoorController,
                    selectedImageName: gambarAcIndoorController.text.isNotEmpty
                        ? gambarAcIndoorController.text.split('/').last
                        : '',
                    onPressed: PilihIndoor,
                  ),
                  SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      'Gambar AC Outdoor',
                      style: TextStyles.title
                          .copyWith(fontSize: 15, color: Warna.darkgrey),
                    ),
                  ),
                  const SizedBox(height: 5),

                  FieldImage(
                      controller: gambarAcOutdoorController,
                      selectedImageName: gambarAcIndoorController.text.isNotEmpty
                          ? gambarAcOutdoorController.text.split('/').last
                          : '',
                      onPressed: PilihOutdoor),
                  const SizedBox(height: 25),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: Kebutuhan_AC.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(Kebutuhan_AC[index].namaKebutuhanAC), // Accessing the property directly
                        subtitle: Text('${Kebutuhan_AC[index].masaKebutuhanAC} Bulan'), // Accessing the property directly
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            ApusKebutuhan(index);
                          },
                          color: Colors.red,
                        ),
                      );
                    },
                  ),

                  InkWell(
                    onTap: tambahKebutuhan,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Row(
                        children: [Icon(Icons.add),
                          SizedBox(width: 5),
                          Text('Tambah Kebutuhan...')],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: (){
                        if(_formState.currentState!.validate()){
                          SimpanAC();
                          print("validate suxxes");

                        }else{

                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Warna.green,
                          minimumSize: const Size(300, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25))),
                      child: Container(
                        width: 200,
                        child: Center(
                          child: Text(
                            'Save',
                            style: TextStyles.title
                                .copyWith(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
