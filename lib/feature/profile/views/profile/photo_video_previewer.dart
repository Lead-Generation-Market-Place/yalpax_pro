import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalpax_pro/feature/profile/controller/profile_controller.dart';

class PhotoVideoPreviewer extends StatefulWidget {
  const PhotoVideoPreviewer({super.key});

  @override
  State<PhotoVideoPreviewer> createState() => _PhotoVideoPreviewerState();
}

class _PhotoVideoPreviewerState extends State<PhotoVideoPreviewer> {
  late final List<String> images;
  late final PageController pageController;
  int currentIndex = 0;
  final TextEditingController captionController = TextEditingController();
  final ProfileController profileController = Get.find<ProfileController>();
  bool hasChanges = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    images = List<String>.from(args['images']);
    currentIndex = args['initialIndex'] ?? 0;
    pageController = PageController(initialPage: currentIndex);
    
    // Load initial caption
    _loadCurrentCaption();

    // Listen for caption changes
    captionController.addListener(_onCaptionChanged);
  }

  void _loadCurrentCaption() {
    // Get caption for current image
    final caption = profileController.imageCaptions[currentIndex] ?? '';
    captionController.text = caption;
    hasChanges = false;
  }

  @override
  void dispose() {
    captionController.removeListener(_onCaptionChanged);
    captionController.dispose();
    pageController.dispose();
    super.dispose();
  }

  void _onCaptionChanged() {
    final currentCaption = profileController.imageCaptions[currentIndex] ?? '';
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
    await profileController.saveImageCaption(
      currentIndex,
      captionController.text,
    );
    setState(() {
      hasChanges = false;
    });
  }

  void _showDeleteConfirmationDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Delete Image',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this image? This action cannot be undone.',
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
            onPressed: () {
              Get.back(); // Close dialog
              deleteCurrentImage(); // Proceed with deletion
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

  void deleteCurrentImage() async {
    try {
      await profileController.deleteImage(currentIndex);
      
      // Update local state
      setState(() {
        images.removeAt(currentIndex);
        if (images.isEmpty) {
          Get.back();
          return;
        }
        if (currentIndex >= images.length) {
          currentIndex = images.length - 1;
        }
        pageController.jumpToPage(currentIndex);
        
        // Load caption for new current image
        _loadCurrentCaption();
      });
    } catch (e) {
      // Error is already handled in the controller
    }
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
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
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
        ],
      ),
      body: Column(
        children: [
          // Caption input
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: captionController,
              decoration: const InputDecoration(
                hintText: "Add a caption...",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (_) => _onCaptionChanged(),
            ),
          ),
          // Image preview area
          Expanded(
            child: PageView.builder(
              controller: pageController,
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() {
                  currentIndex = index;
                  _loadCurrentCaption();
                });
              },
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Center(
                      child: InteractiveViewer(
                        child: Image.network(
                          images[index],
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    // Delete button
                    Positioned(
                      top: 16,
                      right: 16,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.redAccent, size: 28),
                        onPressed: _showDeleteConfirmationDialog,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
