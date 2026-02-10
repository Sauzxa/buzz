import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../Widgets/notification_popup.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'change_pass_settings.dart';
import 'package:provider/provider.dart';
import '../../../theme/colors.dart';
import '../../../Widgets/custom_bottom_nav_bar.dart';
import '../../../Widgets/button.dart';
import '../../../providers/user_provider.dart';
import '../../../routes/route_names.dart';
import '../../../l10n/app_localizations.dart';

class EditProfileSettings extends StatefulWidget {
  const EditProfileSettings({Key? key}) : super(key: key);

  @override
  State<EditProfileSettings> createState() => _EditProfileSettingsState();
}

class _EditProfileSettingsState extends State<EditProfileSettings> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _zipCodeController;
  // State is usually a dropdown, but using controller for now based on Figma
  // Figma shows dropdown, we will implement as read-only field with dropdown icon for visual match
  // State/Wilaya list
  final List<String> _wilayas = [
    'Algiers',
    'Oran',
    'Constantine',
    'Annaba',
    'Blida',
    'Batna',
    'Setif',
    'Sidi Bel Abbes',
    'Biskra',
    'Tlemcen',
    'Bejaia',
    'Skikda',
    'Tiaret',
    'Chlef',
    'Mila',
    'Medea',
    'Mostaganem',
    'Tizi Ouzou',
  ];
  String _selectedState = 'Algiers';

  // Country/Flag Selection (for display only, no dropdown)
  String _selectedCountry = 'Algeria (+213)';
  String _countryCode = '+213';

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user;

    _fullNameController = TextEditingController(text: user.fullName);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phoneNumber);
    _addressController = TextEditingController(text: user.currentAddress);
    _zipCodeController = TextEditingController(
      text: user.postalCode?.toString() ?? '',
    );

    if (user.wilaya != null && user.wilaya!.isNotEmpty) {
      // Ensure the user's wilaya exists in the list to avoid Dropdown assertion error
      // If the backend returns "alger" (lowercase) or any value not in our list,
      // we simply add it to the list so the dropdown works and preserves data.
      if (!_wilayas.contains(user.wilaya)) {
        _wilayas.add(user.wilaya!);
      }
      _selectedState = user.wilaya!;
    }

    // Refresh user data to ensure it's up-to-date
    if (user.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        userProvider.fetchUserById(user.id!).then((_) {
          // Update controllers with fresh data
          if (mounted) {
            setState(() {
              _fullNameController.text = userProvider.user.fullName ?? '';
              _emailController.text = userProvider.user.email ?? '';
              _phoneController.text = userProvider.user.phoneNumber ?? '';
              _addressController.text = userProvider.user.currentAddress ?? '';
              _zipCodeController.text =
                  userProvider.user.postalCode?.toString() ?? '';
              if (userProvider.user.wilaya != null &&
                  userProvider.user.wilaya!.isNotEmpty) {
                if (!_wilayas.contains(userProvider.user.wilaya)) {
                  _wilayas.add(userProvider.user.wilaya!);
                }
                _selectedState = userProvider.user.wilaya!;
              }
            });
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _zipCodeController.dispose();
    super.dispose();
  }

  void _showNotificationBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const NotificationBottomSheet(),
    );
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)?.translate('change_profile_pic') ??
                  'Change Profile Picture',
              style: GoogleFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.roseColor),
              title: Text(
                AppLocalizations.of(context)?.translate('take_photo') ??
                    'Take a photo',
                style: GoogleFonts.dmSans(),
              ),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) {
                  File file = File(image.path);
                  int originalSize = await file.length();
                  print(
                    'Camera - Original Size: ${(originalSize / 1024 / 1024).toStringAsFixed(2)} MB',
                  );

                  try {
                    final compressedFile =
                        await FlutterImageCompress.compressAndGetFile(
                          file.absolute.path,
                          '${file.parent.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg',
                          minWidth: 800,
                          minHeight: 800,
                          quality: 60,
                        );

                    if (compressedFile != null) {
                      int compressedSize = await compressedFile.length();
                      print(
                        'Camera - Compressed Size: ${(compressedSize / 1024 / 1024).toStringAsFixed(2)} MB',
                      );
                      setState(
                        () => _selectedImage = File(compressedFile.path),
                      );
                    } else {
                      print('Camera - Compression failed, using original.');
                      setState(() => _selectedImage = file);
                    }
                  } catch (e) {
                    print('Camera - Compression Error: $e');
                    setState(() => _selectedImage = file);
                  }
                }
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppColors.roseColor,
              ),
              title: Text(
                AppLocalizations.of(context)?.translate('choose_gallery') ??
                    'Choose from gallery',
                style: GoogleFonts.dmSans(),
              ),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  File file = File(image.path);
                  int originalSize = await file.length();
                  print(
                    'Gallery - Original Size: ${(originalSize / 1024 / 1024).toStringAsFixed(2)} MB',
                  );

                  try {
                    final compressedFile =
                        await FlutterImageCompress.compressAndGetFile(
                          file.absolute.path,
                          '${file.parent.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg',
                          minWidth: 800,
                          minHeight: 800,
                          quality: 60,
                        );

                    if (compressedFile != null) {
                      int compressedSize = await compressedFile.length();
                      print(
                        'Gallery - Compressed Size: ${(compressedSize / 1024 / 1024).toStringAsFixed(2)} MB',
                      );
                      setState(
                        () => _selectedImage = File(compressedFile.path),
                      );
                    } else {
                      print('Gallery - Compression failed, using original.');
                      setState(() => _selectedImage = file);
                    }
                  } catch (e) {
                    print('Gallery - Compression Error: $e');
                    setState(() => _selectedImage = file);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onBottomNavTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacementNamed(context, RouteNames.home);
    } else if (index == 1) {
      // Search - Navigate to home
      Navigator.pushReplacementNamed(context, RouteNames.home);
    } else if (index == 2) {
      // Order Management
      Navigator.pushNamed(context, RouteNames.orderManagement);
    } else if (index == 3) {
      // Already on profile/settings
    } else if (index == 4) {
      Navigator.pushNamed(context, RouteNames.chat);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = context.read<UserProvider>();

      // Note: Backend does NOT support email updates via PUT /api/users/{id}
      // UserUpdateDto only accepts: fullName, phoneNumber, currentAddress, postalCode, wilaya, profilePicture
      // Email changes would require a separate endpoint (not currently available)
      final Map<String, dynamic> data = {
        'fullName': _fullNameController.text,
        // 'email': _emailController.text, // NOT SUPPORTED - Backend doesn't accept email updates
        'phoneNumber': _phoneController.text, // Backend handles cleaning
        'currentAddress': _addressController.text,
        'postalCode': _zipCodeController
            .text, // Backend expects string/int? Provider handles parse
        'wilaya': _selectedState,
      };

      final success = await userProvider.updateUserProfile(
        data: data,
        imageFile: _selectedImage,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                    context,
                  )?.translate('profile_updated_success') ??
                  'Profile updated successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Navigator.pop(context); // Stay on page as requested
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              userProvider.errorMessage ??
                  AppLocalizations.of(context)?.translate('update_failed') ??
                  'Update failed',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)?.translate('error_label') ?? 'Error'}: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.roseColor,
      body: Stack(
        children: [
          // Header Content (Pink Area)
          SafeArea(
            bottom: false,
            child: Container(
              height: 120, // Height for the top bar
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      AppLocalizations.of(
                            context,
                          )?.translate('settings_edit_profile') ??
                          'Edit Profile',
                      style: GoogleFonts.dmSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Notification icon with red dot as per design
                  IconButton(
                    icon: Stack(
                      children: [
                        const Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 28,
                        ),
                        Positioned(
                          right: 2,
                          top: 2,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.amber, // Orange/Yellow dot
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: _showNotificationBottomSheet,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ),

          // White Content Card with Overlapping Image
          Padding(
            padding: const EdgeInsets.only(
              top: 100,
            ), // Push down to start white area
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                  children: [
                    const SizedBox(
                      height: 30,
                    ), // Space for the overlapping image
                    // Profile Image Picker
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  25,
                                ), // Squircle shape
                                image: DecorationImage(
                                  image: _selectedImage != null
                                      ? FileImage(_selectedImage!)
                                      : (context
                                                            .read<
                                                              UserProvider
                                                            >()
                                                            .user
                                                            .profilePicture !=
                                                        null &&
                                                    context
                                                        .read<UserProvider>()
                                                        .user
                                                        .profilePicture!
                                                        .isNotEmpty
                                                ? NetworkImage(
                                                    context
                                                        .read<UserProvider>()
                                                        .user
                                                        .profilePicture!,
                                                  )
                                                : const AssetImage(
                                                    'assets/home/welcome.png',
                                                  ))
                                            as ImageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            // Dark overlay
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Form Fields
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabeledField(
                            label:
                                AppLocalizations.of(
                                  context,
                                )?.translate('fullname_label') ??
                                'Full Name',
                            controller: _fullNameController,
                            hint: 'Oussama Aba',
                          ),
                          const SizedBox(height: 20),

                          _buildLabeledField(
                            label:
                                AppLocalizations.of(
                                  context,
                                )?.translate('email_label') ??
                                'Email Address',
                            controller: _emailController,
                            hint: 'oussama.aba@email.com',
                            keyboardType: TextInputType.emailAddress,
                            readOnly:
                                true, // Email cannot be changed - backend doesn't support it
                          ),
                          const SizedBox(height: 20),

                          // Phone Number (Special Layout)
                          _buildPhoneField(),
                          const SizedBox(height: 20),

                          _buildLabeledField(
                            label:
                                AppLocalizations.of(
                                  context,
                                )?.translate('current_address_label') ??
                                'Current Address',
                            controller: _addressController,
                            hint: '0558 Alger centre, Alger',
                          ),
                          const SizedBox(height: 20),

                          // Zip Row
                          Row(
                            children: [
                              Expanded(
                                flex: 4,
                                child: _buildLabeledField(
                                  label:
                                      AppLocalizations.of(
                                        context,
                                      )?.translate('postal_code_label') ??
                                      'Zip Code',
                                  controller: _zipCodeController,
                                  hint: '16016',
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 6,
                                child: _buildDropdownField(
                                  label:
                                      AppLocalizations.of(
                                        context,
                                      )?.translate('wilaya_label') ??
                                      'State',
                                  value: _selectedState,
                                  items: _wilayas, // Use our dynamic list
                                  onChanged: (val) =>
                                      setState(() => _selectedState = val!),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Password (Read only / Change button)
                          _buildLabeledField(
                            label:
                                AppLocalizations.of(
                                  context,
                                )?.translate('password_label') ??
                                'Password',
                            controller: TextEditingController(text: '••••••'),
                            readOnly: true,
                          ),

                          const SizedBox(height: 24),

                          // Change Password Button
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).dividerColor,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ChangePassSettings(),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        AppLocalizations.of(
                                              context,
                                            )?.translate('change_pass_title') ??
                                            'Change Password',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(
                                            context,
                                          ).textTheme.titleLarge!.color,
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Theme.of(
                                          context,
                                        ).iconTheme.color,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Save Button
                          PrimaryButton(
                            text:
                                AppLocalizations.of(
                                  context,
                                )?.translate('save_changes_btn') ??
                                'Save Changes',
                            onPressed: _saveChanges,
                            isLoading: _isLoading,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Floating Bottom Nav Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomBottomNavBar(
              currentIndex: 3, // Settings index
              onTap: _onBottomNavTapped,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabeledField({
    required String label,
    required TextEditingController controller,
    String? hint,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Using a container to mimic the floating label look perfectly or just standard input?
        // Figma shows label OUTSIDE/ON BORDER. Let's use standard InputDecoration with always label.
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: readOnly
                ? Theme.of(context).textTheme.bodySmall!.color
                : Theme.of(context).textTheme.titleLarge!.color,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.dmSans(
              color: Theme.of(context).textTheme.bodySmall!.color,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: hint,
            hintStyle: GoogleFonts.dmSans(
              color: Theme.of(context).textTheme.bodySmall!.color,
            ),
            filled: readOnly,
            fillColor: readOnly
                ? Theme.of(context).cardColor
                : Theme.of(context).scaffoldBackgroundColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.roseColor),
            ),
          ),
          validator: (value) {
            if (label == 'Full Name' && (value == null || value.isEmpty)) {
              return AppLocalizations.of(
                    context,
                  )?.translate('please_enter_name') ??
                  'Please enter your name';
            }
            if (label == 'Email Address' &&
                (value == null || !value.contains('@'))) {
              return AppLocalizations.of(
                    context,
                  )?.translate('please_enter_valid_email') ??
                  'Please enter a valid email';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.titleLarge!.color,
          ),
          decoration: InputDecoration(
            labelText:
                AppLocalizations.of(context)?.translate('phone_number_hint') ??
                'Phone Number',
            labelStyle: GoogleFonts.dmSans(
              color: Theme.of(context).textTheme.bodySmall!.color,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16, right: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Flag emoji
                  Text(
                    _getCountryFlag(_selectedCountry),
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 8),
                  // Country code
                  Text(
                    _countryCode,
                    style: GoogleFonts.dmSans(
                      color: Theme.of(context).textTheme.titleLarge!.color,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            suffixIcon: Icon(
              Icons.check,
              color: Theme.of(context).iconTheme.color,
              size: 18,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.roseColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      style: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).textTheme.titleLarge!.color,
      ),
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: Theme.of(context).iconTheme.color,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.dmSans(
          color: Theme.of(context).textTheme.bodySmall!.color,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.roseColor),
        ),
      ),
    );
  }

  String _getCountryFlag(String country) {
    if (country.contains('Algeria')) return '🇩🇿';
    if (country.contains('France')) return '🇫🇷';
    if (country.contains('Morocco')) return '🇲🇦';
    if (country.contains('Tunisia')) return '🇹🇳';
    if (country.contains('USA')) return '🇺🇸';
    return '🌍';
  }
}
