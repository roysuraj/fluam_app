import 'package:fluam_app/ui/widgets/cache_image/cache_image.dart';
import 'package:flutter/material.dart';

class ImagesView extends StatelessWidget {
  final List<String>? images;
  final int index;
  final Object heroTag;

  ImagesView(this.images, this.index, this.heroTag);

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: Hero(
            tag: heroTag,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: PageView.builder(
                  itemCount: images?.length,
                  itemBuilder: (BuildContext context, int index) {
                    return CacheImage(images![index]);
                  }),
            )));
  }
}
