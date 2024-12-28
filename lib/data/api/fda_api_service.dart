import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medication_tracker/data/model/fda_drug_model.dart';
import 'package:result_dart/result_dart.dart';

class FDAAPIService {
  static final FDAAPIService _instance = FDAAPIService._internal();
  factory FDAAPIService() => _instance;
  FDAAPIService._internal();

  final String baseUrl = "https://api.fda.gov/drug/ndc.json";

  Future<Result<List<FDADrug>>> searchMedications(String query) async {
    query = query.toLowerCase();
    final url = Uri.parse(
        '$baseUrl?search=brand_name:$query+generic_name:$query&limit=10');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['results']?.isNotEmpty ?? false) {
          return Success(_processMedications(data['results']
              .map<FDADrug>((item) => FDADrug.fromMap(item))
              .toList()));
        }
      }
      return Failure(Exception('No results found'));
    } catch (e) {
      return Failure(Exception('Search failed: ${e.toString()}'));
    }
  }

  List<FDADrug> _processMedications(List<FDADrug> medications) {
    // Remove duplicates
    var uniqueMedications = <String, FDADrug>{};
    for (var medication in medications) {
      uniqueMedications[medication.ndc] = medication;
    }
    return uniqueMedications.values.toList();
  }
}
