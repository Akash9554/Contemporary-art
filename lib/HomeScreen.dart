import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AllArtists.dart';
import 'DataListScreen.dart';
import 'Loader.dart';
import 'Models/CatgoryModel.dart';
import 'Models/CityModel.dart';
import 'Models/CountryModel.dart';
import 'Notify.dart';
import 'language.dart';
import 'openurl.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreen createState() => _HomeScreen();

}

class _HomeScreen extends State<HomeScreen>  with WidgetsBindingObserver {


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this as WidgetsBindingObserver);
    loadCategories();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
      // App is resumed
      if(flag2==0) {
        flag=1;
        flag1=1;
        flag2=1;
        citiesList.clear();
        countriesList.clear();
        categoriesList.clear();
        selectedcityid=null;
        _selectedcategory=null;
        selectedcountryid=null;
        loadCategories();
      }
        break;
      case AppLifecycleState.paused:
      // App is paused
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      // Do nothing
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  final prefs =  SharedPreferences.getInstance();
  String? _selectedcategory;
  String? _selectedcountry;

  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/back2.jpg"),
            fit: BoxFit.fill,
          ),
        ),
        child: Scaffold(
          key: _scaffoldKey,
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.white70,
            title: Text(
              'Home'.tr,
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 25.0, 10.0, 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    SizedBox(height: height * 0.05),

                    /// Category Dropdown
                    flag2 == 0
                        ? Center(child: Loader())
                        : Container(
                      height: height * .07,
                      width: width,
                      decoration: _dropdownDecoration(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: Text("Select Category".tr),
                            value: _selectedcategory,
                            isDense: true,
                            onChanged: (String? newValue) async {
                              setState(() => _selectedcategory = newValue);
                              print(_selectedcategory);
                              await loadCountries();
                            },
                            items: categoriesList.map((CategoryModel map) {
                              return DropdownMenuItem<String>(
                                value: map.id_category,
                                child: Text(map.category ?? "Category Name Unavailable",
                                    style: TextStyle(color: Colors.black)),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.05),

                    /// Country Dropdown
                    flag == 0
                        ? Center(child: Loader())
                        : Container(
                      height: height * .07,
                      width: width,
                      decoration: _dropdownDecoration(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: Text("Select Country".tr),
                            value: selectedcountryid,
                            isDense: true,
                            onChanged: (String? newValue) {
                              setState(() => selectedcountryid = newValue);
                              print(selectedcountryid);
                              loadCities();
                            },
                            items: (countriesList ?? []).map((CountryModel map) {
                              return DropdownMenuItem<String>(
                                value: map.id_country,
                                child: Text(map.country ?? "Country Name Unavailable",
                                    style: TextStyle(color: Colors.black)),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.05),

                    /// City Dropdown
                    flag1 == 0
                        ? Center(child: Loader())
                        : Container(
                      height: height * .07,
                      width: width,
                      decoration: _dropdownDecoration(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            hint: Text("Select City".tr),
                            value: selectedcityid,
                            isDense: true,
                            onChanged: (String? newValue) {
                              setState(() => selectedcityid = newValue);
                              print(selectedcityid);
                            },
                            items: (citiesList ?? []).map((CityModel map) {
                              return DropdownMenuItem<String>(
                                value: map.id_city,
                                child: Text(map.city ?? "",
                                    style: TextStyle(color: Colors.black)),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.05),

                    /// All Artists Button
                    _buildButton('All Artists'.tr, () {
                      Get.to(() => AllArtists());
                    }),

                    /// View Map Button (only shows for certain categories)
              if (_selectedcategory == "1" ||
          _selectedcategory == "2" ||
          _selectedcategory == "3" ||
          _selectedcategory == null)
          Container(
          height: height * .06,
          width: width * 1,
          margin: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 1,
                spreadRadius: 0,
                offset: Offset(1.0, 3.0),
              )
            ],
          ),
          child: MaterialButton(
            color: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Text('View Map'.tr,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            onPressed: () async {
              if (_selectedcategory == null) {
                Notify.snackbar("Select Category".tr, "");
              } else {

                if (selectedcountryid == null) {
                  Notify.snackbar("Select Country".tr, "");
                } else {

                  if (selectedcityid == null) {
                    Notify.snackbar("Select City".tr, "");
                  } else {
                    for (var i = 0; i < citiesList.length; i++) {
                      if(selectedcityid==citiesList[i].id_city) {
                        _selectedcountry = citiesList[i].city.tr;
                        if(_selectedcategory=="1"){
                          _selectedcategory="GALLERY";
                          flag2 = 0;

                          OpenUrl.openUrl(
                              "https://mpefm.com/mpefm/jumi_sql/index.php?search=${_selectedcountry!
                                  .tr}&submit=SUBMIT&type=${_selectedcategory!
                                  .tr}");
                          break;
                        }else if(_selectedcategory=="2"){
                          flag2 = 0;

                          _selectedcategory="MUSEUM";
                          OpenUrl.openUrl(
                              "https://mpefm.com/mpefm/jumi_sql/index.php?search=${_selectedcountry!
                                  .tr}&submit=SUBMIT&type=${_selectedcategory!
                                  .tr}");
                          break;
                        }else{
                          flag2 = 0;

                          _selectedcategory="FAIRS";
                          OpenUrl.openUrl(
                              "https://mpefm.com/mpefm/jumi_sql/index.php?search=${_selectedcountry!
                                  .tr}&submit=SUBMIT&type=${"FAIR"}");
                          break;
                        }
                      }
                      /*Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => MapScreen(
                                                selectedcityid,
                                                _selectedcountry,
                                                _selectedcategory,
                                                PopupSnap.markerTop)));*/
                    }
                  }
                }
              }
            },
          ),
        ),

                    _buildButton('View List'.tr, () {
                      if (_selectedcategory == null) {
                        Notify.snackbar("Select Category".tr, "");
                      } else if (selectedcountryid == null) {
                        Notify.snackbar("Select Country".tr, "");
                      } else if (selectedcityid == null) {
                        Notify.snackbar("Select City".tr, "");
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DataListScreen(
                              id_country: selectedcountryid!,
                              id_category: _selectedcategory!,
                              id_city: selectedcityid!,
                            ),
                          ),
                        );
                      }
                    }),
                  ],
                ),

                /// Language Selection Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        content: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Text('Select Language'.tr),
                              ),
                              for (var item in Languages.locale.keys)
                                InkWell(
                                  onTap: () {
                                    Languages.updateLanguage(Languages.locale[item]!);
                                    Get.back();
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    color: Colors.grey[50],
                                    padding: const EdgeInsets.all(10.0),
                                    margin: const EdgeInsets.all(10.0),
                                    child: Text(item.tr),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () => Get.back(),
                            child: Text('Cancel'.tr),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text('Select Language'.tr),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// **Helper Widgets**
  Widget _buildButton(String title, VoidCallback onPressed) {
    return Container(
      height: 50,
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.black,
        boxShadow: [BoxShadow(color: Colors.black, blurRadius: 1, offset: Offset(1.0, 3.0))],
      ),
      child: MaterialButton(
        color: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
        onPressed: onPressed,
      ),
    );
  }

  BoxDecoration _dropdownDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: Colors.white,
      boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 3, spreadRadius: .5, offset: Offset(0.5, 0.5))],
    );
  }


  loadCountries() async {
    setState(() {
      flag = 0;
    });
    if (countriesList != null) {
      countriesList.clear();
    }

    Uri myuri = Uri.parse(
        "https://www.mpefm.com/api/country_city1/index_cat.php?type=" + _selectedcategory!);
    // Uri.parse("https://www.mpefm.com/api/country_city/?type=country,id_country");
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    // Use the HttpClient to create an IOClient for the http package
    IOClient ioClient = IOClient(httpClient);
    var response = await ioClient.post(myuri);

      print(response.body);

      setState(() {
        flag = 1;
        var myjson = json.decode(response.body);
        for (var country in myjson) {
          CountryModel categoryModel = CountryModel(
            country["id_country"].toString(),
            country["country"].toString(),
          );

          countriesList.add(categoryModel);
        }
      });
    // await loadCities();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List<CategoryModel> categoriesList = [];
  int? flag2;

  loadCategories() async {
    setState(() {
      flag2 = 0;
    });

    if (categoriesList != null) {
      categoriesList.clear();
    }

    Uri myuri = Uri.parse("https://www.mpefm.com/api/category/types_list.php?");
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    // Use the HttpClient to create an IOClient for the http package
    IOClient ioClient = IOClient(httpClient);
    var response = await ioClient.post(myuri);



      print(response.body);

      setState(() {
        flag2 = 1;
        var myjson = json.decode(response.body);
        categoriesList.clear();
        if (myjson != null && myjson is List) {
          for (var category in myjson) {
            if (category["ID_TYPE"] != null && category["TITLE_TYPE"] != null) {
              CategoryModel categoryModel = CategoryModel(
                category["ID_TYPE"].toString(),
                category["TITLE_TYPE"].toString(),
              );

              categoriesList.add(categoryModel);
            }
          }
        }
      });

  }


  int? flag;
  List<CountryModel> countriesList = [];

  String? selectedcountryid;

  loadCities() async  {
    setState(() {
      flag1 = 0;
      selectedcityid = null;
    });

    if (citiesList != null) {
      citiesList.clear();
    }

    Uri myuri = Uri.parse("https://www.mpefm.com/api/country_city1/?type=city,id_city,country,id_country&value=$selectedcountryid&id_type=$_selectedcategory");
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    // Use the HttpClient to create an IOClient for the http package
    IOClient ioClient = IOClient(httpClient);
    var response = await ioClient.post(myuri);

      print(response.body);

      setState(() {
        flag1 = 1;
        var myjson = json.decode(response.body);

        if (myjson != null && myjson is List) {
          for (var country in myjson) {
            if (country["id_city"] != null && country["city"] != null) {
              CityModel categoryModel = CityModel(
                country["id_city"].toString(),
                country["city"].toString(),
              );
              citiesList.add(categoryModel);
            }
          }
        }
      });
  }

  int ?flag1;
  List<CityModel> citiesList = [];

  String ?selectedcityid;
}
