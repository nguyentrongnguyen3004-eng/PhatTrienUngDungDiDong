import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class BT1 extends StatelessWidget {
  const BT1({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Google Maps',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final Set<Marker> _markers = {};

  LatLng? _currentPosition;

  static const LatLng _defaultPosition = LatLng(10.7769, 106.7009);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng bật GPS trên thiết bị.')),
        );

        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ứng dụng chưa được cấp quyền vị trí.')),
        );

        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quyền vị trí đã bị từ chối vĩnh viễn.'),
          ),
        );

        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final current = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentPosition = current;

        _markers.clear();

        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: current,
            infoWindow: const InfoWindow(
              title: 'Vị trí của bạn',
              snippet: 'Vị trí hiện tại',
            ),
          ),
        );
      });

      if (_controller.isCompleted) {
        final controller = await _controller.future;

        await controller.animateCamera(CameraUpdate.newLatLngZoom(current, 16));
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể lấy vị trí: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Maps')),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: _defaultPosition,
          zoom: 14,
        ),
        markers: _markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          if (!_controller.isCompleted) {
            _controller.complete(controller);
          }

          if (_currentPosition != null) {
            controller.animateCamera(
              CameraUpdate.newLatLngZoom(_currentPosition!, 16),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        tooltip: 'Vị trí hiện tại',
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
