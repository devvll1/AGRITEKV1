import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

class GuideCard extends StatefulWidget {
  final String videoId;

  const GuideCard({super.key, required this.videoId});

  @override
  _GuideCardState createState() => _GuideCardState();
}

class _GuideCardState extends State<GuideCard> {
  String title = 'Loading...';
  String publishedDate = 'Loading...';
  String runtime = 'Loading...';

  @override
  void initState() {
    super.initState();
    fetchVideoDetails(widget.videoId);
  }

  Future<void> fetchVideoDetails(String videoId) async {
    const String apiKey = 'AIzaSyCiu2BV_raUsRj2X9ZJxohqzdxXJlUiGQU';
    final String url = 'https://www.googleapis.com/youtube/v3/videos?part=snippet,contentDetails&id=$videoId&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final videoInfo = data['items'][0];

        setState(() {
          title = videoInfo['snippet']['title'];
          publishedDate = videoInfo['snippet']['publishedAt'].substring(0, 10); // Extracting date part
          runtime = _convertDuration(videoInfo['contentDetails']['duration']);
        });
      } else {
        throw Exception('Failed to load video details');
      }
    } catch (e) {
      print('Error fetching video details: $e');
    }
  }

  // Helper function to convert ISO 8601 duration (e.g., PT4M13S) to a readable format (e.g., 4:13)
  String _convertDuration(String isoDuration) {
    final regex = RegExp(r'PT(\d+H)?(\d+M)?(\d+S)?');
    final match = regex.firstMatch(isoDuration);

    if (match == null) return 'Unknown';

    final hours = match.group(1) != null ? int.parse(match.group(1)!.replaceAll('H', '')) : 0;
    final minutes = match.group(2) != null ? int.parse(match.group(2)!.replaceAll('M', '')) : 0;
    final seconds = match.group(3) != null ? int.parse(match.group(3)!.replaceAll('S', '')) : 0;

    final formattedMinutes = minutes.toString().padLeft(2, '0');
    final formattedSeconds = seconds.toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$formattedMinutes:$formattedSeconds' : '$formattedMinutes:$formattedSeconds';
  }

  @override
  Widget build(BuildContext context) {
    String thumbnailUrl = 'https://img.youtube.com/vi/${widget.videoId}/0.jpg';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Image.network(
          thumbnailUrl,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
        title: Text(title),
        subtitle: Text('Published on $publishedDate\nDuration: $runtime'),
        onTap: () {
          _showYoutubePlayerDialog(widget.videoId);
        },
      ),
    );
  }

  void _showYoutubePlayerDialog(String videoId) {
    YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            onReady: () {
              print('Player is ready.');
            },
          ),
        );
      },
    );
  }
}

class Ampalaya extends StatelessWidget {
  const Ampalaya({super.key});

  @override
  Widget build(BuildContext context) {
    return const AmpalayaDetailScreen();
  }
}

class AmpalayaDetailScreen extends StatefulWidget {
  const AmpalayaDetailScreen({super.key});

  @override
  AmpalayaDetailScreenState createState() => AmpalayaDetailScreenState();
}

class AmpalayaDetailScreenState extends State<AmpalayaDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  Map<String, dynamic>? ampalayaData;

  @override
  void initState() {
    super.initState();
    getAmpalayaDataFromFirestore();
  }

  Future<void> getAmpalayaDataFromFirestore() async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('Vegetables').doc('ampalaya').get();

      if (snapshot.exists) {
        setState(() {
          ampalayaData = snapshot.data() as Map<String, dynamic>;
        });
      } else {
        print("Ampalaya document not found.");
      }
    } catch (e) {
      print('Error fetching Ampalaya data: $e');
    }
  }

  Future<String> fetchFirebaseImage(String gsUrl) async {
    try {
      final ref = _storage.refFromURL(gsUrl);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Error fetching image URL: $e');
      return ''; // Return empty string as fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ampalayaData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vegetables'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              // Add bookmark functionality here
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAmpalayaCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Description'),
            Text(
              ampalayaData!['description'],
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Materials and Tools Needed:'),
            Text(
              (ampalayaData!['materialsAndTools'] as List<dynamic>).join('\n'),
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Step-by-Step Guide to Planting Ampalaya:'),
            const SizedBox(height: 16),
            ..._buildStepCards(),
            const SizedBox(height: 24),
            const Divider(),
            _buildSectionTitle('Explore More Guides'),
            const SizedBox(height: 8),
            if ((ampalayaData!['videoIds'] as List<dynamic>).isNotEmpty)
              ...ampalayaData!['videoIds'].map<Widget>((videoId) {
                return GuideCard(videoId: videoId);
              }).toList()
            else
              const Text('No videos available.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildAmpalayaCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Image.asset(
              'images/vegetables/Ampalaya.png', // Local ampalaya image
              height: 80,
              width: 80,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ampalayaData!['title'],
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ampalayaData!['scientificName'],
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Published date: ${ampalayaData!['publishedDate']}',
                    style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  List<Widget> _buildStepCards() {
    return List.generate(ampalayaData!['steps'].length, (index) {
      var step = ampalayaData!['steps'][index];
      return FutureBuilder<String>(
        future: fetchFirebaseImage(step['imageUrl']),
        builder: (context, snapshot) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        step['title'],
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    snapshot.connectionState == ConnectionState.done && snapshot.hasData
                        ? Image.network(
                            snapshot.data!,
                            height: 250,
                            fit: BoxFit.cover,
                          )
                        : const SizedBox(
                            height: 150,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  step['description'],
                  textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      );
    });
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/home');
            break;
          case 1:
            // Navigate to forums
            break;
          case 2:
            // Navigate to updates
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.view_module), label: 'Modules'),
        BottomNavigationBarItem(icon: Icon(Icons.forum), label: 'Forums'),
        BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Updates'),
      ],
    );
  }
}
