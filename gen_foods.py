# Generate comprehensive food database
foods = []
food_id = 1

# Proteins (25 items)
proteins = [
    ('Chicken Breast', 165, 31, 0, 3.6, 0, 0, 74, 256),
    ('Beef Steak', 250, 26, 0, 15, 0, 0, 75, 318),
    ('Salmon', 208, 20, 0, 13, 0, 0, 75, 363),
    ('Tuna', 132, 29, 0, 1.3, 0, 0, 41, 287),
    ('Turkey Breast', 189, 29, 0, 7.4, 0, 0, 63, 285),
    ('Pork Chop', 242, 27, 0, 14, 0, 0, 75, 315),
    ('Lamb', 294, 25, 0, 21, 0, 0, 75, 318),
    ('Eggs', 155, 13, 1.1, 11, 0, 1.1, 124, 126),
    ('Greek Yogurt', 59, 10, 3.3, 0.4, 0, 3.3, 75, 155),
    ('Cottage Cheese', 98, 11, 3.9, 5, 0, 3.9, 390, 104),
    ('Tofu', 76, 8, 1.9, 4.8, 0, 0.6, 7, 121),
    ('Tempeh', 195, 19, 7.6, 11, 0, 0, 10, 412),
    ('Lentils', 116, 9, 20, 0.4, 0, 1.5, 4, 369),
    ('Chickpeas', 164, 9, 27, 3, 0, 4.8, 7, 718),
    ('Black Beans', 132, 9, 24, 0.5, 0, 0.3, 2, 355),
    ('Peanut Butter', 588, 25, 20, 50, 0, 4, 18, 705),
    ('Almonds', 579, 21, 22, 50, 0, 4.4, 1, 705),
    ('Whey Protein', 417, 80, 7, 8, 0, 1, 350, 160),
    ('Beef Jerky', 411, 33, 11, 27, 0, 0, 1105, 440),
    ('Chicken Thighs', 209, 26, 0, 11, 0, 0, 81, 246),
    ('Duck Breast', 337, 19, 0, 28, 0, 0, 75, 214),
    ('Shrimp', 99, 24, 0, 0.3, 0, 0, 224, 200),
    ('Crab', 102, 20, 0, 1.1, 0, 0, 324, 223),
    ('Mozzarella', 280, 28, 3.1, 17, 0, 0.7, 506, 107),
    ('Cheddar Cheese', 403, 23, 3.6, 33, 0, 0.7, 621, 98),
]

for name, cal, prot, carb, fat, fib, sug, sod, pot in proteins:
    foods.append({
        'id': f'food_{food_id:03d}',
        'name': name,
        'category': 'Protein',
        'servingSize': '100g',
        'calories': cal,
        'protein': prot,
        'carbs': carb,
        'fats': fat,
        'fiber': fib,
        'sugar': sug,
        'sodium': sod,
        'potassium': pot,
        'vitaminA': 0,
        'vitaminB': 0.9,
        'vitaminC': 0,
        'vitaminD': 0.1,
        'vitaminE': 0.3,
        'calcium': 11,
        'iron': 0.9,
        'magnesium': 29,
        'zinc': 0.9,
        'imageUrl': 'https://images.unsplash.com/photo-1598103442097-8b74394b95c6',
        'dietaryTags': ['high-protein', 'low-carb'],
    })
    food_id += 1

print(f"Generated {len(foods)} foods")
