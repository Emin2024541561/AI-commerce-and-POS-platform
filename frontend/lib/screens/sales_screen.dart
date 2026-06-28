import 'package:flutter/material.dart';

import '../main.dart';
import '../models/models.dart';


class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});


  @override
  State<SalesScreen> createState()
      => _SalesScreenState();
}



class _SalesScreenState
    extends State<SalesScreen> {


 Future<List<SaleReceipt>>? sales;


@override
void didChangeDependencies() {
  super.didChangeDependencies();

  sales ??=
      AppScope.of(context)
          .api
          .sales();
}



  @override
  Widget build(BuildContext context) {


    return FutureBuilder<List<SaleReceipt>>(

      future: sales,


      builder: (context, snapshot) {


        if(snapshot.connectionState
            == ConnectionState.waiting){

          return const Center(
            child:
              CircularProgressIndicator(),
          );
        }



        if(snapshot.hasError){

          return Center(
            child:
              Text(
                snapshot.error.toString(),
              ),
          );
        }



        final data =
            snapshot.data ?? [];



        if(data.isEmpty){

          return const Center(

            child: Text(
              'No sales yet',
            ),
          );
        }



        return ListView(

          padding:
              const EdgeInsets.all(16),


          children: [


            Text(

              'Sales history',

              style:
                Theme.of(context)
                    .textTheme
                    .titleLarge,
            ),



            const SizedBox(
              height: 12,
            ),




            ...data.map(
              (sale) => Card(

                elevation: 0,


                child:
                  ExpansionTile(


                    leading:
                      const Icon(
                        Icons.receipt_long,
                      ),



                    title:
                      Text(
                        sale.receiptNumber,
                      ),



                    subtitle:
                      Text(
                        '${sale.cashierName}\n'
                        '${sale.paymentMethod}',
                      ),



                    trailing:
                      Text(
                        '${sale.totalAmount.toStringAsFixed(2)} BAM',
                      ),



                    children: [


                      ...sale.items.map(

                        (item) =>
                          ListTile(

                            title:
                              Text(
                                item.productName,
                              ),


                            subtitle:
                              Text(
                                '${item.quantity} x '
                                '${item.price.toStringAsFixed(2)} BAM',
                              ),


                            trailing:
                              Text(
                                '${item.lineTotal.toStringAsFixed(2)} BAM',
                              ),
                          ),
                      ),



                      const Divider(),


                      ListTile(

                        title:
                          const Text(
                            'Profit',
                          ),


                        trailing:
                          Text(
                            '${sale.profitAmount.toStringAsFixed(2)} BAM',
                          ),
                      ),
                    ],
                  ),
              ),
            ),
          ],
        );
      },
    );
  }
}