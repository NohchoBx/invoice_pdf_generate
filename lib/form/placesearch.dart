/*
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PlaceSearchPage extends StatefulWidget {
  const PlaceSearchPage({Key? key}) : super(key: key);

  @override
  _PlaceSearchPageState createState() => _PlaceSearchPageState();
}

class _PlaceSearchPageState extends State<PlaceSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];

  Future<void> _searchPlaces(String query) async {
    await dotenv.load(); // Initialize flutter_dotenv

    final apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'];

    if (apiKey != null) {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=$apiKey',
      );

      final String googlePlacesApiUrl = 'https://proxy.cors.sh/maps.googleapis.com/maps/api/place/autocomplete/json?parameters';
      final Uri apiUrl = Uri.parse(googlePlacesApiUrl);

      final response = await http.get(apiUrl, headers: {
        'x-requested-with': 'XMLHttpRequest',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _searchResults = data['results'];
        });      } else {
        // Handle the error
      }
    } else {
      // Handle missing API key
      print('Google Places API key not found');
    }
  }

  void _selectPlace(dynamic place) {
    // Process selected place
    print('Selected place: $place');

    // Close the page
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Place Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Enter a location',
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  _searchPlaces(value);
                } else {
                  setState(() {
                    _searchResults = [];
                  });
                }
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final place = _searchResults[index];
                return ListTile(
                  title: Text(place['name']),
                  subtitle: Text(place['formatted_address']),
                  onTap: () => _selectPlace(place),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
*/
