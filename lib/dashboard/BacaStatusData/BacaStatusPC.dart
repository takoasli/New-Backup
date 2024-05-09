import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../Aset/ControllerLogic.dart';
import '../../komponen/style.dart';

class BacaStatusPC extends StatelessWidget {
  const BacaStatusPC({super.key, required this.dokumenPC});

  final String dokumenPC;

  @override
  Widget build(BuildContext context) {
    CollectionReference PC = FirebaseFirestore.instance.collection('PC');
    return FutureBuilder<DocumentSnapshot>(
      future: PC.doc(dokumenPC).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error : ${snapshot.error}');
          }
          Map<String, dynamic> dataPC = snapshot.data!.data() as Map<
              String,
              dynamic>;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${dataPC['Merek PC']}',
                    style: TextStyles.title.copyWith(
                        fontSize: 20, color: Warna.darkgrey),
                  ),
                  Text(
                    '${dataPC['Jenis Aset']}',
                    style: TextStyles.body.copyWith(
                        fontSize: 15, color: Warna.darkgrey),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: dataPC['Kebutuhan PC'].length,
                    itemBuilder: (context, index) {
                      final kebutuhanPC = dataPC['Kebutuhan PC'][index]['Kebutuhan PC'];
                      final hariKebutuhanPC = dataPC['Kebutuhan PC'][index]['Hari Kebutuhan PC'];
                      final waktuKebutuhanPC = dataPC['Kebutuhan PC'][index]['Waktu Kebutuhan PC'];

                      final part = kebutuhanPC.split(': ');
                      final hasSplit = part.length > 1 ? part[1] : kebutuhanPC;

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
                                getValueIndicator(hariKebutuhanPC,
                                    epochTimeToData(waktuKebutuhanPC)),
                                getProgressColor(waktuKebutuhanPC),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    overflow: TextOverflow.ellipsis,
                                    getRemainingTime(waktuKebutuhanPC),
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
