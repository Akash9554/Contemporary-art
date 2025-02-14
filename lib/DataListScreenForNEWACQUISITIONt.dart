import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import 'DetailsScreencopy.dart';
import 'Loader.dart';
import 'Models/DataListModel.dart';

class DataListScreenForNEWACQUISITIONt extends StatefulWidget {
  final String? id_city, id_gallery;

  DataListScreenForNEWACQUISITIONt({required this.id_city, required this.id_gallery});

  @override
  _DataListScreen createState() => _DataListScreen();
}

class _DataListScreen extends State<DataListScreenForNEWACQUISITIONt> {
  int flag = 0;
  List<DataListModel> dataList = [];
  List<DataListModel> searchedDataList = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => flag = 0);

    Uri uri = Uri.parse(
        "https://www.mpefm.com/api/category/get_tot_list.php?id_city=${widget.id_city}&id_gallery=${widget.id_gallery}");

    HttpClient httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    IOClient ioClient = IOClient(httpClient);
    var response = await ioClient.get(uri);

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      setState(() {
        dataList = jsonResponse.map((data) => DataListModel.fromJson(data)).toList();
        flag = 1;
      });
    } else {
      setState(() => flag = 1);
    }
  }

  void onSearchTextChanged(String text) {
    searchedDataList.clear();
    if (text.isNotEmpty) {
      searchedDataList = dataList
          .where((data) => data.ARTIST_NAME_C?.toLowerCase().contains(text.toLowerCase()) ?? false)
          .toList();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text('NEW'.tr, style: TextStyle(color: Colors.black, fontSize: 16)),
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
                trailing: searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.cancel_outlined),
                  onPressed: () {
                    searchController.clear();
                    onSearchTextChanged('');
                  },
                )
                    : null,
              ),
            ),
          ),
          flag == 0
              ? Loader()
              : Expanded(
            child: (searchedDataList.isNotEmpty || searchController.text.isNotEmpty)
                ? _buildListView(searchedDataList, width)
                : _buildListView(dataList, width),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<DataListModel> list, double width) {
    return list.isEmpty
        ? Center(
      child: Text(
        'No Data Found'.tr,
        style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0, color: Colors.black),
      ),
    )
        : ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final data = list[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailsScreencopy(dataListModel: data),
              ),
            ).then((value) {
              if (value == "filter") Navigator.pop(context, "filter");
            });
          },
          child: Container(
            width: width,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.white),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: width * .025),
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    image: data.IMAGE1 != null
                        ? DecorationImage(image: NetworkImage(data.IMAGE1!), fit: BoxFit.fill)
                        : null,
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.grey[300],
                  ),
                ),
                SizedBox(width: width * .025),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.ARTIST_NAME_C ?? '',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                      SizedBox(height: 4),
                      Text(data.ABSTRACT ?? '',
                          style: TextStyle(fontSize: 12, color: Colors.black.withOpacity(.6))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
