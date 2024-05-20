import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:projek_skripsi/Aset/Motor/ManajemenMotor.dart';
import 'package:projek_skripsi/Aset/Motor/MoreDetailMotor.dart';
import '../../komponen/boxAset.dart';
import '../../komponen/style.dart';

class DetailMotor extends StatefulWidget {
  const DetailMotor({super.key});

  @override
  State<DetailMotor> createState() => _DetailMotorState();
}

class _DetailMotorState extends State<DetailMotor> {
  late List<String> docDetailMotor = [];
  late List<Map<String, dynamic>> _allresult = [];
  late List<Map<String, dynamic>> _resultList = [];
  final TextEditingController _searchController = TextEditingController();

  Future<void> getDetailMotor() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
    await FirebaseFirestore.instance.collection('Motor').get();
    setState(() {
      docDetailMotor = snapshot.docs.map((doc) => doc.id).toList();
      _allresult = snapshot.docs.map((doc) => doc.data()).toList().cast<Map<String, dynamic>>();
      _resultList = List.from(_allresult);
    });
  }

  @override
  void initState() {
    super.initState();
    getDetailMotor();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    searchResultList(_searchController.text);
  }

  void searchResultList(String query) {
    if (query.isNotEmpty) {
      List<Map<String, dynamic>> showResult = [];
      for (var dataMotor in _allresult) {
        var name = dataMotor['Merek Motor'].toString().toLowerCase();
        if (name.contains(query.toLowerCase())) {
          showResult.add(dataMotor);
        }
      }
      setState(() {
        _resultList = showResult;
      });
    } else {
      setState(() {
        _resultList = List.from(_allresult);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF61BF9D),
        title: const Text(
          'Detail Motor',
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Cari Motor...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
          ),

          Expanded(
            child: _resultList.isEmpty
                ? const Center(
              child: Text('Data tidak ditemukan'),
            )
                : Padding(
              padding: const EdgeInsets.only(top: 20, left: 30),
              child: GridView.builder(
                itemCount: _resultList.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemBuilder: (context, index) {
                  Map<String, dynamic> dataMotor = _resultList[index];
                  String gambarMotor = dataMotor['Gambar Motor'] ?? '';

                  ImageProvider<Object>? imageProvider;
                  if (gambarMotor.isNotEmpty) {
                    imageProvider = NetworkImage(gambarMotor);
                  } else {
                    imageProvider = const AssetImage('gambar/motor.png');
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      BoxAset(
                        text: '${dataMotor['Merek Motor']}',
                        gambar: imageProvider,
                        halaman: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MoreDetailMotor(
                                data: dataMotor,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SpeedDial(
          child: const Icon(Icons.more_horiz,
              color: Warna.white),
          backgroundColor: Warna.green,
          activeIcon: Icons.close,
          curve: Curves.bounceIn,
          children: [
            SpeedDialChild(
              elevation: 0,
              child: const Icon(Icons.create_new_folder,
                  color: Warna.white),
              labelWidget: const Text("Manage Motor",
                  style: TextStyle(color: Warna.green)
              ),
              backgroundColor: Warna.green,
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManajemenMotor()),
                );
              },
            ),

            SpeedDialChild(
              elevation: 0,
              child: const Icon(Icons.motorcycle,
                  color: Warna.white),
              labelWidget: const Text("Detail Motor",
                  style: TextStyle(color: Warna.green)
              ),
              backgroundColor: Warna.green,
              onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DetailMotor()),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
