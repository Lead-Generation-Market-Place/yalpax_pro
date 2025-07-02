import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:yalpax_pro/core/constants/app_colors.dart';
import 'package:yalpax_pro/core/routes/routes.dart';
import 'package:yalpax_pro/core/widgets/custom_button.dart';
import 'package:yalpax_pro/feature/auth/controllers/auth_controller.dart';
import 'package:yalpax_pro/main.dart';

class Reviews extends StatefulWidget {
  const Reviews({super.key});

  @override
  State<Reviews> createState() => _ReviewsState();
}

class _ReviewsState extends State<Reviews> {
  final List<TextEditingController> _emailControllers = [
    TextEditingController(),
  ];

  bool _isPending = false;
  int? _sendingIndex;
  String? _userId;
  String? _businessImageUrl;
  String? _username;
  bool _copied = false;

  // Business info that would come from search params in React
  String _businessName = '';
  String _location = '';
  String _email = '';
  String _phone = '';
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    _loadBusinessInfo();
  }

  Future<void> _loadBusinessInfo() async {
    final userId = supabase.auth.currentUser!.id;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await supabase
          .from('service_providers')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _businessName = response['business_name'] ?? 'Unnamed Business';
          _location = response['location'] ?? 'Unknown Location';
          _email = response['email'] ?? 'no-email@example.com';
          _phone = response['phone'] ?? 'No phone';
          _businessImageUrl = response['image_url'] ?? 'No phone';
        });
      } else {
        // Handle no data found
        setState(() {
          _businessName = 'Example Business';
          _location = 'New York, NY';
          _email = 'contact@example.com';
          _phone = '(123) 456-7890';
        });
      }
    } catch (e) {
      debugPrint('Error loading business info: $e');
      // Optionally show an error UI
    } finally {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchUserInfo() async {
    setState(() {
      isLoading = true;
    });

    final userId = supabase.auth.currentUser!.id;

    try {
      final response = await supabase
          .from('users_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _userId = response['id'];
          _businessImageUrl =
              response['image_url'] ?? 'https://example.com/default.jpg';
          _username = response['username'] ?? 'Unnamed';
        });
      } else {
        // Handle case where no user profile is found
        setState(() {
          _userId = 'unknown';
          _businessImageUrl = 'https://example.com/default.jpg';
          _username = 'Unknown User';
        });
      }
    } catch (e) {
      // Optionally log or handle error
      debugPrint('Error fetching user info: $e');
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addEmailField() {
    setState(() {
      _emailControllers.add(TextEditingController());
    });
  }

  Future<void> _handleSendEmail(String email, int index) async {
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address.')),
      );
      return;
    }

    if (_businessName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business name is required.')),
      );
      return;
    }
    debugPrint(
      'Calling function with body: ${{'recipientEmail': email, 'userName': _username ?? 'Unnamed', 'reviewLink': _reviewLink}}',
    );

    setState(() {
      _sendingIndex = index;
    });
    final fullImageUrl =
        _businessImageUrl != null && !_businessImageUrl!.startsWith('http')
        ? 'https://hdwfpfxyzubfksctezkz.supabase.co/storage/v1/object/public/userprofilepicture//$_businessImageUrl'
        : _businessImageUrl ?? 'https://example.com/default.jpg';
    try {
      final response = await supabase.functions.invoke(
        'swift-function',
        body: {
          'recipientEmail': email,
          'userName': _username ?? 'Unnamed',
          'reviewLink': _reviewLink,
          'imageUrl': fullImageUrl,
        },
      );

      if (response.status == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Review request sent to: $email')),
        );
      } else {
        debugPrint('Function error: ${response.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send review request.')),
        );
      }
    } catch (e) {
      debugPrint('Exception while sending email: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred sending the email.')),
      );
    } finally {
      setState(() {
        _sendingIndex = null;
      });
    }
  }

  String get _reviewLink {
    return _userId != null
        ? 'https://marketplace-vhbe.onrender.com/ask-reviews/services/$_userId/reviews'
        : '';
  }

  Future<void> _copyToClipboard() async {
    if (_reviewLink.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: _reviewLink));
    setState(() {
      _copied = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _copied = false;
    });
  }

  @override
  void dispose() {
    for (var controller in _emailControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildAppBar() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildEmailInputList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(_emailControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailControllers[index],
                    decoration: InputDecoration(
                      hintText: 'Enter customer email address',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 80,
                  child: CustomButton(
                    text: 'Send',
                    onPressed: () {
                      _handleSendEmail(_emailControllers[index].text, index);
                    },
                  ),
                ),
              ],
            ),
          );
        }),
        TextButton(
          onPressed: _addEmailField,
          child: Text(
            '+ Add another email address',
            style: TextStyle(color: AppColors.secondaryBlue),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleImportButton() {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: AppColors.neutral300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/google.png', width: 20, height: 20),
          const SizedBox(width: 8),
          const Text('Add reviews from Google'),
        ],
      ),
    );
  }

  Widget _buildShareableLink() {
    if (_userId == null) return const SizedBox.shrink();
    return Center(
      child: TextButton(
        onPressed: _copyToClipboard,
        child: Text(
          _copied ? 'Copied to clipboard' : 'Copy shareable link',
          style: TextStyle(color: AppColors.primaryBlue),
        ),
      ),
    );
  }

  Widget _buildBuildTrustCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        children: [
          Icon(Icons.star, color: AppColors.secondaryBlue, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Build Trust',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'More verified reviews help you earn more jobs.',
            style: TextStyle(color: AppColors.neutral500),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        children: [
          Text(
            'Email Preview',
            style: TextStyle(fontSize: 12, color: AppColors.neutral500),
          ),
          const SizedBox(height: 8),
          Text(
            _businessName,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
          ),
          Text(
            'Review Request',
            style: TextStyle(fontSize: 15, color: AppColors.neutral600),
          ),
          const SizedBox(height: 12),
          _buildUserAvatar(),
          const SizedBox(height: 12),
          _buildEmailContent(),
          const SizedBox(height: 12),
          _buildRatingStars(),
          const SizedBox(height: 12),
          _buildSubmitReviewButton(),
          const SizedBox(height: 8),
          Text(
            'Requested by: ${_username ?? ''}',
            style: TextStyle(fontSize: 12, color: AppColors.neutral400),
          ),
        ],
      ),
    );
  }

  Widget _buildUserAvatar() {
    return _businessImageUrl != null
        ? CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(_businessImageUrl!),
            backgroundColor: Colors.transparent,
          )
        : Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryBlue, width: 2),
              color: Colors.grey[100],
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
  }

  Widget _buildEmailContent() {
    return Column(
      children: [
        Text(
          'Thank you for being a valued client...',
          style: TextStyle(fontSize: 12, color: AppColors.neutral600),
        ),
        const SizedBox(height: 4),
        Text(
          'If you could take a moment to write a brief review...',
          style: TextStyle(fontSize: 12, color: AppColors.neutral600),
        ),
      ],
    );
  }

  Widget _buildRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        5,
        (index) => Icon(Icons.star, color: AppColors.warning),
      ),
    );
  }

  Widget _buildSubmitReviewButton() {
    return CustomButton(text: 'Submit Review', onPressed: () {});
  }

  Widget _buildBottomNavigationBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              side: BorderSide(color: AppColors.neutral300),
            ),
            child: const Text('Back'),
          ),
          const SizedBox(width: 16),
          CustomButton(
            text: 'Skip Now',
            onPressed: () {
              _isPending
                  ? null
                  : () {
                      Get.offAllNamed(Routes.jobs);
                    };
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primaryBlue,
            secondary: AppColors.secondaryBlue,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 768;
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildAppBar(),
                    const SizedBox(height: 20),
                    if (isMobile) ...[
                      _buildMobileLayout(),
                    ] else ...[
                      _buildDesktopLayout(),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add recent ratings for your business',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add reviews from customers your business had before you joined Thumbtack. '
          'This will help generate more jobs earlier on.',
          style: TextStyle(color: AppColors.neutral500),
        ),
        const SizedBox(height: 24),
        _buildBuildTrustCard(),
        const SizedBox(height: 24),
        _buildEmailInputList(),
        const SizedBox(height: 16),
        _buildGoogleImportButton(),
        if (_userId != null) ...[
          const SizedBox(height: 16),
          _buildShareableLink(),
        ],
        const SizedBox(height: 24),
        _buildEmailPreviewMobile(),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add recent ratings for your business',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlue900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add reviews from customers your business had before you joined Thumbtack. '
                    'This will help generate more jobs earlier on.',
                    style: TextStyle(color: AppColors.neutral500),
                  ),
                  const SizedBox(height: 20),
                  _buildEmailInputList(),
                  const SizedBox(height: 16),
                  _buildGoogleImportButton(),
                  _buildShareableLink(),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _buildBuildTrustCard(),
                  const SizedBox(height: 16),
                  _buildEmailPreview(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailPreviewMobile() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: AppColors.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Email Preview',
            style: TextStyle(fontSize: 12, color: AppColors.neutral500),
          ),
          const SizedBox(height: 8),
          Text(
            _businessName,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryBlue,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            'Review Request',
            style: TextStyle(fontSize: 14, color: AppColors.neutral600),
          ),
          const SizedBox(height: 12),
          SizedBox(width: 64, height: 64, child: _buildUserAvatar()),
          const SizedBox(height: 12),
          _buildEmailContent(),
          const SizedBox(height: 12),
          _buildRatingStars(),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: _buildSubmitReviewButton()),
          const SizedBox(height: 8),
          Text(
            'Requested by: ${_username ?? ''}',
            style: TextStyle(fontSize: 12, color: AppColors.neutral400),
          ),
        ],
      ),
    );
  }
}
