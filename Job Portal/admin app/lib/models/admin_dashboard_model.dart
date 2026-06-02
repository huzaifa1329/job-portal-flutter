class DashboardStats {
  final int totalUsers;
  final int totalEmployers;
  final int totalJobs;
  final int totalApplications;
  final int pendingJobs;
  final int recentActivities;

  DashboardStats({
    required this.totalUsers,
    required this.totalEmployers,
    required this.totalJobs,
    required this.totalApplications,
    required this.pendingJobs,
    required this.recentActivities,
  });
}

class ChartData {
  final String month;
  final int jobs;
  final int applications;

  ChartData({
    required this.month,
    required this.jobs,
    required this.applications,
  });
}