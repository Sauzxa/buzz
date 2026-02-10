import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../theme/colors.dart';
import '../../Widgets/custom_bottom_nav_bar.dart';
import '../../routes/route_names.dart';

import 'user_settings_page.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/language_provider.dart';

class GeneralSettingsPage extends StatefulWidget {
  const GeneralSettingsPage({super.key});

  @override
  State<GeneralSettingsPage> createState() => _GeneralSettingsPageState();
}

class _GeneralSettingsPageState extends State<GeneralSettingsPage> {
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
      // Already on settings, do nothing
    } else if (index == 4) {
      Navigator.pushReplacementNamed(context, RouteNames.chat);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.roseColor,
      body: Stack(
        children: [
          Column(
            children: [
              // Pink Header
              SafeArea(
                bottom: false,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          RouteNames.home,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.settings, color: Colors.white, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(
                              context,
                            )?.translate('settings_title') ??
                            'Settings',
                        style: GoogleFonts.dmSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // White Content Body
              Expanded(
                child: Container(
                  width: double.infinity,
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
                      padding: const EdgeInsets.only(bottom: 100, top: 20),
                      children: [
                        // GENERAL Section
                        _buildSectionHeader(
                          AppLocalizations.of(
                                context,
                              )?.translate('settings_general_title') ??
                              'GENERAL',
                        ),
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          title:
                              AppLocalizations.of(
                                context,
                              )?.translate('settings_account') ??
                              'Account',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SettingsPage(),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.notifications_outlined,
                          title:
                              AppLocalizations.of(
                                context,
                              )?.translate('settings_notifications') ??
                              'Notifications',
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              RouteNames.notificationsBuzz,
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.local_offer_outlined,
                          title:
                              AppLocalizations.of(
                                context,
                              )?.translate('settings_coupons') ??
                              'Coupons',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                        context,
                                      )?.translate('settings_coupons_soon') ??
                                      'Coupons page coming soon!',
                                ),
                              ),
                            );
                          },
                        ),

                        _buildMenuItem(
                          icon: Icons.language,
                          title:
                              AppLocalizations.of(
                                context,
                              )?.translate('language_label') ??
                              'Language',
                          onTap: () {
                            _showLanguageDialog(context);
                          },
                        ),

                        const SizedBox(height: 20),

                        // FEEDBACK Section
                        _buildSectionHeader(
                          AppLocalizations.of(
                                context,
                              )?.translate('settings_feedback_title') ??
                              'FEEDBACK',
                        ),
                        _buildMenuItem(
                          icon: Icons.bug_report_outlined,
                          title:
                              AppLocalizations.of(
                                context,
                              )?.translate('settings_report_bug') ??
                              'Report a bug',
                          onTap: () {
                            Navigator.pushNamed(context, RouteNames.bugReport);
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.feedback_outlined,
                          title:
                              AppLocalizations.of(
                                context,
                              )?.translate('settings_send_feedback') ??
                              'Send Feedback',
                          onTap: () {
                            Navigator.pushNamed(context, RouteNames.feedback);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Floating Bottom Nav Bar - Hide when keyboard is visible
          if (MediaQuery.of(context).viewInsets.bottom == 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CustomBottomNavBar(
                currentIndex: 0,
                onTap: _onBottomNavTapped,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Text(
        title,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodySmall!.color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Theme.of(context).iconTheme.color, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).textTheme.titleLarge!.color,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Theme.of(context).textTheme.bodySmall!.color,
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final languageProvider = Provider.of<LanguageProvider>(
          context,
          listen: false,
        );
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            AppLocalizations.of(context)?.translate('select_language') ??
                'Select Language',
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption(
                context,
                title:
                    AppLocalizations.of(context)?.translate('english') ??
                    'English',
                value: const Locale('en'),
                groupValue: languageProvider.appLocale,
                onChanged: (Locale? value) {
                  if (value != null) {
                    languageProvider.changeLanguage(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
              _buildLanguageOption(
                context,
                title:
                    AppLocalizations.of(context)?.translate('french') ??
                    'French',
                value: const Locale('fr'),
                groupValue: languageProvider.appLocale,
                onChanged: (Locale? value) {
                  if (value != null) {
                    languageProvider.changeLanguage(value);
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String title,
    required Locale value,
    required Locale groupValue,
    required ValueChanged<Locale?> onChanged,
  }) {
    return RadioListTile<Locale>(
      title: Text(
        title,
        style: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      activeColor: AppColors.roseColor,
      contentPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}
