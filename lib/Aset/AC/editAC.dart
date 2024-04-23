import 'dart:io';
import 'dart:math';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projek_skripsi/Aset/AC/ManajemenAC.dart';

import '../../komponen/kotakDialog.dart';
import '../../komponen/style.dart';
import '../../main.dart';
import '../../textfield/imageField.dart';
import '../../textfield/textfields.dart';
import '../ControllerLogic.dart';

class UpdateAC extends StatefulWidget {
  const UpdateAC({super.key, required this.dokumenAC});
  final String dokumenAC;

  @override
  State<UpdateAC> createState() => _UpdateACState();
}

class KebutuhanModelUpdateAC {
  String namaKebutuhanAC;
  int masaKebutuhanAC;
  int RandomID;

  KebutuhanModelUpdateAC(
      this.namaKebutuhanAC,
      this.masaKebutuhanAC,
      this.RandomID);

  Map<String, dynamic> toMap() {
    return {
      'Nama Kebutuhan AC': namaKebutuhanAC,
      'Masa Kebutuhan AC': masaKebutuhanAC,
      'ID' : RandomID,
    };
  }
}


class _UpdateACState extends State<UpdateAC> {
  String selectedRuangan = "";
  String selectedKondisi = "";
  final MerekACController = TextEditingController();
  final idACController = TextEditingController();
  final wattController = TextEditingController();
  final PKController = TextEditingController();
  final MasaKebutuhanController = TextEditingController();
  final isiKebutuhan_AC = TextEditingController();
  final ImagePicker _gambarACIndoor = ImagePicker();
  final ImagePicker _gambarACOutdoor = ImagePicker();
  final gambarAcIndoorController = TextEditingController();
  final _formState = GlobalKey<FormState>();
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

  List<String> StatusAC = [
    "Aktif",
    "Rusak",
    "Hilang"
  ];
  String oldphotoIndoor = '';
  String oldphotoOutdoor = '';
  Map <String, dynamic> dataAC = {};
  final Sukses = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: 'SUCCESS',
      message:
      'Data AC berhasil Diupdate!',
      contentType: ContentType.success,
    ),
  );

  final gagal = SnackBar(
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: 'FAILED',
      message:
      'Data AC Gagal Dibuat',
      contentType: ContentType.success,
    ),
  );

  void SimpanKebutuhan_AC() async {
    String masaKebutuhanText = MasaKebutuhanController.text.trim();
    int randomId = generateRandomId();
    if (masaKebutuhanText.isNotEmpty) {
      try {
        int masaKebutuhan = int.parse(masaKebutuhanText);

        Kebutuhan_AC.add({
          'Nama Kebutuhan AC': isiKebutuhan_AC.text,
          'Masa Kebutuhan AC': masaKebutuhan,
          'ID' : randomId,
        });

        isiKebutuhan_AC.clear();
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

      } catch (error) {
        print('Error saat mengatur alarm: $error');
        // Lakukan penanganan kesalahan jika parsing gagal
      }
    } else {
      print('Input Masa Kebutuhan tidak boleh kosong');
      // Tindakan jika input kosong
    }
  }

  void AlarmFunctionAC(int id) {
    // Lakukan tugas yang diperlukan saat alarm terpicu
    Notif.showTextNotif(
      judul: 'PT Dami Sariwana',
      body: 'Ada Aset PC yang jatuh tempo!',
      fln: flutterLocalNotificationsPlugin,
      id: id,
    );
  }

  void tambahKebutuhan_AC(){
    showDialog(
        context: context,
        builder: (context){
          return DialogBox(
            controller: isiKebutuhan_AC,
            onAdd: SimpanKebutuhan_AC,
            onCancel: () => Navigator.of(context).pop(),
            TextJudul: 'Tambah Kebutuhan AC',
            JangkaKebutuhan: MasaKebutuhanController,
          );
        });
  }

  void ApusKebutuhan_AC(int index) {
    setState(() {
      Kebutuhan_AC.removeAt(index);
    });
  }

  void PilihUpdateIndoor() async {
    final pilihIndoor = await _gambarACIndoor.pickImage(source: ImageSource.gallery);
    if (pilihIndoor != null) {
      setState(() {
        gambarAcIndoorController.text = pilihIndoor.path;
      });
    }
  }

  void PilihUpdateOutdoor() async {
    final pilihOutdoor = await _gambarACOutdoor.pickImage(source: ImageSource.gallery);
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

  int generateRandomId() {
    Random random = Random();
    return random.nextInt(400) + 1;
  }

  Future<void> UpdateAC(String dokAC, Map<String, dynamic> DataAC) async{
    try{
      String GambarACIndoor;
      String GambarACOutdoor;
      List<Map<String, dynamic>> ListKebutuhan_AC = Kebutuhan_AC.map((kebutuhan) {
        var timeKebutuhan = contTimeService(int.parse(kebutuhan['Masa Kebutuhan AC'].toString()));
        return {
          'Nama Kebutuhan AC': kebutuhan['Nama Kebutuhan AC'],
          'Masa Kebutuhan AC': kebutuhan['Masa Kebutuhan AC'],
          'Waktu Kebutuhan AC': timeKebutuhan.millisecondsSinceEpoch,
          'Hari Kebutuhan AC': daysBetween(DateTime.now(), timeKebutuhan),
          'ID' : kebutuhan['ID'],
        };
      }).toList();

      if(gambarAcIndoorController.text.isNotEmpty&&gambarAcOutdoorController.text.isNotEmpty
      ||gambarAcIndoorController.text.isNotEmpty&&gambarAcOutdoorController.text.isEmpty){
        File gambarIndoorBaru = File(gambarAcIndoorController.text);
        GambarACIndoor = await unggahACIndoor(gambarIndoorBaru);
        File gambarOutdoorBaru = File(gambarAcOutdoorController.text);
        GambarACOutdoor = await unggahACOutdoor(gambarOutdoorBaru);
      }else{
        GambarACIndoor = oldphotoIndoor;
        GambarACOutdoor = oldphotoOutdoor;
      }

      for(var item in ListKebutuhan_AC){
        var waktuKebutuhanAC = contTimeService(int.parse(item['Masa Kebutuhan AC'].toString()));
        Map<String, dynamic> DataACBaru = {
          'Merek AC': MerekACController.text,
          'ID AC': idACController.text,
          'Kapasitas Watt': wattController.text,
          'Kapasitas PK': PKController.text,
          'Ruangan' : selectedRuangan,
          'Kebutuhan AC' : ListKebutuhan_AC,
          'Foto AC Indoor': GambarACIndoor,
          'Foto AC Outdoor': GambarACOutdoor,
          'Jenis Aset' : 'AC',
          'Waktu Kebutuhan AC' : waktuKebutuhanAC.millisecondsSinceEpoch,
          'Hari Kebutuhan AC' : daysBetween(DateTime.now(), waktuKebutuhanAC),
          'Status' : selectedKondisi
        };
        await FirebaseFirestore.instance.collection('Aset').doc(dokAC).update(DataACBaru);
      }

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: 'Berhasil!',
        desc: 'Data AC Berhasil Diupdate',
        btnOkOnPress: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ManajemenAC()),
          );
        },
      ).show();

      print('Data AC Berhasil Diupdate');
    }catch (e){
      print(e);
    }
  }

  void initState(){
    super.initState();
    getData();
  }

  Future<void> getData() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('Aset').doc(widget.dokumenAC).get();
      final data = snapshot.data();

      setState(() {
        MerekACController.text = data?['Merek AC'] ?? '';
        idACController.text = data?['ID AC'] ?? '';
        selectedKondisi = data?['Status'] ?? '';
        wattController.text = (data?['Kapasitas Watt'] ?? '').toString();
        PKController.text = (data?['Kapasitas PK'] ?? '').toString();
        selectedRuangan = data?['Ruangan'] ?? '';
        final UrlIndoor = data?['Foto AC Indoor'] ?? '';
        oldphotoIndoor = UrlIndoor;
        final UrlOutdoor = data?['Foto AC Outdoor'] ?? '';
        oldphotoOutdoor = UrlOutdoor;
        Kebutuhan_AC = List<Map<String, dynamic>>.from(data?['Kebutuhan AC'] ?? []);
      });
    } catch (e) {
      print('Terjadi Kesalahan: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.green,
      appBar: AppBar(
        backgroundColor: const Color(0xFF61BF9D),
        title: const Text(
          'Edit Data AC',
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
                    popupProps: const PopupProps.menu(
                      showSelectedItems: true,
                    ),
                    items: StatusAC,
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
                  const SizedBox(height: 25),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text('kapasitas PK',
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

                  const SizedBox(height: 25),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Text('Ruangan',
                      style: TextStyles.title
                          .copyWith(fontSize: 15, color: Warna.darkgrey)
                      ,)
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
                          hintText: "Pilih Ruangan...",
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
                        ? gambarAcIndoorController.text.split('/').last // Display only the image name
                        : '',
                    onPressed: PilihUpdateIndoor, // Pass the pickImage method to FieldImage
                  ),

                  const SizedBox(height: 25),

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
                          ? gambarAcOutdoorController.text.split('/').last // Display only the image name
                          : '',
                      onPressed: PilihUpdateOutdoor),
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
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: Kebutuhan_AC.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(Kebutuhan_AC[index]['Nama Kebutuhan AC']),
                        subtitle: Text('${Kebutuhan_AC[index]['Masa Kebutuhan AC']} Bulan'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            ApusKebutuhan_AC(index);
                          },
                          color: Colors.red,
                        ),
                      );
                    },
                  ),



                  InkWell(
                    onTap: tambahKebutuhan_AC,
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
                          UpdateAC(widget.dokumenAC, dataAC);
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
