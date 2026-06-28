import 'package:flutter/material.dart';

import '../main.dart';



class OrdersScreen extends StatefulWidget {

  const OrdersScreen({super.key});


  @override
  State<OrdersScreen> createState()
  => _OrdersScreenState();

}



class _OrdersScreenState
extends State<OrdersScreen> {


  List orders = [];


  bool loading = true;



  @override
  void initState() {

    super.initState();

    debugPrint(
      "USAO SAM U ORDERS SCREEN"
    );

    WidgetsBinding.instance
        .addPostFrameCallback(
          (_) => load()
    );

  }




  Future<void> load() async {


    try {


      setState(() {
        loading = true;
      });



      final result =
      await AppScope.of(context)
          .api
          .pendingOrders();



      if (!mounted) return;



      setState(() {

        orders = result;

        loading = false;

      });


    } catch (e) {


      if (!mounted) return;



      setState(() {

        loading = false;

      });



      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content:
          Text(
            "ORDER ERROR: $e"
          ),

        ),

      );



      debugPrint(
        "ORDER ERROR: $e"
      );


    }


  }







  @override
  Widget build(BuildContext context) {



    if (loading) {


      return const Center(

        child:
        CircularProgressIndicator(),

      );


    }




    if (orders.isEmpty) {


      return const Center(

        child: Text(

          "Nema novih narudžbi 🔔",

          style: TextStyle(
            fontSize: 22
          ),

        ),

      );


    }






    return ListView.builder(


      padding:
      const EdgeInsets.all(16),



      itemCount:
      orders.length,



      itemBuilder:
          (context,index) {



        final order =
        orders[index];





        return Card(


          elevation: 0,



          child:
          Padding(


            padding:
            const EdgeInsets.all(16),



            child:
            Column(


              crossAxisAlignment:
              CrossAxisAlignment.start,



              children: [




                Text(

                  "Nova narudžba 🔔",

                  style:
                  Theme.of(context)
                      .textTheme
                      .titleLarge,

                ),



                const SizedBox(
                  height: 8,
                ),





                Text(

                  "Kupac: ${order.customerName}",

                ),




                Text(

                  "Telefon: ${order.phone}",

                ),




                Text(

                  "Adresa: ${order.address}",

                ),




                const Divider(),




                ...order.items.map(

                      (x) => ListTile(

                    leading:
                    const Icon(
                        Icons.fastfood
                    ),


                    title:
                    Text(
                      x.productName
                    ),


                    trailing:
                    Text(
                      "x${x.quantity}"
                    ),

                  ),

                ),




                const Divider(),





                Text(

                  "Ukupno: ${order.totalAmount} BAM",

                  style:
                  Theme.of(context)
                      .textTheme
                      .titleMedium,

                ),






                const SizedBox(
                  height: 15,
                ),







                Row(

                  children: [





                    FilledButton.icon(


                      icon:
                      const Icon(
                        Icons.check
                      ),



                      label:
                      const Text(
                          "POTVRDI"
                      ),



                      onPressed:
                          () async {


                        await AppScope.of(context)
                            .api
                            .approveOrder(
                            order.id
                        );



                        load();



                      },

                    ),








                    const SizedBox(
                      width: 10,
                    ),








                    OutlinedButton.icon(


                      icon:
                      const Icon(
                          Icons.close
                      ),



                      label:
                      const Text(
                          "ODBIJ"
                      ),




                      onPressed:
                          () async {



                        await AppScope.of(context)
                            .api
                            .rejectOrder(
                            order.id
                        );



                        load();



                      },

                    ),


                  ],

                )


              ],


            ),


          ),


        );



      },


    );


  }


}