import 'package:flutter/material.dart';

class AlbumsPage extends StatelessWidget {
  const AlbumsPage({Key? key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromRGBO(64, 64, 64, 1),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AlbumRow(
                albums: [
                  Album(title: 'Family', imageUrl: 'lib/images/family.jpeg'),
                  Album(title: 'Travel', imageUrl: 'lib/images/travel.jpeg'),
                ],
              ),
              AlbumRow(
                albums: [
                  Album(title: 'Nature', imageUrl: 'lib/images/nature.jpeg'),
                  Album(title: 'Friends', imageUrl: 'lib/images/friends.jpeg'),
                ],
              ),
              AlbumRow(
                albums: [
                  Album(title: 'Events', imageUrl: 'lib/images/events.jpeg'),
                  Album(title: 'Pets', imageUrl: 'lib/images/pets.jpeg'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AlbumRow extends StatelessWidget {
  final List<Album> albums;

  const AlbumRow({Key? key, required this.albums}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: albums
            .map((album) => Expanded(
                  child: AlbumBox(
                    album: album,
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class AlbumBox extends StatelessWidget {
  final Album album;

  const AlbumBox({Key? key, required this.album}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Handle tap event here
        print('Album tapped: ${album.title}');
      },
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          image: DecorationImage(
            image: AssetImage(album.imageUrl),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.0),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
            ),
          ),
          child: Center(
            child: Text(
              album.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Album {
  final String title;
  final String imageUrl;

  Album({required this.title, required this.imageUrl});
}