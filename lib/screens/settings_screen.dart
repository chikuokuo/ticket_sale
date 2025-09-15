import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: AppColorScheme.neutral50,
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTheme.headlineSmall.copyWith(
          color: AppColorScheme.neutral900,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader(l10n.preferences),
            const SizedBox(height: 16),
            _buildLanguageSection(context, ref, l10n, currentLocale),
            const SizedBox(height: 32),
            _buildSectionHeader(l10n.about),
            const SizedBox(height: 16),
            _buildAboutSection(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: AppColorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTheme.headlineSmall.copyWith(
            color: AppColorScheme.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSection(BuildContext context, WidgetRef ref, AppLocalizations l10n, Locale? currentLocale) {
    final languages = [
      {'code': 'en', 'name': 'English', 'nativeName': 'English'},
      {'code': 'ko', 'name': 'Korean', 'nativeName': '한국어'},
      {'code': 'fr', 'name': 'French', 'nativeName': 'Français'},
      {'code': 'de', 'name': 'German', 'nativeName': 'Deutsch'},
      {'code': 'ja', 'name': 'Japanese', 'nativeName': '日本語'},
      {'code': 'vi', 'name': 'Vietnamese', 'nativeName': 'Tiếng Việt'},
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.language,
                  color: AppColorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.selectLanguage,
                  style: AppTheme.titleMedium.copyWith(
                    color: AppColorScheme.neutral900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...languages.map((language) {
              final isSelected = currentLocale?.languageCode == language['code'];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    ref.read(languageProvider.notifier).changeLanguage(language['code']!);
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? AppColorScheme.primary.withValues(alpha: 0.1) 
                        : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected 
                        ? Border.all(color: AppColorScheme.primary, width: 1)
                        : null,
                    ),
                    child: Row(
                      children: [
                        Text(
                          language['nativeName']!,
                          style: AppTheme.bodyLarge.copyWith(
                            color: isSelected 
                              ? AppColorScheme.primary 
                              : AppColorScheme.neutral900,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${language['name']})',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppColorScheme.neutral600,
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: AppColorScheme.primary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context, AppLocalizations l10n) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.info_outline,
              color: AppColorScheme.primary,
            ),
            title: Text(
              l10n.aboutApp,
              style: AppTheme.titleMedium.copyWith(
                color: AppColorScheme.neutral900,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: AppColorScheme.neutral400,
              size: 16,
            ),
            onTap: () {
              _showAboutDialog(context, l10n);
            },
          ),
          Divider(
            color: AppColorScheme.neutral200,
            height: 1,
            indent: 56,
          ),
          ListTile(
            leading: Icon(
              Icons.star_outline,
              color: AppColorScheme.primary,
            ),
            title: Text(
              l10n.rateApp,
              style: AppTheme.titleMedium.copyWith(
                color: AppColorScheme.neutral900,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: AppColorScheme.neutral400,
              size: 16,
            ),
            onTap: () {
              // TODO: Implement rate app functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.thankYouForRating),
                  backgroundColor: AppColorScheme.primary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.aboutApp,
          style: AppTheme.titleLarge.copyWith(
            color: AppColorScheme.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.appTitle,
              style: AppTheme.titleMedium.copyWith(
                color: AppColorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version 1.0.0',
              style: AppTheme.bodyMedium.copyWith(
                color: AppColorScheme.neutral600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.appDescription,
              style: AppTheme.bodyMedium.copyWith(
                color: AppColorScheme.neutral700,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.ok,
              style: AppTheme.labelLarge.copyWith(
                color: AppColorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
