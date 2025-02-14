import 'dart:convert';
import 'dart:io';
import 'package:contemporaryart/openurl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'Models/CountryModel.dart';

class AllArtists extends StatefulWidget {
  @override
  State<AllArtists> createState() => _AllArtistsState();
}

class _AllArtistsState extends State<AllArtists> {
  bool isLoading = true;
  bool showArtistList = true;
  TextEditingController searchController = TextEditingController();

  List<CountryModel> countriesList = [];
  List<String> searchedDataList = [];
  List<String> artistNames = [];

  String? selectedCountryId;

  @override
  void initState() {
    super.initState();
    loadCountries();
  }

  Future<void> loadCountries() async {
    setState(() {
      isLoading = true;
    });

    try {
      Uri uri = Uri.parse("https://www.mpefm.com/api/prova/index_country.php?&type=COUNTRY");
      HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);
      var response = await ioClient.post(uri);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);

        // Use Set to remove duplicates
        Set<String> countryIds = {};
        countriesList = jsonResponse
            .map((data) => CountryModel(
          data["id_country"].toString(),
          data["COUNTRY"].toString(),
        ))
            .where((country) => countryIds.add(country.id_country)) // Ensures only unique values
            .toList();

        // Validate selectedCountryId
        if (selectedCountryId != null &&
            !countriesList.any((country) => country.id_country == selectedCountryId)) {
          selectedCountryId = null; // Reset invalid selection
        }

        // Auto-select the first country if only one exists
        if (countriesList.length == 1) {
          selectedCountryId = countriesList.first.id_country;
        }
      } else {
        print("Failed to load countries. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error loading countries: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }





  Future<void> loadAllArtists() async {
    if (selectedCountryId == null || !mounted) return;

    setState(() {
      showArtistList = true;
    });

    try {
      Uri uri = Uri.parse(
          'https://www.mpefm.com/api/prova/index_artistcountry.php?&type=artist_name&value=$selectedCountryId');
      HttpClient httpClient = HttpClient()
        ..badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);
      var response = await ioClient.post(uri);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        artistNames = jsonResponse
            .map((data) => data['artist_name_c']?.toString() ?? "")
            .toList()
            .where((name) => name.isNotEmpty)
            .toList();
      } else {
        print("Failed to load artists. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error loading artists: $e");
    } finally {
      if (mounted) {
        setState(() {
          showArtistList = false;
        });
      }
    }
  }


  void onSearchTextChanged(String text) {
    searchedDataList = text.isEmpty
        ? []
        : artistNames.where((name) => name.toLowerCase().contains(text.toLowerCase())).toList();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('All Artists'.tr, style: TextStyle(color: Colors.black)),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(children: [
        SizedBox(height: 20),
        buildCountryDropdown(height, width),
        SizedBox(height: 20),
        if (selectedCountryId != null) buildSearchBar(),
        SizedBox(height: 20),
        buildArtistList()
      ]),
    );
  }

  Widget buildCountryDropdown(double height, double width) {
    return Container(
      height: height * 0.07,
      width: width,
      margin: EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 3, spreadRadius: 0.5)],
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          alignedDropdown: true, // Ensures dropdown is aligned properly
          child: DropdownButton<String>(
            hint: Padding(
              padding: EdgeInsets.only(left: 30), // Add 30dp left padding to hint text
              child: Text("Select Country".tr, textAlign: TextAlign.start),
            ),
            value: countriesList.any((country) => country.id_country == selectedCountryId)
                ? selectedCountryId
                : null, // Ensure selected value exists
            isExpanded: true, // Ensure full width
            alignment: Alignment.centerLeft, // Aligns selected text from the left
            onChanged: (String? newValue) async {
              if (newValue != null) {
                setState(() {
                  selectedCountryId = newValue;
                });
                await loadAllArtists();
              }
            },
            items: countriesList.isNotEmpty
                ? countriesList
                .map((country) => DropdownMenuItem<String>(
              value: country.id_country,
              child: Padding(
                padding: EdgeInsets.only(left: 30), // Add left padding to dropdown items
                child: Text(country.country, textAlign: TextAlign.start),
              ),
            ))
                .toList()
                : [
              DropdownMenuItem<String>(
                value: null,
                child: Padding(
                  padding: EdgeInsets.only(left: 30), // Add left padding to 'No Data'
                  child: Text("No Data", textAlign: TextAlign.start, style: TextStyle(color: Colors.grey)),
                ),
              )
            ], // Show 'No Data' when list is empty
          ),
        ),
      ),
    );
  }





  Widget buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: Colors.grey[200],
        child: ListTile(
          leading: Icon(Icons.search),
          title: TextField(
            controller: searchController,
            decoration: InputDecoration(hintText: 'Search'.tr, border: InputBorder.none),
            onChanged: onSearchTextChanged,
          ),
          trailing: IconButton(
            icon: Icon(Icons.cancel_outlined),
            onPressed: () {
              searchController.clear();
              onSearchTextChanged('');
            },
          ),
        ),
      ),
    );
  }

  Widget buildArtistList() {
    if (selectedCountryId == null || showArtistList) {
      return Center(child: CircularProgressIndicator());
    }

    final displayList = searchedDataList.isNotEmpty ? searchedDataList : artistNames;

    return Expanded(
      child: ListView.builder(
        itemCount: displayList.length,
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        itemBuilder: (_, index) {
          return ListTile(
            title: Text(displayList[index]),
            trailing: InkWell(
              onTap: () {
                OpenUrl.openUrl("https://www.mpefm.com/mpefm/jumi_files/artisti1_5.php?comuni=" + Uri.encodeComponent(displayList[index]));
              },
              child: Icon(Icons.arrow_forward_ios_outlined, size: 20),
            ),
          );
        },
      ),
    );
  }
}
