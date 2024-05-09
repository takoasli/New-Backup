import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../Aset/ControllerLogic.dart';
import '../../komponen/style.dart';

class BacaStatusMobil extends StatelessWidget {
  const BacaStatusMobil({super.key, required this.dokumenMobil});

  final String dokumenMobil;

  @override
  Widget build(BuildContext context) {
    CollectionReference Mobil = FirebaseFirestore.instance.collection('Mobil');
    return FutureBuilder<DocumentSnapshot>(
      future: Mobil.doc(dokumenMobil).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error : ${snapshot.error}');
          }
          Map<String, dynamic> dataMobil = snapshot.data!.data() as Map<
              String,
              dynamic>;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${dataMobil['Merek Mobil']}',
                    style: TextStyles.title.copyWith(
                        fontSize: 20, color: Warna.darkgrey),
                  ),
                  Text(
                    '${dataMobil['Jenis Aset']}',
                    style: TextStyles.body.copyWith(
                        fontSize: 15, color: Warna.darkgrey),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: dataMobil['Kebutuhan Mobil'].length,
                    itemBuilder: (context, index) {
                      final kebutuhanMobil = dataMobil['Kebutuhan Mobil'][index]['Nama Kebutuhan Mobil'];
                      final hariKebutuhanMobil = dataMobil['Kebutuhan Mobil'][index]['Hari Kebutuhan Mobil'];
                      final waktuKebutuhanMobil = dataMobil['Kebutuhan Mobil'][index]['Waktu Kebutuhan Mobil'];

                      final part = kebutuhanMobil.split(': ');
                      final hasSplit = part.length > 1 ? part[1] : kebutuhanMobil;

                      return SizedBox(
                        height: 80,
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8),
                          title: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              '- $hasSplit',
                              style: const TextStyle(
                                fontSize: 16,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              showIndicator(
                                getValueIndicator(hariKebutuhanMobil,
                                    epochTimeToData(waktuKebutuhanMobil)),
                                getProgressColor(waktuKebutuhanMobil),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    overflow: TextOverflow.ellipsis,
                                    getRemainingTime(waktuKebutuhanMobil),
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
            ],
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          return const Text('Loading...');
        }
      },
    );
  }
}
