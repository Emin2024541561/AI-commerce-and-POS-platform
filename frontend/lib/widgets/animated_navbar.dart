import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'blurred_container.dart';

class NavBarItem {
  const NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badgeCount,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int? badgeCount;
}



class AnimatedNavBar extends StatelessWidget {

  const AnimatedNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });


  final List<NavBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;



  @override
  Widget build(BuildContext context) {

    final bottomInset =
        MediaQuery.of(context).padding.bottom;


    return Padding(

      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        0,
        AppSpacing.lg,
        bottomInset + AppSpacing.md,
      ),


      child: Container(

        decoration: BoxDecoration(

          borderRadius:
          AppRadius.pillRadius,

          boxShadow:
          AppShadows.elevated(
            Theme.of(context).brightness,
          ),

        ),


        child: BlurredContainer(

          blur: AppBlur.lg,

          borderRadius:
          AppRadius.pillRadius,

          gradientBorder:true,


          // FIX OVDJE
          padding:
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 0,
          ),


          height:64,


          child: LayoutBuilder(


            builder:(context,constraints){


              final itemWidth =
                  constraints.maxWidth /
                  items.length;



              return SizedBox.expand(

                child: Stack(

                  alignment:
                  Alignment.center,


                  children:[



                    AnimatedPositioned(

                      duration:
                      const Duration(
                        milliseconds:320,
                      ),


                      curve:
                      Curves.easeOutCubic,


                      left:
                      itemWidth * currentIndex,


                      top:8,

                      bottom:8,


                      width:itemWidth,



                      child: Container(

                        width:
                        itemWidth -
                        AppSpacing.sm,


                        decoration:
                        BoxDecoration(

                          gradient:
                          AppColors.accentGradient,


                          borderRadius:
                          AppRadius.pillRadius,


                          boxShadow:
                          AppShadows.glow(
                            AppColors.accentBlue,
                            opacity:0.4,
                          ),

                        ),

                      ),

                    ),





                    Row(

                      crossAxisAlignment:
                      CrossAxisAlignment.center,


                      children:

                      List.generate(

                        items.length,

                        (index){


                          final item =
                          items[index];


                          final selected =
                          index == currentIndex;



                          return Expanded(

                            child:
                            Center(

                              child:
                              _NavBarTapTarget(

                                item:item,

                                selected:selected,

                                onTap:
                                ()=>onTap(index),

                              ),

                            ),

                          );


                        },

                      ),

                    ),



                  ],


                ),

              );


            },

          ),

        ),

      ),

    );

  }

}






class _NavBarTapTarget extends StatelessWidget {


  const _NavBarTapTarget({
    required this.item,
    required this.selected,
    required this.onTap,
  });



  final NavBarItem item;
  final bool selected;
  final VoidCallback onTap;




  @override
  Widget build(BuildContext context) {


    final isDark =
        Theme.of(context)
            .brightness ==
            Brightness.dark;



    final inactiveColor =
    isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;




    return GestureDetector(

      behavior:
      HitTestBehavior.opaque,


      onTap:onTap,



      child:SizedBox(

        height:64,


        child:Stack(


          alignment:
          Alignment.center,



          children:[



            AnimatedSwitcher(


              duration:
              const Duration(
                milliseconds:200,
              ),



              transitionBuilder:

              (child,anim)

              => ScaleTransition(

                scale:anim,

                child:child,

              ),



              child:Icon(

                selected
                    ? item.activeIcon
                    : item.icon,


                key:
                ValueKey(selected),


                color:
                selected
                    ? Colors.white
                    : inactiveColor,


                size:24,

              ),

            ),




            if(
            item.badgeCount != null &&
                item.badgeCount! > 0
            )

              Positioned(

                top:8,

                right:18,


                child:Container(

                  padding:
                  const EdgeInsets.symmetric(
                    horizontal:5,
                    vertical:1,
                  ),


                  decoration:
                  const BoxDecoration(

                    color:
                    AppColors.danger,


                    borderRadius:
                    BorderRadius.all(
                      Radius.circular(
                        AppRadius.pill,
                      ),
                    ),

                  ),



                  child:Text(

                    item.badgeCount! > 9
                        ? "9+"
                        : "${item.badgeCount}",


                    style:
                    AppTypography
                        .caption2(
                      Colors.white,
                    ),

                  ),

                ),

              ),

          ],

        ),

      ),

    );

  }

}