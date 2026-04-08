import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/settings_provider.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthService>();
    final db = context.read<DatabaseService>();
    final user = auth.currentUser;

    if (user == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGreen),
      );
    }

    final isFarmer = user.role == UserRole.farmer;
    final l10n = AppLocalizations.of(context)!;
    final settings = context.watch<SettingsProvider>();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Profile Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.surfaceGreen,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      isFarmer
                          ? LucideIcons.sprout
                          : LucideIcons.layoutDashboard,
                      size: 40,
                      color: AppTheme.primaryGreen,
                    ),
                  ).animate().scale(
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    user.name,
                    style: const TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fade().slideY(begin: 0.2),

                  const SizedBox(height: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceGreen,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isFarmer ? 'Verified Farmer' : 'Mandi Operator',
                      style: const TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ).animate().fade(delay: 100.ms).slideY(begin: 0.2),

                  const SizedBox(height: 16),
                  
                  // Edit Profile Button
                  ElevatedButton.icon(
                    onPressed: () => _showEditProfileDialog(context, user),
                    icon: const Icon(LucideIcons.edit2, size: 16),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).cardTheme.color ?? AppTheme.surfaceWhite,
                      foregroundColor: AppTheme.primaryGreen,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: AppTheme.primaryGreen.withValues(alpha: 0.5)),
                      ),
                    ),
                  ).animate().fade(delay: 120.ms).slideY(begin: 0.2),
                ],
              ),
            ),
          ),

          // Information Section
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Settings Section
                  Text(
                    l10n.settings,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color:
                          Theme.of(context).textTheme.titleLarge?.color ??
                          AppTheme.textDark,
                    ),
                  ).animate().fade(delay: 150.ms),
                  const SizedBox(height: 24),

                  Container(
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).cardTheme.color ??
                          AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color:
                            Theme.of(context).cardTheme.shape
                                is RoundedRectangleBorder
                            ? (Theme.of(context).cardTheme.shape
                                      as RoundedRectangleBorder)
                                  .side
                                  .color
                            : const Color(0xFFE2E8F0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildThemeToggle(context, settings, l10n),
                        _buildDivider(),
                        _buildLanguageSelector(context, settings, l10n),
                      ],
                    ),
                  ).animate().fade(delay: 180.ms).slideY(begin: 0.1),

                  const SizedBox(height: 32),

                  Text(
                    l10n.accountInformation,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ).animate().fade(delay: 200.ms),
                  const SizedBox(height: 24),

                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          context,
                          LucideIcons.phone,
                          l10n.phoneNumber,
                          user.phone,
                          isTop: true,
                        ),
                        _buildDivider(),
                        if (isFarmer) ...[
                          _buildInfoRow(
                            context,
                            LucideIcons.mapPin,
                            l10n.villageLocation,
                            user.village ?? 'Not provided',
                          ),
                          _buildDivider(),
                          _buildInfoRow(
                            context,
                            LucideIcons.wheat,
                            l10n.primaryCrop,
                            user.preferredCrop ?? 'Not provided',
                            isBottom: true,
                          ),
                        ] else ...[
                          _buildInfoRow(
                            context,
                            LucideIcons.hash,
                            'Assigned Mandi ID',
                            user.mandiId ?? 'Not assigned',
                          ),
                          _buildDivider(),
                          Builder(
                            builder: (context) {
                              final mandi = db.getMandi(user.mandiId ?? '');
                              return _buildInfoRow(
                                context,
                                LucideIcons.store,
                                l10n.mandiName,
                                mandi.name,
                                isBottom: true,
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ).animate().fade(delay: 300.ms).slideY(begin: 0.1),

                  const SizedBox(height: 48),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => auth.logout(),
                      icon: const Icon(LucideIcons.logOut, size: 20),
                      label: Text(l10n.signOut),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEF2F2),
                        foregroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                            color: Color(0xFFFECACA),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ).animate().fade(delay: 400.ms),

                  const SizedBox(height: 100), // padding for custom nav bar
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String title,
    String value, {
    bool isTop = false,
    bool isBottom = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.textMuted, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF1F5F9),
      indent: 64,
    );
  }

  Widget _buildThemeToggle(
    BuildContext context,
    SettingsProvider settings,
    AppLocalizations l10n,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          settings.isDarkMode ? LucideIcons.moon : LucideIcons.sun,
          color: AppTheme.textMuted,
          size: 18,
        ),
      ),
      title: Text(
        l10n.theme,
        style: TextStyle(
          color:
              Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textDark,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Switch(
        value: settings.isDarkMode,
        onChanged: (val) => settings.toggleTheme(),
        activeColor: AppTheme.primaryGreen,
      ),
    );
  }

  Widget _buildLanguageSelector(
    BuildContext context,
    SettingsProvider settings,
    AppLocalizations l10n,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          LucideIcons.languages,
          color: AppTheme.textMuted,
          size: 18,
        ),
      ),
      title: Text(
        l10n.language,
        style: TextStyle(
          color:
              Theme.of(context).textTheme.bodyLarge?.color ?? AppTheme.textDark,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: DropdownButton<String>(
        value: settings.locale.languageCode,
        underline: const SizedBox(),
        dropdownColor: Theme.of(context).cardTheme.color,
        icon: const Icon(LucideIcons.chevronDown, size: 16),
        items: [
          DropdownMenuItem(
            value: 'en',
            child: Text(
              l10n.english,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          DropdownMenuItem(
            value: 'hi',
            child: Text(
              l10n.hindi,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          DropdownMenuItem(
            value: 'ta',
            child: Text(
              l10n.tamil,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
        onChanged: (String? newValue) {
        },
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, UserModel user) {
    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phone);
    final villageCtrl = TextEditingController(text: user.village ?? '');
    final cropCtrl = TextEditingController(text: user.preferredCrop ?? '');
    final isFarmer = user.role == UserRole.farmer;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color ?? AppTheme.textDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(LucideIcons.user)),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(LucideIcons.phone)),
                  keyboardType: TextInputType.phone,
                ),
                if (isFarmer) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: villageCtrl,
                    decoration: const InputDecoration(labelText: 'Village', prefixIcon: Icon(LucideIcons.mapPin)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: cropCtrl,
                    decoration: const InputDecoration(labelText: 'Preferred Crop', prefixIcon: Icon(LucideIcons.leaf)),
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty || phoneCtrl.text.isEmpty) return;
                    
                    await context.read<AuthService>().updateUserProfile(
                      name: nameCtrl.text.trim(),
                      phone: phoneCtrl.text.trim(),
                      village: isFarmer ? villageCtrl.text.trim() : null,
                      preferredCrop: isFarmer ? cropCtrl.text.trim() : null,
                    );
                    
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('Save Changes'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}
