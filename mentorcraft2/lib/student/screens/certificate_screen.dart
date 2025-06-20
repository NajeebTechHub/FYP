import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import '../models/certificate.dart';
import 'package:mentorcraft2/theme/color.dart';
import 'certificate_preview_screen.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({Key? key}) : super(key: key);

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen> with SingleTickerProviderStateMixin {
  late List<Certificate> _certificates;
  late List<Certificate> _filteredCertificates;
  bool _isLoading = true;
  String _searchQuery = '';
  bool _isGridView = true;
  late AnimationController _animationController;

  // For filtering
  String? _selectedCategory;
  final List<String> _viewModes = ['Grid', 'List'];
  String _selectedViewMode = 'Grid';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadCertificates();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCertificates() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Load sample data
    _certificates = Certificate.getSampleCertificates();
    _filteredCertificates = List.from(_certificates);

    setState(() {
      _isLoading = false;
    });

    _animationController.forward();
  }

  void _filterCertificates() {
    setState(() {
      _filteredCertificates = _certificates.where((certificate) {
        // Filter by search query
        final matchesSearch = certificate.courseName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            certificate.instructor.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            certificate.id.toLowerCase().contains(_searchQuery.toLowerCase());

        // Filter by category
        final matchesCategory = _selectedCategory == null || certificate.category == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  List<String> _getUniqueCategories() {
    final categories = _certificates.map((cert) => cert.category).toSet().toList();
    categories.sort();
    return categories;
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
      _selectedViewMode = _isGridView ? 'Grid' : 'List';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Certificates',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.darkBlue,
        elevation: 0,
        actions: [
          // View toggle
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            tooltip: 'Toggle View',
            onPressed: _toggleViewMode,
          ),
          // Export all
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download All',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Downloading all certificates...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading ? _buildLoadingView() : _buildContent(),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        _buildFilterSection(),
        _buildAchievementSummary(),
        Expanded(
          child: _filteredCertificates.isEmpty
              ? _buildEmptyState()
              : _isGridView
              ? _buildGridView()
              : _buildListView(),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Search certificates...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (value) {
              _searchQuery = value;
              _filterCertificates();
            },
          ),
          const SizedBox(height: 12),

          // Category filter
          Row(
            children: [
              const Text(
                'Category:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: _selectedCategory,
                      isExpanded: true,
                      hint: const Text('All Categories'),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('All Categories'),
                        ),
                        ..._getUniqueCategories().map((category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                        _filterCertificates();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementSummary() {
    final certificateCount = _certificates.length;
    final totalHours = _certificates.fold<int>(
        0, (prev, cert) => prev + cert.courseDurationHours);
    final averageRating = _certificates.isEmpty
        ? 0.0
        : _certificates.fold<double>(
        0, (prev, cert) => prev + cert.courseRating) / _certificates.length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.darkBlue,
            AppColors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBlue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Achievements',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAchievementStat(
                '$certificateCount',
                'Certificates',
                Icons.workspace_premium,
              ),
              _buildAchievementStat(
                '$totalHours',
                'Learning Hours',
                Icons.timer,
              ),
              _buildAchievementStat(
                averageRating.toStringAsFixed(1),
                'Avg. Rating',
                Icons.star,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.60,
      ),
      itemCount: _filteredCertificates.length,
      itemBuilder: (context, index) {
        final certificate = _filteredCertificates[index];

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final delayedAnimation = CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                math.min(1.0, index * 0.1),
                math.min(1.0, index * 0.1 + 0.4),
                curve: Curves.easeOut,
              ),
            );

            return FadeTransition(
              opacity: delayedAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.2),
                  end: Offset.zero,
                ).animate(delayedAnimation),
                child: child,
              ),
            );
          },
          child: _buildCertificateGridCard(certificate),
        );
      },
    );
  }

  Widget _buildCertificateGridCard(Certificate certificate) {
    final dateFormat = DateFormat('MMM d, yyyy');

    return GestureDetector(
      onTap: () => _showCertificateDetailsSheet(certificate),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Certificate image
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  color: AppColors.darkBlue.withOpacity(0.05),
                ),
                child: Stack(
                  children: [
                    // kStatus badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: certificate.getStatusColor().withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              certificate.getStatusIcon(),
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              certificate.getStatusText(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Certificate details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      certificate.courseName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      certificate.instructor,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Issued: ${dateFormat.format(certificate.issueDate)}',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredCertificates.length,
      itemBuilder: (context, index) {
        final certificate = _filteredCertificates[index];

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            final delayedAnimation = CurvedAnimation(
              parent: _animationController,
              curve: Interval(
                math.min(1.0, index * 0.05),
                math.min(1.0, index * 0.05 + 0.45),
                curve: Curves.easeOut,
              ),
            );

            return FadeTransition(
              opacity: delayedAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0),
                  end: Offset.zero,
                ).animate(delayedAnimation),
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildCertificateListCard(certificate),
          ),
        );
      },
    );
  }

  Widget _buildCertificateListCard(Certificate certificate) {
    final dateFormat = DateFormat('MMMM d, yyyy');

    return GestureDetector(
      onTap: () => _showCertificateDetailsSheet(certificate),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Certificate thumbnail
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                color: AppColors.darkBlue.withOpacity(0.05),
              ),
            ),

            // Certificate details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: certificate.getStatusColor().withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                certificate.getStatusIcon(),
                                color: certificate.getStatusColor(),
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                certificate.getStatusText(),
                                style: TextStyle(
                                  color: certificate.getStatusColor(),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          certificate.id,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      certificate.courseName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Instructor: ${certificate.instructor}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Issued: ${dateFormat.format(certificate.issueDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCertificateDetailsSheet(Certificate certificate) {
    final dateFormat = DateFormat('MMMM d, yyyy');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Certificate header
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'CERTIFICATE OF COMPLETION',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBlue,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Course ID: ${certificate.courseId} • Certificate ID: ${certificate.id}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Certificate image
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.darkBlue.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.darkBlue.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          // Use our custom certificate template widget instead of an image
                          child: Icon(
                            Icons.workspace_premium,
                            size: 80,
                            color: AppColors.darkBlue.withOpacity(0.3),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: IconButton(
                          icon: const Icon(Icons.fullscreen, color: AppColors.primary),
                          onPressed: () {
                            // Show full-screen preview with our custom template
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => CertificatePreviewScreen(
                                  certificate: certificate,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Certificate info
                const Text(
                  'Certificate Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),

                // Course info card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        certificate.courseName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Instructor: ${certificate.instructor}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.category,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Category: ${certificate.category}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Duration: ${certificate.courseDurationHours} hours',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Course Rating: ${certificate.courseRating.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Text(
                        certificate.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Dates
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Completion Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dateFormat.format(certificate.completionDate),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Issue Date',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dateFormat.format(certificate.issueDate),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Skills
                const Text(
                  'Skills Acquired',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: certificate.skills.map((skill) {
                    return Chip(
                      label: Text(skill),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      labelStyle: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Verification
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Certificate verified!')),
                          );
                        },
                        icon: const Icon(Icons.qr_code),
                        label: const Text('Verify'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.darkBlue,
                          side: const BorderSide(color: AppColors.darkBlue),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Sharing certificate...')),
                          );
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Downloading certificate as PDF...')),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download PDF'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.workspace_premium,
              size: 100,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            const Text(
              'No Certificates Yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty || _selectedCategory != null
                  ? 'No certificates match your search criteria. Try adjusting your filters.'
                  : 'Keep learning and earn your first badge of excellence! Complete courses to receive certificates that showcase your skills.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            if (_searchQuery.isNotEmpty || _selectedCategory != null)
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchQuery = '';
                    _selectedCategory = null;
                  });
                  _filterCertificates();
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/courses');
                },
                icon: const Icon(Icons.school),
                label: const Text('Explore Courses'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}