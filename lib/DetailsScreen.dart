import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ArtistListScreen.dart';
import 'DataListScreenForNEWACQUISITIONt.dart';
import 'Models/DataListModel.dart';
import 'openurl.dart';

class DetailsScreen extends StatefulWidget {
  DataListModel dataListModel;

  DetailsScreen({required this.dataListModel});

  @override
  _DetailsScreen createState() => _DetailsScreen();
}

class _DetailsScreen extends State<DetailsScreen> {
  final PopupController _popupLayerController = PopupController();
  final double _zoomIncrement = 0.5;
  late MapController _mapController;
  double _zoom = 15;
  List<LatLng> _points = [
    LatLng(37.7749, -122.4194), // Sample coordinates (San Francisco)
  ];
  late List<Marker> _markers;
  final double _markerSize = 40.0;


  bool showPORTFOLIO = false;
  bool showNEWACQUISITION = false;
  bool showPressrelease =false;
  bool isVisible = false;


  @override
  void initState() {
    super.initState();
    getPortfoloi();
    _mapController = MapController();

    _points = []; // Clear the list before adding new points

    setState(() {
      // Add the new point dynamically
      _points.add(LatLng(
        double.parse(widget.dataListModel.lat),
        double.parse(widget.dataListModel.lng),
      ));

      // Create markers from updated points
      _markers = _points.map((LatLng point) {
        return Marker(
          point: point,
          width: _markerSize,
          height: _markerSize,
          child: GestureDetector(
            onTap: () {
              String s = widget.dataListModel.address;
              if (s.contains("&")) s = s.replaceAll("&", "%26");

              String s2 = widget.dataListModel.name;
              if (s2.contains("&")) s2 = s2.replaceAll("&", "%26");

              OpenUrl.openUrl(
                "https://www.mpefm.com/mpefm/jumi_sql/exampleUK.php?"
                    "lat=${widget.dataListModel.lat.tr}&long=${widget.dataListModel.lng.tr}"
                    "&indirizzo=${s.tr}&galleria=${s2.tr}",
              );
            },
            child: const Icon(Icons.location_on, size: 40, color: Colors.red),
          ),
        );
      }).toList();
    });
  }


  Future<void> getPortfoloi() async {
    try {
      // Fetch portfolio data
      Uri checkPortfolio = Uri.parse(
          "https://www.mpefm.com/api/category/tot_api.php?ID_GALLERY=${widget.dataListModel.id}");
      var responsePortfolio = await http.post(checkPortfolio);

      List<dynamic> myjson = [];
      if (responsePortfolio.statusCode == 200) {
        myjson = json.decode(responsePortfolio.body);
      } else {
        print("Failed to fetch portfolio. Status: ${responsePortfolio.statusCode}");
      }

      print("Portfolio items count: ${myjson.length}");

      // Fetch new acquisition data
      Uri checkNEWACQUISITION = Uri.parse(
          "https://www.mpefm.com/api/category/check_tot_count.php?id_city=${widget.dataListModel.cityId}&id_gallery=${widget.dataListModel.id}");
      var responseNEWACQUISITION = await http.post(checkNEWACQUISITION);

      List<dynamic> myjsonNEWACQUISITION = [];
      if (responseNEWACQUISITION.statusCode == 200) {
        myjsonNEWACQUISITION = json.decode(responseNEWACQUISITION.body);
      } else {
        print("Failed to fetch acquisitions. Status: ${responseNEWACQUISITION.statusCode}");
      }

      if (mounted && myjson.isNotEmpty) {
        setState(() {
          showPORTFOLIO = true;
        });
      }

      if (mounted && myjsonNEWACQUISITION.isNotEmpty) {
        int count = int.tryParse(myjsonNEWACQUISITION.first['count'].toString()) ?? 0;
        if (count > 0) {
          setState(() {
            showNEWACQUISITION = true;
          });
        }
      }
    } catch (e, stackTrace) {
      print("Error in getPortfoloi: $e");
      print(stackTrace);
    }
  }

  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text(
          'Details'.tr,
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_outlined,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.filter_alt_rounded,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context, "filter");
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10.0, 25.0, 10.0, 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if(widget.dataListModel.lat!="0.000000")
              Container(
                width: width,
                height: height * 0.3,
                child:
                FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _points.first,
            initialZoom: _zoom,
            onMapEvent: (MapEvent event) {
              setState(() {
                _zoom = (_zoom / _zoomIncrement).round() * _zoomIncrement;
              });
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),

            // 🛠️ Use PopupMarkerLayerWidget for popups
            PopupMarkerLayerWidget(
              options: PopupMarkerLayerOptions(
                popupController: _popupLayerController,
                markers: _markers, // Ensure markers are initialized
                popupDisplayOptions: PopupDisplayOptions(
                  builder: (BuildContext context, Marker marker) => Container(
                    height: 80,
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.blue[300],
                      borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                    ),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.dataListModel.name.tr,
                            style: const TextStyle(color: Colors.black, fontSize: 18),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            widget.dataListModel.city.tr,
                            style: const TextStyle(color: Colors.black, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                maxClusterRadius: 120,
                size: const Size(40, 40),
                markers: _markers,
                polygonOptions: const PolygonOptions(
                  borderColor: Colors.blueAccent,
                  color: Colors.black12,
                  borderStrokeWidth: 3,
                ),
                builder: (context, markers) {
                  return FloatingActionButton(
                    child: Text(markers.length.toString()),
                    onPressed: null,
                  );
                },
              ),
            ),
          ],
        ),

              ),

              SizedBox(
                height: height * 0.025,
              ),
             
              Container(
                width: width,
                color: Colors.grey[200],
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          if (widget.dataListModel.IMAGE1?.isNotEmpty ?? false)
                            SizedBox(
                              width: double.infinity,
                              height: 200,
                              child: Image.network(
                                widget.dataListModel.IMAGE1!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Image.asset(
                                  'assets/photo.png',
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          if (widget.dataListModel.IMAGE2?.isNotEmpty ?? false)
                            SizedBox(
                              width: double.infinity,
                              height: 200,
                              child: Image.network(
                                widget.dataListModel.IMAGE2!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Image.asset(
                                  'assets/photo.png',
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                        ],
                      ),


                      SizedBox(
                        height: height * 0.025,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: height * 0.025),

                          // Name
                          Text(
                            '${'Name'.tr}:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          Text(
                            widget.dataListModel.name ?? '',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
                          ),

                          SizedBox(height: height * 0.025),

                          // City
                          Text(
                            '${'City'.tr}:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          Text(
                            widget.dataListModel.city?.tr ?? '',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
                          ),

                          SizedBox(height: height * 0.025),

                          // Address
                          Text(
                            '${'Address'.tr}:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          SizedBox(
                            width: width * 0.8,
                            child: Text(
                              widget.dataListModel.address?.tr ?? '',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
                            ),
                          ),

                          // Phone
                          if (widget.dataListModel.phone?.isNotEmpty ?? false) ...[
                            SizedBox(height: height * 0.025),
                            Text(
                              '${'Phone'.tr}:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            Text(
                              widget.dataListModel.phone!.tr,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
                            ),
                          ],

                          // Email
                          if (widget.dataListModel.link?.isNotEmpty ?? false) ...[
                            SizedBox(height: height * 0.025),
                            Text(
                              '${'Email'.tr}:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            Text(
                              widget.dataListModel.link!.tr,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
                            ),
                          ],

                          // Website
                          if (widget.dataListModel.EMAIL?.isNotEmpty ?? false) ...[
                            SizedBox(height: height * 0.025),
                            Text(
                              '${'Website'.tr}:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            GestureDetector(
                              onTap: () => OpenUrl.openUrl(widget.dataListModel.EMAIL!),
                              child: Text(
                                widget.dataListModel.EMAIL!.tr,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.blue, decoration: TextDecoration.underline),
                              ),
                            ),
                          ],

                          // Opening Hours
                          if (widget.dataListModel.opening?.isNotEmpty ?? false) ...[
                            SizedBox(height: height * 0.025),
                            Text(
                              '${'Opening'.tr}:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            SizedBox(
                              width: width * 0.8,
                              child: Text(
                                widget.dataListModel.opening!.tr,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
                              ),
                            ),
                          ],

                          // Description
                          if (widget.dataListModel.ABSTRACT?.isNotEmpty ?? false) ...[
                            SizedBox(height: height * 0.025),
                            Text(
                              '${'Description'.tr}:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            SizedBox(
                              width: width * 0.8,
                              child: Text(
                                widget.dataListModel.ABSTRACT!.tr,
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
                              ),
                            ),
                          ],
                        ],
                      ),


                      SizedBox(
                        height: height * 0.025,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (widget.dataListModel.SKYPE.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                OpenUrl.openUrl(widget.dataListModel.SKYPE);
                              },
                              child: Image.asset(
                                'assets/skype.png',
                                width: 35,
                                height: 35,
                              ),
                            ),
                          if (widget.dataListModel.FACEBOOK.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                OpenUrl.openUrl(widget.dataListModel.FACEBOOK);
                              },
                              child: Image.asset(
                                'assets/facebook.png',
                                width: 35,
                                height: 35,
                              ),
                            ),
                          if (widget.dataListModel.TWITTER.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                OpenUrl.openUrl(widget.dataListModel.TWITTER);
                              },
                              child: Image.asset(
                                'assets/twitter.png',
                                width: 35,
                                height: 35,
                              ),
                            ),
                          if (widget.dataListModel.FLICKR.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                OpenUrl.openUrl(widget.dataListModel.FLICKR);
                              },
                              child: Image.asset(
                                'assets/flickr.png',
                                width: 35,
                                height: 35,
                              ),
                            ),
                          if (widget.dataListModel.INSTAGRAM.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                OpenUrl.openUrl(widget.dataListModel.INSTAGRAM);
                              },
                              child: Image.asset(
                                'assets/instagram.png',
                                width: 35,
                                height: 35,
                              ),
                            ),
                          if (widget.dataListModel.YOUTUBE.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                OpenUrl.openUrl(widget.dataListModel.YOUTUBE);
                              },
                              child: Image.asset(
                                'assets/youtube.png',
                                width: 35,
                                height: 35,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(
                        height: height * 0.025,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (widget.dataListModel.VIMEO.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                OpenUrl.openUrl(widget.dataListModel.VIMEO);
                              },
                              child: Image.asset(
                                'assets/vimeo.png',
                                width: 35,
                                height: 35,
                              ),
                            ),
                          if (widget.dataListModel.LINKEDIN.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                OpenUrl.openUrl(widget.dataListModel.LINKEDIN);
                              },
                              child: Image.asset(
                                'assets/linkedin.png',
                                width: 35,
                                height: 35,
                              ),
                            ),
                          if (widget.dataListModel.PINTEREST.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                OpenUrl.openUrl(widget.dataListModel.PINTEREST);
                              },
                              child: Image.asset(
                                'assets/pinterest.png',
                                width: 35,
                                height: 35,
                              ),
                            ),
                          if (widget.dataListModel.WORDPRESS.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                OpenUrl.openUrl(widget.dataListModel.WORDPRESS);
                              },
                              child: Image.asset(
                                'assets/wordpress.png',
                                width: 35,
                                height: 35,
                              ),
                            ),
                          if (widget.dataListModel.BLOGGER.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                OpenUrl.openUrl(widget.dataListModel.BLOGGER);
                              },
                              child: Image.asset(
                                'assets/blogger.png',
                                width: 35,
                                height: 35,
                              ),
                            ),
                          if (widget.dataListModel.TUMBLR.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                OpenUrl.openUrl(widget.dataListModel.TUMBLR);
                              },
                              child: Image.asset(
                                'assets/tumblr.png',
                                width: 35,
                                height: 35,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(
                        height: height * 0.025,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (widget.dataListModel.FOURSQUARE.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                OpenUrl.openUrl(widget.dataListModel.FOURSQUARE);
                              },
                              child: Image.asset(
                                'assets/foursquare.png',
                                width: 35,
                                height: 35,
                              ),
                            ),
                          if (widget.dataListModel.ABSTRACT.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                OpenUrl.openUrl(widget.dataListModel.ABSTRACT);
                              },
                              child: Image.asset(
                                'assets/abstract.png',
                                width: 35,
                                height: 35,
                              ),
                            ),
                          if (widget.dataListModel.XING.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                OpenUrl.openUrl(widget.dataListModel.XING);
                              },
                              child: Image.asset(
                                'assets/xing.png',
                                width: 35,
                                height: 35,
                              ),
                            ),
                          if (widget.dataListModel.GOOGLEPLUS.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                OpenUrl.openUrl(widget.dataListModel.GOOGLEPLUS);
                              },
                              child: Image.asset(
                                'assets/googleplus.png',
                                width: 35,
                                height: 35,
                              ),
                            ),
                          if (widget.dataListModel.WEIBO.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                OpenUrl.openUrl(widget.dataListModel.WEIBO);
                              },
                              child: Image.asset(
                                'assets/weibo.png',
                                width: 35,
                                height: 35,
                              ),
                            ),
                          if (widget.dataListModel.BLOGGER.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                OpenUrl.openUrl(widget.dataListModel.BLOGGER);
                              },
                              child: Image.asset(
                                'assets/googlemaps.png',
                                width: 35,
                                height: 35,
                              ),
                            ),
                          if (widget.dataListModel.BEHANCE.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                OpenUrl.openUrl(widget.dataListModel.BEHANCE);
                              },
                              child: Image.asset(
                                'assets/behance.png',
                                width: 35,
                                height: 35,
                              ),
                            ),
                        ],
                      ),
                      if (showPORTFOLIO)
                        _buildButton(
                          context: context,
                          height: height,
                          width: width,
                          title: 'PORTFOLIO'.tr,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ArtistListScreen(
                                  id_gallery: widget.dataListModel.id.toString(),
                                ),
                              ),
                            ).then((value) {
                              if (value == "filter") {
                                Navigator.pop(context, "filter");
                              }
                            });
                          },
                        ),
                      if (showNEWACQUISITION)
                        _buildButton(
                          context: context,
                          height: height,
                          width: width,
                          title: 'New Acquisition'.tr,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DataListScreenForNEWACQUISITIONt(
                                  id_city: widget.dataListModel.cityId,
                                  id_gallery: widget.dataListModel.id,
                                ),
                              ),
                            ).then((value) {
                              if (value == "filter") {
                                Navigator.pop(context, "filter");
                              }
                            });
                          },
                        ),
                      if (widget.dataListModel.PRESS_RELEASE != null && widget.dataListModel.PRESS_RELEASE!.isNotEmpty)
                        _buildButton(
                          context: context,
                          height: height,
                          width: width,
                          title: 'Press Release'.tr,
                          onPressed: () {
                            OpenUrl.openUrl(widget.dataListModel.PRESS_RELEASE.toString());
                          },
                        ),

                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildButton({
    required BuildContext context,
    required double height,
    required double width,
    required String title,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: height * 0.06,
      width: width,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.black,
        boxShadow: [
          const BoxShadow(
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
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
