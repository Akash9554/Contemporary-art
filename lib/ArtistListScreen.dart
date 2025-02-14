import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/io_client.dart';
import 'ArtistDetailsScreen.dart';
import 'Loader.dart';
import 'Models/ArtistListModel.dart';

class ArtistListScreen extends StatefulWidget {
  final String id_gallery;

  ArtistListScreen({required this.id_gallery});

  @override
  _ArtistListScreenState createState() => _ArtistListScreenState();
}

class _ArtistListScreenState extends State<ArtistListScreen> {
  int flag = 0;
  List<ArtistListModel> dataList = [];
  List<ArtistListModel> searchedDataList = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      flag = 0;
      dataList.clear();
      searchedDataList.clear();
    });

    Uri uri = Uri.parse(
        "https://www.mpefm.com/api/category/tot_api.php?ID_GALLERY=${widget.id_gallery}");
    HttpClient httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) =>
      true;
    IOClient ioClient = IOClient(httpClient);

    try {
      final response = await ioClient.get(uri);
      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);

        List<ArtistListModel> tempDataList = jsonData.map((data) {
          return ArtistListModel(
            data["ID"].toString(),
            data["IMAGE1"].toString(),
            data["IMAGE2"].toString(),
            data["ARTIST_NAME_C"].toString(),
            data["ARTIST_NAME_R"].toString(),
            data["COUNTRY"].toString(),
            data["EMAIL"].toString(),
            data["TYPE"].toString(),
            data["CITY"].toString(),
            data["LINK_ARTIST"].toString(),
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
          );
        }).toList();

        setState(() {
          dataList = tempDataList;
          flag = 1;
        });
      } else {
        setState(() => flag = 1);
      }
    } catch (e) {
      print("Error fetching data: $e");
      setState(() => flag = 1);
    }
  }

  void onSearchTextChanged(String text) {
    searchedDataList.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    searchedDataList = dataList
        .where((data) => data.name.toLowerCase().contains(text.toLowerCase()))
        .toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text('Artists'.tr, style: TextStyle(color: Colors.black, fontSize: 16)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_outlined, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_alt_rounded, color: Colors.black),
            onPressed: () => Navigator.pop(context, "filter"),
          ),
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
          SizedBox(height: 10),
          Expanded(
            child: flag == 0
                ? Loader()
                : dataList.isEmpty
                ? Center(
              child: Text(
                'No Data Found'.tr,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18.0, color: Colors.black),
              ),
            )
                : ListView.builder(
              itemCount: searchedDataList.isNotEmpty ? searchedDataList.length : dataList.length,
              itemBuilder: (context, index) {
                final artist = searchedDataList.isNotEmpty ? searchedDataList[index] : dataList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ArtistDetailsScreen(artistListModel: artist)),
                    );
                  },
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: width * 0.025),
                          Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                artist.image1,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset('assets/photo.png', fit: BoxFit.cover);
                                },
                              ),
                            ),
                          ),

                          SizedBox(width: width * 0.025),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  artist.name.tr,
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  artist.email.tr,
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Divider(color: Colors.grey[700]),
                    ],
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
