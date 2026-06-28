import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/models.dart';

import '../../widgets/glass_card.dart';
import '../../widgets/premium_button.dart';

import 'customer_widgets.dart';


class ProductDetailsScreen extends StatelessWidget {

  const ProductDetailsScreen({
    super.key,
    required this.productId,
  });


  final int productId;


  @override
  Widget build(BuildContext context) {


    final bloc =
    AppScope.of(context);



    return Scaffold(

      extendBody:true,


      appBar:AppBar(

        title:
        const Text(
          "Detalji proizvoda",
        ),

      ),



      body:

      FutureBuilder<ProductDetails>(


        future:
        bloc.customerProductDetails(
          productId,
        ),



        builder:
        (context,snapshot){


          if(!snapshot.hasData){

            return const Center(

              child:
              CircularProgressIndicator(),

            );

          }



          final details =
          snapshot.data!;


          final product =
          details.product;




          return ListView(


            padding:
            const EdgeInsets.all(16),



            children:[




              GlassCard(


                child:

                Column(


                  crossAxisAlignment:
                  CrossAxisAlignment.start,



                  children:[



                    AspectRatio(

                      aspectRatio:
                      16/9,


                      child:

                      ClipRRect(

                        borderRadius:
                        BorderRadius.circular(
                          20,
                        ),



                        child:

                        product.imageUrl.isNotEmpty


                        ?


                        Image.network(

                          product.imageUrl,

                          fit:
                          BoxFit.cover,

                        )



                        :



                        Container(

                          alignment:
                          Alignment.center,


                          decoration:
                          BoxDecoration(

                            gradient:
                            LinearGradient(

                              colors:[

                                Theme.of(context)
                                    .colorScheme
                                    .primary,


                                Theme.of(context)
                                    .colorScheme
                                    .secondary,

                              ],

                            ),

                          ),



                          child:

                          const Icon(

                            Icons.fastfood,

                            size:80,

                            color:
                            Colors.white,

                          ),

                        ),


                      ),

                    ),





                    const SizedBox(
                      height:20,
                    ),




                    Text(

                      product.name,


                      style:
                      Theme.of(context)
                          .textTheme
                          .headlineSmall,

                    ),




                    const SizedBox(
                      height:6,
                    ),




                    Text(

                      product.categoryName,


                      style:
                      Theme.of(context)
                          .textTheme
                          .bodyMedium,

                    ),





                    const SizedBox(
                      height:20,
                    ),





                    Text(

                      "${product.price.toStringAsFixed(2)} BAM",


                      style:
                      Theme.of(context)
                          .textTheme
                          .headlineMedium,

                    ),





                    const SizedBox(
                      height:12,
                    ),




                    Text(

                      product.isAvailable

                          ?

                      "Dostupno: ${product.stockQuantity} komada"

                          :

                      "Nije dostupno",

                    ),




                    const SizedBox(
                      height:24,
                    ),





                    PremiumButton(

                      expand:true,


                      icon:
                      Icons.add_shopping_cart,


                      label:
                      "Dodaj u korpu",



                      onPressed:

                      product.isAvailable

                      ?

                      (){

                        bloc.addCustomerProductToCart(
                          product,
                        );

                      }


                      :

                      null,

                    ),




                  ],


                ),


              ),






              const SizedBox(
                height:30,
              ),




              ProductSection(

                title:
                "Slični proizvodi",


                products:
                details.relatedProducts,


                onAdd:
                bloc.addCustomerProductToCart,

              ),



            ],

          );


        },

      ),

    );

  }

}