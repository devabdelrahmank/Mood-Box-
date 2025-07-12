import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_styles.dart';
import 'package:movie_proj/core/spacing.dart';

class PhotosSection extends StatelessWidget {
  final List<String> photos;

  const PhotosSection({
    super.key,
    required this.photos,
  });

  @override
  Widget build(BuildContext context) {
    // Filter out empty photos
    final validPhotos = photos.where((photo) => photo.isNotEmpty).toList();

    if (validPhotos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Photos',
              style: MyStyles.heading2.copyWith(color: Colors.white),
            ),
            TextButton(
              onPressed: () {
                _showPhotoGallery(context, validPhotos);
              },
              child: Text(
                'See all ${validPhotos.length}',
                style: MyStyles.body.copyWith(color: MyColors.secondaryColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.medium),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 4),
            itemCount: validPhotos.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index < validPhotos.length - 1 ? Spacing.medium : 0,
                ),
                child: GestureDetector(
                  onTap: () => _showPhotoViewer(context, validPhotos, index),
                  child: Hero(
                    tag: 'photo_$index',
                    child: Container(
                      width: 320,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Image.network(
                              validPhotos[index],
                              width: 320,
                              height: 200,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 320,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: MyColors.secondaryColor,
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 320,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                      size: 48,
                                    ),
                                  ),
                                );
                              },
                            ),
                            // Gradient overlay for better visual appeal
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Photo index indicator
                            if (validPhotos.length > 1)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${index + 1}/${validPhotos.length}',
                                    style: MyStyles.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showPhotoViewer(
      BuildContext context, List<String> photos, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PhotoViewerScreen(
          photos: photos,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  void _showPhotoGallery(BuildContext context, List<String> photos) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => PhotoGallerySheet(photos: photos),
    );
  }
}

class PhotoViewerScreen extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;

  const PhotoViewerScreen({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<PhotoViewerScreen> createState() => _PhotoViewerScreenState();
}

class _PhotoViewerScreenState extends State<PhotoViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_currentIndex + 1} of ${widget.photos.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.photos.length,
        itemBuilder: (context, index) {
          return Center(
            child: Hero(
              tag: 'photo_$index',
              child: InteractiveViewer(
                child: Image.network(
                  widget.photos[index],
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class PhotoGallerySheet extends StatelessWidget {
  final List<String> photos;

  const PhotoGallerySheet({
    super.key,
    required this.photos,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: MyColors.primaryColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All Photos (${photos.length})',
                  style: MyStyles.heading2.copyWith(color: Colors.white),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 16 / 9,
              ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PhotoViewerScreen(
                          photos: photos,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      photos[index],
                      fit: BoxFit.cover,
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
