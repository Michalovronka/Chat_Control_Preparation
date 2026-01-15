import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import '../widgets/glass_message_bubble.dart';

class MessageBubbleBuilder extends StatefulWidget {
  final Map<String, dynamic> message;

  const MessageBubbleBuilder({super.key, required this.message});

  @override
  State<MessageBubbleBuilder> createState() => _MessageBubbleBuilderState();
}

class _MessageBubbleBuilderState extends State<MessageBubbleBuilder> {
  Uint8List? _imageBytes;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.message.containsKey("imagePath") || widget.message["isImage"] == true) {
      // Delay slightly to ensure image is available on server
      Future.delayed(Duration(milliseconds: 100), () {
        if (mounted) {
          _loadImage();
        }
      });
    }
  }

  @override
  void didUpdateWidget(MessageBubbleBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload image if the imagePath changed
    final oldPath = oldWidget.message["imagePath"];
    final newPath = widget.message["imagePath"];
    if ((widget.message.containsKey("imagePath") || widget.message["isImage"] == true) &&
        oldPath != newPath) {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _imageBytes = null;
      });
      _loadImage();
    }
  }

  void _showFullScreenImage(BuildContext context) {
    if (_imageBytes == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: IconThemeData(color: Colors.white),
            title: Text(
              widget.message["sender"]?.toString() ?? "Image",
              style: TextStyle(
                fontFamily: 'Jura',
                color: Colors.white,
              ),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.memory(
                _imageBytes!,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loadImage() async {
    final imagePath = widget.message["imagePath"];
    if (imagePath == null || imagePath is! String) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
      return;
    }

    try {
      // Always load from network URL (works on all platforms)
      print('Loading image from: $imagePath');
      final response = await http.get(Uri.parse(imagePath));
      if (response.statusCode == 200) {
        setState(() {
          _imageBytes = response.bodyBytes;
          _isLoading = false;
        });
        print('Image loaded successfully');
      } else {
        print('Failed to load image: ${response.statusCode}');
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    } catch (e) {
      print('Error loading image from $imagePath: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.message.containsKey("imagePath") || widget.message["isImage"] == true) {
      final sender = widget.message["sender"]?.toString() ?? "Unknown";
      final isMe = widget.message["isMe"] == true;
      
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Sender name above image
              Padding(
                padding: EdgeInsets.only(bottom: 4, left: isMe ? 0 : 4, right: isMe ? 4 : 0),
                child: Text(
                  sender,
                  style: TextStyle(
                    fontFamily: 'Jura',
                    fontWeight: FontWeight.bold,
                    color: isMe
                        ? const Color.fromARGB(255, 0, 255, 170)
                        : const Color.fromARGB(255, 255, 255, 255),
                    fontSize: 14,
                  ),
                ),
              ),
              // Image (tappable to enlarge)
              GestureDetector(
                onTap: _imageBytes != null && !_isLoading && !_hasError
                    ? () => _showFullScreenImage(context)
                    : null,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _isLoading
                      ? Container(
                          width: 200,
                          height: 200,
                          color: Colors.grey.withOpacity(0.2),
                          child: Center(
                            child: CircularProgressIndicator(color: Colors.white70),
                          ),
                        )
                      : _hasError || _imageBytes == null
                          ? Container(
                              width: 200,
                              height: 200,
                              color: Colors.grey.withOpacity(0.2),
                              child: Icon(Icons.broken_image, color: Colors.white70),
                            )
                          : Image.memory(
                              _imageBytes!,
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 200,
                                  height: 200,
                                  color: Colors.grey.withOpacity(0.2),
                                  child: Icon(Icons.broken_image, color: Colors.white70),
                                );
                              },
                            ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return GlassMessageBubble(
        sender: widget.message["sender"],
        content: widget.message["content"],
        isMe: widget.message["isMe"],
      );
    }
  }
}
