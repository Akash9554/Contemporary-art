import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:http/io_client.dart';

import 'DetailsScreen.dart';
import 'Loader.dart';
import 'Models/DataListModel.dart';

class DataListScreen extends StatefulWidget {
  final String id_city, id_country, id_category;

  DataListScreen({required this.id_city, required this.id_country, required this.id_category});

  @override
  _DataListScreenState createState() => _DataListScreenState();
}

class _DataListScreenState extends State<DataListScreen> {
  int flag = 0;
  List<DataListModel> dataList = [];
  List<DataListModel> searchedDataList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      flag = 0;
    });

    dataList.clear();

    Uri myUri = Uri.parse(
        "https://www.mpefm.com/api/category/test.php?id_country=${widget.id_country}&id_city=${widget.id_city}&id_type=${widget.id_category}");

    HttpClient httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    IOClient ioClient = IOClient(httpClient);
    var response = await ioClient.post(myUri);

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      setState(() {
        dataList = jsonResponse
            .map((data) => DataListModel(
          data["ID"].toString(),
          data["image1"].toString(),
          data["IMAGE2"].toString(),
          data["logo"].toString(),
          data["name"].toString(),
          data["address"].toString(),
          data["phone"].toString(),
          data["GALLERY"].toString(),
          data["tel"].toString(),
          data["opening"].toString(),
          data["lat"].toString(),
          data["lng"].toString(),
          data["city"].toString(),
          data["ID_CITY"].toString(),
          data["mobile"].toString(),
          data["fax"].toString(),
          data["SKYPE"].toString(),
          data["FACEBOOK"].toString(),
          data["TWITTER"].toString(),
          data["FLICKR"].toString(),
          data["INSTAGRAM"].toString(),
          data["YOUTUBE"].toString(),
          data["VIMEO"].toString(),
          data["LINKEDIN"].toString(),
          data["PINTEREST"].toString(),
          data["WORDPRESS"].toString(),
          data["BLOGGER"].toString(),
          data["TUMBLR"].toString(),
          data["FOURSQUARE"].toString(),
          data["ABSTRACT"].toString(),
          data["XING"].toString(),
          data["GOOGLEPLUS"].toString(),
          data["WEIBO"].toString(),
          data["GOOGLEMAP"].toString(),
          data["BEHANCE"].toString(),
          data["ARTIST_NAME_R"].toString(),
          data["ARTIST_NAME_C"].toString(),
          data["PRESS_RELEASE"].toString(),
          data["EMAIL"].toString(),
          data["link"].toString(),
        ))
            .toList();
        flag = 1;
      });
    } else {
      setState(() {
        flag = 1;
      });
    }
  }

  void onSearchTextChanged(String text) {
    setState(() {
      searchedDataList = dataList
          .where((item) => item.name.toLowerCase().contains(text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text('Places'.tr, style: TextStyle(color: Colors.black, fontSize: 16)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt_rounded, color: Colors.black),
            onPressed: () => Navigator.pop(context, "filter"),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
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
          ),
          SizedBox(height: 20),
          flag == 0
              ? Loader()
              : dataList.isEmpty
              ? Center(child: Text('No Data Found'.tr, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)))
              : Expanded(
            child: ListView.builder(
              itemCount: searchedDataList.isNotEmpty ? searchedDataList.length : dataList.length,
              itemBuilder: (context, index) {
                var item = searchedDataList.isNotEmpty ? searchedDataList[index] : dataList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailsScreen(dataListModel: item),
                      ),
                    ).then((value) {
                      if (value == "filter") Navigator.pop(context, "filter");
                    });
                  },
                  child: Container(
                    width: width,
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.white,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.logo.isNotEmpty)
                          SizedBox(
                            width: width,
                            height: 300,
                            child: Image.network(
                              item.logo,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Center(child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) => Image.asset(
                                'assets/photo.png',
                                width: width,
                                height: 300,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        SizedBox(height: 8),
                        Text(item.name.tr, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text(item.address.tr, style: TextStyle(fontSize: 12)),
                        SizedBox(height: 4),
                        Text(item.tel.tr, style: TextStyle(fontSize: 12)),
                        SizedBox(height: 4),
                        Text(item.opening.tr, style: TextStyle(fontSize: 12)),
                        Divider(color: Colors.grey[700]),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
