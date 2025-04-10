// ignore_for_file: depend_on_referenced_packages, unnecessary_to_list_in_spreads, library_private_types_in_public_api, unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart'; // For image picking
import 'dart:io'; // For handling file paths
import 'package:firebase_storage/firebase_storage.dart'; // For Firebase Storage
import 'package:path/path.dart'; // For handling file paths
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:printing/printing.dart';

class ViewGuides extends StatelessWidget {
  // Renamed from ViewCrops to ViewGuides
  const ViewGuides({super.key});

  Future<void> _refreshData() async {
    // Logic to refresh data
  }

  @override
  Widget build(BuildContext context) {
    final agricultureCategories = [
      {'name': 'Crop Farming', 'image': 'assets/images/cropfarming.jpg'},
      {'name': 'Livestock', 'image': 'assets/images/livestock.jpeg'},
      {'name': 'Aquaculture', 'image': 'assets/images/aquaculture.jpg'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // Light green background
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        elevation: 4,
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text('Branch of Agriculture'),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData, // Define a method to refresh data
        child: ListView.builder(
          itemCount: agricultureCategories.length,
          itemBuilder: (context, index) {
            final category = agricultureCategories[index];
            return GestureDetector(
              onTap: () {
                if (category['name'] == 'Crop Farming') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CropFarmingViewer(),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TitleViewer(category: category['name']!),
                    ),
                  );
                }
              },
              child: Container(
                height: 150, // Enlarged height for each item
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: AssetImage(category['image']!),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.black.withOpacity(
                            0.4), // Dark overlay for text visibility
                      ),
                    ),
                    Center(
                      child: Text(
                        category['name']!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CropFarmingViewer extends StatelessWidget {
  const CropFarmingViewer({super.key});

  @override
  Widget build(BuildContext context) {
    final cropCategories = [
      {'name': 'Fruits', 'image': 'assets/images/fruits.jpg'},
      {'name': 'Grains', 'image': 'assets/images/grains.jpg'},
      {'name': 'Spices', 'image': 'assets/images/spices.jpg'},
      {'name': 'Root Crops', 'image': 'assets/images/root_crops.jpg'},
      {
        'name': 'Highland Vegetables',
        'image': 'assets/images/highland_vegetables.png'
      },
      {
        'name': 'Lowland Vegetables',
        'image': 'assets/images/lowland_vegetables.png'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        elevation: 4,
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text('Crop Farming'),
      ),
      body: ListView.builder(
        itemCount: cropCategories.length,
        itemBuilder: (context, index) {
          final category = cropCategories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TitleViewer(
                    category: 'Crop Farming',
                    cropCategory: category['name'],
                  ),
                ),
              );
            },
            child: Container(
              height: 150, // Enlarged height for each item
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage(category['image']!),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black
                          .withOpacity(0.4), // Dark overlay for text visibility
                    ),
                  ),
                  Center(
                    child: Text(
                      category['name']!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TitleViewer extends StatefulWidget {
  final String category;
  final String? cropCategory;

  const TitleViewer({super.key, required this.category, this.cropCategory});

  @override
  _TitleViewerState createState() => _TitleViewerState();
}

class _TitleViewerState extends State<TitleViewer> {
  String searchQuery = '';
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        elevation: 4,
        backgroundColor: const Color(0xFF2E7D32),
        title: Text(widget.cropCategory ?? widget.category),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56.0),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search titles...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('agriculture_guides')
            .where('category', isEqualTo: widget.category)
            .where('cropCategory', isEqualTo: widget.cropCategory)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No data available.'));
          }

          final docs = snapshot.data!.docs.where((doc) {
            final title = doc['title']?.toString().toLowerCase() ?? '';
            return title.contains(searchQuery);
          }).toList();

          if (docs.isEmpty) {
            return const Center(child: Text('No results found.'));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final imageUrl = doc['titleImage'] ?? '';
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InfoViewer(docId: doc.id),
                    ),
                  );
                },
                child: Container(
                  height: 150,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.black.withOpacity(0.4),
                        ),
                      ),
                      Center(
                        child: Text(
                          doc['title'],
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
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
    );
  }
}

class InfoViewer extends StatelessWidget {
  final String docId;

  const InfoViewer({super.key, required this.docId});

  Future<void> _downloadGuide(
      BuildContext context, String title, List<dynamic> sections) async {
    final pdf = pw.Document();

    // Load the custom font
    final fontData = await rootBundle.load('fonts/Roboto-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    // Prefetch images
    final List<Map<String, dynamic>> preprocessedSections = [];
    for (var section in sections) {
      final heading = section['heading'] ?? 'No Heading';
      final content = section['content'] ?? 'No Content';
      final images = section['images'] as List<dynamic>? ?? [];

      // Download images as bytes
      final List<pw.MemoryImage> imageWidgets = [];
      for (var imageUrl in images) {
        try {
          final response = await http.get(Uri.parse(imageUrl));
          if (response.statusCode == 200) {
            final imageBytes = response.bodyBytes;
            imageWidgets.add(pw.MemoryImage(imageBytes));
          }
        } catch (e) {
          debugPrint('Error loading image: $e');
        }
      }

      preprocessedSections.add({
        'heading': heading,
        'content': content,
        'images': imageWidgets,
      });
    }

    // Build the PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          final widgets = <pw.Widget>[];

          // Add the title
          widgets.add(
            pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                font: ttf,
              ),
            ),
          );
          widgets.add(pw.SizedBox(height: 16));

          // Add the sections
          for (var section in preprocessedSections) {
            final heading = section['heading'];
            final content = section['content'];
            final images = section['images'] as List<pw.MemoryImage>;

            // Add the heading
            widgets.add(
              pw.Text(
                heading,
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                  font: ttf,
                ),
              ),
            );
            widgets.add(pw.SizedBox(height: 8));

            // Add the content
            widgets.add(
              pw.Text(
                content,
                style: pw.TextStyle(
                  fontSize: 14,
                  font: ttf,
                ),
              ),
            );
            widgets.add(pw.SizedBox(height: 8));

            // Add the images
            for (var image in images) {
              widgets.add(
                pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 8.0),
                  child: pw.Image(
                    image,
                    fit: pw.BoxFit.contain,
                    height: 150,
                  ),
                ),
              );
            }

            widgets.add(pw.SizedBox(height: 16));
          }

          return widgets;
        },
      ),
    );

    // Use the `printing` package to preview and share the PDF
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        elevation: 4,
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text('Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              try {
                // Fetch the guide data
                final doc = await FirebaseFirestore.instance
                    .collection('agriculture_guides')
                    .doc(docId)
                    .get();

                if (!doc.exists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Document does not exist.')),
                  );
                  return;
                }

                final data = doc.data() as Map<String, dynamic>;
                final title = data['title'] ?? 'Untitled Guide';
                final sections = data['sections'] as List<dynamic>? ?? [];

                if (sections.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('No content available to download.')),
                  );
                  return;
                }

                // Generate and view the PDF
                await _downloadGuide(context, title, sections);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditInfoPage(docId: docId),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('agriculture_guides')
            .doc(docId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No details available.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final cropCategory = data['cropCategory'] ?? '';
          final cropCategoryImage = data['cropCategoryImage'];
          final title = data['title'] ?? 'No Title';
          final titleImage = data['titleImage'];
          final sections = data['sections'] as List<dynamic>? ?? [];

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (cropCategory != null && cropCategory.isNotEmpty)
                            Text(
                              cropCategory,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (titleImage != null)
                      GestureDetector(
                        onTap: () {
                          _showFullScreenImage(context, titleImage);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            titleImage,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Display Crop Category Image
              if (cropCategoryImage != null)
                GestureDetector(
                  onTap: () {
                    _showFullScreenImage(context, cropCategoryImage);
                  },
                  child: Image.network(
                    cropCategoryImage,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              const SizedBox(height: 16),

              // Display Sections
              ...sections.map((section) {
                final heading = section['heading'];
                final content = section['content'];
                final images = section['images'] as List<dynamic>? ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (heading != null)
                      Text(
                        heading,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    if (heading != null) const SizedBox(height: 8),
                    if (content != null) Text(content),
                    if (content != null) const SizedBox(height: 8),
                    ...images.map((image) {
                      return GestureDetector(
                        onTap: () {
                          _showFullScreenImage(context, image);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Image.network(
                            image,
                            width: double.infinity,
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(imageUrl: imageUrl),
      ),
    );
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageViewer({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class EditInfoPage extends StatefulWidget {
  final String docId;

  const EditInfoPage({super.key, required this.docId});

  @override
  _EditInfoPageState createState() => _EditInfoPageState();
}

class _EditInfoPageState extends State<EditInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _cropCategoryController;
  late List<Map<String, dynamic>> _sections;
  late List<String> _images; // List to store image URLs
  final ImagePicker _picker = ImagePicker(); // Image picker instance
  late Future<void> _fetchDataFuture; // Future to track data fetching

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = _fetchData(); // Initialize the future
  }

  Future<void> _fetchData() async {
    final doc = await FirebaseFirestore.instance
        .collection('agriculture_guides')
        .doc(widget.docId)
        .get();

    final data = doc.data() as Map<String, dynamic>;
    _titleController = TextEditingController(text: data['title']);
    _cropCategoryController = TextEditingController(text: data['cropCategory']);
    _sections = [
      {"heading": "Section 1", "content": "This is the content of section 1."},
      {"heading": "Section 2", "content": "This is the content of section 2."}
    ];
    _images = (data['images'] as List<dynamic>?)?.cast<String>() ?? [];
  }

  Future<void> _updateData() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('agriculture_guides')
          .doc(widget.docId)
          .update({
        'title': _titleController.text,
        'cropCategory': _cropCategoryController.text,
        'sections': _sections,
        'images': _images,
      });

      // Show success message
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(content: Text('Content updated successfully!')),
      );

      // Navigate back
      Navigator.pop(context as BuildContext);
    }
  }

  Future<void> _pickImage(int sectionIndex) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageUrl = await _uploadImageToFirebase(File(pickedFile.path));
      if (imageUrl != null) {
        setState(() {
          _sections[sectionIndex]['images'].add(imageUrl); // Add the image URL
        });
      }
    }
  }

  Future<String?> _uploadImageToFirebase(File imageFile) async {
    try {
      final fileName = basename(imageFile.path); // Get the file name
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now().millisecondsSinceEpoch}_$fileName');

      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() => null);

      // Get the public URL of the uploaded image
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  void _removeImage(int sectionIndex, int imageIndex) {
    setState(() {
      _sections[sectionIndex]['images'].removeAt(imageIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        elevation: 4,
        backgroundColor: const Color(0xFF2E7D32),
        title: const Text('Edit Content'),
      ),
      body: FutureBuilder<void>(
        future: _fetchDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          // Render the form after data is fetched
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Crop Category Field
                  TextFormField(
                    controller: _cropCategoryController,
                    decoration:
                        const InputDecoration(labelText: 'Crop Category'),
                  ),
                  const SizedBox(height: 16),

                  // Sections
                  const Text(
                    'Sections',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ..._sections.asMap().entries.map((entry) {
                    final sectionIndex = entry.key;
                    final section = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          initialValue: section['heading'],
                          decoration:
                              const InputDecoration(labelText: 'Heading'),
                          onChanged: (value) {
                            _sections[sectionIndex]['heading'] = value;
                          },
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          initialValue: section['content'],
                          decoration:
                              const InputDecoration(labelText: 'Content'),
                          maxLines: 3,
                          onChanged: (value) {
                            _sections[sectionIndex]['content'] = value;
                          },
                        ),
                        const SizedBox(height: 8),

                        // Images for the Section
                        const Text(
                          'Images',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...section['images'].asMap().entries.map((imageEntry) {
                          final imageIndex = imageEntry.key;
                          final imageUrl = imageEntry.value;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Use Image.network for URLs
                              Image.network(
                                imageUrl,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Text(
                                    'Failed to load image',
                                    style: TextStyle(color: Colors.red),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () =>
                                      _removeImage(sectionIndex, imageIndex),
                                  child: const Text(
                                    'Remove Image',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ),
                              const Divider(),
                            ],
                          );
                        }).toList(),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _pickImage(sectionIndex),
                          child: const Text('Add Image'),
                        ),
                        const Divider(),
                      ],
                    );
                  }).toList(),

                  // Add New Section Button
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _sections.add({
                          'heading': '',
                          'content': '',
                          'images': [],
                        });
                      });
                    },
                    child: const Text('Add New Section'),
                  ),
                  const SizedBox(height: 16),

                  // Save Changes Button
                  ElevatedButton(
                    onPressed: _updateData,
                    child: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class PDFViewerScreen extends StatelessWidget {
  final String pdfPath;

  const PDFViewerScreen({super.key, required this.pdfPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: FutureBuilder<bool>(
        future: File(pdfPath).exists(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.data!) {
            return const Center(
              child: Text('Failed to load PDF.'),
            );
          }
          return PDFView(
            filePath: pdfPath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            onRender: (pages) {
              debugPrint('Document rendered with $pages pages.');
            },
            onError: (error) {
              debugPrint('Error loading PDF: $error');
            },
            onPageError: (page, error) {
              debugPrint('Error on page $page: $error');
            },
          );
        },
      ),
    );
  }
}
