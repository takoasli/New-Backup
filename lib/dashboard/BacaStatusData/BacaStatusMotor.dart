import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../Aset/ControllerLogic.dart';
import '../../komponen/style.dart';

class BacaStatusMotor extends StatelessWidget {
  const BacaStatusMotor({super.key, required this.dokumenMotor});

  final String dokumenMotor;

  @override
  Widget build(BuildContext context) {
    CollectionReference Motor = FirebaseFirestore.instance.collection('Motor');
    return FutureBuilder<DocumentSnapshot>(
      future: Motor.doc(dokumenMotor).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error : ${snapshot.error}');
          }
          Map<String, dynamic> dataMotor = snapshot.data!.data() as Map<
              String,
              dynamic>;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${dataMotor['Merek Motor']}',
                    style: TextStyles.title.copyWith(
                        fontSize: 20, color: Warna.darkgrey),
                  ),
                  Text(
                    '${dataMotor['Jenis Aset']}',
                    style: TextStyles.body.copyWith(
                        fontSize: 15, color: Warna.darkgrey),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: dataMotor['Kebutuhan Motor'].length,
                    itemBuilder: (context, index) {
                      final kebutuhanMotor = dataMotor['Kebutuhan Motor'][index]['Nama Kebutuhan Motor'];
                      final hariKebutuhanMotor = dataMotor['Kebutuhan Motor'][index]['Hari Kebutuhan Motor'];
                      final waktuKebutuhanMotor = dataMotor['Kebutuhan Motor'][index]['Waktu Kebutuhan Motor'];

                      final part = kebutuhanMotor.split(': ');
                      final hasSplit = part.length > 1 ? part[1] : kebutuhanMotor;

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
                                getValueIndicator(hariKebutuhanMotor,
                                    epochTimeToData(waktuKebutuhanMotor)),
                                getProgressColor(waktuKebutuhanMotor),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    overflow: TextOverflow.ellipsis,
                                    getRemainingTime(waktuKebutuhanMotor),
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
