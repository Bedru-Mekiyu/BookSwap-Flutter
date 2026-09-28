import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookswap/providers/books_provider.dart';
import 'package:bookswap/providers/auth_provider.dart';
import 'package:bookswap/core/dio_client.dart';

class MyBookListPage extends ConsumerStatefulWidget {
  final bool isTab;
  final VoidCallback? onAddBook;

  const MyBookListPage({super.key, this.isTab = false, this.onAddBook});

  @override
  ConsumerState<MyBookListPage> createState() => _MyBookListPageState();
}

class _MyBookListPageState extends ConsumerState<MyBookListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchMyBooks();
    });
  }

  Future<void> _fetchMyBooks() async {
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to view your books.')),
        );
        Navigator.pushReplacementNamed(context, '/');
      }
      return;
    }
    await ref.read(booksProvider.notifier).fetchUserBooks();
  }

  Future<void> _deleteBook(String bookId) async {
    await ref.read(booksProvider.notifier).deleteBook(bookId);
  }

  void _confirmDelete(String bookId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this book?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteBook(bookId);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
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
          'My Books',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            tooltip: 'Refresh Books',
            onPressed: _fetchMyBooks,
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
                      onPressed: _fetchMyBooks,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
              : booksState.books.isEmpty
              ? RefreshIndicator(
                  onRefresh: _fetchMyBooks,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.7,
                      padding: const EdgeInsets.all(24.0),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.menu_book, size: 70, color: Colors.purple.shade200),
                          const SizedBox(height: 16),
                          const Text(
                            'You have no books listed yet.',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Share books from your collection to start swapping with others.',
                            style: TextStyle(fontSize: 14, color: Colors.black54),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed:
                                widget.onAddBook ??
                                () => Navigator.pushNamed(context, '/add_book'),
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text(
                              'Add Your First Book',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchMyBooks,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: booksState.books.length,
                itemBuilder: (context, index) {
                  final book = booksState.books[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/edit_book',
                          arguments: book,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book['title'] ?? 'N/A',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Author : ${book['author'] ?? 'N/A'}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      OutlinedButton(
                                        onPressed: () {
                                          Navigator.pushNamed(
                                            context,
                                            '/edit_book',
                                            arguments: book,
                                          );
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.green,
                                          side: const BorderSide(
                                            color: Colors.green,
                                          ),
                                        ),
                                        child: const Text('Edit'),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton(
                                        onPressed:
                                            () => _confirmDelete(book['_id']),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.red,
                                          side: const BorderSide(
                                            color: Colors.red,
                                          ),
                                        ),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              width: 100,
                              height: 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8.0),
                                color: Colors.grey[200],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: book['photo'] != null &&
                                            book['photo'].toString().isNotEmpty
                                        ? Image.network(
                                          DioClient.buildMediaUrl(book['photo'].toString()),
                                          fit: BoxFit.cover,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return const Center(
                                              child: Icon(
                                                Icons.broken_image,
                                                size: 40,
                                              ),
                                            );
                                          },
                                        )
                                        : const Center(
                                          child: Icon(Icons.book, size: 40),
                                        ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
