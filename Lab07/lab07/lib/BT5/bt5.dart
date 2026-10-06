import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class BT5 extends StatelessWidget {
  const BT5({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bài 5 - Tìm đường',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        fontFamily: 'Roboto',
      ),
      home: const BT5Page(),
    );
  }
}

class BT5Page extends StatefulWidget {
  const BT5Page({super.key});

  @override
  State<BT5Page> createState() => _BT5PageState();
}

class _BT5PageState extends State<BT5Page> {
  // ============================================================
  // GOOGLE MAP
  // ============================================================

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const LatLng _defaultLocation = LatLng(
    10.7725,
    106.6980,
  );

  // ============================================================
  // TEXT CONTROLLERS
  // ============================================================

  final TextEditingController _startController =
      TextEditingController(text: 'Chợ Bến Thành');

  final TextEditingController _destinationController =
      TextEditingController(text: 'Landmark 81');

  // ============================================================
  // LOCATION
  // ============================================================

  LatLng? _startPosition;
  LatLng? _destinationPosition;

  // ============================================================
  // MAP DATA
  // ============================================================

  Set<Marker> _markers = {};

  Set<Polyline> _polylines = {};

  List<LatLng> _routePoints = [];

  // ============================================================
  // VEHICLE
  // ============================================================

  String _selectedVehicle = 'Đi bộ';

  // ============================================================
  // RESULT
  // ============================================================

  String _distanceText = '';
  String _durationText = '';

  String _errorText = '';

  bool _isLoadingGeocode = false;
  bool _isLoadingRoute = false;

  // ============================================================
  // DATABASE
  // ============================================================

  Database? _database;

  List<Map<String, dynamic>> _favoriteRoutes = [];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _initializeDatabase();
  }

  @override
  void dispose() {
    _startController.dispose();
    _destinationController.dispose();

    super.dispose();
  }

  // ============================================================
  // DATABASE
  // ============================================================

  Future<void> _initializeDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();

      final dbPath = path.join(
        databasesPath,
        'bai07_bt5.db',
      );

      _database = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE favorite_routes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              start_address TEXT NOT NULL,
              end_address TEXT NOT NULL,
              start_lat REAL NOT NULL,
              start_lng REAL NOT NULL,
              end_lat REAL NOT NULL,
              end_lng REAL NOT NULL,
              vehicle TEXT NOT NULL,
              distance TEXT NOT NULL,
              duration TEXT NOT NULL,
              created_at TEXT NOT NULL
            )
          ''');
        },
      );

      await _loadFavoriteRoutes();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorText = 'Lỗi khởi tạo SQLite: $e';
      });
    }
  }

  Future<void> _loadFavoriteRoutes() async {
    if (_database == null) return;

    try {
      final data = await _database!.query(
        'favorite_routes',
        orderBy: 'id DESC',
      );

      if (!mounted) return;

      setState(() {
        _favoriteRoutes = data;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorText = 'Lỗi đọc tuyến yêu thích: $e';
      });
    }
  }

  Future<void> _saveFavoriteRoute() async {
    if (_database == null) {
      _showMessage('Cơ sở dữ liệu chưa sẵn sàng.');
      return;
    }

    if (_startPosition == null || _destinationPosition == null) {
      _showMessage('Vui lòng tìm đường trước khi lưu.');
      return;
    }

    if (_routePoints.isEmpty) {
      _showMessage('Chưa có tuyến đường để lưu.');
      return;
    }

    try {
      await _database!.insert(
        'favorite_routes',
        {
          'start_address': _startController.text.trim(),
          'end_address': _destinationController.text.trim(),
          'start_lat': _startPosition!.latitude,
          'start_lng': _startPosition!.longitude,
          'end_lat': _destinationPosition!.latitude,
          'end_lng': _destinationPosition!.longitude,
          'vehicle': _selectedVehicle,
          'distance': _distanceText,
          'duration': _durationText,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      await _loadFavoriteRoutes();

      _showMessage('Đã lưu tuyến đường yêu thích.');
    } catch (e) {
      _showMessage('Lỗi lưu tuyến đường: $e');
    }
  }

  Future<void> _deleteFavoriteRoute(int id) async {
    if (_database == null) return;

    try {
      await _database!.delete(
        'favorite_routes',
        where: 'id = ?',
        whereArgs: [id],
      );

      await _loadFavoriteRoutes();

      _showMessage('Đã xóa tuyến đường.');
    } catch (e) {
      _showMessage('Lỗi xóa tuyến đường: $e');
    }
  }

  // ============================================================
  // GEOCODING
  // ============================================================

  Future<LatLng?> _geocodeAddress(String address) async {
    final query = address.trim();

    if (query.isEmpty) {
      return null;
    }

    try {
      final uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        {
          'q': '$query, Việt Nam',
          'format': 'jsonv2',
          'limit': '1',
          'countrycodes': 'vn',
          'addressdetails': '1',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'Flutter-Bai07-BT5/1.0',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Geocoding HTTP ${response.statusCode}',
        );
      }

      final List<dynamic> results = jsonDecode(response.body);

      if (results.isEmpty) {
        return null;
      }

      final result = results.first;

      final double latitude =
          double.parse(result['lat'].toString());

      final double longitude =
          double.parse(result['lon'].toString());

      return LatLng(
        latitude,
        longitude,
      );
    } catch (e) {
      debugPrint('Geocoding error: $e');
      return null;
    }
  }

  // ============================================================
  // TÌM ĐỊA CHỈ
  // ============================================================

  Future<void> _searchAddresses() async {
    final startAddress = _startController.text.trim();
    final destinationAddress =
        _destinationController.text.trim();

    if (startAddress.isEmpty ||
        destinationAddress.isEmpty) {
      _showMessage(
        'Vui lòng nhập đầy đủ địa chỉ.',
      );
      return;
    }

    setState(() {
      _isLoadingGeocode = true;
      _errorText = '';
      _distanceText = '';
      _durationText = '';
      _routePoints = [];
      _polylines = {};
    });

    try {
      final results = await Future.wait([
        _geocodeAddress(startAddress),
        _geocodeAddress(destinationAddress),
      ]);

      final start = results[0];
      final destination = results[1];

      if (start == null) {
        throw Exception(
          'Không tìm thấy địa chỉ xuất phát.',
        );
      }

      if (destination == null) {
        throw Exception(
          'Không tìm thấy địa chỉ đích.',
        );
      }

      _startPosition = start;
      _destinationPosition = destination;

      _updateMarkers();

      await _moveCameraToPoints(
        start,
        destination,
      );
    } catch (e) {
      setState(() {
        _errorText = 'Lỗi tìm địa chỉ: $e';
      });
    } finally {
      setState(() {
        _isLoadingGeocode = false;
      });
    }
  }

  // ============================================================
  // MARKERS
  // ============================================================

  void _updateMarkers() {
    final Set<Marker> newMarkers = {};

    if (_startPosition != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('start'),
          position: _startPosition!,
          infoWindow: InfoWindow(
            title: 'Điểm xuất phát',
            snippet: _startController.text,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
        ),
      );
    }

    if (_destinationPosition != null) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: _destinationPosition!,
          infoWindow: InfoWindow(
            title: 'Điểm đến',
            snippet: _destinationController.text,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueRed,
          ),
        ),
      );
    }

    setState(() {
      _markers = newMarkers;
    });
  }

  // ============================================================
  // CAMERA
  // ============================================================

  Future<void> _moveCameraToPoints(
    LatLng start,
    LatLng destination,
  ) async {
    try {
      final controller = await _controller.future;

      final double minLat = start.latitude < destination.latitude
          ? start.latitude
          : destination.latitude;

      final double maxLat = start.latitude > destination.latitude
          ? start.latitude
          : destination.latitude;

      final double minLng = start.longitude < destination.longitude
          ? start.longitude
          : destination.longitude;

      final double maxLng = start.longitude > destination.longitude
          ? start.longitude
          : destination.longitude;

      if ((maxLat - minLat).abs() < 0.0001 &&
          (maxLng - minLng).abs() < 0.0001) {
        await controller.animateCamera(
          CameraUpdate.newLatLngZoom(
            start,
            15,
          ),
        );

        return;
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

      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          bounds,
          80,
        ),
      );
    } catch (e) {
      debugPrint(
        'Camera error: $e',
      );
    }
  }

  Future<void> _fitRoute(
    List<LatLng> points,
  ) async {
    if (points.isEmpty) return;

    try {
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

      final controller = await _controller.future;

      if ((maxLat - minLat).abs() < 0.0001 &&
          (maxLng - minLng).abs() < 0.0001) {
        await controller.animateCamera(
          CameraUpdate.newLatLngZoom(
            points.first,
            15,
          ),
        );

        return;
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

      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          bounds,
          70,
        ),
      );
    } catch (e) {
      debugPrint(
        'Fit route error: $e',
      );
    }
  }

  // ============================================================
  // VEHICLE
  // ============================================================

  String _getCosting() {
    switch (_selectedVehicle) {
      case 'Ô tô':
        return 'auto';

      case 'Xe máy':
        return 'motor_scooter';

      case 'Đi bộ':
        return 'pedestrian';

      default:
        return 'auto';
    }
  }

  // ============================================================
  // VALHALLA ROUTE
  // ============================================================

  Future<void> _findRoute() async {
    if (_startPosition == null ||
        _destinationPosition == null) {
      await _searchAddresses();

      if (_startPosition == null ||
          _destinationPosition == null) {
        return;
      }
    }

    setState(() {
      _isLoadingRoute = true;
      _errorText = '';
      _distanceText = '';
      _durationText = '';
      _routePoints = [];
      _polylines = {};
    });

    try {
      final costing = _getCosting();

      final response = await http.post(
        Uri.parse(
          'https://valhalla1.openstreetmap.de/route',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client-Id': 'flutter-bai07-bt5',
        },
        body: jsonEncode({
          'locations': [
            {
              'lat': _startPosition!.latitude,
              'lon': _startPosition!.longitude,
              'type': 'break',
            },
            {
              'lat': _destinationPosition!.latitude,
              'lon': _destinationPosition!.longitude,
              'type': 'break',
            },
          ],
          'costing': costing,
          'units': 'kilometers',
          'shape_format': 'polyline6',
          'directions_options': {
            'units': 'kilometers',
            'language': 'vi-VN',
          },
        }),
      );

      debugPrint(
        'VALHALLA STATUS: ${response.statusCode}',
      );

      debugPrint(
        'VALHALLA RESPONSE: ${response.body}',
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Valhalla HTTP ${response.statusCode}: ${response.body}',
        );
      }

      final dynamic data = jsonDecode(
        response.body,
      );

      if (data is! Map<String, dynamic>) {
        throw Exception(
          'Dữ liệu Valhalla không hợp lệ.',
        );
      }

      final trip = data['trip'];

      if (trip is! Map<String, dynamic>) {
        throw Exception(
          'Không tìm thấy dữ liệu tuyến đường.',
        );
      }

      // ----------------------------------------------------------
      // SUMMARY
      // ----------------------------------------------------------

      final summary = trip['summary'];

      if (summary is! Map<String, dynamic>) {
        throw Exception(
          'Không tìm thấy thông tin khoảng cách/thời gian.',
        );
      }

      final double distance =
          (summary['length'] as num?)?.toDouble() ?? 0.0;

      final double timeSeconds =
          (summary['time'] as num?)?.toDouble() ?? 0.0;

      final int totalMinutes =
          (timeSeconds / 60).round();

      final int hours =
          totalMinutes ~/ 60;

      final int minutes =
          totalMinutes % 60;

      String durationText;

      if (hours > 0) {
        durationText =
            '$hours giờ $minutes phút';
      } else {
        durationText =
            '$minutes phút';
      }

      // ----------------------------------------------------------
      // GET SHAPE
      // ----------------------------------------------------------

      final legs = trip['legs'];

      if (legs is! List || legs.isEmpty) {
        throw Exception(
          'Không tìm thấy dữ liệu tuyến đường.',
        );
      }

      final firstLeg = legs.first;

      if (firstLeg is! Map<String, dynamic>) {
        throw Exception(
          'Dữ liệu chặng đường không hợp lệ.',
        );
      }

      final shape = firstLeg['shape'];

      if (shape is! String || shape.isEmpty) {
        throw Exception(
          'Dữ liệu đường đi không hợp lệ.',
        );
      }

      // ----------------------------------------------------------
      // DECODE POLYLINE6
      // ----------------------------------------------------------

      final routePoints =
          _decodePolyline6Safe(shape);

      if (routePoints.isEmpty) {
        throw Exception(
          'Không giải mã được tuyến đường.',
        );
      }

      setState(() {
        _routePoints = routePoints;

        _polylines = {
          Polyline(
            polylineId:
                const PolylineId('route'),
            points: routePoints,
            width: 6,
            color: Colors.blue,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
            jointType: JointType.round,
          ),
        };

        _distanceText =
            '${distance.toStringAsFixed(2)} km';

        _durationText =
            durationText;

        _errorText = '';
      });

      await _fitRoute(
        routePoints,
      );
    } catch (e) {
      debugPrint(
        'Route error: $e',
      );

      if (!mounted) return;

      setState(() {
        _errorText =
            'Lỗi tìm đường: $e';
      });
    } finally {
      if (!mounted) return;

      setState(() {
        _isLoadingRoute = false;
      });
    }
  }

  // ============================================================
  // POLYLINE6 DECODER AN TOÀN
  // ============================================================

  List<LatLng> _decodePolyline6Safe(
    String encoded,
  ) {
    final List<LatLng> points = [];

    int index = 0;

    int latitude = 0;
    int longitude = 0;

    try {
      while (index < encoded.length) {
        // --------------------------------------------------------
        // LATITUDE
        // --------------------------------------------------------

        int result = 0;
        int shift = 0;

        bool finished = false;

        while (index < encoded.length) {
          final int byte =
              encoded.codeUnitAt(index) - 63;

          index++;

          result |=
              (byte & 0x1f) << shift;

          shift += 5;

          if (byte < 0x20) {
            finished = true;
            break;
          }
        }

        if (!finished) {
          break;
        }

        final int latitudeChange =
            (result & 1) != 0
                ? ~(result >> 1)
                : (result >> 1);

        latitude += latitudeChange;

        // --------------------------------------------------------
        // LONGITUDE
        // --------------------------------------------------------

        result = 0;
        shift = 0;
        finished = false;

        while (index < encoded.length) {
          final int byte =
              encoded.codeUnitAt(index) - 63;

          index++;

          result |=
              (byte & 0x1f) << shift;

          shift += 5;

          if (byte < 0x20) {
            finished = true;
            break;
          }
        }

        if (!finished) {
          break;
        }

        final int longitudeChange =
            (result & 1) != 0
                ? ~(result >> 1)
                : (result >> 1);

        longitude += longitudeChange;

        // --------------------------------------------------------
        // CONVERT TO LATLNG
        // --------------------------------------------------------

        final double lat =
            latitude / 1000000.0;

        final double lng =
            longitude / 1000000.0;

        if (lat >= -90 &&
            lat <= 90 &&
            lng >= -180 &&
            lng <= 180) {
          points.add(
            LatLng(
              lat,
              lng,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint(
        'Polyline decode error: $e',
      );
    }

    return points;
  }

  // ============================================================
  // MAP CLICK
  // ============================================================

  void _onMapTap(
    LatLng position,
  ) {
    setState(() {
      _destinationPosition = position;

      _destinationController.text =
          '${position.latitude.toStringAsFixed(6)}, '
          '${position.longitude.toStringAsFixed(6)}';

      _routePoints = [];
      _polylines = {};
      _distanceText = '';
      _durationText = '';
      _errorText = '';
    });

    _updateMarkers();
  }

  // ============================================================
  // CLEAR
  // ============================================================

  void _clearRoute() {
    setState(() {
      _startPosition = null;
      _destinationPosition = null;

      _markers = {};
      _polylines = {};
      _routePoints = [];

      _distanceText = '';
      _durationText = '';
      _errorText = '';

      _startController.text =
          'Chợ Bến Thành';

      _destinationController.text =
          'Landmark 81';
    });
  }

  // ============================================================
  // LOAD FAVORITE
  // ============================================================

  Future<void> _loadFavoriteRoute(
    Map<String, dynamic> route,
  ) async {
    final double startLat =
        (route['start_lat'] as num).toDouble();

    final double startLng =
        (route['start_lng'] as num).toDouble();

    final double endLat =
        (route['end_lat'] as num).toDouble();

    final double endLng =
        (route['end_lng'] as num).toDouble();

    setState(() {
      _startController.text =
          route['start_address'].toString();

      _destinationController.text =
          route['end_address'].toString();

      _selectedVehicle =
          route['vehicle'].toString();

      _startPosition =
          LatLng(
            startLat,
            startLng,
          );

      _destinationPosition =
          LatLng(
            endLat,
            endLng,
          );

      _distanceText =
          route['distance'].toString();

      _durationText =
          route['duration'].toString();

      _routePoints = [];

      _polylines = {};

      _errorText = '';
    });

    _updateMarkers();

    await _moveCameraToPoints(
      _startPosition!,
      _destinationPosition!,
    );

    await _findRoute();
  }

  // ============================================================
  // FAVORITES BOTTOM SHEET
  // ============================================================

  void _showFavoriteRoutes() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (
            context,
            setModalState,
          ) {
            return SizedBox(
              height:
                  MediaQuery.of(context).size.height *
                      0.70,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Tuyến đường yêu thích',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  Expanded(
                    child: _favoriteRoutes.isEmpty
                        ? const Center(
                            child: Text(
                              'Chưa có tuyến đường nào được lưu.',
                            ),
                          )
                        : ListView.builder(
                            itemCount:
                                _favoriteRoutes.length,
                            itemBuilder:
                                (context, index) {
                              final route =
                                  _favoriteRoutes[index];

                              return Card(
                                margin:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: ListTile(
                                  leading:
                                      const CircleAvatar(
                                    child: Icon(
                                      Icons.route,
                                    ),
                                  ),
                                  title: Text(
                                    '${route['start_address']} → ${route['end_address']}',
                                    maxLines: 2,
                                    overflow:
                                        TextOverflow
                                            .ellipsis,
                                  ),
                                  subtitle: Text(
                                    '${route['vehicle']} • '
                                    '${route['distance']} • '
                                    '${route['duration']}',
                                  ),
                                  onTap: () async {
                                    Navigator.pop(
                                      context,
                                    );

                                    await _loadFavoriteRoute(
                                      route,
                                    );
                                  },
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                    ),
                                    onPressed: () async {
                                      await _deleteFavoriteRoute(
                                        route['id'] as int,
                                      );

                                      setModalState(() {});
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  // ============================================================
  // VEHICLE BUTTON
  // ============================================================

  Widget _vehicleButton({
    required String title,
    required IconData icon,
  }) {
    final bool selected =
        _selectedVehicle == title;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedVehicle = title;
          });
        },
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 200),
          margin:
              const EdgeInsets.symmetric(
            horizontal: 3,
          ),
          padding:
              const EdgeInsets.symmetric(
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: selected
                ? Colors.blue.withOpacity(0.08)
                : Colors.transparent,
            borderRadius:
                BorderRadius.circular(32),
            border: Border.all(
              color: selected
                  ? Colors.blue
                  : Colors.grey.shade400,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected
                    ? Colors.blue
                    : Colors.blueGrey,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: selected
                      ? Colors.blue
                      : Colors.blueGrey,
                  fontSize: 13,
                  fontWeight: selected
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _addressField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: Colors.blueGrey,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.blue,
            width: 2,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }

  // ============================================================
  // RESULT PANEL
  // ============================================================

  Widget _resultPanel() {
    if (_distanceText.isEmpty &&
        _durationText.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin:
          const EdgeInsets.only(
        top: 8,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.06),
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.withOpacity(0.20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                const Icon(
                  Icons.straighten,
                  color: Colors.blue,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Khoảng cách',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  _distanceText,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 45,
            width: 1,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: Column(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Colors.blue,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Thời gian',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  _durationText,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR PANEL
  // ============================================================

  Widget _errorPanel() {
    if (_errorText.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin:
          const EdgeInsets.only(
        top: 8,
      ),
      padding:
          const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
          color: Colors.red.withOpacity(0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorText,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FC),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFFF8F9FC),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Bài 5 - Tìm đường',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 21,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Tuyến yêu thích',
            onPressed:
                _showFavoriteRoutes,
            icon: const Icon(
              Icons.favorite,
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          // ======================================================
          // FORM
          // ======================================================

          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              8,
            ),
            child: Column(
              children: [
                _addressField(
                  controller:
                      _startController,
                  label:
                      'Địa chỉ xuất phát',
                  icon:
                      Icons.radio_button_checked,
                ),

                const SizedBox(height: 8),

                _addressField(
                  controller:
                      _destinationController,
                  label:
                      'Địa chỉ đích',
                  icon:
                      Icons.location_on,
                ),

                const SizedBox(height: 8),

                // ==================================================
                // TÌM ĐỊA CHỈ
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed:
                        _isLoadingGeocode
                            ? null
                            : _searchAddresses,
                    icon: _isLoadingGeocode
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.search,
                          ),
                    label: Text(
                      _isLoadingGeocode
                          ? 'Đang tìm...'
                          : 'Tìm địa chỉ',
                    ),
                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          Colors.blueGrey,
                      side: BorderSide(
                        color:
                            Colors.grey.shade300,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          25,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ==================================================
                // PHƯƠNG TIỆN
                // ==================================================

                const Align(
                  alignment:
                      Alignment.centerLeft,
                  child: Text(
                    'Phương tiện',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    _vehicleButton(
                      title: 'Ô tô',
                      icon:
                          Icons.directions_car,
                    ),
                    _vehicleButton(
                      title: 'Xe máy',
                      icon:
                          Icons.two_wheeler,
                    ),
                    _vehicleButton(
                      title: 'Đi bộ',
                      icon:
                          Icons.directions_walk,
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // ==================================================
                // BUTTON TÌM ĐƯỜNG + LƯU
                // ==================================================

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 42,
                        child: OutlinedButton.icon(
                          onPressed:
                              _isLoadingRoute
                                  ? null
                                  : _findRoute,
                          icon:
                              _isLoadingRoute
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
                                      Icons
                                          .directions,
                                    ),
                          label: Text(
                            _isLoadingRoute
                                ? 'Đang tìm...'
                                : 'Tìm đường',
                          ),
                          style: OutlinedButton
                              .styleFrom(
                            foregroundColor:
                                Colors.blueGrey,
                            side: BorderSide(
                              color:
                                  Colors.grey.shade300,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                25,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: OutlinedButton.icon(
                          onPressed:
                              _saveFavoriteRoute,
                          icon: const Icon(
                            Icons.favorite_border,
                          ),
                          label:
                              const Text('Lưu'),
                          style: OutlinedButton
                              .styleFrom(
                            foregroundColor:
                                Colors.blueGrey,
                            side: BorderSide(
                              color:
                                  Colors.grey.shade300,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(
                                25,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // ==================================================
                // XÓA
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed:
                        _clearRoute,
                    icon: const Icon(
                      Icons.close,
                    ),
                    label:
                        const Text('Xóa'),
                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          Colors.blueGrey,
                      side: BorderSide(
                        color:
                            Colors.grey.shade300,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          25,
                        ),
                      ),
                    ),
                  ),
                ),

                _resultPanel(),

                _errorPanel(),
              ],
            ),
          ),

          // ======================================================
          // MAP
          // ======================================================

          Expanded(
            child: GoogleMap(
              initialCameraPosition:
                  const CameraPosition(
                target: _defaultLocation,
                zoom: 14,
              ),

              mapType:
                  MapType.normal,

              myLocationEnabled: false,

              myLocationButtonEnabled:
                  false,

              zoomControlsEnabled:
                  true,

              compassEnabled:
                  true,

              markers:
                  _markers,

              polylines:
                  _polylines,

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

              onTap:
                  _onMapTap,
            ),
          ),
        ],
      ),
    );
  }
}