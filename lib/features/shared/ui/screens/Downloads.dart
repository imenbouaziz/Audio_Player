import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';

class Downloads extends StatefulWidget {
  Downloads({Key? key}) : super(key: key);

  @override
  State<Downloads> createState() => _DownloadsState();
}

class _DownloadsState extends State<Downloads> {
  FileDownloader _fileDownloader = FileDownloader();

  @override
  Widget build(BuildContext context) {
    final TextEditingController urlController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Downloads"),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Download icon logo
          const Icon(
            Icons.download_rounded,
            size: 100,
            color: Colors.white,
          ),

          // Textfield widget
          Padding(
            padding: const EdgeInsets.all(36.0),
            child: TextField(
              controller: urlController,
              decoration: const InputDecoration(
                hintText: "Please do insert MP3 link..",
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Elevated button to download MP3
          ElevatedButton(
            // if the download button is pressed, then fetch the mp3 file
            // from the inserted link, and then download it inside the
            // phone storage
            onPressed: () async {
              final inputUrl = urlController.text.trim();
              if (inputUrl.isNotEmpty) {
                final File? file = await FileDownloader.downloadFile(
                    url: inputUrl,
                    onProgress: (String? fileName, double progress) {
                      var _progress = progress;
                      setState(() => progress);
                    });
              }
            },
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(250, 70),
              backgroundColor: Colors.purple,
            ),
            child: const Text(
              "Download",
              style: TextStyle(fontSize: 18.0),
            ),
          ),
        ],
      ),
    );
  }
}
