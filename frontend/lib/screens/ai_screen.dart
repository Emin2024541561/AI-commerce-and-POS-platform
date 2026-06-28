import 'package:flutter/material.dart';

import '../main.dart';

import '../widgets/glass_card.dart';
import '../widgets/premium_button.dart';
import '../widgets/ai_chat_widget.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}



class _AiScreenState extends State<AiScreen> {


  dynamic bestSeller;
  List<dynamic> profits = [];
  List<dynamic> deals = [];
final List<AiChatMessage> messages = [];

  bool loading = false;



  Future<void> loadAI() async {

    setState(() {
      loading = true;
    });


    final api =
        AppScope.of(context).api;


    final b =
        await api.bestSellers();


    final p =
        await api.profitAnalysis();


    final d =
        await api.smartDeals();



    setState(() {

      bestSeller = b;

      profits = p;

      deals = d;

      loading = false;

    });

  }





  @override
  void initState() {

    super.initState();


    WidgetsBinding.instance.addPostFrameCallback(
      (_) => loadAI(),
    );

  }





  @override
  Widget build(BuildContext context) {


    final bloc =
        AppScope.of(context);



    return ListView(

      padding:
      const EdgeInsets.all(16),


      children: [


        Text(
          '🤖 Smart AI Center',
          style:
          Theme.of(context)
              .textTheme
              .headlineSmall,
        ),



        const SizedBox(height: 20),




        // =====================
        // FORECAST RESTOCK
        // =====================


       Wrap(
  spacing: 12,
  children: [

    PremiumButton(
      icon: Icons.trending_up,
      label: "Forecast",
      onPressed: () {
        bloc.api.forecast();
      },
    ),

    PremiumButton(
      icon: Icons.inventory,
      label: "Restock AI",
      onPressed: () {
        bloc.api.restock();
      },
    ),

  ],
),



        const Divider(height:30),





        if(loading)

          const LinearProgressIndicator(),
          const SizedBox(height:20),

AiChatWidget(
  messages: messages,

  suggestions: const [
    "Analiziraj prodaju 📊",
    "Predloži akcije 🔥",
    "Šta treba naručiti?"
  ],

  onSend: (text){

    setState((){

      messages.add(
        AiChatMessage(
          role: AiChatRole.user,
          text: text,
        ),
      );


      messages.add(
        const AiChatMessage(
          role: AiChatRole.ai,
          text:
          "AI analiza je spremna. Provjeravam podatke prodaje.",
        ),
      );

    });

  },

),

const SizedBox(height:20),





        // =====================
        // BEST SELLERS
        // =====================


        Text(
          "🔥 Best Sellers AI",
          style:
          Theme.of(context)
          .textTheme
          .titleLarge,
        ),



        if(bestSeller != null)

          ...bestSeller.products.map(

            (x)=>GlassCard(

              child:ListTile(

                leading:
                const Icon(Icons.local_fire_department),


                title:
                Text(x.productName),


                subtitle:
                Text(
                  "${x.quantitySold} sold"
                ),


                trailing:
                Text(
                  "${x.revenue} BAM"
                ),

              ),

            )

          ),






        const SizedBox(height:20),



        // =====================
        // PROFIT
        // =====================


        Text(
          "💰 Profit Analyzer",
          style:
          Theme.of(context)
          .textTheme
          .titleLarge,
        ),




        ...profits.map(

          (x)=>GlassCard(

            child:ListTile(

              leading:
              const Icon(
                Icons.attach_money
              ),


              title:
              Text(x.productName),


              subtitle:
              Text(
                x.aiMessage
              ),


              trailing:
              Text(
                "${x.marginPercent}%"
              ),

            ),

          )

        ),





        const SizedBox(height:20),




        // =====================
        // SMART DEALS
        // =====================


        Text(
          "🏷 Smart Deals",
          style:
          Theme.of(context)
          .textTheme
          .titleLarge,
        ),




        ...deals.map(

          (x)=>GlassCard(

            child:ListTile(

              leading:
              const Icon(
                Icons.discount
              ),


              title:
              Text(
                "${x.mainProductName} + ${x.secondProductName}"
              ),


              subtitle:
              Text(
                x.aiReason
              ),


              trailing:
              Text(
                "${x.dealPrice} BAM"
              ),

            ),

          )

        ),





      ],

    );

  }

}