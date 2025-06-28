import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/my_text_field.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/search/widget/search_field_item.dart';

class SearchField extends StatelessWidget {
  const SearchField({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Expanded(
      child: SizedBox(
        height: size.height,
        width: double.infinity,
        //  color: MyColors.btnColor,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xff1A1A1A),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          MyText.sortBy,
                          style: TextStyle(
                            color: Color(0xff797979),
                            fontSize: 13,
                          ),
                        ),
                        hSpace(5),
                        const Text(
                          MyText.listOrder,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                        hSpace(5),
                        const Icon(
                          Icons.switch_right,
                          color: Color(0xff797979),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                hSpace(10),
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    borderDelete: true,
                    obscureText: false,
                    fillColor: const Color(0xff1A1A1A),
                    isDense: true,
                    onTap: () {},
                    validator: (val) {
                      return '';
                    },
                    text: MyText.searchMoodBox,
                    heintStyle: const TextStyle(
                      color: Color(0xff797979),
                      fontSize: 13,
                    ),
                    textStyle: MyStyles.title24White400.copyWith(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.start,
                    controller: TextEditingController(),
                    suffix: IconButton(
                      icon: const Icon(
                        Icons.search,
                        color: Color(0xff797979),
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
            vSpace(20),
            Expanded(
              child: ListView.builder(
                //  shrinkWrap: true,
                itemBuilder: (context, index) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: SearchFieldItem(),
                ),
                itemCount: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
