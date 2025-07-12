import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:yalpax_pro/feature/profile/controller/profile_controller.dart';

class PhotoVideoPreviewer extends StatefulWidget {
  const PhotoVideoPreviewer({super.key});

  @override
  State<PhotoVideoPreviewer> createState() => _PhotoVideoPreviewerState();
}

class _PhotoVideoPreviewerState extends State<PhotoVideoPreviewer> {
  late PageController _pageController;
  late List<String> images;
  late int currentIndex;
  VideoPlayerController? _videoController;
  final ProfileController controller = Get.find<ProfileController>();
  bool isCurrentVideo = false;
  final TextEditingController captionController = TextEditingController();
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    images = List<String>.from(args['images']);
    currentIndex = args['initialIndex'] as int;
    _pageController = PageController(initialPage: currentIndex);
    _initializeVideoController(currentIndex);
    
    // Load initial caption
    _loadCurrentCaption();
    
    // Listen for caption changes
    captionController.addListener(_onCaptionChanged);
  }

  void _loadCurrentCaption() {
    // Get caption for current image
    final caption = controller.imageCaptions[currentIndex] ?? '';
    captionController.text = caption;
    hasChanges = false;
  }

  void _onCaptionChanged() {
    final currentCaption = controller.imageCaptions[currentIndex] ?? '';
    final newCaption = captionController.text;
    
    if (currentCaption != newCaption) {
      if (!hasChanges) {
        setState(() {
          hasChanges = true;
        });
      }
    } else {
      if (hasChanges) {
        setState(() {
          hasChanges = false;
        });
      }
    }
  }

  Future<void> _saveCaption() async {
    await controller.saveImageCaption(
      currentIndex,
      captionController.text,
    );
    setState(() {
      hasChanges = false;
    });
  }

  bool _isVideoFile(String url) {
    final lowercaseUrl = url.toLowerCase();
    return lowercaseUrl.contains('.mp4') || 
           lowercaseUrl.contains('.mov') || 
           lowercaseUrl.contains('.avi');
  }

  Future<void> _initializeVideoController(int index) async {
    final url = images[index];
    isCurrentVideo = _isVideoFile(url);

    if (_videoController != null) {
      await _videoController!.dispose();
      _videoController = null;
    }

    if (isCurrentVideo) {
      try {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
        await _videoController!.initialize();
        setState(() {});
      } catch (e) {
        print('Error initializing video: $e');
      }
    }
  }

  @override
  void dispose() {
    captionController.removeListener(_onCaptionChanged);
    captionController.dispose();
    _pageController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  void _showDeleteConfirmationDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Delete Media',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this item? This action cannot be undone.',
          style: TextStyle(
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.deleteImage(currentIndex);
              if (images.length <= 1) {
                Get.back(); // Close previewer if no images left
              } else {
                setState(() {
                  images.removeAt(currentIndex);
                  if (currentIndex >= images.length) {
                    currentIndex = images.length - 1;
                  }
                  _pageController.jumpToPage(currentIndex);
                  _loadCurrentCaption();
                });
              }
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Photos & Videos',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          if (hasChanges)
            TextButton(
              onPressed: _saveCaption,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _showDeleteConfirmationDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Caption input
          Container(
            color: Colors.grey[900],
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: captionController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Add a caption...",
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[700]!),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (_) => _onCaptionChanged(),
            ),
          ),
          // Media preview area
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                  _initializeVideoController(index);
                  _loadCurrentCaption();
                });
              },
              itemBuilder: (context, index) {
                final url = images[index];
                final isVideo = _isVideoFile(url);

                if (isVideo) {
                  if (_videoController?.value.isInitialized ?? false) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_videoController!.value.isPlaying) {
                            _videoController!.pause();
                          } else {
                            _videoController!.play();
                          }
                        });
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          ),
                          if (!_videoController!.value.isPlaying)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Padding(
                                padding: EdgeInsets.all(12),
                                child: Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    );
                  }
                } else {
                  return InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Image.network(
                      url,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / 
                                  loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 48,
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
