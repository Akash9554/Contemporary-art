import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import 'DataListScreenForNEWACQUISITIONt.dart';
import 'Models/DataListModel.dart';
import 'openurl.dart';

class DetailsScreencopy extends StatefulWidget {
  final DataListModel dataListModel;

  const DetailsScreencopy({Key? key, required this.dataListModel}) : super(key: key);

  @override
  _DetailsScreencopyState createState() => _DetailsScreencopyState();
}

class _DetailsScreencopyState extends State<DetailsScreencopy> {
  final PopupController _popupLayerController = PopupController();
  final double _zoomIncrement = 0.5;
  late MapController _mapController;
  double _zoom = 15;
  final double _markerSize = 40.0;
  bool showNEWACQUISITION = false;

  late List<LatLng> _points;
  late List<Marker> _markers;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    _points = [];

    try {
      double lat = double.tryParse(widget.dataListModel.lat) ?? 0.0;
      double lng = double.tryParse(widget.dataListModel.lng) ?? 0.0;
      if (lat != 0.0 && lng != 0.0) {
        _points.add(LatLng(lat, lng));
      }
    } catch (e) {
      debugPrint("Invalid lat/lng: $e");
    }

    _markers = _points.map((LatLng point) {
      return Marker(
        point: point,
        width: _markerSize,
        height: _markerSize,
        child: GestureDetector(
          onTap: () {
            String address = Uri.encodeComponent(widget.dataListModel.address);
            String gallery = Uri.encodeComponent(widget.dataListModel.name);

            OpenUrl.openUrl(
              "https://www.mpefm.com/mpefm/jumi_sql/exampleUK.php?"
                  "lat=${widget.dataListModel.lat.tr}&long=${widget.dataListModel.lng.tr}"
                  "&indirizzo=$address&galleria=$gallery",
            );
          },
          child: const Icon(Icons.location_on, size: 40, color: Colors.red),
        ),
      );
    }).toList();

    getPortfolio();
  }

  void getPortfolio() {
    setState(() {
      showNEWACQUISITION = true;
    });
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  Future<bool> _isLandscape(String imageUrl) async {
    final image = NetworkImage(imageUrl);
    final completer = Completer<bool>();
    final ImageStream stream = image.resolve(ImageConfiguration.empty);

    stream.addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info.image.width > info.image.height);
    }));

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        title: Text('Details'.tr, style: const TextStyle(color: Colors.black, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_outlined, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_rounded, color: Colors.black),
            onPressed: () => Navigator.pop(context, "filter"),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(10, 25, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(widget.dataListModel.IMAGE1, height),
            _buildImage(widget.dataListModel.IMAGE2, height),
            const SizedBox(height: 20),
            _buildDetailsSection(context, width, height),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(String? imageUrl, double height) {
    if (imageUrl == null || imageUrl.isEmpty) return const SizedBox.shrink();

    return FutureBuilder<bool>(
      future: _isLandscape(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        return Image.network(
          imageUrl,
          height: height * 0.4,
          fit: BoxFit.fill,
        );
      },
    );
  }

  Widget _buildDetailsSection(BuildContext context, double width, double height) {
    return Container(
      width: width,
      color: Colors.grey[200],
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailItem('Name', widget.dataListModel.ARTIST_NAME_C),
          _buildDetailItem('City', widget.dataListModel.city),
          _buildDetailItem('Address', widget.dataListModel.address),
          _buildDetailItem('Abstract', widget.dataListModel.ABSTRACT),
          _buildDetailItem('Gallery', widget.dataListModel.gallary),
          const SizedBox(height: 20),
          _buildNewAcquisitionButton(context, width, height),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:'.tr,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Text(
            value.tr,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildNewAcquisitionButton(BuildContext context, double width, double height) {
    return Container(
      height: height * 0.06,
      width: width,
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.black,
      ),
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        child: Text(
          'New Acquisition'.tr,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
        ),
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
            if (value == "filter") Navigator.pop(context, "filter");
          });
        },
      ),
    );
  }
}
