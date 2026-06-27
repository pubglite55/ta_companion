import 'package:dio/dio.dart';

class Recipe {
  final String id;
  final String name;
  final String? imageUrl;
  final String? category;
  final String? instructions;

  const Recipe({
    required this.id,
    required this.name,
    this.imageUrl,
    this.category,
    this.instructions,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json['idMeal'],
    name: json['strMeal'],
    imageUrl: json['strMealThumb'],
    category: json['strCategory'],
    instructions: json['strInstructions'],
  );
}

class RecipeService {
  final Dio _dio = Dio();

  Future<Recipe?> getRandomRecipe() async {
    try {
      final response = await _dio.get('https://www.themealdb.com/api/json/v1/1/random.php');
      if (response.statusCode == 200 && response.data['meals'] != null) {
        return Recipe.fromJson(response.data['meals'][0]);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
