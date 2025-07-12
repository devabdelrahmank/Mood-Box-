import 'package:flutter/material.dart';
import 'package:movie_proj/core/my_colors.dart';
import 'package:movie_proj/core/my_styles.dart';

class AllPhotosScreen extends StatefulWidget {
  final List<String> photos;
  final String movieTitle;

  const AllPhotosScreen({
    super.key,
    required this.photos,
    required this.movieTitle,
  });

  @override
  State<AllPhotosScreen> createState() => _AllPhotosScreenState();
}

class _AllPhotosScreenState extends State<AllPhotosScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.primaryColor,
      appBar: AppBar(
        backgroundColor: MyColors.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Photos',
              style: MyStyles.heading2.copyWith(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            Text(
              widget.movieTitle,
              style: MyStyles.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list : Icons.grid_view,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with count and view toggle
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.photo_library,
                  color: MyColors.secondaryColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.photos.length} Photos',
                  style: MyStyles.heading2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: MyColors.secondaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: MyColors.secondaryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _isGridView ? 'Grid View' : 'List View',
                    style: MyStyles.caption.copyWith(
                      color: MyColors.secondaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Photos display
          Expanded(
            child: _isGridView ? _buildGridView() : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 16 / 9,
      ),
      itemCount: widget.photos.length,
      itemBuilder: (context, index) {
        return _buildPhotoCard(index, isGrid: true);
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: widget.photos.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildPhotoCard(index, isGrid: false),
        );
      },
    );
  }

  Widget _buildPhotoCard(int index, {required bool isGrid}) {
    return GestureDetector(
      onTap: () => _showPhotoViewer(index),
      child: Hero(
        tag: 'photo_$index',
        child: Container(
          height: isGrid ? null : 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Image.network(
                  widget.photos[index],
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
                // Overlay with photo number
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${index + 1}/${widget.photos.length}',
                      style: MyStyles.caption.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Play icon overlay for better UX
                if (!isGrid)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.zoom_in,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPhotoViewer(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PhotoViewerScreen(
          photos: widget.photos,
          initialIndex: initialIndex,
        ),
      ),
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
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share functionality coming soon!'),
                  backgroundColor: MyColors.secondaryColor,
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Photo viewer
          PageView.builder(
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
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey,
                            size: 64,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
          // Navigation indicators
          if (widget.photos.length > 1)
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  widget.photos.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: index == _currentIndex ? 12 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: index == _currentIndex
                          ? MyColors.secondaryColor
                          : Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
