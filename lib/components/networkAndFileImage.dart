import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_my_ride_partners_1/components/shimmerWidget.dart';

class NetworkAndFileImage extends StatelessWidget {
  final imageData;
  final fit;
  final height;
  final borderRadius;
  final iconColor;

  const NetworkAndFileImage(
      {@required this.imageData,
        this.fit = BoxFit.cover,
        @required this.height,
        @required this.borderRadius,
        this.iconColor = Colors.black});

  @override
  Widget build(BuildContext context) {
    if (imageData.toString().startsWith('http')) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.network(
          imageData,
          errorBuilder: (context, obj, trace) {
            return Container(
              width: double.infinity,
              height: double.parse(height.toString()),
              child: Icon(
                Icons.image_not_supported,
                color: this.iconColor,
              ),
            );
          },
          width: double.infinity,
          height: double.parse(height.toString()),
          loadingBuilder: (BuildContext context, Widget child,
              ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) return child;
            return ShimmerWidget(
              isLoading: true,
              child: Container(
                color: Colors.grey,
                height: double.parse(height.toString()),
              ),
            );
          },
          fit: fit,
        ),
      );
    } else {
      return imageData == null
          ? Container(
        width: double.infinity,
        height: double.parse(height.toString()),
        decoration: BoxDecoration(borderRadius: borderRadius),
        child: Icon(
          Icons.image_not_supported,
          color: iconColor,
        ),
      )
          : ClipRRect(
        borderRadius: borderRadius,
        child: Image.file(
          File(imageData),
          width: double.infinity,
          height: double.parse(height.toString()),
          fit: fit,
        ),
      );
    }
  }
}
