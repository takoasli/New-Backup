import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projek_skripsi/Catatan/Dashboards.dart';
import 'package:projek_skripsi/komponen/kotakDialogCatatan.dart';
import '../Aset/ControllerLogic.dart';
import '../komponen/checklists.dart';
import '../komponen/kotakBiaya.dart';
import '../komponen/style.dart';


class Catatan extends StatefulWidget {
  const Catatan({Key? key,
    required this.List_Kebutuhan,
    required this.ID_Aset,
    required this.Nama_Aset,
    required this.Jenis_Aset,
    this.lokasiAset,}) : super(key: key);

  final List<dynamic> List_Kebutuhan;
  final String ID_Aset;
  final String Nama_Aset;
  final String Jenis_Aset;
  final String? lokasiAset;

  @override
  State<Catatan> createState() => _CatatanState();
}

class _CatatanState extends State<Catatan> {

  final isiDialog = TextEditingController();
  final isiBiaya = TextEditingController();
  final CatatanLengkapController = TextEditingController();
  final hargaIsiBiaya = TextEditingController(text: '');
  late String idAset;
  late String merekAset;
  late String jenisAset;
  late String lokasi;
  List<List<dynamic>> List_Kebutuhan = [];
  List biayaKebutuhans = [];


  void checkBoxberubah(bool? value, int index) {
    setState(() {
      if (value != null) {
        List_Kebutuhan[index][1] = value;
      }
    });
  }


  void SimpanTask(BuildContext context) {
    setState(() {
      List_Kebutuhan.add([isiDialog.text, false]);
      isiDialog.clear();
    });
    Navigator.of(context).pop();
  }

  void tambahTugas() {
    showDialog(
        context: context,
        builder: (context) {
          return KotakCatatanKebutuhan(
              controller: isiDialog,
              TextJudul: 'Kebutuhan Tambahan',
              onAdd: () => SimpanTask(context),
              onCancel: () => Navigator.of(context).pop());
        });
  }


  void ApusTask(int index){
  setState(() {
    List_Kebutuhan.removeAt(index);
  });
  }

  void SimpanBiaya(BuildContext context) {
    setState(() {
      // Pastikan isiBiaya dan hargaIsiBiaya tidak kosong
      if (isiBiaya.text.isNotEmpty && hargaIsiBiaya.text.isNotEmpty) {
        // Tambahkan nama biaya dan harga ke Biaya_Kebutuhan
        biayaKebutuhans.add(
            CatatanBiaya(isiBiaya.text, double.parse(hargaIsiBiaya.text.replaceAll(".", ""))));
        isiBiaya.clear();
        hargaIsiBiaya.clear();
      } else {
        print('tolong tambahkan informasi yang diminta');
      }
    });
    Navigator.of(context).pop();
  }

  void tambahListBiaya() {
    showDialog(
        context: context,
        builder: (context) {
          return DialogBiaya(
            NamaBiayacontroller: isiBiaya,
            HargaBiayacontroller: hargaIsiBiaya,
            onAdd: () => SimpanBiaya(context),
            onCancel: () => Navigator.of(context).pop(),
            TextJudul: 'Tambah Nama Biaya',
          );
        });
  }

  void ApusBiayaAC(int index) {
    setState(() {
      biayaKebutuhans.removeAt(index);
    });
  }

  double hitungTotalBiaya() {
    double totalBiaya = 0.0;
    for (int i = 0; i < biayaKebutuhans.length; i++) {
      totalBiaya += biayaKebutuhans[i].biaya;
    }
    return totalBiaya;
  }

  void SimpanCatatan() async {
    try {
      // Construct List of Kebutuhan data
      List<Map<String, dynamic>> DataKebutuhan = [];
      for (int i = 0; i < List_Kebutuhan.length; i++) {
        DataKebutuhan.add({
          'Nama Kebutuhan': List_Kebutuhan[i][0],
          'status': List_Kebutuhan[i][1] ? 'Done' : 'unDone',
        });
      }

      List<Map<String, dynamic>> CatatanBiaya = [];
      for (int i = 0; i < biayaKebutuhans.length; i++) {
        CatatanBiaya.add({
          'Nama Biaya': biayaKebutuhans[i].nama,
          'Harga Biaya': biayaKebutuhans[i].biaya,
        });
      }

      // Save data into Firestore
      await tambahCatatan(
          merekAset,
          idAset,
          lokasi,
          DataKebutuhan,
          CatatanBiaya,
          CatatanLengkapController.text,
          hitungTotalBiaya(),
          jenisAset
      );

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: 'Berhasil!',
        desc: 'Catatan Berhasil Ditambahkan!',
        btnOkOnPress: () {
          Navigator.of(context).pop();
        },
        btnOkText: 'Ok',
        btnCancelOnPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Dashboards()),
          );
        },
        btnCancelText: 'Dashboard',
        btnCancel: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Warna.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Dashboards()),
            );
          },
          child: Text('Dashboard'),
        ),
      ).show();

      print('Data Catatan Berhasil Disimpan!');
    } catch (e) {
      print("Error: $e");
    }
  }

  Future tambahCatatan (
      String merekAset,
      String idAset,
      String lokasi,
      List<Map<String, dynamic>> ListButuh,
      List<Map<String, dynamic>> CatatanBiaya,
      String CatatanLengkap,
      double totalBiaya,
      String jenisAset) async{
    await FirebaseFirestore.instance.collection('Catatan Servis').add({
      'Nama Aset': merekAset,
      'ID Aset': idAset,
      'Lokasi Aset' : lokasi,
      'List Kebutuhan' : ListButuh,
      'Catatan Biaya' : CatatanBiaya,
      'Catatan Tambahan' : CatatanLengkap,
      'Total Biaya' : totalBiaya,
      'Jenis Aset' : jenisAset,
      'Tanggal Dilakukan Servis': FieldValue.serverTimestamp(),
    });
  }




  @override
  void initState(){
    super.initState();
    idAset = '${widget.ID_Aset}';
    merekAset = '${widget.Nama_Aset}';
    jenisAset = '${widget.Jenis_Aset}';
    lokasi = '${widget.lokasiAset}';
    List_Kebutuhan = List<List<dynamic>>.from(widget.List_Kebutuhan.map((item) => [item, false]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Warna.green,
      appBar: AppBar(
        backgroundColor: Warna.green,
        title: const Text(
          'Catatan Servis',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        elevation: 1,
        centerTitle: false,
      ),

      body: SingleChildScrollView(
        child: Center(
          child: Stack(
            children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: Text('Aset yang terpilih...',
                          style: TextStyles.title.copyWith(fontSize: 20, color: Warna.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: 370,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Warna.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 15),
                          const Padding(
                              padding: EdgeInsets.all(10),
                          child:
                          Icon(Icons.home_repair_service_outlined,
                          size: 40
                          ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(merekAset,
                              style: TextStyles.title.copyWith(fontSize: 20)
                              ),
                              SizedBox(height: 5.0),
                              Text(idAset,
                              style: TextStyles.body.copyWith(fontSize: 17),
                              ),
                              Text(jenisAset,
                                style: TextStyles.body.copyWith(fontSize: 17),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: Text('List Kebutuhan',
                        style: TextStyles.title.copyWith(fontSize: 20, color: Warna.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Container(
                      width: 350,
                      height: 350,
                      decoration: BoxDecoration(
                        color: Warna.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              itemCount: List_Kebutuhan.length,
                              itemBuilder: (context, index) {
                                return Checklist(
                                  namaTask: List_Kebutuhan[index][0],
                                  TaskKelar: List_Kebutuhan[index][1],
                                  onChanged: (value) => checkBoxberubah(value, index),
                                  Hapus: (context) => ApusTask(index),
                                );
                              },
                            ),
                          ),
                          InkWell(
                            onTap: tambahTugas,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Row(
                                children: [
                                  Icon(Icons.add),
                                  SizedBox(width: 5),
                                  Text('Tambah Kebutuhan Lainnya...'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: Text('Catatan Biaya',
                          style: TextStyles.title.copyWith(fontSize: 20, color: Warna.white)
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    Container(
                      width: 350,
                      height: 300,
                      decoration: BoxDecoration(
                        color: Warna.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListView(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: biayaKebutuhans.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(biayaKebutuhans[index].nama),
                                  subtitle: Text(convertToRupiah(
                                      biayaKebutuhans[index].biaya)),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      ApusBiayaAC(index);
                                    },
                                    color: Colors.red,
                                  ),
                                );
                              },
                            ),
                          ),
                          InkWell(
                            onTap: tambahListBiaya,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Row(
                                children: [
                                  Icon(Icons.add),
                                  SizedBox(width: 5),
                                  Text('Tambah Biaya Penyeluaran...'),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                        ],
                      ),
                    ),
                    SizedBox(height: 15),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 25.0),
                        child: Text('Catatan Lengkap',
                          style: TextStyles.title.copyWith(fontSize: 20, color: Warna.white),),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Container(
                      width: 350,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Warna.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: TextField(
                          controller: CatatanLengkapController,
                          maxLines: null, // Untuk mengizinkan multiple baris teks
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Masukkan catatan tambahan...',
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 10),
                    Container(
                      width: 350,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Warna.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 15.0),
                            child: Text(
                              'Total:',
                              style: TextStyles.title.copyWith(
                                fontSize: 18,
                                color: Warna.darkgrey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Text(
                                convertToRupiah(hitungTotalBiaya()),
                                style: TextStyles.title.copyWith(
                                  fontSize: 18,
                                  color: Warna.darkgrey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                          onPressed: SimpanCatatan,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Warna.white,
                              minimumSize: const Size(200, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                              side: const BorderSide(color: Warna.lightgreen, width: 5),
                              )
                          ),
                          child: Container(
                            width: 200,
                            child: Center(
                              child: Text(
                                'Simpan Catatan',
                                style: TextStyles.title
                                    .copyWith(fontSize: 20, color: Warna.black),
                              ),
                            ),
                          ),
                        ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
