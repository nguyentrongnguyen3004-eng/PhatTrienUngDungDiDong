import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class BT4 extends StatelessWidget {
  const BT4({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bài 4 - Google Maps',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const BT4Page(),
    );
  }
}

class BT4Page extends StatefulWidget {
  const BT4Page({super.key});

  @override
  State<BT4Page> createState() => _BT4PageState();
}

class _BT4PageState extends State<BT4Page> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final TextEditingController _startController =
      TextEditingController(
    text: '10.7660,	106.6380',
  );

  final TextEditingController _endController =
      TextEditingController();

  final TextEditingController _searchController =
      TextEditingController();

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  static const LatLng _initialPosition =
      LatLng(10.7769, 106.7009);

  LatLng? _startPosition;
  LatLng? _endPosition;

  bool _isLoadingRoute = false;
  bool _isGettingLocation = false;
  bool _isSearching = false;

  String _distanceText = '';
  String _durationText = '';

  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();

    _startPosition = _parseLatLng(
      _startController.text,
    );

    if (_startPosition != null) {
      _markers.add(
        Marker(
          markerId: const MarkerId('start'),
          position: _startPosition!,
          infoWindow: const InfoWindow(
            title: 'Xuất phát',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // CHUYỂN CHUỖI LAT, LNG THÀNH LATLNG
  // ============================================================

  LatLng? _parseLatLng(String text) {
    try {
      final parts = text.split(',');

      if (parts.length != 2) {
        return null;
      }

      final latitude =
          double.parse(parts[0].trim());

      final longitude =
          double.parse(parts[1].trim());

      if (latitude < -90 || latitude > 90) {
        return null;
      }

      if (longitude < -180 || longitude > 180) {
        return null;
      }

      return LatLng(
        latitude,
        longitude,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // HIỂN THỊ THÔNG BÁO
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // KIỂM TRA QUYỀN VỊ TRÍ
  // ============================================================

  Future<bool> _checkLocationPermission() async {
    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      _showMessage(
        'Vui lòng bật GPS trên thiết bị.',
      );
      return false;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      _showMessage(
        'Bạn chưa cấp quyền vị trí.',
      );
      return false;
    }

    if (permission ==
        LocationPermission.deniedForever) {
      _showMessage(
        'Quyền vị trí đã bị từ chối vĩnh viễn. '
        'Hãy cấp quyền trong phần Cài đặt.',
      );
      return false;
    }

    return true;
  }

  // ============================================================
  // LẤY VỊ TRÍ HIỆN TẠI
  // ============================================================

  Future<LatLng?> _getCurrentLocation() async {
    final permission =
        await _checkLocationPermission();

    if (!permission) {
      return null;
    }

    try {
      final position =
          await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      return LatLng(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      _showMessage(
        'Không thể lấy vị trí hiện tại.',
      );
      return null;
    }
  }

  // ============================================================
  // LẤY VỊ TRÍ HIỆN TẠI LÀM ĐIỂM ĐÍCH
  // ============================================================

  Future<void> _setCurrentLocationAsDestination() async {
    if (_isGettingLocation) return;

    setState(() {
      _isGettingLocation = true;
    });

    final currentPosition =
        await _getCurrentLocation();

    if (currentPosition != null) {
      setState(() {
        _endPosition = currentPosition;

        _endController.text =
            '${currentPosition.latitude.toStringAsFixed(6)}, '
            '${currentPosition.longitude.toStringAsFixed(6)}';

        _markers.removeWhere(
          (marker) =>
              marker.markerId.value == 'end',
        );

        _markers.add(
          Marker(
            markerId: const MarkerId('end'),
            position: currentPosition,
            infoWindow: const InfoWindow(
              title: 'Vị trí hiện tại',
              snippet: 'Điểm đích',
            ),
          ),
        );
      });

      await _moveCamera(currentPosition);
    }

    if (mounted) {
      setState(() {
        _isGettingLocation = false;
      });
    }
  }

  // ============================================================
  // DI CHUYỂN CAMERA
  // ============================================================

  Future<void> _moveCamera(LatLng position) async {
    if (!_controller.isCompleted) {
      return;
    }

    final controller =
        await _controller.future;

    await controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        position,
        15,
      ),
    );
  }

  // ============================================================
  // XỬ LÝ CLICK TRÊN BẢN ĐỒ
  // ============================================================

  void _onMapTapped(LatLng position) {
    setState(() {
      _endPosition = position;

      _endController.text =
          '${position.latitude.toStringAsFixed(6)}, '
          '${position.longitude.toStringAsFixed(6)}';

      _markers.removeWhere(
        (marker) =>
            marker.markerId.value == 'end',
      );

      _markers.add(
        Marker(
          markerId: const MarkerId('end'),
          position: position,
          infoWindow: const InfoWindow(
            title: 'Điểm đích',
            snippet: 'Được chọn trên bản đồ',
          ),
        ),
      );

      _polylines.clear();
      _distanceText = '';
      _durationText = '';
    });

    _showMessage(
      'Đã chọn điểm đích trên bản đồ.',
    );
  }

  // ============================================================
  // TÌM ĐƯỜNG BẰNG OSRM
  // ============================================================

  Future<void> _findRoute() async {
    final start =
        _parseLatLng(_startController.text);

    final end =
        _parseLatLng(_endController.text);

    if (start == null) {
      _showMessage(
        'Điểm xuất phát không hợp lệ.',
      );
      return;
    }

    if (end == null) {
      _showMessage(
        'Điểm đích không hợp lệ.',
      );
      return;
    }

    setState(() {
      _startPosition = start;
      _endPosition = end;
      _isLoadingRoute = true;
      _polylines.clear();
      _distanceText = '';
      _durationText = '';
    });

    try {
      final coordinates =
          '${start.longitude},${start.latitude};'
          '${end.longitude},${end.latitude}';

      final url =
          'https://router.project-osrm.org/route/v1/driving/'
          '$coordinates'
          '?overview=full'
          '&geometries=geojson';

      debugPrint('================================');
      debugPrint('CALLING OSRM - BÀI 4');
      debugPrint(
        'START: '
        '${start.latitude}, ${start.longitude}',
      );
      debugPrint(
        'END: '
        '${end.latitude}, ${end.longitude}',
      );
      debugPrint('URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: const {
          'Accept': 'application/json',
        },
      );

      debugPrint(
        'OSRM STATUS: ${response.statusCode}',
      );
      debugPrint(
        'OSRM RESPONSE: ${response.body}',
      );

      if (response.statusCode != 200) {
        throw Exception(
          'OSRM trả về HTTP '
          '${response.statusCode}',
        );
      }

      final data =
          jsonDecode(response.body);

      if (data['code'] != 'Ok') {
        throw Exception(
          data['message'] ??
              'Không tìm thấy tuyến đường.',
        );
      }

      final routes = data['routes'];

      if (routes == null ||
          routes.isEmpty) {
        throw Exception(
          'Không tìm thấy tuyến đường nào.',
        );
      }

      final route = routes[0];

      // --------------------------------------------------------
      // KHOẢNG CÁCH
      // --------------------------------------------------------

      final distanceMeters =
          (route['distance'] as num)
              .toDouble();

      // --------------------------------------------------------
      // THỜI GIAN
      // --------------------------------------------------------

      final durationSeconds =
          (route['duration'] as num)
              .toDouble();

      // --------------------------------------------------------
      // GEOJSON
      // --------------------------------------------------------

      final geometry =
          route['geometry'];

      if (geometry == null ||
          geometry['coordinates'] == null) {
        throw Exception(
          'Không có dữ liệu hình học của tuyến đường.',
        );
      }

      final coordinatesList =
          geometry['coordinates'] as List;

      final List<LatLng> routePoints = [];

      for (final coordinate
          in coordinatesList) {
        final longitude =
            (coordinate[0] as num)
                .toDouble();

        final latitude =
            (coordinate[1] as num)
                .toDouble();

        routePoints.add(
          LatLng(
            latitude,
            longitude,
          ),
        );
      }

      // --------------------------------------------------------
      // FORMAT KHOẢNG CÁCH
      // --------------------------------------------------------

      String distanceText;

      if (distanceMeters >= 1000) {
        distanceText =
            '${(distanceMeters / 1000).toStringAsFixed(2)} km';
      } else {
        distanceText =
            '${distanceMeters.toStringAsFixed(0)} m';
      }

      // --------------------------------------------------------
      // FORMAT THỜI GIAN
      // --------------------------------------------------------

      final durationMinutes =
          (durationSeconds / 60).round();

      String durationText;

      if (durationMinutes >= 60) {
        final hours =
            durationMinutes ~/ 60;

        final minutes =
            durationMinutes % 60;

        if (minutes == 0) {
          durationText =
              '$hours giờ';
        } else {
          durationText =
              '$hours giờ $minutes phút';
        }
      } else {
        durationText =
            '$durationMinutes phút';
      }

      // --------------------------------------------------------
      // MARKERS
      // --------------------------------------------------------

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

      // --------------------------------------------------------
      // POLYLINE
      // --------------------------------------------------------

      final routePolyline = Polyline(
        polylineId:
            const PolylineId('route'),
        points: routePoints,
        width: 5,
        color: Colors.blue,
      );

      setState(() {
        _startPosition = start;
        _endPosition = end;

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

      await _fitRouteToMap(
        routePoints,
      );
    } catch (e) {
      debugPrint(
        'OSRM ERROR: $e',
      );

      if (mounted) {
        _showMessage(
          'Lỗi tìm đường: $e',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRoute = false;
        });
      }
    }
  }

  // ============================================================
  // CAMERA BAO QUÁT TUYẾN ĐƯỜNG
  // ============================================================

  Future<void> _fitRouteToMap(
    List<LatLng> points,
  ) async {
    if (points.isEmpty ||
        !_controller.isCompleted) {
      return;
    }

    final controller =
        await _controller.future;

    double minLat =
        points.first.latitude;

    double maxLat =
        points.first.latitude;

    double minLng =
        points.first.longitude;

    double maxLng =
        points.first.longitude;

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
      southwest: LatLng(
        minLat,
        minLng,
      ),
      northeast: LatLng(
        maxLat,
        maxLng,
      ),
    );

    try {
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          bounds,
          80,
        ),
      );
    } catch (_) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          points.first,
          14,
        ),
      );
    }
  }

  // ============================================================
  // TÌM KIẾM ĐỊA ĐIỂM
  // ============================================================

  Future<void> _searchPlace() async {
    final query =
        _searchController.text.trim();

    if (query.isEmpty) {
      _showMessage(
        'Vui lòng nhập địa điểm cần tìm.',
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = [];
    });

    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        {
          'q': query,
          'format': 'jsonv2',
          'limit': '5',
          'countrycodes': 'vn',
          'addressdetails': '1',
        },
      );

      debugPrint(
        'SEARCH URL: $uri',
      );

      final response = await http.get(
        uri,
        headers: const {
          'Accept':
              'application/json',
          'User-Agent':
              'Flutter-Bai07-Maps/1.0',
        },
      );

      debugPrint(
        'SEARCH STATUS: '
        '${response.statusCode}',
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Không thể tìm kiếm địa điểm.',
        );
      }

      final List<dynamic> data =
          jsonDecode(response.body);

      if (data.isEmpty) {
        _showMessage(
          'Không tìm thấy địa điểm.',
        );
      }

      if (mounted) {
        setState(() {
          _searchResults =
              data.cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      _showMessage(
        'Lỗi tìm kiếm địa điểm: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  // ============================================================
  // CHỌN KẾT QUẢ TÌM KIẾM
  // ============================================================

  Future<void> _selectSearchResult(
    Map<String, dynamic> result,
  ) async {
    final latitude =
        double.tryParse(
      result['lat'].toString(),
    );

    final longitude =
        double.tryParse(
      result['lon'].toString(),
    );

    if (latitude == null ||
        longitude == null) {
      return;
    }

    final position =
        LatLng(latitude, longitude);

    setState(() {
      _endPosition = position;

      _endController.text =
          '${latitude.toStringAsFixed(6)}, '
          '${longitude.toStringAsFixed(6)}';

      _markers.removeWhere(
        (marker) =>
            marker.markerId.value == 'end',
      );

      _markers.add(
        Marker(
          markerId: const MarkerId('end'),
          position: position,
          infoWindow: InfoWindow(
            title: 'Điểm đích',
            snippet:
                result['display_name'] ??
                    'Địa điểm được tìm kiếm',
          ),
        ),
      );

      _searchResults.clear();
    });

    await _moveCamera(position);
  }

  // ============================================================
  // XÓA TUYẾN ĐƯỜNG
  // ============================================================

  void _clearRoute() {
    setState(() {
      _polylines.clear();
      _distanceText = '';
      _durationText = '';

      _markers.clear();

      if (_startPosition != null) {
        _markers.add(
          Marker(
            markerId:
                const MarkerId('start'),
            position: _startPosition!,
            infoWindow: const InfoWindow(
              title: 'Xuất phát',
            ),
          ),
        );
      }

      if (_endPosition != null) {
        _markers.add(
          Marker(
            markerId:
                const MarkerId('end'),
            position: _endPosition!,
            infoWindow: const InfoWindow(
              title: 'Đích đến',
            ),
          ),
        );
      }
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bài 4 - Google Maps',
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // ====================================================
          // KHU VỰC NHẬP TỌA ĐỘ
          // ====================================================

          Padding(
            padding:
                const EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  controller:
                      _startController,
                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Điểm xuất phát (lat, lng)',
                    hintText:
                        '10.7725, 106.6980',
                    border:
                        OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.location_on,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller:
                      _endController,
                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    decimal: true,
                    signed: true,
                  ),
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Điểm đích (lat, lng)',
                    hintText:
                        '10.7769, 106.7009',
                    border:
                        OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.flag,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            _isGettingLocation
                                ? null
                                : _setCurrentLocationAsDestination,
                        icon:
                            _isGettingLocation
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.my_location,
                                  ),
                        label: const Text(
                          'Vị trí hiện tại',
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            _isLoadingRoute
                                ? null
                                : _findRoute,
                        icon: _isLoadingRoute
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                ),
                              )
                            : const Icon(
                                Icons.directions,
                              ),
                        label: Text(
                          _isLoadingRoute
                              ? 'Đang tìm...'
                              : 'Tìm đường',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // =================================================
                // TÌM KIẾM ĐỊA ĐIỂM
                // =================================================

                TextField(
                  controller:
                      _searchController,
                  textInputAction:
                      TextInputAction.search,
                  onSubmitted: (_) =>
                      _searchPlace(),
                  decoration:
                      InputDecoration(
                    labelText:
                        'Tìm địa điểm',
                    hintText:
                        'Ví dụ: bệnh viện, khách sạn, quán ăn...',
                    border:
                        const OutlineInputBorder(),
                    prefixIcon:
                        const Icon(
                      Icons.search,
                    ),
                    suffixIcon:
                        _isSearching
                            ? const Padding(
                                padding:
                                    EdgeInsets.all(
                                  12,
                                ),
                                child:
                                    SizedBox(
                                  width: 18,
                                  height: 18,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth:
                                        2,
                                  ),
                                ),
                              )
                            : IconButton(
                                icon:
                                    const Icon(
                                  Icons.search,
                                ),
                                onPressed:
                                    _searchPlace,
                              ),
                  ),
                ),

                // =================================================
                // DANH SÁCH KẾT QUẢ TÌM KIẾM
                // =================================================

                if (_searchResults.isNotEmpty)
                  Container(
                    constraints:
                        const BoxConstraints(
                      maxHeight: 160,
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount:
                          _searchResults.length,
                      itemBuilder:
                          (context, index) {
                        final result =
                            _searchResults[index];

                        return ListTile(
                          dense: true,
                          leading:
                              const Icon(
                            Icons.place,
                          ),
                          title: Text(
                            result[
                                    'display_name'] ??
                                'Không có tên',
                            maxLines: 2,
                            overflow:
                                TextOverflow
                                    .ellipsis,
                          ),
                          onTap: () =>
                              _selectSearchResult(
                            result,
                          ),
                        );
                      },
                    ),
                  ),

                // =================================================
                // KHOẢNG CÁCH + THỜI GIAN
                // =================================================

                if (_distanceText
                        .isNotEmpty &&
                    _durationText
                        .isNotEmpty)
                  Container(
                    margin:
                        const EdgeInsets.only(
                      top: 8,
                    ),
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration:
                        BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(
                        8,
                      ),
                      color: Colors.blue
                          .withValues(
                        alpha: 0.08,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceAround,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons
                                  .straighten,
                              size: 20,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              _distanceText,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons
                                  .access_time,
                              size: 20,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              _durationText,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 5),

                // =================================================
                // NÚT XÓA
                // =================================================

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed:
                        _clearRoute,
                    icon: const Icon(
                      Icons.clear,
                    ),
                    label: const Text(
                      'Xóa tuyến đường',
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ====================================================
          // GOOGLE MAP
          // ====================================================

          Expanded(
            child: GoogleMap(
              initialCameraPosition:
                  const CameraPosition(
                target: _initialPosition,
                zoom: 13,
              ),
              markers: _markers,
              polylines: _polylines,

              myLocationEnabled: true,

              myLocationButtonEnabled:
                  true,

              zoomControlsEnabled: true,

              onMapCreated:
                  (GoogleMapController
                      controller) {
                if (!_controller
                    .isCompleted) {
                  _controller.complete(
                    controller,
                  );
                }
              },

              onTap: _onMapTapped,
            ),
          ),
        ],
      ),
    );
  }
}