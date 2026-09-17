import json

foods = [
    # Proteins (20 items)
    {'id': 'food_001', 'name': 'Chicken Breast', 'category': 'Protein', 'servingSize': '100g', 'calories': 165, 'protein': 31, 'carbs': 0, 'fats': 3.6, 'fiber': 0, 'sugar': 0, 'sodium': 74, 'potassium': 256, 'vitaminA': 0, 'vitaminB': 0.9, 'vitaminC': 0, 'vitaminD': 0.1, 'vitaminE': 0.3, 'calcium': 11, 'iron': 0.9, 'magnesium': 29, 'zinc': 0.9, 'imageUrl': 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6', 'dietaryTags': ['high-protein', 'low-carb']},
    {'id': 'food_002', 'name': 'Beef Steak', 'category': 'Protein', 'servingSize': '100g', 'calories': 250, 'protein': 26, 'carbs': 0, 'fats': 15, 'fiber': 0, 'sugar': 0, 'sodium': 75, 'potassium': 318, 'vitaminA': 0, 'vitaminB': 1.2, 'vitaminC': 0, 'vitaminD': 0.2, 'vitaminE': 0.6, 'calcium': 18, 'iron': 2.6, 'magnesium': 26, 'zinc': 6.3, 'imageUrl': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c', 'dietaryTags': ['high-protein', 'iron-rich']},
]

print(json.dumps(foods, indent=2))
