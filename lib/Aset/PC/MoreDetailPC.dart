import 'dart:async';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import '../../Catatan/catatanAset.dart';
import '../../komponen/style.dart';
import '../../qrView.dart';
import '../ControllerLogic.dart';

class MoreDetail extends StatefulWidget {
  const MoreDetail({super.key,
    required this.data});
  final Map<String, dynamic> data;

  @override
  State<MoreDetail> createState() => _MoreDetailState();
}

class _MoreDetailState extends State<MoreDetail> {
  late DateTime targetDate = DateTime(2024, 2, 1);
  late Timer timer;
  double progressValue = 1.0;


  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (DateTime.now().isBefore(targetDate)) {
        setState(() {
          progressValue = targetDate.difference(DateTime.now()).inSeconds /
              targetDate.difference(DateTime(targetDate.year, targetDate.month, 0)).inSeconds;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    String imageUrl = widget.data['Gambar PC'] ?? '';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF61BF9D),
        title: Text(
            '${widget.data['ID PC']}',
            style: TextStyles.title.copyWith(
                fontSize: 20,
                color: Warna.white
            )
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 370,
              height: 570,
              decoration: BoxDecoration(
                color: Warna.green,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                      )
                          : Image.asset(
                        'gambar/pc.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  Positioned(
                      top: 30,
                      right: 30,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Warna.white,
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QRView(
                                    assetCollection: "PC",
                                    assetId: widget.data['ID PC'],
                                    assetName: widget.data['Merek PC'],
                                  ),
                                ));
                          },
                          icon: const Icon(Icons.qr_code_2, size: 33),
                        ),
                      )),
                  Positioned(
                      top: 100,
                      right: 30,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Warna.white,
                        ),
                        child: IconButton(
                          onPressed: () {
                            AwesomeDialog(
                              context: context,
                              dialogType: DialogType.infoReverse,
                              headerAnimationLoop: false,
                              animType: AnimType.topSlide,
                              showCloseIcon: true,
                              closeIcon: const Icon(Icons.close),
                              title: 'Peringatan',
                              desc:
                              'Silahkan Periksa Aset! Apa Perlu diservis?',
                              btnOkOnPress: () {
                                List<dynamic> kebutuhanPC = widget.data['kebutuhan'];
                                List<String> namaKebutuhan = [];
                                for (var kebutuhan in kebutuhanPC) {
                                  if (kebutuhan is Map<String, dynamic> &&
                                      kebutuhan.containsKey('Kebutuhan PC')) {
                                    namaKebutuhan.add(kebutuhan['Kebutuhan PC']);
                                  }
                                }

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Catatan(
                                          List_Kebutuhan: namaKebutuhan,
                                          ID_Aset: widget.data['ID PC'],
                                          Nama_Aset: widget.data['Merek PC'],
                                          Jenis_Aset: widget.data['Jenis Aset'],
                                          lokasiAset: widget.data['Ruangan'],
                                        )
                                    )
                                );
                              },
                              btnCancelOnPress: () {},
                              onDismissCallback: (type) {
                                debugPrint('button yang ditekan $type');
                              },
                            ).show();
                          },
                          icon:
                          const Icon(Icons.border_color_outlined, size: 33),
                        ),
                      )
                  ),
                  Positioned(
                    top: 170,
                    child: Container(
                      width: 320,
                      height: 380,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  'Kebutuhan Servis',
                                  style: TextStyles.title.copyWith(
                                      fontSize: 18,
                                      color: Warna.darkgrey,
                                      fontWeight: FontWeight.w500
                                  )
                              ),
                              const SizedBox(height: 5),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: widget.data['kebutuhan'].length,
                                    itemBuilder: (context, index) {
                                      final kebutuhan = widget.data['kebutuhan']
                                      [index]['Kebutuhan PC'];
                                      ['Masa Kebutuhan'];
                                      final hariKebutuhan =
                                      widget.data['kebutuhan'][index]
                                      ['Hari Kebutuhan PC'];
                                      final waktuKebutuhan =
                                      widget.data['kebutuhan'][index]
                                      ['Waktu Kebutuhan PC'];

                                      final part = kebutuhan.split(': ');
                                      final hasSplit =
                                      part.length > 1 ? part[1] : kebutuhan;

                                      return SizedBox(
                                        height: 80,
                                        child: ListTile(
                                          dense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 8),
                                          title: Text(
                                            '- $hasSplit',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              showIndicator(
                                                getValueIndicator(
                                                    hariKebutuhan,
                                                    epochTimeToData(
                                                        waktuKebutuhan)),
                                                getProgressColor(
                                                    waktuKebutuhan),
                                              ),
                                              const SizedBox(height: 5),
                                              Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    overflow:
                                                    TextOverflow.ellipsis,
                                                    getRemainingTime(
                                                        waktuKebutuhan),
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                  'Merek PC',
                                  style: TextStyles.title.copyWith(
                                      fontSize: 18,
                                      color: Warna.darkgrey,
                                      fontWeight: FontWeight.w500
                                  )
                              ),
                              Text(
                                '${widget.data['Merek PC']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 15),

                              Text(
                                  'ID PC',
                                  style: TextStyles.title.copyWith(
                                      fontSize: 18,
                                      color: Warna.darkgrey,
                                      fontWeight: FontWeight.w500
                                  )
                              ),
                              Text(
                                '${widget.data['ID PC']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 15),

                              Text(
                                  'Lokasi Ruangan',
                                  style: TextStyles.title.copyWith(
                                      fontSize: 18,
                                      color: Warna.darkgrey,
                                      fontWeight: FontWeight.w500
                                  )
                              ),
                              Text(
                                '${widget.data['Ruangan']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 15),

                              Text(
                                  'CPU',
                                  style: TextStyles.title.copyWith(
                                      fontSize: 18,
                                      color: Warna.darkgrey,
                                      fontWeight: FontWeight.w500
                                  )
                              ),
                              Text(
                                '${widget.data['CPU']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 15),

                              Text(
                                  'RAM',
                                  style: TextStyles.title.copyWith(
                                      fontSize: 18,
                                      color: Warna.darkgrey,
                                      fontWeight: FontWeight.w500
                                  )
                              ),
                              Text(
                                '${widget.data['RAM']} GB',
                                style: const TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 15),

                              Text(
                                  'Kapasitas Penyimpanan',
                                  style: TextStyles.title.copyWith(
                                      fontSize: 18,
                                      color: Warna.darkgrey,
                                      fontWeight: FontWeight.w500
                                  )
                              ),
                              Text(
                                '${widget.data['Kapasitas Penyimpanan']} GB',
                                style: const TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 15),

                              Text(
                                  'VGA',
                                  style: TextStyles.title.copyWith(
                                      fontSize: 18,
                                      color: Warna.darkgrey,
                                      fontWeight: FontWeight.w500
                                  )
                              ),
                              Text(
                                '${widget.data['VGA']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 15),

                              Text(
                                  'Power Supply',
                                  style: TextStyles.title.copyWith(
                                      fontSize: 18,
                                      color: Warna.darkgrey,
                                      fontWeight: FontWeight.w500
                                  )
                              ),
                              Text(
                                '${widget.data['Kapasitas Power Supply']}W',
                                style: const TextStyle(
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
