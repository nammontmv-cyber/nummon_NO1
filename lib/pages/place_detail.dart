import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../models/place_model.dart';
import 'map.dart';

class PlaceDetailPage extends StatefulWidget {
  final Place place;
  final Function(Place) onAddToPlan;

  const PlaceDetailPage({
    super.key,
    required this.place,
    required this.onAddToPlan,
  });

  @override
  State<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage> {
  int _currentImageIndex = 0;
  late PageController _pageController;

  List<String> get _allImages {
    final urls = widget.place.imageUrls;
    if (urls != null && urls.isNotEmpty) return urls;
    if (widget.place.imageUrl.isNotEmpty) return [widget.place.imageUrl];
    return [];
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentImageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onThumbnailTap(int index) {
    setState(() => _currentImageIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _openFullscreenImageViewer(int initialIndex, List<String> images) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenImageViewer(
          images: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = _allImages;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.place.name),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                SizedBox(
                  height: 260,
                  child: images.isNotEmpty
                      ? PageView.builder(
                          controller: _pageController,
                          itemCount: images.length,
                          onPageChanged: (index) {
                            setState(() => _currentImageIndex = index);
                          },
                          itemBuilder: (context, index) {
                            // เช็คว่าเป็นรูปภาพหลัก/รูปแรกหรือไม่ ถ้าใช่ให้ดึง Alignment ที่ผู้ใช้กำหนดมาแสดงผล
                            final isFirstImage = index == 0 && images[index] == widget.place.imageUrl;

                            return GestureDetector(
                              onTap: () => _openFullscreenImageViewer(index, images),
                              child: Image.network(
                                images[index],
                                width: double.infinity,
                                height: 260,
                                fit: BoxFit.cover,
                                alignment: isFirstImage 
                                    ? Alignment(0, widget.place.imageAlignmentY) 
                                    : Alignment.center, // รูปอื่นๆ ให้จัดกึ่งกลางปกติ
                                errorBuilder: (context, error, stackTrace) => const SizedBox(
                                  height: 260,
                                  child: Center(child: Icon(Icons.broken_image, size: 80)),
                                ),
                              ),
                            );
                          },
                        )
                      : const SizedBox(
                          height: 260,
                          child: Center(child: Icon(Icons.broken_image, size: 80)),
                        ),
                ),
                if (images.length > 1)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "${_currentImageIndex + 1} / ${images.length}",
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),

            if (images.length > 1)
              Container(
                height: 78,
                margin: const EdgeInsets.only(top: 8, bottom: 4),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final isSelected = index == _currentImageIndex;
                    return GestureDetector(
                      onTap: () => _onThumbnailTap(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 72,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.teal : Colors.grey.shade300,
                            width: isSelected ? 2.5 : 1.5,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: Colors.teal.withOpacity(0.3), blurRadius: 4, spreadRadius: 1)]
                              : [],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                images[index],
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Icon(Icons.broken_image, color: Colors.grey),
                              ),
                              if (isSelected)
                                Container(color: Colors.teal.withOpacity(0.15)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.place.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.red, size: 20),
                      const SizedBox(width: 4),
                      Text(widget.place.district,
                          style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("ລາຍລະອຽດ",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(widget.place.description ?? "ບໍ່ມີລາຍລະອຽดສະຖານທີ່ໃນຕອນນີ້"),
                  const SizedBox(height: 24),

                  const Text("ຕຳແໜ່ງສະຖານທີ່",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapPage(
                            latitude: widget.place.latitude,
                            longitude: widget.place.longitude,
                            placeName: widget.place.name,
                          ),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: AbsorbPointer(
                          absorbing: true,
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: ll.LatLng(
                                  widget.place.latitude, widget.place.longitude),
                              initialZoom: 14,
                              interactionOptions: const InteractionOptions(
                                flags: InteractiveFlag.none,
                              ),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.abc_new',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: ll.LatLng(
                                        widget.place.latitude, widget.place.longitude),
                                    width: 40,
                                    height: 40,
                                    child: const Icon(Icons.location_pin,
                                        color: Colors.red, size: 40),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      widget.onAddToPlan(widget.place);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("ເພີ່ມເຂົ້າໃນແຜน"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FullscreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullscreenImageViewer({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: Center(
                  child: Image.network(
                    widget.images[index],
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${_currentIndex + 1} / ${widget.images.length}",
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}