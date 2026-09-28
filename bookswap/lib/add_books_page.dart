import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:bookswap/providers/books_provider.dart';
import 'package:dio/dio.dart';

class AddBookPage extends ConsumerStatefulWidget {
  final bool isTab;
  final VoidCallback? onSuccess;

  const AddBookPage({super.key, this.isTab = false, this.onSuccess});

  @override
  ConsumerState<AddBookPage> createState() => _AddBookPageState();
}

class _AddBookPageState extends ConsumerState<AddBookPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  final TextEditingController _editionController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedGenre;
  Uint8List? _imageBytes;
  String? _imageFileName;
  Uint8List? _pdfBytes;
  String? _pdfFileName;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _languageController.dispose();
    _editionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _imageFileName = pickedFile.name;
      });
    }
  }

  Future<void> _pickPDF() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pdfBytes = result.files.first.bytes;
        _pdfFileName = result.files.first.name;
      });
    }
  }

  Future<void> _submitBook() async {
    final title = _titleController.text;
    final author = _authorController.text;
    final language = _languageController.text;
    final edition = _editionController.text;
    final description = _descriptionController.text;
    final genre = _selectedGenre;

    if (title.isEmpty || author.isEmpty || genre == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all required fields.')),
        );
      }
      return;
    }

    if (_imageBytes == null && _pdfBytes == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select either a cover photo or a PDF file.'),
          ),
        );
      }
      return;
    }

    try {
      final formData = FormData.fromMap({
        'title': title,
        'author': author,
        'genre': genre,
        'language': language,
        'edition': edition,
        'description': description,
      });

      if (_imageBytes != null) {
        formData.files.add(
          MapEntry(
            'photo',
            MultipartFile.fromBytes(
              _imageBytes!,
              filename: _imageFileName ?? 'cover.jpg',
            ),
          ),
        );
      }

      if (_pdfBytes != null) {
        formData.files.add(
          MapEntry(
            'pdf_file',
            MultipartFile.fromBytes(
              _pdfBytes!,
              filename: _pdfFileName ?? 'document.pdf',
            ),
          ),
        );
      }

      await ref.read(booksProvider.notifier).addBook(formData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book added successfully!')),
        );
        _titleController.clear();
        _authorController.clear();
        _languageController.clear();
        _editionController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedGenre = null;
          _imageBytes = null;
          _imageFileName = null;
          _pdfBytes = null;
          _pdfFileName = null;
        });

        if (widget.onSuccess != null) {
          widget.onSuccess!();
        } else if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'An error occurred: ${e.toString()}';
        if (e is DioException) {
          errorMessage = e.response?.data?['message'] ?? errorMessage;
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    }
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
          'Add Book',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body:
          booksState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Upload Area
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child:
                            _imageBytes == null
                                ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(
                                      Icons.cloud_upload,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Upload Cover Photo',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                )
                                : Image.memory(_imageBytes!, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // PDF Upload Area
                    GestureDetector(
                      onTap: _pickPDF,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Center(
                          child:
                              _pdfBytes == null
                                  ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.picture_as_pdf,
                                        size: 24,
                                        color: Colors.redAccent,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Upload PDF File',
                                        style: TextStyle(
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  )
                                  : Text(
                                    _pdfFileName!,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Title Field
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Author Field
                    TextField(
                      controller: _authorController,
                      decoration: InputDecoration(
                        hintText: 'Author',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Language Field
                    TextField(
                      controller: _languageController,
                      decoration: InputDecoration(
                        hintText: 'Language',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Edition Field
                    TextField(
                      controller: _editionController,
                      decoration: InputDecoration(
                        hintText: 'Edition',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Description Field
                    TextField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // Genre Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          hint: const Text('Please select genre'),
                          value: _selectedGenre,
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedGenre = newValue;
                            });
                          },
                          items:
                              <String>[
                                'Fiction',
                                'Non-Fiction',
                                'Science',
                                'Fantasy',
                                'History',
                                'Biography',
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Submit Button
                    ElevatedButton(
                      onPressed: booksState.isLoading ? null : _submitBook,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF673AB7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child:
                          booksState.isLoading
                              ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              )
                              : const Text(
                                'Add Book',
                                style: TextStyle(fontSize: 18),
                              ),
                    ),
                  ],
                ),
              ),
      bottomNavigationBar: widget.isTab
          ? null
          : BottomNavigationBar(
              currentIndex: 2, // 'Add Book' is at index 2
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/my_book');
          } else if (index == 2) {
            // Already on Add Book page, do nothing
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
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
