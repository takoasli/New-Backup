import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../Aset/ControllerLogic.dart';
import '../../komponen/style.dart';

class BacaStatusLaptop extends StatelessWidget {
  const BacaStatusLaptop({super.key, required this.dokumenLaptop});

  final String dokumenLaptop;

  @override
  Widget build(BuildContext context) {
    CollectionReference Laptop = FirebaseFirestore.instance.collection('Laptop');
    return FutureBuilder<DocumentSnapshot>(
      future: Laptop.doc(dokumenLaptop).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error : ${snapshot.error}');
          }
          Map<String, dynamic> dataLaptop = snapshot.data!.data() as Map<
              String,
              dynamic>;

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${dataLaptop['Merek Laptop']}',
                    style: TextStyles.title.copyWith(
                        fontSize: 20, color: Warna.darkgrey),
                  ),
                  Text(
                    '${dataLaptop['Jenis Aset']}',
                    style: TextStyles.body.copyWith(
                        fontSize: 15, color: Warna.darkgrey),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: dataLaptop['Kebutuhan Laptop'].length,
                    itemBuilder: (context, index) {
                      final kebutuhanLaptop = dataLaptop['Kebutuhan Laptop'][index]['Nama Kebutuhan Laptop'];
                      final hariKebutuhanLaptop = dataLaptop['Kebutuhan Laptop'][index]['Hari Kebutuhan Laptop'];
                      final waktuKebutuhanLaptop = dataLaptop['Kebutuhan Laptop'][index]['Waktu Kebutuhan Laptop'];

                      final part = kebutuhanLaptop.split(': ');
                      final hasSplit = part.length > 1 ? part[1] : kebutuhanLaptop;

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
                                getValueIndicator(hariKebutuhanLaptop,
                                    epochTimeToData(waktuKebutuhanLaptop)),
                                getProgressColor(waktuKebutuhanLaptop),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    overflow: TextOverflow.ellipsis,
                                    getRemainingTime(waktuKebutuhanLaptop),
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
