import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../models/performance_data.dart';
import '../services/firebase_service.dart';
import '../services/wearable_service.dart';
import '../utils/constants.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_chart.dart';
import '../widgets/navigation_drawer.dart';
import '../widgets/loading_indicator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Stream<UserModel> _userStream;
  late Stream<List<PerformanceData>> _performanceStream;

  @override
  void initState() {
    super.initState();
    final firebaseService = Provider.of<FirebaseService>(context, listen: false);
    final userId = Provider.of<UserModel>(context, listen: false).id;
    
    _userStream = firebaseService.getUserStream(userId);
    _performanceStream = firebaseService.getPerformanceStream(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Dashboard'),
      drawer: const NavigationDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          // TODO: Implement refresh logic
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<UserModel>(
                stream: _userStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: LoadingIndicator());
                  }

                  final user = snapshot.data!;
                  return _buildUserOverview(user);
                },
              ),
              const SizedBox(height: 24.0),
              Text(
                'Performance Metrics',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 16.0),
              StreamBuilder<List<PerformanceData>>(
                stream: _performanceStream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: LoadingIndicator());
                  }

                  return _buildPerformanceMetrics(snapshot.data!);
                },
              ),
              const SizedBox(height: 24.0),
              _buildQuickActions(),
              const SizedBox(height: 24.0),
              _buildUpcomingEvents(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement quick action
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildUserOverview(UserModel user) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: user.profilePictureUrl.isNotEmpty
                    ? NetworkImage(user.profilePictureUrl)
                    : null,
                child: user.profilePictureUrl.isEmpty
                    ? Text(user.name[0], style: const TextStyle(fontSize: 24))
                    : null,
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                    Text(
                      '${user.sport} • ${user.age} years',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Wrap(
            spacing: 16.0,
            runSpacing: 8.0,
            children: [
              _buildStatChip(
                icon: Icons.timer,
                label: 'Training Hours',
                value: '24',
              ),
              _buildStatChip(
                icon: Icons.trending_up,
                label: 'Progress',
                value: '85%',
              ),
              _buildStatChip(
                icon: Icons.star,
                label: 'Goals Met',
                value: '8/10',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics(List<PerformanceData> performanceData) {
    if (performanceData.isEmpty) {
      return const Center(
        child: Text('No performance data available'),
      );
    }

    return Column(
      children: [
        CustomCard(
          child: SizedBox(
            height: 200,
            child: CustomChart(
              data: performanceData,
              metricKey: PerformanceData.HEART_RATE,
              title: 'Heart Rate Over Time',
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        CustomCard(
          child: SizedBox(
            height: 200,
            child: CustomChart(
              data: performanceData,
              metricKey: PerformanceData.SPEED,
              title: 'Speed Analysis',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 16.0),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16.0,
          crossAxisSpacing: 16.0,
          children: [
            _buildActionCard(
              icon: Icons.fitness_center,
              title: 'Start Training',
              onTap: () {
                // TODO: Implement training start
              },
            ),
            _buildActionCard(
              icon: Icons.medical_services,
              title: 'Log Injury',
              onTap: () {
                // TODO: Implement injury logging
              },
            ),
            _buildActionCard(
              icon: Icons.timeline,
              title: 'View Progress',
              onTap: () {
                // TODO: Implement progress view
              },
            ),
            _buildActionCard(
              icon: Icons.school,
              title: 'Career Goals',
              onTap: () {
                // TODO: Implement career goals
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 32,
            color: AppColors.primary,
          ),
          const SizedBox(height: 8.0),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upcoming Events',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 16.0),
        CustomCard(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.event, color: Colors.white),
                ),
                title: Text('Training Session ${index + 1}'),
                subtitle: Text('Tomorrow at ${9 + index}:00 AM'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Implement event details
                },
              );
            },
          ),
        ),
      ],
    );
  }
}