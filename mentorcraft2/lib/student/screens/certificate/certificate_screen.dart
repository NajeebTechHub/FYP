import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mentorcraft2/student/models/certificate.dart';
import '../../../theme/color.dart';
import 'certificate_grid_card.dart';
import 'certificate_list_card.dart';
import 'certificate_filter_section.dart';
import 'certificate_detail_bottom_sheet.dart';
import 'empty_state.dart';

class CertificatesScreen extends StatefulWidget {
  const CertificatesScreen({Key? key}) : super(key: key);

  @override
  State<CertificatesScreen> createState() => _CertificatesScreenState();
}

class _CertificatesScreenState extends State<CertificatesScreen>
    with SingleTickerProviderStateMixin {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  List<Certificate> _allCerts = [];
  List<Certificate> _filteredCerts = [];
  bool _isGridView = false;
  String _searchQuery = '';
  String? _selectedCategory;

  late AnimationController _animController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _loadCertificates();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadCertificates() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final querySnap = await _firestore
        .collection('certificates')
        .where('userId', isEqualTo: uid)
        .orderBy('issueDate', descending: true)
        .get();

    _allCerts = querySnap.docs.map((doc) {
      final data = doc.data();
      return Certificate.fromFirestore(doc.id, data);
    }).toList();

    setState(() {
      _filteredCerts = _allCerts;
      _isLoading = false;
    });
    _animController.forward();
  }

  void _filter() {
    setState(() {
      _filteredCerts = _allCerts.where((c) {
        final matchSearch = c.courseName.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchCat = _selectedCategory == null || c.category == _selectedCategory;
        return matchSearch && matchCat;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
        title: const Text('My Certificates'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          )
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            CertificateFilterSection(
              searchQuery: _searchQuery,
              selectedCategory: _selectedCategory,
              onSearchChanged: (val) {
                _searchQuery = val;
                _filter();
              },
              onCategoryChanged: (val) {
                _selectedCategory = val;
                _filter();
              },
            ),
            Expanded(
              child: _filteredCerts.isEmpty
                  ? EmptyState(
                isFiltered: _searchQuery.isNotEmpty || _selectedCategory != null,
                onClearFilters: () {
                  setState(() {
                    _searchQuery = '';
                    _selectedCategory = null;
                    _filter();
                  });
                },
              )
                  : _isGridView ? _buildGridView() : _buildListView(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
      ),
      itemCount: _filteredCerts.length,
      itemBuilder: (context, i) {
        final cert = _filteredCerts[i];
        return CertificateGridCard(
          certificate: cert,
          onTap: () {
            final studentName = _auth.currentUser?.displayName ?? 'Student';
            showCertificateDetailsSheet(context, cert, studentName: studentName);
          },
        );
      },
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      itemCount: _filteredCerts.length,
      itemBuilder: (context, i) {
        final cert = _filteredCerts[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: CertificateListCard(
            certificate: cert,
            animationController: _animController,
            index: i,
            onTap: () {
              final studentName = _auth.currentUser?.displayName ?? 'Student';
              showCertificateDetailsSheet(context, cert, studentName: studentName);
            },
          ),
        );
      },
    );
  }
}
