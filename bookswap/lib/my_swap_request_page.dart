import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookswap/providers/books_provider.dart';
import 'package:bookswap/providers/auth_provider.dart';

class MySwapRequestsPage extends ConsumerStatefulWidget {
  final bool isTab;

  const MySwapRequestsPage({super.key, this.isTab = false});

  @override
  ConsumerState<MySwapRequestsPage> createState() => _MySwapRequestsPageState();
}

class _MySwapRequestsPageState extends ConsumerState<MySwapRequestsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSwapRequests();
    });
  }

  Future<void> _fetchSwapRequests() async {
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to view swap requests.')),
        );
        Navigator.pushReplacementNamed(context, '/');
      }
      return;
    }
    await ref.read(booksProvider.notifier).fetchSwapRequests();
  }

  Future<void> _handleSwapRequest(String requestId, bool accept) async {
    await ref.read(booksProvider.notifier).handleSwapRequest(requestId, accept);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Widget _buildBookTradeInfo(Map<String, dynamic> trade, bool isSent) {
    final book = trade['requestedBook'] as Map<String, dynamic>?;
    final requester = trade['requester'] as Map<String, dynamic>?;
    final owner = trade['owner'] as Map<String, dynamic>?;
    final status = trade['status']?.toString() ?? 'pending';

    final offeredBook = trade['offeredBook'] as Map<String, dynamic>?;
    String offeredBookTitle =
        offeredBook != null ? (offeredBook['title'] ?? 'No title') : 'No book offered';

    final requesterName = requester != null
        ? (requester['name'] ?? requester['username'] ?? requester['email'] ?? 'User')
        : 'Unknown User';

    final bookTitle = book != null ? (book['title'] ?? 'Unknown Title') : 'Book Unavailable';
    final bookAuthor = book != null ? (book['author'] ?? 'Unknown Author') : 'N/A';
    final bookDesc = book != null ? (book['description'] ?? 'No description') : 'N/A';

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: $bookTitle',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Author: $bookAuthor'),
            Text(
              'Description: $bookDesc',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!isSent && offeredBook != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Offered by $requesterName: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text('Book Title: $offeredBookTitle'),
                ],
              ),
            const SizedBox(height: 8),
            Text(
              'Status: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              status,
              style: TextStyle(
                color: _getStatusColor(status),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!isSent && status == 'pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => _handleSwapRequest(trade['_id'], true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Accept'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _handleSwapRequest(trade['_id'], false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Reject'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final booksState = ref.watch(booksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: !widget.isTab,
        leading: widget.isTab
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacementNamed(context, '/home');
                  }
                },
              ),
        title: const Text(
          'Swap Requests',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            tooltip: 'Refresh Requests',
            onPressed: _fetchSwapRequests,
          ),
        ],
      ),
      body:
          booksState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : booksState.error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      booksState.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchSwapRequests,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  if (!widget.isTab)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/my_book_list');
                        },
                        icon: const Icon(Icons.book, color: Colors.white),
                        label: const Text(
                          'My Book List',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          minimumSize: const Size.fromHeight(50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        children: [
                          const TabBar(
                            tabs: [
                              Tab(text: 'Sent Requests'),
                              Tab(text: 'Received Requests'),
                            ],
                            labelColor: Colors.purple,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Colors.purple,
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                booksState.sentSwapRequests.isEmpty
                                    ? const Center(
                                      child: Text('No sent swap requests.'),
                                    )
                                    : ListView.builder(
                                      padding: const EdgeInsets.all(8.0),
                                      itemCount:
                                          booksState.sentSwapRequests.length,
                                      itemBuilder: (context, index) {
                                        final trade =
                                            booksState.sentSwapRequests[index];
                                        return _buildBookTradeInfo(trade, true);
                                      },
                                    ),
                                booksState.receivedSwapRequests.isEmpty
                                    ? const Center(
                                      child: Text('No received swap requests.'),
                                    )
                                    : ListView.builder(
                                      padding: const EdgeInsets.all(8.0),
                                      itemCount:
                                          booksState
                                              .receivedSwapRequests
                                              .length,
                                      itemBuilder: (context, index) {
                                        final trade =
                                            booksState
                                                .receivedSwapRequests[index];
                                        return _buildBookTradeInfo(
                                          trade,
                                          false,
                                        );
                                      },
                                    ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
