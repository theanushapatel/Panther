import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';
import '../services/service_locator.dart';

class NavigationItem {
  final String title;
  final IconData icon;
  final String route;
  final bool requiresAuth;

  const NavigationItem({
    required this.title,
    required this.icon,
    required this.route,
    this.requiresAuth = true,
  });
}

class CustomNavigationDrawer extends StatelessWidget {
  final String? currentRoute;
  final String? userName;
  final String? userEmail;
  final String? userPhotoUrl;
  final VoidCallback? onProfileTap;

  final List<NavigationItem> navigationItems = const [
    NavigationItem(
      title: 'Dashboard',
      icon: Icons.dashboard,
      route: '/dashboard',
    ),
    NavigationItem(
      title: 'Performance',
      icon: Icons.trending_up,
      route: '/performance',
    ),
    NavigationItem(
      title: 'Injuries',
      icon: Icons.healing,
      route: '/injuries',
    ),
    NavigationItem(
      title: 'Career',
      icon: Icons.work,
      route: '/career',
    ),
    NavigationItem(
      title: 'Financial',
      icon: Icons.account_balance_wallet,
      route: '/financial',
    ),
    NavigationItem(
      title: 'Settings',
      icon: Icons.settings,
      route: '/settings',
    ),
  ];

  CustomNavigationDrawer({
    Key? key,
    this.currentRoute,
    this.userName,
    this.userEmail,
    this.userPhotoUrl,
    this.onProfileTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ...navigationItems.map((item) => _buildNavigationItem(context, item)),
                const Divider(),
                _buildLogoutButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return UserAccountsDrawerHeader(
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      currentAccountPicture: GestureDetector(
        onTap: onProfileTap,
        child: CircleAvatar(
          backgroundColor: AppColors.secondary,
          backgroundImage: userPhotoUrl != null
              ? NetworkImage(userPhotoUrl!) as ImageProvider
              : const AssetImage('assets/images/default_avatar.png'),
          child: userPhotoUrl == null
              ? const Icon(
                  Icons.person,
                  size: 40,
                  color: Colors.white,
                )
              : null,
        ),
      ),
      accountName: Text(
        userName ?? 'Guest User',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      accountEmail: Text(
        userEmail ?? '',
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildNavigationItem(BuildContext context, NavigationItem item) {
    final isSelected = currentRoute == item.route;

    return ListTile(
      leading: Icon(
        item.icon,
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        item.title,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primary.withOpacity(0.1),
      onTap: () {
        Navigator.pop(context); // Close drawer
        if (currentRoute != item.route) {
          Navigator.pushNamed(context, item.route);
        }
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ListTile(
      leading: const Icon(
        Icons.exit_to_app,
        color: AppColors.error,
      ),
      title: const Text(
        'Logout',
        style: TextStyle(
          color: AppColors.error,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Logout',
                  style: TextStyle(color: AppColors.error),
                ),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          final authService = context.authService;
          await authService.signOut();
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      },
    );
  }
}

// Mini drawer for tablets and larger screens
class MiniNavigationDrawer extends StatelessWidget {
  final String? currentRoute;
  final List<NavigationItem> navigationItems;

  const MiniNavigationDrawer({
    Key? key,
    this.currentRoute,
    required this.navigationItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Drawer(
        child: Column(
          children: [
            const SizedBox(height: 48),
            Expanded(
              child: ListView(
                children: navigationItems.map((item) => _buildMiniNavigationItem(
                  context,
                  item,
                  currentRoute == item.route,
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniNavigationItem(
    BuildContext context,
    NavigationItem item,
    bool isSelected,
  ) {
    return Tooltip(
      message: item.title,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 4,
            ),
          ),
          color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
        ),
        child: InkWell(
          onTap: () {
            if (currentRoute != item.route) {
              Navigator.pushNamed(context, item.route);
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}