import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:glass_kit/glass_kit.dart';

void main() =>
    runApp(MaterialApp(debugShowCheckedModeBanner: false, home: GalleryApp()));

class GalleryApp extends StatefulWidget {
  const GalleryApp({super.key});

  @override
  _GalleryAppState createState() => _GalleryAppState();
}

class _GalleryAppState extends State<GalleryApp> {
  List<AssetPathEntity> albums = [];

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        hasAll: true,
      );
      setState(() => albums = paths);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Albums"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(12),
        itemCount: albums.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemBuilder: (context, index) {
          final album = albums[index];
          return FutureBuilder<List<AssetEntity>>(
            future: album.getAssetListRange(start: 0, end: 1),
            builder: (_, snapshot) {
              final thumb =
                  snapshot.data?.isNotEmpty == true ? snapshot.data![0] : null;
              return GlassContainer(
                borderRadius: BorderRadius.circular(16),
                blur: 18,
                borderWidth: 1.0,
                width: double.infinity,
                height: double.infinity,
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderGradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.5),
                    Colors.blueAccent.withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    thumb != null
                        ? FutureBuilder<Uint8List?>(
                          future: thumb.thumbnailDataWithSize(
                            ThumbnailSize(100, 100),
                          ),
                          builder: (_, snap) {
                            if (snap.connectionState == ConnectionState.done &&
                                snap.data != null) {
                              return Image.memory(
                                snap.data!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              );
                            } else {
                              return Icon(
                                Icons.image,
                                size: 60,
                                color: Colors.white70,
                              );
                            }
                          },
                        )
                        : Icon(Icons.image, size: 60, color: Colors.white70),
                    SizedBox(height: 8),
                    Text(
                      album.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${album.assetCount} items',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
