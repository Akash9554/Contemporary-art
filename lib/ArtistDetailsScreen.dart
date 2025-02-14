import 'dart:async';
import 'package:contemporaryart/openurl.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'Models/ArtistListModel.dart';

class ArtistDetailsScreen extends StatefulWidget {
  final ArtistListModel artistListModel;

  ArtistDetailsScreen({required this.artistListModel});

  @override
  _ArtistDetailsScreenState createState() => _ArtistDetailsScreenState();
}

class _ArtistDetailsScreenState extends State<ArtistDetailsScreen> {
  @override
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(10.0, 35.0, 10.0, 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageWidget(widget.artistListModel.image1, height),
            _buildImageWidget(widget.artistListModel.image2, height),
            SizedBox(height: height * 0.025),
            _buildDetailsSection(width, height),
          ],
        ),
      ),
    );
  }

  /// Widget to display artist images with landscape check.
  Widget _buildImageWidget(String? imageUrl, double height) {
    if (imageUrl == null || imageUrl.isEmpty) return SizedBox.shrink();

    return FutureBuilder<bool>(
      future: _isLandscape(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        bool isLandscape = snapshot.data ?? false;
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            imageUrl,
            height: height * 0.4,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Image.asset('assets/photo.png', height: height * 0.4, fit: BoxFit.cover),
          ),
        );
      },
    );
  }

  /// Section to display artist details.
  Widget _buildDetailsSection(double width, double height) {
    return Container(
      width: width,
      color: Colors.grey[200],
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Name', widget.artistListModel.name),
          _buildDetailRow('City', widget.artistListModel.city?.tr),
          _buildDetailRow('Country', widget.artistListModel.country?.tr),
          _buildWebsiteRow(),
          SizedBox(height: height * 0.025),
          _buildSocialMediaIcons(),
        ],
      ),
    );
  }

  /// Helper widget to build each detail row.
  Widget _buildDetailRow(String label, String? value) {
    if (value == null || value.isEmpty) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:'.tr, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.black)),
        ],
      ),
    );
  }

  /// Widget to handle website link.
  Widget _buildWebsiteRow() {
    if (widget.artistListModel.website == null || widget.artistListModel.website!.isEmpty) return SizedBox.shrink();

    return GestureDetector(
      onTap: () => OpenUrl.openUrl(widget.artistListModel.website!),
      child: Text(
        widget.artistListModel.website!.tr,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.blue, decoration: TextDecoration.underline),
      ),
    );
  }

  /// Widget to display social media icons.
  Widget _buildSocialMediaIcons() {
    final socialMedia = {
      'SKYPE': widget.artistListModel.SKYPE,
      'FACEBOOK': widget.artistListModel.FACEBOOK,
      'TWITTER': widget.artistListModel.TWITTER,
      'FLICKR': widget.artistListModel.FLICKR,
      'INSTAGRAM': widget.artistListModel.INSTAGRAM,
      'YOUTUBE': widget.artistListModel.YOUTUBE,
      'VIMEO': widget.artistListModel.VIMEO,
      'LINKEDIN': widget.artistListModel.LINKEDIN,
      'PINTEREST': widget.artistListModel.PINTEREST,
      'WORDPRESS': widget.artistListModel.WORDPRESS,
      'BLOGGER': widget.artistListModel.BLOGGER,
      'TUMBLR': widget.artistListModel.TUMBLR,
      'FOURSQUARE': widget.artistListModel.FOURSQUARE,
      'ABSTRACT': widget.artistListModel.ABSTRACT,
      'XING': widget.artistListModel.XING,
    };

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: socialMedia.entries
          .where((entry) => entry.value != null && entry.value!.isNotEmpty)
          .map((entry) => GestureDetector(
        onTap: () => OpenUrl.openUrl(entry.value!),
        child: Image.asset('assets/${entry.key.toLowerCase()}.png',
            width: 35, height: 35),
      ))
          .toList(),
    );
  }


  /// Determines if the image is landscape.
  Future<bool> _isLandscape(String imageUrl) async {
    try {
      final image = NetworkImage(imageUrl);
      final completer = Completer<bool>();
      final ImageStream stream = image.resolve(ImageConfiguration.empty);

      stream.addListener(
        ImageStreamListener((ImageInfo info, bool _) {
          completer.complete(info.image.width > info.image.height);
        }, onError: (dynamic error, StackTrace? stackTrace) {
          completer.complete(false);
        }),
      );

      return completer.future;
    } catch (e) {
      return false;
    }
  }
}
