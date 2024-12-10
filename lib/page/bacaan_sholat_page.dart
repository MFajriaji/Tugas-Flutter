import 'dart:convert';
import 'package:apkbacaansholat/model/model_bacaan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' as rootBundle;
import 'package:video_player/video_player.dart';

class BacaanSholat extends StatefulWidget {
  const BacaanSholat({Key? key}) : super(key: key);

  @override
  _BacaanSholatState createState() => _BacaanSholatState();
}

class _BacaanSholatState extends State<BacaanSholat> {
  Future<List<ModelBacaan>> ReadJsonData() async {
    final jsondata =
        await rootBundle.rootBundle.loadString('assets/data/bacaanshalat.json');
    final list = json.decode(jsondata) as List<dynamic>;
    return list.map((e) => ModelBacaan.fromJson(e)).toList();
  }

  // Video controller untuk memutar video lokal
  VideoPlayerController? _controller;

  void _initializeVideo(String videoPath) {
    // Dispose controller lama jika ada
    if (_controller != null) {
      _controller!.dispose();
      _controller = null;
    }

    // Inisialisasi controller baru
    _controller = VideoPlayerController.asset(videoPath)
      ..initialize().then((_) {
        setState(() {}); // Perbarui UI
        _controller!.play(); // Mulai video
      }).catchError((error) {
        print("Error saat inisialisasi video: $error");
      });
  }

  @override
  void dispose() {
    _controller?.dispose(); // Hentikan video ketika widget dihancurkan
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0e1446),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header Layout
            Stack(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: const EdgeInsets.only(top: 80),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: const Color(0xff44aca0),
                    ),
                    height: 200,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      margin: const EdgeInsets.only(top: 120, left: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "Bacaan Sholat",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Bacaan sholat dari doa Iftitah sampai Salam",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder(
                future: ReadJsonData(),
                builder: (context, data) {
                  if (data.hasError) {
                    return Center(child: Text("${data.error}"));
                  } else if (data.hasData) {
                    var items = data.data as List<ModelBacaan>;
                    return ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        // Path video sesuai dengan nama file di folder assets/videos
                        String videoPath = "assets/videos/${items[index].id}.mp4";

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                          margin: const EdgeInsets.all(15),
                          child: Theme(
                            data: Theme.of(context)
                                .copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              title: Text(
                                items[index].name.toString(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        items[index].arabic.toString(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        items[index].latin.toString(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      Text(
                                        items[index].terjemahan.toString(),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(height: 10),
                                      // Tombol untuk memutar video
                                      ElevatedButton(
                                        onPressed: () {
                                          print("Memutar video: $videoPath");
                                          _initializeVideo(videoPath);
                                        },
                                        child: const Text("Lihat Video"),
                                      ),
                                      if (_controller != null && _controller!.value.isInitialized)
                                      Container(
                                        height: 500, // Tinggi video (atur sesuai kebutuhan)
                                        width: double.infinity, // Lebar video (atur sesuai kebutuhan)
                                        child: VideoPlayer(_controller!),
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
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}