import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_images.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/my_text.dart';
import 'package:movie_proj/core/spacing.dart';
import 'package:movie_proj/feature/search/widget/container_text.dart';
import 'package:movie_proj/feature/search/widget/row_director.dart';

class SearchFieldItem extends StatelessWidget {
  const SearchFieldItem({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: double.infinity,
      height: size.height / 2.5,
      color: const Color(0xff1A1A1A),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: size.height / 5,
              child: ClipRRect(
                child: Image.asset(
                  MyImages.poster,
                ),
              ),
            ),
            hSpace(20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        MyText.kungFuPanda,
                        style: MyStyles.title24White400.copyWith(
                          color: const Color(0xffC3C3C3),
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.yellow,
                            size: 20,
                          ),
                          hSpace(5),
                          Text(
                            MyText.rate,
                            style: MyStyles.title24White400.copyWith(
                              color: const Color(0xffC3C3C3),
                              fontSize: 15,
                            ),
                          ),
                          hSpace(20),
                          TextButton.icon(
                            onPressed: () {},
                            label: const Text(
                              MyText.rate,
                              style: TextStyle(color: Color(0xffC3C3C3)),
                            ),
                            icon: const Icon(
                              Icons.star_border,
                              size: 20,
                              color: Color(0xffC3C3C3),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                  vSpace(10),
                  Text(
                    '2024 .PG-13 .2h 46m',
                    style: MyStyles.title13Redw700.copyWith(
                      color: const Color(0xff797979),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  vSpace(10),
                  Row(
                    children: [
                      const TypeFilmContainerText(
                        text: MyText.action,
                      ),
                      hSpace(10),
                      const TypeFilmContainerText(
                        text: MyText.adventure,
                      ),
                      hSpace(10),
                      const TypeFilmContainerText(
                        text: MyText.drama,
                      ),
                    ],
                  ),
                  vSpace(5),
                  const RowDirector(
                      text1: MyText.director, text2: MyText.sianHeder),
                  vSpace(5),
                  const RowDirector(
                      text1: MyText.stars, text2: MyText.emiliaJones),
                  vSpace(5),
                  const RowDirector(text1: MyText.votes, text2: ''),
                  vSpace(10),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 0,
                          child: Container(
                            width: 5,
                            height: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                bottomLeft: Radius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 10,
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: const BoxDecoration(
                              color: Color(0xff363636),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                MyText.sianHeders,
                                style: TextStyle(
                                  color: Color(0xffC3C3C3),
                                  fontSize: 12,
                                ),
                                maxLines: 3,
                                textAlign: TextAlign.start,
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
          ],
        ),
      ),
    );
  }
}
