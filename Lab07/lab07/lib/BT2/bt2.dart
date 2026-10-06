import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class BT2 extends StatelessWidget {
  const BT2({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bài 2 - Tìm đường',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const RouteFinderPage(),
    );
  }
}

class RouteFinderPage extends StatefulWidget {
  const RouteFinderPage({super.key});

  @override
  State<RouteFinderPage> createState() => _RouteFinderPageState();
}

class _RouteFinderPageState extends State<RouteFinderPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final TextEditingController _startController = TextEditingController(
    text: '10.7725, 106.6980',
  );

  final TextEditingController _endController = TextEditingController(
    text: '10.7769, 106.7009',
  );

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  static const LatLng _initialPosition = LatLng(
    10.7725,
    106.6980,
  );

  bool _isLoading = false;

  String _distanceText = '';
  String _durationText = '';

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  // ================================
  // CHUYỂN TEXT -> LATLNG
  // ================================

  LatLng? _parseLatLng(String text) {
    try {
      final parts = text.split(',');

      if (parts.length != 2) {
        return null;
      }

      final latitude = double.parse(parts[0].trim());
      final longitude = double.parse(parts[1].trim());

      if (latitude < -90 || latitude > 90) {
        return null;
      }

      if (longitude < -180 || longitude > 180) {
        return null;
      }

      return LatLng(latitude, longitude);
    } catch (_) {
      return null;
    }
  }

  // ================================
  // TÌM ĐƯỜNG BẰNG OSRM
  // ================================

  Future<void> _findRoute() async {
    final start = _parseLatLng(_startController.text);
    final end = _parseLatLng(_endController.text);

    if (start == null || end == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng nhập tọa độ đúng định dạng: latitude, longitude',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _polylines.clear();
      _distanceText = '';
      _durationText = '';
    });

    try {
      // OSRM yêu cầu thứ tự:
      // longitude,latitude
      final coordinates =
          '${start.longitude},${start.latitude};'
          '${end.longitude},${end.latitude}';

      final url =
          'https://router.project-osrm.org/route/v1/driving/'
          '$coordinates'
          '?overview=full'
          '&geometries=geojson';

      debugPrint('==============================');
      debugPrint('CALLING OSRM');
      debugPrint('START: ${start.latitude}, ${start.longitude}');
      debugPrint('END: ${end.latitude}, ${end.longitude}');
      debugPrint('URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/json',
        },
      );

      debugPrint('OSRM STATUS: ${response.statusCode}');
      debugPrint('OSRM RESPONSE: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
          'OSRM trả về HTTP ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body);

      if (data['code'] != 'Ok') {
        throw Exception(
          data['message'] ?? 'Không tìm thấy tuyến đường',
        );
      }

      final routes = data['routes'];

      if (routes == null || routes.isEmpty) {
        throw Exception('Không tìm thấy tuyến đường nào!');
      }

      final route = routes[0];

      // ================================
      // KHOẢNG CÁCH
      // ================================

      final distanceMeters =
          (route['distance'] as num).toDouble();

      // ================================
      // THỜI GIAN
      // ================================

      final durationSeconds =
          (route['duration'] as num).toDouble();

      // ================================
      // GEOJSON
      // ================================

      final geometry = route['geometry'];

      if (geometry == null ||
          geometry['coordinates'] == null) {
        throw Exception(
          'OSRM không trả về dữ liệu tuyến đường.',
        );
      }

      final coordinatesList =
          geometry['coordinates'] as List;

      final List<LatLng> routePoints = [];

      for (final coordinate in coordinatesList) {
        final longitude =
            (coordinate[0] as num).toDouble();

        final latitude =
            (coordinate[1] as num).toDouble();

        routePoints.add(
          LatLng(latitude, longitude),
        );
      }

      // ================================
      // FORMAT KHOẢNG CÁCH
      // ================================

      String distanceText;

      if (distanceMeters >= 1000) {
        distanceText =
            '${(distanceMeters / 1000).toStringAsFixed(2)} km';
      } else {
        distanceText =
            '${distanceMeters.toStringAsFixed(0)} m';
      }

      // ================================
      // FORMAT THỜI GIAN
      // ================================

      final durationMinutes =
          (durationSeconds / 60).round();

      String durationText;

      if (durationMinutes >= 60) {
        final hours = durationMinutes ~/ 60;
        final minutes = durationMinutes % 60;

        durationText = minutes == 0
            ? '$hours giờ'
            : '$hours giờ $minutes phút';
      } else {
        durationText = '$durationMinutes phút';
      }

      // ================================
      // MARKER
      // ================================

      final startMarker = Marker(
        markerId: const MarkerId('start'),
        position: start,
        infoWindow: const InfoWindow(
          title: 'Xuất phát',
        ),
      );

      final endMarker = Marker(
        markerId: const MarkerId('end'),
        position: end,
        infoWindow: const InfoWindow(
          title: 'Đích đến',
        ),
      );

      // ================================
      // POLYLINE
      // ================================

      final routePolyline = Polyline(
        polylineId: const PolylineId('route'),
        points: routePoints,
        width: 5,
        color: Colors.blue,
      );

      setState(() {
        _markers
          ..clear()
          ..add(startMarker)
          ..add(endMarker);

        _polylines
          ..clear()
          ..add(routePolyline);

        _distanceText = distanceText;
        _durationText = durationText;
      });

      // ================================
      // ĐƯA CAMERA NHÌN TOÀN BỘ ROUTE
      // ================================

      await _fitRouteToMap(routePoints);
    } catch (e) {
      debugPrint('OSRM ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lỗi tìm đường: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ================================
  // CAMERA BAO QUÁT TUYẾN ĐƯỜNG
  // ================================

  Future<void> _fitRouteToMap(
    List<LatLng> points,
  ) async {
    if (points.isEmpty) return;

    final controller = await _controller.future;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final point in points) {
      if (point.latitude < minLat) {
        minLat = point.latitude;
      }

      if (point.latitude > maxLat) {
        maxLat = point.latitude;
      }

      if (point.longitude < minLng) {
        minLng = point.longitude;
      }

      if (point.longitude > maxLng) {
        maxLng = point.longitude;
      }
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        bounds,
        80,
      ),
    );
  }

  // ================================
  // BUILD
  // ================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bài 2 - Tìm đường'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  controller: _startController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: const InputDecoration(
                    labelText:
                        'Điểm xuất phát (lat, lng)',
                    hintText:
                        'Ví dụ: 10.7725, 106.6980',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.location_on,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: _endController,
                  keyboardType:
                      const TextInputType.numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration: const InputDecoration(
                    labelText:
                        'Điểm đích (lat, lng)',
                    hintText:
                        'Ví dụ: 10.7769, 106.7009',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.flag,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        _isLoading ? null : _findRoute,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.directions,
                          ),
                    label: Text(
                      _isLoading
                          ? 'Đang tìm đường...'
                          : 'Tìm đường đi',
                    ),
                  ),
                ),

                if (_distanceText.isNotEmpty &&
                    _durationText.isNotEmpty)
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.straighten,
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _distanceText,
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              _durationText,
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
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

          Expanded(
            child: GoogleMap(
              initialCameraPosition:
                  const CameraPosition(
                target: _initialPosition,
                zoom: 14,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
              onMapCreated:
                  (GoogleMapController controller) {
                if (!_controller.isCompleted) {
                  _controller.complete(controller);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}