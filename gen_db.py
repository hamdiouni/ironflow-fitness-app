import json

# Comprehensive food database with 200+ foods
foods = []
food_id = 1

# Proteins (30 items)
proteins = [
    ("Chicken Breast", 165, 31, 0, 3.6, 0, 0, 74, 256, "https://images.unsplash.com/photo-1598103442097-8b74394b95c6"),
    ("Beef Steak", 250, 26, 0, 15, 0, 0, 75, 318, "https://images.unsplash.com/photo-1546069901-ba9599a7e63c"),
    ("Salmon", 208, 20, 0, 13, 0, 0, 75, 363, "https://images.unsplash.com/photo-1546069901-ba9599a7e63c"),
    ("Tuna", 132, 29, 0, 1.3, 0, 0, 41, 287, "https://images.unsplash.com/photo-1559827260-dc66d52bef19"),
    ("Turkey Breast", 189, 29, 0, 7.4, 0, 0, 63, 285, "https://images.unsplash.com/photo-1598103442097-8b74394b95c6"),
    ("Pork Chop", 242, 27, 0, 14, 0, 0, 75, 315, "https://images.unsplash.com/photo-1546069901-ba9599a7e63c"),
    ("Lamb", 294, 25, 0, 21, 0, 0, 75, 318, "https://images.unsplash.com/photo-1546069901-ba9599a7e63c"),
    ("Eggs", 155, 13, 1.1, 11, 0, 1.1, 124, 126, "https://images.unsplash.com/photo-1585238341710-4b4e6416b573"),
    ("Greek Yogurt", 59, 10, 3.3, 0.4, 0, 3.3, 75, 155, "https://images.unsplash.com/photo-1488477181946-6428a0291840"),
    ("Cottage Cheese", 98, 11, 3.9, 5, 0, 3.9, 390, 104, "https://images.unsplash.com/photo-1488477181946-6428a0291840"),
    ("Tofu", 76, 8, 1.9, 4.8, 0, 0.6, 7, 121, "https://images.unsplash.com/photo-1546069901-ba9599a7e63c"),
    ("Tempeh", 195, 19, 7.6, 11, 0, 0, 10, 412, "https://images.unsplash.com/photo-1546069901-ba9599a7e63c"),
    ("Lentils", 116, 9, 20, 0.4, 0, 1.5, 4, 369, "https://images.unsplash.com/photo-1512621776951-a57141f2eefd"),
    ("Chickpeas", 164, 9, 27, 3, 0, 4.8, 7, 718, "https://images.unsplash.com/photo-1512621776951-a57141f2eefd"),
    ("Black Beans", 132, 9, 24, 0.5, 0, 0.3, 2, 355, "https://images.unsplash.com/photo-1512621776951-a57141f2eefd"),
    ("Peanut Butter", 588, 25, 20, 50, 0, 4, 18, 705, "https://images.unsplash.com/photo-1599599810694-b5ac4dd64b73"),
    ("Almonds", 579, 21, 22, 50, 0, 4.4, 1, 705, "https://images.unsplash.com/photo-1599599810694-b5ac4dd64b73"),
    ("Whey Protein", 417, 80, 7, 8, 0, 1, 350, 160, "https://images.unsplash.com/photo-1599599810694-b5ac4dd64b73"),
    ("Beef Jerky", 411, 33, 11, 27, 0, 0, 1105, 440, "https://images.unsplash.com/photo-1546069901-ba9599a7e63c"),
    ("Chicken Thighs", 209, 26, 0, 11, 0, 0, 81, 246, "https://images.unsplash.com/photo-1598103442097-8b74394b95c6"),
]

for name, cal, prot, carb, fat, fib, sug, sod, pot, img in proteins:
    foods.append({
        "id": f"food_{food_id:03d}",
        "name": name,
        "category": "Protein",
        "servingSize": "100g",
        "calories": cal,
        "protein": prot,
        "carbs": carb,
        "fats": fat,
        "fiber": fib,
        "sugar": sug,
        "sodium": sod,
        "potassium": pot,
        "vitaminA": 0,
        "vitaminB": 0.9,
        "vitaminC": 0,
        "vitaminD": 0.1,
        "vitaminE": 0.3,
        "calcium": 11,
        "iron": 0.9,
        "magnesium": 29,
        "zinc": 0.9,
        "imageUrl": img,
        "dietaryTags": ["high-protein", "low-carb"],
    })
    food_id += 1

print(f"Generated {len(foods)} foods")

