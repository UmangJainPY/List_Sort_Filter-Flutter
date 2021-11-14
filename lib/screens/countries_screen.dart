import 'dart:async';
import 'dart:convert';

import 'package:filter_locations/data/countries_api.dart';
import 'package:filter_locations/model/countries.dart';
import 'package:filter_locations/utils/app_constants.dart';
import 'package:filter_locations/utils/app_image_constants.dart';
import 'package:flutter/material.dart';
import 'package:searchfield/searchfield.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class CountriesList extends StatefulWidget {
  const CountriesList({Key? key}) : super(key: key);

  @override
  _CountriesListState createState() => _CountriesListState();
}

class _CountriesListState extends State<CountriesList> {
  List<Countries> countriesList = <Countries>[];
  late Map list = {};
  late List countryList = [];
  late List countryListSort = [];
  late List countryListMainList = [];
  double gridWidth = kDefaultGridWidth;
  bool isLoading = false;

  final _searchController = TextEditingController();
  void getCountriesFromApi() async {
    setState(() {
      isLoading = true;
    });
    EasyLoading.show(status: 'loading...');
    CountriesApi.getCountries().then((response) {
      setState(() {
        list = json.decode(response.body);
        list['data'].forEach((dynamic key, dynamic value) {
          countryList.add(value['country']);
        });
        countryListMainList = countryList;
      });
      isLoading = false;
      EasyLoading.showSuccess('Data Successfully\nLoaded.');
    });
  }

  Timer? _timer;
  late double _progress;

  @override
  void initState() {
    super.initState();
    //fething data from api "https://api.first.org/data/v1/countries"
    getCountriesFromApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Countries"),
          actions: [
            buildFilterButton(context),
            const SizedBox(
              width: 15,
            )
          ],
        ),
        body: isLoading
            ? const Center(
                child: Text("Loading"),
              )
            : countryList.isEmpty
                ? const Center(
                    child: Text("No countries found"),
                  )
                : Container(
                    color: Colors.grey,
                    child: buildCountriesGridView(),
                  ));
  }

  GridView buildCountriesGridView() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: gridWidth,
          childAspectRatio: gridWidth > 400 ? 5 : 2),
      itemCount: countryList.length,
      itemBuilder: (BuildContext context, int index) {
        return GridTile(
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 2),
            color: Colors.white,
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                alignment: Alignment.center,
                // color: Colors.red,
                child: Text(
                  countryList[index].toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: gridWidth > 400
                        ? 20
                        : gridWidth > 250
                            ? 16
                            : 12,
                  ),
                )),
          ),
        );
      },
    );
  }

  GestureDetector buildFilterButton(BuildContext context) {
    return GestureDetector(
      child: const Image(
        image: AssetImage(pngFilterIcon),
        width: 25,
        height: 25,
      ),
      // const Icon(
      //   Icons.clear_all,
      //   size: 30,
      // ),
      onTap: () {
        showGeneralDialog(
          context: context,
          pageBuilder: (context, _, __) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.transparent,
                  child: Card(
                    color: Colors.transparent,
                    child: buildFilterSection(context),
                  ),
                ),
              ],
            );
          },
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ).drive(Tween<Offset>(
                begin: const Offset(0, -1.0),
                end: Offset.zero,
              )),
              child: child,
            );
          },
        );
      },
    );
  }

  Column buildFilterSection(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          color: Colors.white,
          child: Column(
            children: [
              const SizedBox(
                height: 30,
              ),
              Row(
                children: const [
                  SizedBox(
                    width: 10,
                  ),
                  Text("View by"),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Image(
                      image: AssetImage(pngListIcon),
                      width: 23,
                      height: 23,
                    ),
                    onPressed: () {
                      setState(() {
                        gridWidth = kDefaultGridWidth;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  IconButton(
                    icon: const Image(
                      image: AssetImage(pngGrid2x2Icon),
                      width: 40,
                      height: 40,
                    ),
                    onPressed: () {
                      setState(() {
                        gridWidth = 300;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  IconButton(
                    icon: const Image(
                      image: AssetImage(pngGrid3x3Icon),
                      width: 24,
                      height: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        gridWidth = 200;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: const [
                  SizedBox(
                    width: 10,
                  ),
                  Text("Show only by alphabets"),
                ],
              ),
              SizedBox(
                height: 200,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 80, childAspectRatio: 2),
                  itemCount: alphabets.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GridTile(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            countryListSort.clear();
                            countryListMainList.forEach((element) {
                              if (element
                                      .toString()
                                      .toLowerCase()
                                      .substring(0, 1) ==
                                  alphabets[index].toString().toLowerCase()) {
                                countryListSort.add(element);
                              }
                            });
                            countryList = countryListSort;
                          });
                          Navigator.pop(context);
                        },
                        child: Container(
                          color: Colors.white,
                          width: 50,
                          height: 50,
                          child: Center(
                            // color: Colors.blue,
                            child: Text(
                              alphabets[index].toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              Row(
                children: const [
                  SizedBox(
                    width: 10,
                  ),
                  Text("Sort by"),
                ],
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      child: Row(
                        children: const [
                          Text("Ascending"),
                          Image(
                            image: AssetImage(pngAscendingIcon),
                            width: 24,
                            height: 24,
                          ),
                        ],
                      ),
                      onPressed: () {
                        setState(() {
                          countryList.sort((a, b) {
                            return a
                                .toString()
                                .toLowerCase()
                                .compareTo(b.toString().toLowerCase());
                          });
                        });
                        Navigator.pop(context);
                      },
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      child: Row(
                        children: const [
                          Text("Descending"),
                          Image(
                            image: AssetImage(pngDescendingIcon),
                            width: 24,
                            height: 24,
                          ),
                        ],
                      ),
                      onPressed: () {
                        setState(() {
                          countryList.sort((a, b) {
                            return b
                                .toString()
                                .toLowerCase()
                                .compareTo(a.toString().toLowerCase());
                          });
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              const Divider(),
              Row(
                children: const [
                  SizedBox(
                    width: 10,
                  ),
                  Text("Search"),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 20),
                    width: 200,
                    height: 80,
                    child: buildSearchField(context),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.only(bottom: 20),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(100),
                  bottomLeft: Radius.circular(100))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                child: const Text('Reset'),
                onPressed: () {
                  setState(() {
                    countryList = countryListMainList;
                    countryList.sort((a, b) {
                      return a
                          .toString()
                          .toLowerCase()
                          .compareTo(b.toString().toLowerCase());
                    });
                    gridWidth = 450;
                  });
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: const Text('Close'),
                onPressed: () {
                  setState(() {
                    countryList = countryListMainList;
                    countryList.sort((a, b) {
                      return a
                          .toString()
                          .toLowerCase()
                          .compareTo(b.toString().toLowerCase());
                    });
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  SearchField buildSearchField(BuildContext context) {
    return SearchField(
      suggestions: countryListMainList.map((e) => e.toString()).toList(),
      suggestionState: SuggestionState.enabled,
      controller: _searchController,
      hint: 'Search by country name',
      maxSuggestionsInViewPort: 4,
      itemHeight: 45,
      onTap: (x) {
        setState(() {
          final country =
              countryListMainList.firstWhere((e) => e.toString() == x);
          countryList = [country.toString()];
          Navigator.pop(context);
        });
      },
    );
  }
}
