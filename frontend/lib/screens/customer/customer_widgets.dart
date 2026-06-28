import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../widgets/product_card.dart';
import '../../widgets/animated_navigation.dart';

import 'product_details_screen.dart';


class CustomerProductCard extends StatelessWidget {

  const CustomerProductCard({
    super.key,
    required this.product,
    required this.onAdd,
  });


  final CustomerProduct product;
  final VoidCallback onAdd;



  @override
  Widget build(BuildContext context) {


    return ProductCard(


      name:
      product.name,


      price:
      product.price,


      category:
      product.categoryName,


      imageUrl:
      product.imageUrl,


      available:
      product.isAvailable,


      compact:
      true,



      onTap: () {


        Navigator.of(context)
            .push(

          AppPageRoute(

            child:
            ProductDetailsScreen(

              productId:
              product.id,

            ),

          ),

        );


      },



      onAdd:
      product.isAvailable
          ? onAdd
          : null,


    );


  }


}








class ProductSection extends StatelessWidget {


  const ProductSection({

    super.key,

    required this.title,

    required this.products,

    required this.onAdd,

  });



  final String title;


  final List<CustomerProduct> products;


  final void Function(CustomerProduct product)
  onAdd;





  @override
  Widget build(BuildContext context) {


    if(products.isEmpty){

      return const SizedBox.shrink();

    }



    return Column(

      crossAxisAlignment:
      CrossAxisAlignment.start,


      children:[



        Padding(

          padding:
          const EdgeInsets.fromLTRB(
            16,
            20,
            16,
            12,
          ),


          child:

          Text(

            title,

            style:
            Theme.of(context)
                .textTheme
                .titleLarge,

          ),

        ),





        SizedBox(

          height:
          280,


          child:

          ListView.separated(


            padding:

            const EdgeInsets.symmetric(
              horizontal:16,
            ),



            scrollDirection:
            Axis.horizontal,



            itemCount:
            products.length,



            separatorBuilder:

            (_,__)

            =>

            const SizedBox(
              width:16,
            ),




            itemBuilder:

            (context,index){



              final product =
              products[index];



              return CustomerProductCard(


                product:
                product,


                onAdd:
                ()=>onAdd(product),


              );


            },


          ),

        ),



      ],


    );


  }


}