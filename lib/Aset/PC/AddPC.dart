import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projek_skripsi/textfield/textfields.dart';
import '../../komponen/kotakDialog.dart';
import '../../komponen/style.dart';
import '../../main.dart';
import '../../textfield/imageField.dart';
import '../ControllerLogic.dart';
import 'ManajemenPC.dart';

class AddPC extends StatefulWidget {
  const AddPC({super.key,});

  @override
  State<AddPC> createState() => _AddPCState();
}


class KebutuhanModel {
  String namaKebutuhan;
  int masaKebutuhan;
  int randomID;

  KebutuhanModel(
      this.namaKebutuhan,
      this.masaKebutuhan,
      this.randomID,
      );
}

enum PCStatus { aktif, rusak, hilang }
PCStatus selectedStatus = PCStatus.aktif;

class _AddPCState extends State<AddPC> {
  String selectedKondisi = "";
  String selectedRuangan = "";
  final _formState = GlobalKey<FormState>();
  final merekPCController = TextEditingController();
  final IdPCController = TextEditingController();
  final CPUController = TextEditingController();
  final RamController = TextEditingController();
  final VGAController = TextEditingController();
  final isiKebutuhan = TextEditingController();
  final MasaKebutuhan = TextEditingController();
  final ImgPCController = TextEditingController();
  final StorageController = TextEditingController();
  final PSUController = TextEditingController();
  final ImagePicker _gambarPC = ImagePicker();
  List Kebutuhan = [];
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


  void PilihGambarPC() async{
    final pilihPC = await _gambarPC.pickImage(source: ImageSource.gallery);
    if (pilihPC != null) {
      setState(() {
        ImgPCController.text = pilihPC.path;
      });
    }
  }

  int generateRandomId() {
    Random random = Random();
    return random.nextInt(400) + 1;
  }

  void SimpanKebutuhan_PC() async {
    String masaKebutuhanText = MasaKebutuhan.text.trim();
    int randomId = generateRandomId();
    print('Random ID: $randomId');
    if (masaKebutuhanText.isNotEmpty) {
      try {
        int masaKebutuhan = int.parse(masaKebutuhanText);

        Kebutuhan.add(KebutuhanModel(
          isiKebutuhan.text,
          masaKebutuhan,
          randomId
        ));

        isiKebutuhan.clear();
        MasaKebutuhan.clear();

        setState(() {});
        await AndroidAlarmManager.oneShot(
          Duration(days: masaKebutuhan),
          randomId,
              () => myAlarmFunctionPC(randomId),
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

  void myAlarmFunctionPC(int id) {
    Notif.showTextNotif(
      judul: 'PT Dami Sariwana',
      body: 'Ada PC yang jatuh tempo!',
      fln: flutterLocalNotificationsPlugin,
      id: id,
    );
  }

  void tambahKebutuhan(){
    showDialog(
        context: context,
        builder: (context){
          return DialogBox(
            controller: isiKebutuhan,
            onAdd: SimpanKebutuhan_PC,
            onCancel: () => Navigator.of(context).pop(),
            TextJudul: 'Tambah Kebutuhan PC',
            JangkaKebutuhan: MasaKebutuhan,
          );
        });
  }

  void myAlarmFunctionLaptop() {
    // Lakukan tugas yang diperlukan saat alarm terpicu
    print('Alarm terpicu untuk kebutuhan Laptop!');
  }

  void ApusKebutuhan(int index) {
    setState(() {
      Kebutuhan.removeAt(index);
    });
  }

  Future<String> unggahGambarPC(File gambarPC) async {
    try {
      if (!gambarPC.existsSync()) {
        print('File tidak ditemukan!');
        return '';
      }
      Reference penyimpanan = FirebaseStorage.instance
          .ref()
          .child('Personal Conputer')
          .child(ImgPCController.text.split('/').last);

      UploadTask uploadPC = penyimpanan.putFile(gambarPC);
      await uploadPC;
      String fotoPC = await penyimpanan.getDownloadURL();
      return fotoPC;
    } catch (e) {
      print('$e');
      return '';
    }
  }

  void SimpanPC() async {
    try {
      String lokasiGambarPC = ImgPCController.text;
      String fotoPC = '';
      List<Map<String, dynamic>> listKebutuhan = Kebutuhan.map((kebutuhan) {
        var timeKebutuhan = contTimeService(kebutuhan.masaKebutuhan);
        return {
          'Kebutuhan PC': kebutuhan.namaKebutuhan,
          'Masa Kebutuhan': kebutuhan.masaKebutuhan,
          'Waktu Kebutuhan PC': timeKebutuhan.millisecondsSinceEpoch,
          'Hari Kebutuhan PC': daysBetween(DateTime.now(), timeKebutuhan),
          'ID' : kebutuhan.randomID
        };
      }).toList();


      // kalo lokasiGambarPC tidak kosong, unggah gambar PC
      if (lokasiGambarPC.isNotEmpty) {
        File imgPC = File(lokasiGambarPC);
        fotoPC = await unggahGambarPC(imgPC);
      }

        // Tambahkan data PC ke Firestore
        await tambahPC(
          merekPCController.text.trim(),
          IdPCController.text.trim(),
          selectedRuangan,
          selectedKondisi,
          CPUController.text.trim(),
          int.parse(RamController.text.trim()),
          int.parse(StorageController.text.trim()),
          VGAController.text.trim(),
          int.parse(PSUController.text.trim()),
          listKebutuhan,
          fotoPC,
        );

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: 'Berhasil!',
        desc: 'Data PC Berhasil Ditambahkan',
        btnOkOnPress: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ManajemenPC()),
          );
        },
        autoHide: Duration(seconds: 5),
      ).show();
      print('Data PC Berhasil Ditambahkan');

    } catch (e) {
      print("Error : $e");
    }
  }

  Future tambahPC (String merek, String ID, String selectedRuangan, String selectedKondisi,
      String CPU, int ram, int storage, String vga, int psu, List<Map<String, dynamic>> kebutuhan, String gambarPC,
      ) async{
      await FirebaseFirestore.instance.collection('PC').add({
        'Merek PC' : merek,
        'ID PC' : ID,
        'Ruangan' : selectedRuangan,
        'CPU' : CPU,
        'RAM' : ram,
        'Kapasitas Penyimpanan' : storage,
        'VGA' : vga,
        'Kapasitas Power Supply' : psu,
        'kebutuhan' : kebutuhan,
        'Gambar PC' : gambarPC,
        'Jenis Aset' : 'PC',
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
          'Tambah Data PC',
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
                      'Merek PC',
                      style: TextStyles.title
                          .copyWith(fontSize: 15, color: Warna.darkgrey),
                    ),
                  ),
                  SizedBox(height: 5),

                  MyTextField(
                      textInputType: TextInputType.text,
                      hint: '',
                      textInputAction: TextInputAction.next,
                      controller: merekPCController,
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
                      'ID PC',
                      style: TextStyles.title
                          .copyWith(fontSize: 15, color: Warna.darkgrey),
                    ),
                  ),
                  const SizedBox(height: 5),

                  MyTextField(
                      textInputType: TextInputType.text,
                      hint: '',
                      textInputAction: TextInputAction.next,
                      controller: IdPCController,
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
                      'Ruangan',
                      style: TextStyles.title
                          .copyWith(fontSize: 15, color: Warna.darkgrey),
                    ),
                  ),
                  const SizedBox(height: 5),

                  DropdownSearch<String>(
                    popupProps: PopupProps.menu(
                      showSelectedItems: true,
                    ),
                    items: Ruangan,
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
                        selectedRuangan = selectedValue ?? "";
                      });
                    },
                  ),
                  const SizedBox(height: 25),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      'CPU',
                      style: TextStyles.title
                          .copyWith(fontSize: 15, color: Warna.darkgrey),
                    ),
                  ),
                  const SizedBox(height: 5),

                  MyTextField(
                      textInputType: TextInputType.text,
                      hint: '',
                      textInputAction: TextInputAction.next,
                      controller: CPUController,
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
                      'RAM (GB)',
                      style: TextStyles.title
                          .copyWith(fontSize: 15, color: Warna.darkgrey),
                    ),
                  ),
                  const SizedBox(height: 5),

                  MyTextField(
                      textInputType: TextInputType.number,
                      hint: '',
                      textInputAction: TextInputAction.next,
                      controller: RamController,
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
                      'Storage (GB)',
                      style: TextStyles.title
                          .copyWith(fontSize: 15, color: Warna.darkgrey),
                    ),
                  ),
                  const SizedBox(height: 5),

                  MyTextField(
                      textInputType: TextInputType.number,
                      hint: '',
                      textInputAction: TextInputAction.next,
                      controller: StorageController,
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
                      'VGA',
                      style: TextStyles.title
                          .copyWith(fontSize: 15, color: Warna.darkgrey),
                    ),
                  ),
                  const SizedBox(height: 5),

                  MyTextField(
                      textInputType: TextInputType.text,
                      hint: '',
                      textInputAction: TextInputAction.next,
                      controller: VGAController,
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
                      'Kapasitas PSU (watt)',
                      style: TextStyles.title
                          .copyWith(fontSize: 15, color: Warna.darkgrey),
                    ),
                  ),
                  const SizedBox(height: 5),

                  MyTextField(
                      textInputType: TextInputType.number,
                      hint: '',
                      textInputAction: TextInputAction.next,
                      controller: PSUController,
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
                      'Gambar PC',
                      style: TextStyles.title
                          .copyWith(fontSize: 15, color: Warna.darkgrey),
                    ),
                  ),
                  const SizedBox(height: 5),

                  FieldImage(
                      controller: ImgPCController,
                      selectedImageName: ImgPCController.text.isNotEmpty
                          ? ImgPCController.text.split('/').last
                          : '',
                      onPressed: PilihGambarPC),
                  const SizedBox(height: 25),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text(
                      'Kebutuhan',
                      style: TextStyles.title
                          .copyWith(fontSize: 15, color: Warna.darkgrey),
                    ),
                  ),
                  const SizedBox(height: 5),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: Kebutuhan.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(Kebutuhan[index].namaKebutuhan),
                        subtitle: Text('${Kebutuhan[index].masaKebutuhan} Bulan'),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            ApusKebutuhan(index); // Fungsi apus kebutuhan
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
                      padding: EdgeInsets.all(8),
                      child: Row(
                        children: [Icon(Icons.add),
                        SizedBox(width: 5),
                        Text('Tambah Kebutuhan...')],
                      ),
                    ),
                  ),

                  SizedBox(height: 30),

                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: (){
                        if(_formState.currentState!.validate()){
                          SimpanPC();
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
