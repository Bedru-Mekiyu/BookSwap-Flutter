import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bookswap/providers/books_provider.dart';
import 'package:bookswap/providers/auth_provider.dart';
import 'package:bookswap/core/dio_client.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedGenre = 'All';

  final List<String> _genres = const [
    'All',
    'Fiction',
    'Sci-Fi',
    'Fantasy',
    'Mystery',
    'Non-Fiction',
    'Technology',
    'Classics',
    'Self-Help',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndLoadBooks();
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndLoadBooks() async {
    final authState = ref.read(authProvider);
    if (!authState.isAuthenticated) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
      return;
    }
    await _loadBooks();
  }

  Future<void> _loadBooks() async {
    final query =
        _searchController.text.trim().isEmpty
            ? null
            : _searchController.text.trim();
    final genre = _selectedGenre == 'All' ? null : _selectedGenre;
    await ref
        .read(booksProvider.notifier)
        .fetchBooks(searchQuery: query, genre: genre);
  }

  void _onSearchChanged() {
    _loadBooks();
  }

  void _onGenreSelected(String genre) {
    if (_selectedGenre == genre) return;
    setState(() {
      _selectedGenre = genre;
    });
    _loadBooks();
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        _loadBooks();
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/my_book');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/add_book');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final booksState = ref.watch(booksProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'BookSwap',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/');
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Search books by title, author, or genre...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF8A2BE2)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged();
                          },
                        )
                        : null,
              ),
              onSubmitted: (value) {
                _loadBooks();
              },
            ),
          ),

          // Interactive Genre Filter Chips
          SizedBox(
            height: 48,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              scrollDirection: Axis.horizontal,
              itemCount: _genres.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final genre = _genres[index];
                final isSelected = genre == _selectedGenre;
                return ChoiceChip(
                  label: Text(genre),
                  selected: isSelected,
                  selectedColor: const Color(0xFF8A2BE2),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color:
                          isSelected
                              ? const Color(0xFF8A2BE2)
                              : Colors.grey.shade300,
                    ),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      _onGenreSelected(genre);
                    }
                  },
                );
              },
            ),
          ),

          // Catalog Status Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedGenre == 'All'
                      ? 'Available Books (${booksState.books.length})'
                      : '$_selectedGenre Books (${booksState.books.length})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (_selectedGenre != 'All' || _searchController.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _onGenreSelected('All');
                    },
                    child: const Text(
                      'Clear Filters',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8A2BE2),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Books Grid
          Expanded(
            child:
                booksState.isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF8A2BE2),
                        ),
                      ),
                    )
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
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8A2BE2),
                            ),
                            onPressed: _loadBooks,
                            child: const Text(
                              'Retry',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    )
                    : booksState.books.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.menu_book_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No books found',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Try adjusting your search or category filter',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black38,
                            ),
                          ),
                        ],
                      ),
                    )
                    : LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        final crossAxisCount =
                            width > 1200
                                ? 5
                                : (width > 900
                                    ? 4
                                    : (width > 600 ? 3 : 2));
                        final childAspectRatio = width > 600 ? 0.62 : 0.65;

                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: childAspectRatio,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: booksState.books.length,
                          itemBuilder: (context, index) {
                            final book = booksState.books[index];
                            final photoUrl = book['photo']?.toString();
                            final genre = book['genre']?.toString();
                            final ownerName =
                                book['owner']?['name']?.toString() ?? 'Community';

                            return GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  '/book_detail',
                                  arguments: book,
                                );
                              },
                              child: Card(
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Book Cover with Genre Badge
                                    Expanded(
                                      child: Stack(
                                        children: [
                                          photoUrl != null && photoUrl.isNotEmpty
                                              ? Image.network(
                                                DioClient.buildMediaUrl(photoUrl),
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                                errorBuilder: (
                                                  context,
                                                  error,
                                                  stackTrace,
                                                ) {
                                                  return Container(
                                                    color: Colors.grey[200],
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons.book,
                                                        size: 48,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              )
                                              : Container(
                                                color: Colors.grey[200],
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.book,
                                                    size: 48,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                          if (genre != null && genre.isNotEmpty)
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(
                                                    0.75,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  genre,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            book['title'] ?? 'Unknown Title',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            book['author'] ?? 'Unknown Author',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade700,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.person_outline,
                                                size: 13,
                                                color: Colors.grey.shade600,
                                              ),
                                              const SizedBox(width: 3),
                                              Expanded(
                                                child: Text(
                                                  ownerName,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey.shade600,
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'My Books'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add Book'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
