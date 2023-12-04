import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:projek_skripsi/Aset/AC/ManajemenAC.dart';

import '../../komponen/style.dart';
import '../../textfield/imageField.dart';
import '../../textfield/textfields.dart';

class UpdateAC extends StatefulWidget {
  const UpdateAC({super.key, required this.dokumenAC});
  final String dokumenAC;

  @override
  State<UpdateAC> createState() => _UpdateACState();
}

class _UpdateACState extends State<UpdateAC> {
  final MerekACController = TextEditingController();
  final idACController = TextEditingController();
  final wattController = TextEditingController();
  final PKController = TextEditingController();
  final ruanganController = TextEditingController();
  final MasaServisACController = TextEditingController();
  final ImagePicker _gambarACIndoor = ImagePicker();
  final ImagePicker _gambarACOutdoor = ImagePicker();
  final gambarAcIndoorController = TextEditingController();
  final gambarAcOutdoorController = TextEditingController();
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

  Future<void> UpdateAC(String dokAC, Map<String, dynamic> DataAC) async{
    try{
      String GambarACIndoor;
      String GambarACOutdoor;

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

      Map<String, dynamic> DataACBaru = {
        'Merek AC': MerekACController.text,
        'ID AC': idACController.text,
        'Kapasitas Watt': wattController.text,
        'Kapasitas PK': PKController.text,
        'Lokasi Ruangan' : ruanganController.text,
        'Masa Servis' : MasaServisACController.text,
        'Foto AC Indoor': GambarACIndoor,
        'Foto AC Outdoor': GambarACOutdoor,
      };

      await FirebaseFirestore.instance.collection('Aset').doc(dokAC).update(DataACBaru);

      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => ManajemenAC()),
      );
    }catch (e){
      print(e);
    }
  }

  void initState(){
    super.initState();
    getData();
  }

  Future<void> getData() async{
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('Aset').doc(widget.dokumenAC).get();
    final data = snapshot.data();

    setState(() {
      MerekACController.text = data?['Merek AC'] ?? '';
      idACController.text = data?['ID AC'] ?? '';
      wattController.text = (data?['Kapasitas Watt'] ?? '').toString();
      PKController.text = (data?['Kapasitas PK'] ?? '').toString();
      ruanganController.text = data?['Lokasi Ruangan' ?? ''];
      MasaServisACController.text = (data?['Masa Servis'] ?? '').toString();
      final UrlIndoor = data?['Foto AC Indoor'] ?? '';
      oldphotoIndoor = UrlIndoor;
      final UrlOutdoor = data?['Foto AC Outdoor'] ?? '';
      oldphotoOutdoor = UrlOutdoor;
    });
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
                const SizedBox(height: 10),
                MyTextField(
                    textInputType: TextInputType.text,
                    hint: '',
                    textInputAction: TextInputAction.next,
                    controller: MerekACController),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'ID AC',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                const SizedBox(height: 10),
                MyTextField(
                    textInputType: TextInputType.text,
                    hint: '',
                    textInputAction: TextInputAction.next,
                    controller: idACController),

                SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'Kapasitas Watt',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),

                MyTextField(
                    textInputType: TextInputType.number,
                    hint: '',
                    textInputAction: TextInputAction.next,
                    controller: wattController),

                SizedBox(height: 10),

                Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Text('kapasitas PK',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),

                MyTextField(
                    textInputType: TextInputType.number,
                    hint: '',
                    textInputAction: TextInputAction.next,
                    controller: PKController),

                SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'Jangka Waktu Servis (Perbulan)',
                    style: TextStyles.title.copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),
                SizedBox(height: 10),

                MyTextField(
                  textInputType: TextInputType.number,
                  hint: '',
                  textInputAction: TextInputAction.next,
                  controller: MasaServisACController,
                ),
                SizedBox(height: 10),

                Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Text('Ruangan',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey)
                    ,)
                  ),

                MyTextField(
                    textInputType: TextInputType.text,
                    hint: '',
                    textInputAction: TextInputAction.next,
                    controller: ruanganController),

                SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'Gambar AC Indoor',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),

                FieldImage(
                  controller: gambarAcIndoorController,
                  selectedImageName: gambarAcIndoorController.text.isNotEmpty
                      ? gambarAcIndoorController.text.split('/').last // Display only the image name
                      : '',
                  onPressed: PilihUpdateIndoor, // Pass the pickImage method to FieldImage
                ),

                SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'Gambar AC Outdoor',
                    style: TextStyles.title
                        .copyWith(fontSize: 15, color: Warna.darkgrey),
                  ),
                ),

                FieldImage(
                    controller: gambarAcOutdoorController,
                    selectedImageName: gambarAcIndoorController.text.isNotEmpty
                        ? gambarAcOutdoorController.text.split('/').last // Display only the image name
                        : '',
                    onPressed: PilihUpdateOutdoor),

                const SizedBox(height: 30),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: (){
                      UpdateAC(widget.dokumenAC, dataAC);
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
    );
  }
}