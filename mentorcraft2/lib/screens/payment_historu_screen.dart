import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/payment_history.dart';
import '../theme/color.dart';
import '../widgets/app_drawer.dart';
import '../widgets/appbar_widget.dart';

class PaymentHistoryScreen extends StatefulWidget {
  static const routeName = '/payment-history';

  const PaymentHistoryScreen({Key? key}) : super(key: key);

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final List<PaymentHistory> _paymentHistory = PaymentHistory.getSampleData();
  final List<PaymentHistory> _filteredPaymentHistory = [];
  final TextEditingController _searchController = TextEditingController();

  // Filter states
  PaymentStatus? _statusFilter;
  SortOption _currentSortOption = SortOption.dateNewest;
  String _searchQuery = '';

  // Pagination
  final int _itemsPerPage = 5;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _filteredPaymentHistory.addAll(_paymentHistory);
    _applyFilters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      // First filter by search query
      if (_searchQuery.isEmpty) {
        _filteredPaymentHistory.clear();
        _filteredPaymentHistory.addAll(_paymentHistory);
      } else {
        _filteredPaymentHistory.clear();
        _filteredPaymentHistory.addAll(_paymentHistory.where((payment) {
          return payment.courseName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              payment.instructorName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              payment.transactionId.toLowerCase().contains(_searchQuery.toLowerCase());
        }));
      }

      // Then filter by status
      if (_statusFilter != null) {
        _filteredPaymentHistory.removeWhere((payment) => payment.status != _statusFilter);
      }

      // Finally sort
      switch (_currentSortOption) {
        case SortOption.dateNewest:
          _filteredPaymentHistory.sort((a, b) => b.dateTime.compareTo(a.dateTime));
          break;
        case SortOption.dateOldest:
          _filteredPaymentHistory.sort((a, b) => a.dateTime.compareTo(b.dateTime));
          break;
        case SortOption.amountHighest:
          _filteredPaymentHistory.sort((a, b) => b.amount.compareTo(a.amount));
          break;
        case SortOption.amountLowest:
          _filteredPaymentHistory.sort((a, b) => a.amount.compareTo(b.amount));
          break;
      }

      // Reset current page when filters change
      _currentPage = 1;
    });
  }

  int get _pageCount {
    return (_filteredPaymentHistory.length / _itemsPerPage).ceil();
  }

  List<PaymentHistory> get _paginatedItems {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage > _filteredPaymentHistory.length
        ? _filteredPaymentHistory.length
        : startIndex + _itemsPerPage;

    if (startIndex >= _filteredPaymentHistory.length) {
      return [];
    }

    return _filteredPaymentHistory.sublist(startIndex, endIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Payment History'),
      // drawer: const AppDrawer(),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _filteredPaymentHistory.isEmpty
                ? _buildEmptyState()
                : _buildPaymentList(),
          ),
          if (_pageCount > 1) _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by course, instructor or transaction ID',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[200],
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
                _applyFilters();
              });
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatusDropdown(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSortDropdown(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<PaymentStatus?>(
          isExpanded: true,
          value: _statusFilter,
          hint: const Text('Filter by Status'),
          onChanged: (PaymentStatus? newValue) {
            setState(() {
              _statusFilter = newValue;
              _applyFilters();
            });
          },
          items: [
            const DropdownMenuItem<PaymentStatus?>(
              value: null,
              child: Text('All Statuses'),
            ),
            ...PaymentStatus.values.map((status) {
              String statusText = '';
              Color statusColor = Colors.black;

              switch (status) {
                case PaymentStatus.successful:
                  statusText = 'Successful';
                  statusColor = Colors.green.shade700;
                  break;
                case PaymentStatus.failed:
                  statusText = 'Failed';
                  statusColor = Colors.red.shade700;
                  break;
                case PaymentStatus.pending:
                  statusText = 'Pending';
                  statusColor = Colors.orange.shade700;
                  break;
                case PaymentStatus.refunded:
                  statusText = 'Refunded';
                  statusColor = Colors.blue.shade700;
                  break;
              }

              return DropdownMenuItem<PaymentStatus?>(
                value: status,
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(statusText),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[800]
            : Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SortOption>(
          isExpanded: true,
          value: _currentSortOption,
          onChanged: (SortOption? newValue) {
            if (newValue != null) {
              setState(() {
                _currentSortOption = newValue;
                _applyFilters();
              });
            }
          },
          items: [
            const DropdownMenuItem<SortOption>(
              value: SortOption.dateNewest,
              child: Text('Date (Newest)'),
            ),
            const DropdownMenuItem<SortOption>(
              value: SortOption.dateOldest,
              child: Text('Date (Oldest)'),
            ),
            const DropdownMenuItem<SortOption>(
              value: SortOption.amountHighest,
              child: Text('Amount (Highest)'),
            ),
            const DropdownMenuItem<SortOption>(
              value: SortOption.amountLowest,
              child: Text('Amount (Lowest)'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _paginatedItems.length,
      itemBuilder: (context, index) {
        final payment = _paginatedItems[index];
        return _buildPaymentCard(payment);
      },
    );
  }

  Widget _buildPaymentCard(PaymentHistory payment) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.courseName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Instructor: ${payment.instructorName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(payment),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    label: 'Transaction ID',
                    value: payment.transactionId,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    label: 'Amount',
                    value: '\$${payment.amount.toStringAsFixed(2)}',
                    valueStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    label: 'Date',
                    value: dateFormat.format(payment.dateTime),
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    label: 'Time',
                    value: timeFormat.format(payment.dateTime),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              label: 'Payment Method',
              value: payment.paymentMethod,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (payment.status == PaymentStatus.successful ||
                    payment.status == PaymentStatus.refunded)
                  OutlinedButton.icon(
                    onPressed: () {
                      // Download receipt functionality
                    },
                    icon: const Icon(Icons.receipt_long, size: 18),
                    label: const Text('Receipt'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      side: BorderSide(color: AppColors.primary),
                    ),
                  ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // View details functionality
                  },
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('Details'),
                  style: ElevatedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PaymentHistory payment) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: payment.getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: payment.getStatusColor().withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        payment.getStatusText(),
        style: TextStyle(
          color: payment.getStatusColor(),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: valueStyle ?? const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1
                ? () => setState(() => _currentPage--)
                : null,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous Page',
          ),
          ...List.generate(
            _pageCount > 5 ? 5 : _pageCount,
                (index) {
              // Calculate which page numbers to show
              int pageNum;
              if (_pageCount <= 5) {
                pageNum = index + 1;
              } else {
                if (_currentPage <= 3) {
                  pageNum = index + 1;
                } else if (_currentPage >= _pageCount - 2) {
                  pageNum = _pageCount - 4 + index;
                } else {
                  pageNum = _currentPage - 2 + index;
                }
              }

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: ElevatedButton(
                  onPressed: () => setState(() => _currentPage = pageNum),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(0),
                    minimumSize: const Size(40, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: _currentPage == pageNum
                        ? AppColors.primary
                        : Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[200],
                  ),
                  child: Text(
                    pageNum.toString(),
                    style: TextStyle(
                      color: _currentPage == pageNum
                          ? Colors.white
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            onPressed: _currentPage < _pageCount
                ? () => setState(() => _currentPage++)
                : null,
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next Page',
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Payment Records Found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty || _statusFilter != null
                ? 'Try changing your search or filter settings'
                : 'You haven\'t made any payment yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isNotEmpty || _statusFilter != null)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _searchController.clear();
                  _statusFilter = null;
                  _applyFilters();
                });
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
        ],
      ),
    );
  }
}

enum SortOption {
  dateNewest,
  dateOldest,
  amountHighest,
  amountLowest,
}