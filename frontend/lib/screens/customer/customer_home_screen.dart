import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/models.dart';

import '../../widgets/glass_card.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/premium_button.dart';
import '../../widgets/loading_animation.dart';
import '../../widgets/ai_chat_widget.dart';
import 'customer_widgets.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() =>
      _CustomerHomeScreenState();
}

class _CustomerHomeScreenState
    extends State<CustomerHomeScreen> {


  final search =
      TextEditingController();


  final aiText =
      TextEditingController();


  AiAssistantResponse? aiResponse;

final List<AiChatMessage> messages = [];

bool aiLoading = false;

List<AiRecommendation> recommendations = [];



  Future<void> askAI() async {


    if (aiText.text.trim().isEmpty) {
      return;
    }


    setState(() {
      aiLoading = true;
    });



    final bloc =
        AppScope.of(context);



    try {


      final result =
    await bloc.api.aiAssistant(

  bloc.value.session!.user.id,

  aiText.text.trim(),

);



      setState(() {

aiResponse = result;

messages.add(
AiChatMessage(
role: AiChatRole.ai,
text: result.message,
),
);

aiLoading = false;

});



    } catch (e) {

if(!mounted) return;
      setState(() {

        aiLoading = false;

      });



      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content:
          Text(
            e.toString(),
          ),

        ),

      );


    }


  }

Future<void> loadRecommendations() async {


 final bloc =
 AppScope.of(context);


 try{


 final result =
 await bloc.api.aiRecommendations(

   bloc.value.session!.user.id,

 );


 if(!mounted) return;


 setState((){

   recommendations = result;

 });


 }
 catch(e){

   debugPrint(
     e.toString()
   );

 }


}



@override
void initState(){

 super.initState();


 WidgetsBinding.instance
 .addPostFrameCallback(
   (_)=>loadRecommendations()
 );

}

  @override
  Widget build(BuildContext context) {


    final bloc =
        AppScope.of(context);



    return ValueListenableBuilder(

      valueListenable: bloc,


      builder:
          (context, state, _) =>

              ListView(


        children: [



          // ======================
          // SEARCH
          // ======================


          Padding(

            padding:
            const EdgeInsets.all(16),


            child:


              CustomTextField(
  controller: search,

  prefixIcon: Icons.search,

  hintText: "Search burgers, pizza, drinks",

  onChanged: (value) {

    bloc.loadCustomerProducts(
      search:value,
    );

  },
)

          ),








          // ======================
          // SMART AI CHAT
          // ======================


Padding(

padding:
const EdgeInsets.all(16),

child:
AiChatWidget(

messages:
messages,


suggestions:
const [

"Imam 15 KM 🍔",

"Preporuči ručak 🤖",

"Najbolje akcije 🔥",

],


onSend:
(text){

setState((){

messages.add(
AiChatMessage(
role: AiChatRole.user,
text:text,
),
);

});


aiText.text=text;


askAI();

},

),

),


const SizedBox(
height:16,
),
          GlassCard(

            margin:
            const EdgeInsets.all(16),




            child:

            Padding(


              padding:
              const EdgeInsets.all(16),



              child:

              Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,



                children:[



                  Text(

                    "🤖 SmartAI Shopping Assistant",


                    style:

                    Theme.of(context)
                        .textTheme
                        .titleLarge,

                  ),




                  const SizedBox(
                    height: 8,
                  ),




                  const Text(

                    "Tell AI what you want, mood or budget.",

                  ),





                  const SizedBox(
                    height: 12,
                  ),




                  TextField(


                    controller:
                    aiText,



                    decoration:

                    const InputDecoration(


                      prefixIcon:

                      Icon(
                          Icons.auto_awesome
                      ),



                      hintText:

                      "Example: Imam 15 KM i gladan sam",


                    ),

                  ),





                  const SizedBox(
                    height:12,
                  ),





PremiumButton(

icon:
Icons.smart_toy,

label:
"Ask Smart AI",

onPressed:
aiLoading
? null
: askAI,

),





if(aiLoading)

const PulseLoader(),






                  if(aiResponse != null)

                    Padding(

                      padding:

                      const EdgeInsets.only(
                          top:16
                      ),



                      child:


                      Column(


                        crossAxisAlignment:

                        CrossAxisAlignment.start,



                        children:[



                          Text(

                            aiResponse!.message,


                            style:

                            Theme.of(context)
                                .textTheme
                                .bodyLarge,

                          ),




                          const SizedBox(
                            height:8,
                          ),






                        ...aiResponse!.products.map(

(p)=>GlassCard(

child:ListTile(

leading:
const Icon(
Icons.shopping_bag,
),

title:
Text(
p.name,
),

subtitle:
Text(
"${p.price} BAM",
),

trailing:
IconButton(

icon:
const Icon(
Icons.add_circle,
),

onPressed:(){

bloc.addCustomerProductToCart(
p,
);

},

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

),







        if(state.loading)

const ShimmerCardGrid(),




// ======================
// AI RECOMMENDATIONS
// ======================


if(recommendations.isNotEmpty)

Padding(

padding:
const EdgeInsets.all(16),


child:

Column(

crossAxisAlignment:
CrossAxisAlignment.start,


children:[


Text(

"🧠 Recommended For You",

style:

Theme.of(context)
.textTheme
.titleLarge,

),



const SizedBox(
height:10
),




...recommendations.map(

(x)=>GlassCard(


child:

ListTile(

leading:

const Icon(
Icons.psychology
),


title:

Text(
x.productName
),



subtitle:

Text(
x.reason
),



trailing:

Text(
"${x.price} BAM"
),


),

)

)



],

),

),



          // ======================
          // PRODUCTS
          // ======================



          ProductSection(

            title:

            'Featured products',


            products:

            state.featuredProducts,


            onAdd:

            bloc.addCustomerProductToCart,

          ),





          ProductSection(

            title:

            'Popular now',

            products:

            state.popularProducts,


            onAdd:

            bloc.addCustomerProductToCart,

          ),






          ProductSection(

            title:

            'Today deals',


            products:

            state.dealProducts,


            onAdd:

            bloc.addCustomerProductToCart,

          ),




        ],


      ),


    );


  }

    
}