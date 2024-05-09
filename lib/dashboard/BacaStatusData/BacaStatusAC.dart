import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../Aset/ControllerLogic.dart';
import '../../komponen/style.dart';

class BacaStatusAC extends StatelessWidget {
  const BacaStatusAC({super.key,
    required this.dokumenAC});

  final String dokumenAC;

  @override
  Widget build(BuildContext context) {
    CollectionReference AC = FirebaseFirestore.instance.collection('Aset');
    return FutureBuilder<DocumentSnapshot>(
      future: AC.doc(dokumenAC).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error : ${snapshot.error}');
          }
          Map<String, dynamic> dataAC = snapshot.data!.data() as Map<
              String,
              dynamic>;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${dataAC['Merek AC']}',
                    style: TextStyles.title.copyWith(
                        fontSize: 20, color: Warna.darkgrey),
                  ),
                  Text(
                    '${dataAC['Jenis Aset']}',
                    style: TextStyles.body.copyWith(
                        fontSize: 15, color: Warna.darkgrey),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: dataAC['Kebutuhan AC'].length,
                    itemBuilder: (context, index) {
                      final kebutuhanAC = dataAC['Kebutuhan AC'][index]['Nama Kebutuhan AC'];
                      final hariKebutuhanAC = dataAC['Kebutuhan AC'][index]['Hari Kebutuhan AC'];
                      final waktuKebutuhanAC = dataAC['Kebutuhan AC'][index]['Waktu Kebutuhan AC'];

                      final part = kebutuhanAC.split(': ');
                      final hasSplit = part.length > 1 ? part[1] : kebutuhanAC;

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
                                getValueIndicator(hariKebutuhanAC,
                                    epochTimeToData(waktuKebutuhanAC)),
                                getProgressColor(waktuKebutuhanAC),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    overflow: TextOverflow.ellipsis,
                                    getRemainingTime(waktuKebutuhanAC),
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
