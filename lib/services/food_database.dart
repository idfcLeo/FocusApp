class FoodNutritionData {
  final String name;
  final String category;
  final int caloriesPerServing;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;
  final String servingUnit;

  const FoodNutritionData({
    required this.name,
    required this.category,
    required this.caloriesPerServing,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
    this.servingUnit = '1 serving',
  });
}

class FoodDatabase {
  static const List<FoodNutritionData> items = [
    // --- FITNESS & PROTEIN SUPPLEMENTS ---
    FoodNutritionData(name: 'Protein Shake', category: 'Fitness & Shakes', caloriesPerServing: 210, proteinGrams: 28.0, carbsGrams: 8.0, fatGrams: 3.0, servingUnit: '1 Shake (350ml)'),
    FoodNutritionData(name: 'Whey Protein Scoop', category: 'Fitness & Shakes', caloriesPerServing: 120, proteinGrams: 24.0, carbsGrams: 2.0, fatGrams: 1.5, servingUnit: '1 Scoop (30g)'),
    FoodNutritionData(name: 'Mass Gainer Shake', category: 'Fitness & Shakes', caloriesPerServing: 450, proteinGrams: 32.0, carbsGrams: 65.0, fatGrams: 6.0, servingUnit: '1 Large Shake'),
    FoodNutritionData(name: 'BCAA Energy Drink', category: 'Fitness & Shakes', caloriesPerServing: 15, proteinGrams: 5.0, carbsGrams: 1.0, fatGrams: 0.0, servingUnit: '1 Can (330ml)'),
    FoodNutritionData(name: 'Protein Bar', category: 'Fitness & Shakes', caloriesPerServing: 220, proteinGrams: 20.0, carbsGrams: 22.0, fatGrams: 7.0, servingUnit: '1 Bar (60g)'),
    FoodNutritionData(name: 'Peanut Butter Smoothie', category: 'Fitness & Shakes', caloriesPerServing: 360, proteinGrams: 18.0, carbsGrams: 40.0, fatGrams: 14.0, servingUnit: '1 Glass (350ml)'),
    FoodNutritionData(name: 'Banana Smoothie', category: 'Fitness & Shakes', caloriesPerServing: 260, proteinGrams: 8.0, carbsGrams: 48.0, fatGrams: 4.0, servingUnit: '1 Glass'),

    // --- INDIAN HIGH-PROTEIN PANTRY (values are label-style estimates per 100g) ---
    FoodNutritionData(name: 'Yoga Bar High Protein Oats', category: 'Indian Protein Pantry', caloriesPerServing: 390, proteinGrams: 20.0, carbsGrams: 58.0, fatGrams: 8.0, servingUnit: '100g'),
    FoodNutritionData(name: 'Yoga Bar Protein Bar', category: 'Indian Protein Pantry', caloriesPerServing: 370, proteinGrams: 30.0, carbsGrams: 42.0, fatGrams: 12.0, servingUnit: '100g'),
    FoodNutritionData(name: 'True Elements Chia Seeds', category: 'Indian Protein Pantry', caloriesPerServing: 486, proteinGrams: 17.0, carbsGrams: 42.0, fatGrams: 31.0, servingUnit: '100g'),
    FoodNutritionData(name: 'True Elements Rolled Oats', category: 'Indian Protein Pantry', caloriesPerServing: 389, proteinGrams: 13.0, carbsGrams: 66.0, fatGrams: 7.0, servingUnit: '100g'),
    FoodNutritionData(name: 'Saffola Masala Oats', category: 'Indian Protein Pantry', caloriesPerServing: 370, proteinGrams: 10.0, carbsGrams: 68.0, fatGrams: 7.0, servingUnit: '100g'),
    FoodNutritionData(name: 'Amul High Protein Milk', category: 'Indian Protein Pantry', caloriesPerServing: 72, proteinGrams: 10.0, carbsGrams: 5.0, fatGrams: 1.5, servingUnit: '100ml'),
    FoodNutritionData(name: 'Roasted Chana', category: 'Indian Protein Pantry', caloriesPerServing: 370, proteinGrams: 20.0, carbsGrams: 60.0, fatGrams: 6.0, servingUnit: '100g'),
    FoodNutritionData(name: 'Peanut Chikki', category: 'Indian Protein Pantry', caloriesPerServing: 520, proteinGrams: 14.0, carbsGrams: 50.0, fatGrams: 30.0, servingUnit: '100g'),
    FoodNutritionData(name: 'Yoga Bar 26g Protein Oats Dark Chocolate', category: 'Yoga Bar', caloriesPerServing: 390, proteinGrams: 26.0, carbsGrams: 55.0, fatGrams: 8.0, servingUnit: '100g'),
    FoodNutritionData(name: 'Yoga Bar Fermented Yeast Protein Chocolate', category: 'Yoga Bar', caloriesPerServing: 390, proteinGrams: 52.0, carbsGrams: 20.0, fatGrams: 9.0, servingUnit: '100g'),
    FoodNutritionData(name: 'Yoga Bar Ultimate Whey Isolate Chocolate', category: 'Yoga Bar', caloriesPerServing: 370, proteinGrams: 84.0, carbsGrams: 5.0, fatGrams: 3.0, servingUnit: '100g'),
    FoodNutritionData(name: 'Yoga Bar Ultimate Whey Isolate Unflavoured', category: 'Yoga Bar', caloriesPerServing: 370, proteinGrams: 88.0, carbsGrams: 4.0, fatGrams: 2.0, servingUnit: '100g'),
    FoodNutritionData(name: 'Yoga Bar ProClean Whey Chocolate', category: 'Yoga Bar', caloriesPerServing: 390, proteinGrams: 75.0, carbsGrams: 10.0, fatGrams: 5.0, servingUnit: '100g'),
    FoodNutritionData(name: 'Yoga Bar ProClean Plant Protein Chocolate', category: 'Yoga Bar', caloriesPerServing: 380, proteinGrams: 60.0, carbsGrams: 22.0, fatGrams: 7.0, servingUnit: '100g'),
    FoodNutritionData(name: 'Yoga Bar 26g Protein Shake Double Chocolate', category: 'Yoga Bar', caloriesPerServing: 180, proteinGrams: 26.0, carbsGrams: 14.0, fatGrams: 3.0, servingUnit: '250ml bottle'),
    FoodNutritionData(name: 'Yoga Bar 26g Protein Shake Mango', category: 'Yoga Bar', caloriesPerServing: 180, proteinGrams: 26.0, carbsGrams: 15.0, fatGrams: 3.0, servingUnit: '250ml bottle'),
    FoodNutritionData(name: 'Yoga Bar 10g Protein Wafer Bar', category: 'Yoga Bar', caloriesPerServing: 210, proteinGrams: 10.0, carbsGrams: 24.0, fatGrams: 9.0, servingUnit: '1 bar (40g)'),
    FoodNutritionData(name: 'Yoga Bar Breakfast Bar', category: 'Yoga Bar', caloriesPerServing: 170, proteinGrams: 4.0, carbsGrams: 24.0, fatGrams: 7.0, servingUnit: '1 bar (45g)'),
    FoodNutritionData(name: 'Yoga Bar Energy Bar', category: 'Yoga Bar', caloriesPerServing: 140, proteinGrams: 3.0, carbsGrams: 22.0, fatGrams: 5.0, servingUnit: '1 bar (35g)'),
    FoodNutritionData(name: 'Yoga Bar Fruits Nuts Seeds Muesli', category: 'Yoga Bar', caloriesPerServing: 430, proteinGrams: 10.0, carbsGrams: 62.0, fatGrams: 15.0, servingUnit: '100g'),
    FoodNutritionData(name: 'Yoga Bar No Added Sugar Muesli', category: 'Yoga Bar', caloriesPerServing: 410, proteinGrams: 11.0, carbsGrams: 65.0, fatGrams: 12.0, servingUnit: '100g'),
    FoodNutritionData(name: 'True Elements Steel Cut Oats', category: 'True Elements', caloriesPerServing: 380, proteinGrams: 13.0, carbsGrams: 67.0, fatGrams: 7.0, servingUnit: '100g'),
    FoodNutritionData(name: 'True Elements Multigrain Oatmeal', category: 'True Elements', caloriesPerServing: 380, proteinGrams: 12.0, carbsGrams: 68.0, fatGrams: 6.0, servingUnit: '100g'),
    FoodNutritionData(name: 'True Elements 7 in 1 Super Seeds Mix', category: 'True Elements', caloriesPerServing: 520, proteinGrams: 28.1, carbsGrams: 20.0, fatGrams: 40.0, servingUnit: '100g'),
    FoodNutritionData(name: 'True Elements Raw Flax Seeds', category: 'True Elements', caloriesPerServing: 535, proteinGrams: 18.0, carbsGrams: 29.0, fatGrams: 42.0, servingUnit: '100g'),
    FoodNutritionData(name: 'True Elements Raw Sunflower Seeds', category: 'True Elements', caloriesPerServing: 585, proteinGrams: 25.0, carbsGrams: 20.0, fatGrams: 51.0, servingUnit: '100g'),
    FoodNutritionData(name: 'True Elements Raw Watermelon Seeds', category: 'True Elements', caloriesPerServing: 560, proteinGrams: 32.9, carbsGrams: 15.0, fatGrams: 45.0, servingUnit: '100g'),
    FoodNutritionData(name: 'True Elements Antioxidant Seeds Mix', category: 'True Elements', caloriesPerServing: 530, proteinGrams: 20.0, carbsGrams: 24.0, fatGrams: 42.0, servingUnit: '100g'),
    FoodNutritionData(name: 'True Elements 9 in 1 Snack Mix', category: 'True Elements', caloriesPerServing: 520, proteinGrams: 18.0, carbsGrams: 30.0, fatGrams: 38.0, servingUnit: '100g'),
    FoodNutritionData(name: 'True Elements Chocolate Granola', category: 'True Elements', caloriesPerServing: 450, proteinGrams: 10.0, carbsGrams: 64.0, fatGrams: 16.0, servingUnit: '100g'),
    FoodNutritionData(name: 'True Elements Nuts Berries Muesli', category: 'True Elements', caloriesPerServing: 420, proteinGrams: 10.0, carbsGrams: 65.0, fatGrams: 13.0, servingUnit: '100g'),

    // --- BREAKFAST ---
    FoodNutritionData(name: 'Scrambled Eggs', category: 'Breakfast', caloriesPerServing: 180, proteinGrams: 14.0, carbsGrams: 2.0, fatGrams: 12.0, servingUnit: '2 Whole Eggs'),
    FoodNutritionData(name: 'Egg White Omelette', category: 'Breakfast', caloriesPerServing: 110, proteinGrams: 18.0, carbsGrams: 1.5, fatGrams: 1.0, servingUnit: '3 Egg Whites'),
    FoodNutritionData(name: 'Boiled Eggs', category: 'Breakfast', caloriesPerServing: 155, proteinGrams: 13.0, carbsGrams: 1.1, fatGrams: 10.5, servingUnit: '2 Eggs'),
    FoodNutritionData(name: 'Oatmeal Bowl', category: 'Breakfast', caloriesPerServing: 240, proteinGrams: 10.0, carbsGrams: 42.0, fatGrams: 4.5, servingUnit: '1 Bowl'),
    FoodNutritionData(name: 'Peanut Butter Toast', category: 'Breakfast', caloriesPerServing: 280, proteinGrams: 11.0, carbsGrams: 28.0, fatGrams: 14.0, servingUnit: '2 Slices'),
    FoodNutritionData(name: 'Avocado Toast', category: 'Breakfast', caloriesPerServing: 260, proteinGrams: 6.0, carbsGrams: 26.0, fatGrams: 15.0, servingUnit: '2 Slices'),
    FoodNutritionData(name: 'Pancakes', category: 'Breakfast', caloriesPerServing: 310, proteinGrams: 8.0, carbsGrams: 54.0, fatGrams: 7.0, servingUnit: '2 Pancakes'),
    FoodNutritionData(name: 'Waffles', category: 'Breakfast', caloriesPerServing: 290, proteinGrams: 6.5, carbsGrams: 46.0, fatGrams: 9.0, servingUnit: '1 Waffle'),
    FoodNutritionData(name: 'Muesli Bowl', category: 'Breakfast', caloriesPerServing: 270, proteinGrams: 9.0, carbsGrams: 45.0, fatGrams: 6.0, servingUnit: '1 Bowl with Milk'),

    // --- INDIAN MAINS & THALIS ---
    FoodNutritionData(name: 'Paneer Butter Masala', category: 'Indian Main', caloriesPerServing: 320, proteinGrams: 14.0, carbsGrams: 12.0, fatGrams: 24.0, servingUnit: '1 Bowl (150g)'),
    FoodNutritionData(name: 'Paneer Tikka', category: 'Indian Main', caloriesPerServing: 280, proteinGrams: 18.0, carbsGrams: 8.0, fatGrams: 19.0, servingUnit: '6 Pieces'),
    FoodNutritionData(name: 'Dal Makhani', category: 'Indian Main', caloriesPerServing: 290, proteinGrams: 11.0, carbsGrams: 30.0, fatGrams: 14.0, servingUnit: '1 Bowl'),
    FoodNutritionData(name: 'Dal Tadka', category: 'Indian Main', caloriesPerServing: 210, proteinGrams: 12.0, carbsGrams: 28.0, fatGrams: 6.0, servingUnit: '1 Bowl'),
    FoodNutritionData(name: 'Rajma Chawal', category: 'Indian Main', caloriesPerServing: 420, proteinGrams: 15.0, carbsGrams: 72.0, fatGrams: 8.0, servingUnit: '1 Plate'),
    FoodNutritionData(name: 'Chole Bhature', category: 'Indian Main', caloriesPerServing: 550, proteinGrams: 16.0, carbsGrams: 68.0, fatGrams: 24.0, servingUnit: '2 Bhature + Chole'),
    FoodNutritionData(name: 'Kadai Chicken', category: 'Indian Main', caloriesPerServing: 340, proteinGrams: 28.0, carbsGrams: 10.0, fatGrams: 20.0, servingUnit: '1 Bowl'),
    FoodNutritionData(name: 'Butter Chicken', category: 'Indian Main', caloriesPerServing: 410, proteinGrams: 30.0, carbsGrams: 14.0, fatGrams: 26.0, servingUnit: '1 Bowl'),
    FoodNutritionData(name: 'Chicken Curry', category: 'Indian Main', caloriesPerServing: 320, proteinGrams: 29.0, carbsGrams: 8.0, fatGrams: 18.0, servingUnit: '1 Bowl'),
    FoodNutritionData(name: 'Mutton Curry', category: 'Indian Main', caloriesPerServing: 430, proteinGrams: 26.0, carbsGrams: 9.0, fatGrams: 32.0, servingUnit: '1 Bowl'),
    FoodNutritionData(name: 'Fish Curry', category: 'Indian Main', caloriesPerServing: 270, proteinGrams: 25.0, carbsGrams: 7.0, fatGrams: 15.0, servingUnit: '1 Bowl'),
    FoodNutritionData(name: 'Palak Paneer', category: 'Indian Main', caloriesPerServing: 260, proteinGrams: 13.0, carbsGrams: 10.0, fatGrams: 18.0, servingUnit: '1 Bowl'),
    FoodNutritionData(name: 'Aloo Gobi', category: 'Indian Main', caloriesPerServing: 180, proteinGrams: 4.5, carbsGrams: 26.0, fatGrams: 7.0, servingUnit: '1 Bowl'),
    FoodNutritionData(name: 'Bhindi Masala', category: 'Indian Main', caloriesPerServing: 160, proteinGrams: 3.5, carbsGrams: 18.0, fatGrams: 8.0, servingUnit: '1 Bowl'),
    FoodNutritionData(name: 'Vegetable Biryani', category: 'Indian Main', caloriesPerServing: 380, proteinGrams: 9.0, carbsGrams: 64.0, fatGrams: 10.0, servingUnit: '1 Plate'),
    FoodNutritionData(name: 'Chicken Biryani', category: 'Indian Main', caloriesPerServing: 480, proteinGrams: 28.0, carbsGrams: 55.0, fatGrams: 16.0, servingUnit: '1 Plate'),
    FoodNutritionData(name: 'Hyderabadi Biryani', category: 'Indian Main', caloriesPerServing: 520, proteinGrams: 31.0, carbsGrams: 58.0, fatGrams: 18.0, servingUnit: '1 Plate'),

    // --- INDIAN BREADS & RICE ---
    FoodNutritionData(name: 'Chapati / Roti', category: 'Breads & Rice', caloriesPerServing: 120, proteinGrams: 3.5, carbsGrams: 22.0, fatGrams: 2.0, servingUnit: '2 Rotis'),
    FoodNutritionData(name: 'Butter Naan', category: 'Breads & Rice', caloriesPerServing: 260, proteinGrams: 7.0, carbsGrams: 42.0, fatGrams: 8.0, servingUnit: '1 Naan'),
    FoodNutritionData(name: 'Garlic Naan', category: 'Breads & Rice', caloriesPerServing: 280, proteinGrams: 7.5, carbsGrams: 44.0, fatGrams: 9.0, servingUnit: '1 Naan'),
    FoodNutritionData(name: 'Aloo Paratha', category: 'Breads & Rice', caloriesPerServing: 290, proteinGrams: 6.0, carbsGrams: 45.0, fatGrams: 10.0, servingUnit: '1 Paratha with Butter'),
    FoodNutritionData(name: 'Paneer Paratha', category: 'Breads & Rice', caloriesPerServing: 340, proteinGrams: 12.0, carbsGrams: 40.0, fatGrams: 14.0, servingUnit: '1 Paratha'),
    FoodNutritionData(name: 'Puri', category: 'Breads & Rice', caloriesPerServing: 240, proteinGrams: 4.0, carbsGrams: 30.0, fatGrams: 12.0, servingUnit: '3 Puris'),
    FoodNutritionData(name: 'Plain Basmati Rice', category: 'Breads & Rice', caloriesPerServing: 205, proteinGrams: 4.2, carbsGrams: 45.0, fatGrams: 0.5, servingUnit: '1 Cup (150g)'),
    FoodNutritionData(name: 'Jeera Rice', category: 'Breads & Rice', caloriesPerServing: 230, proteinGrams: 4.5, carbsGrams: 46.0, fatGrams: 3.5, servingUnit: '1 Cup'),
    FoodNutritionData(name: 'Brown Rice', category: 'Breads & Rice', caloriesPerServing: 215, proteinGrams: 5.0, carbsGrams: 45.0, fatGrams: 1.8, servingUnit: '1 Cup'),
    FoodNutritionData(name: 'Veg Pulao', category: 'Breads & Rice', caloriesPerServing: 280, proteinGrams: 6.0, carbsGrams: 50.0, fatGrams: 6.5, servingUnit: '1 Cup'),

    // --- SOUTH INDIAN ---
    FoodNutritionData(name: 'Masala Dosa', category: 'South Indian', caloriesPerServing: 310, proteinGrams: 7.0, carbsGrams: 48.0, fatGrams: 10.0, servingUnit: '1 Masala Dosa'),
    FoodNutritionData(name: 'Plain Dosa', category: 'South Indian', caloriesPerServing: 210, proteinGrams: 5.0, carbsGrams: 35.0, fatGrams: 6.0, servingUnit: '1 Dosa'),
    FoodNutritionData(name: 'Idli', category: 'South Indian', caloriesPerServing: 130, proteinGrams: 4.0, carbsGrams: 26.0, fatGrams: 0.8, servingUnit: '2 Idlis'),
    FoodNutritionData(name: 'Vada', category: 'South Indian', caloriesPerServing: 190, proteinGrams: 4.5, carbsGrams: 18.0, fatGrams: 11.0, servingUnit: '2 Medu Vadas'),
    FoodNutritionData(name: 'Uttapam', category: 'South Indian', caloriesPerServing: 240, proteinGrams: 6.0, carbsGrams: 40.0, fatGrams: 6.0, servingUnit: '1 Uttapam'),
    FoodNutritionData(name: 'Sambhar Rice', category: 'South Indian', caloriesPerServing: 330, proteinGrams: 9.0, carbsGrams: 60.0, fatGrams: 5.0, servingUnit: '1 Bowl'),
    FoodNutritionData(name: 'Curd Rice', category: 'South Indian', caloriesPerServing: 260, proteinGrams: 7.0, carbsGrams: 42.0, fatGrams: 7.0, servingUnit: '1 Bowl'),
    FoodNutritionData(name: 'Upma', category: 'South Indian', caloriesPerServing: 220, proteinGrams: 5.0, carbsGrams: 36.0, fatGrams: 6.5, servingUnit: '1 Bowl'),
    FoodNutritionData(name: 'Poha', category: 'South Indian', caloriesPerServing: 250, proteinGrams: 4.8, carbsGrams: 42.0, fatGrams: 7.0, servingUnit: '1 Bowl'),

    // --- WESTERN & FAST FOOD ---
    FoodNutritionData(name: 'Margherita Pizza', category: 'Fast Food', caloriesPerServing: 250, proteinGrams: 11.0, carbsGrams: 30.0, fatGrams: 9.5, servingUnit: '1 Slice'),
    FoodNutritionData(name: 'Pepperoni Pizza', category: 'Fast Food', caloriesPerServing: 310, proteinGrams: 13.0, carbsGrams: 32.0, fatGrams: 14.0, servingUnit: '1 Slice'),
    FoodNutritionData(name: 'Chicken Burger', category: 'Fast Food', caloriesPerServing: 420, proteinGrams: 24.0, carbsGrams: 40.0, fatGrams: 18.0, servingUnit: '1 Burger'),
    FoodNutritionData(name: 'Veg Burger', category: 'Fast Food', caloriesPerServing: 350, proteinGrams: 10.0, carbsGrams: 46.0, fatGrams: 14.0, servingUnit: '1 Burger'),
    FoodNutritionData(name: 'Cheese Burger', category: 'Fast Food', caloriesPerServing: 460, proteinGrams: 22.0, carbsGrams: 42.0, fatGrams: 23.0, servingUnit: '1 Burger'),
    FoodNutritionData(name: 'French Fries', category: 'Fast Food', caloriesPerServing: 315, proteinGrams: 3.5, carbsGrams: 41.0, fatGrams: 15.0, servingUnit: '1 Medium Pack'),
    FoodNutritionData(name: 'Chicken Nuggets', category: 'Fast Food', caloriesPerServing: 280, proteinGrams: 16.0, carbsGrams: 18.0, fatGrams: 16.0, servingUnit: '6 Pieces'),
    FoodNutritionData(name: 'Fried Chicken', category: 'Fast Food', caloriesPerServing: 390, proteinGrams: 26.0, carbsGrams: 14.0, fatGrams: 22.0, servingUnit: '2 Pieces'),
    FoodNutritionData(name: 'Hot Dog', category: 'Fast Food', caloriesPerServing: 290, proteinGrams: 11.0, carbsGrams: 24.0, fatGrams: 16.0, servingUnit: '1 Hot Dog'),
    FoodNutritionData(name: 'Tacos', category: 'Fast Food', caloriesPerServing: 210, proteinGrams: 10.0, carbsGrams: 20.0, fatGrams: 10.0, servingUnit: '2 Crunchy Tacos'),
    FoodNutritionData(name: 'Burrito', category: 'Fast Food', caloriesPerServing: 540, proteinGrams: 24.0, carbsGrams: 66.0, fatGrams: 20.0, servingUnit: '1 Large Burrito'),
    FoodNutritionData(name: 'Pasta Carbonara', category: 'Italian', caloriesPerServing: 420, proteinGrams: 16.0, carbsGrams: 48.0, fatGrams: 18.0, servingUnit: '1 Bowl'),
    FoodNutritionData(name: 'Penne Arrabbiata', category: 'Italian', caloriesPerServing: 310, proteinGrams: 9.0, carbsGrams: 52.0, fatGrams: 8.0, servingUnit: '1 Bowl'),
    FoodNutritionData(name: 'Mac & Cheese', category: 'Italian', caloriesPerServing: 390, proteinGrams: 14.0, carbsGrams: 44.0, fatGrams: 17.0, servingUnit: '1 Bowl'),
    FoodNutritionData(name: 'Club Sandwich', category: 'Sandwiches', caloriesPerServing: 380, proteinGrams: 18.0, carbsGrams: 36.0, fatGrams: 16.0, servingUnit: '1 Sandwich'),
    FoodNutritionData(name: 'Veg Grilled Sandwich', category: 'Sandwiches', caloriesPerServing: 260, proteinGrams: 8.0, carbsGrams: 34.0, fatGrams: 10.0, servingUnit: '1 Sandwich'),

    // --- ASIAN & ORIENTAL ---
    FoodNutritionData(name: 'Chicken Momos', category: 'Asian', caloriesPerServing: 260, proteinGrams: 18.0, carbsGrams: 28.0, fatGrams: 8.0, servingUnit: '6 Steamed Momos'),
    FoodNutritionData(name: 'Veg Momos', category: 'Asian', caloriesPerServing: 210, proteinGrams: 6.0, carbsGrams: 34.0, fatGrams: 5.0, servingUnit: '6 Steamed Momos'),
    FoodNutritionData(name: 'Ramen Bowl', category: 'Asian', caloriesPerServing: 440, proteinGrams: 22.0, carbsGrams: 56.0, fatGrams: 14.0, servingUnit: '1 Bowl'),
    FoodNutritionData(name: 'Fried Rice', category: 'Asian', caloriesPerServing: 330, proteinGrams: 8.0, carbsGrams: 54.0, fatGrams: 9.0, servingUnit: '1 Plate'),
    FoodNutritionData(name: 'Hakka Noodles', category: 'Asian', caloriesPerServing: 360, proteinGrams: 9.0, carbsGrams: 58.0, fatGrams: 10.0, servingUnit: '1 Plate'),
    FoodNutritionData(name: 'Pad Thai', category: 'Asian', caloriesPerServing: 410, proteinGrams: 16.0, carbsGrams: 52.0, fatGrams: 15.0, servingUnit: '1 Plate'),
    FoodNutritionData(name: 'Sushi Roll', category: 'Asian', caloriesPerServing: 280, proteinGrams: 12.0, carbsGrams: 42.0, fatGrams: 6.0, servingUnit: '6 Pieces'),
    FoodNutritionData(name: 'Dim Sum', category: 'Asian', caloriesPerServing: 240, proteinGrams: 10.0, carbsGrams: 30.0, fatGrams: 8.0, servingUnit: '5 Pieces'),
    FoodNutritionData(name: 'Veg Manchurian', category: 'Asian', caloriesPerServing: 290, proteinGrams: 6.0, carbsGrams: 36.0, fatGrams: 14.0, servingUnit: '1 Bowl'),

    // --- HEALTHY & SALADS ---
    FoodNutritionData(name: 'Fresh Salad', category: 'Healthy', caloriesPerServing: 120, proteinGrams: 3.5, carbsGrams: 15.0, fatGrams: 4.0, servingUnit: '1 Bowl'),
    FoodNutritionData(name: 'Caesar Salad', category: 'Healthy', caloriesPerServing: 230, proteinGrams: 8.0, carbsGrams: 12.0, fatGrams: 17.0, servingUnit: '1 Bowl'),
    FoodNutritionData(name: 'Chicken Breast Salad', category: 'Healthy', caloriesPerServing: 290, proteinGrams: 34.0, carbsGrams: 8.0, fatGrams: 11.0, servingUnit: '1 Bowl'),
    FoodNutritionData(name: 'Quinoa Bowl', category: 'Healthy', caloriesPerServing: 270, proteinGrams: 10.0, carbsGrams: 42.0, fatGrams: 6.0, servingUnit: '1 Bowl'),
    FoodNutritionData(name: 'Boiled Chickpeas Salad', category: 'Healthy', caloriesPerServing: 210, proteinGrams: 11.0, carbsGrams: 32.0, fatGrams: 4.0, servingUnit: '1 Bowl'),
    FoodNutritionData(name: 'Sprouted Moong Salad', category: 'Healthy', caloriesPerServing: 160, proteinGrams: 12.0, carbsGrams: 24.0, fatGrams: 2.0, servingUnit: '1 Bowl'),
    FoodNutritionData(name: 'Grilled Salmon', category: 'Healthy', caloriesPerServing: 340, proteinGrams: 34.0, carbsGrams: 0.0, fatGrams: 21.0, servingUnit: '1 Fillet (200g)'),

    // --- SNACKS & STREET FOOD ---
    FoodNutritionData(name: 'Samosa', category: 'Street Food', caloriesPerServing: 250, proteinGrams: 4.5, carbsGrams: 32.0, fatGrams: 12.0, servingUnit: '1 Samosa'),
    FoodNutritionData(name: 'Kachori', category: 'Street Food', caloriesPerServing: 280, proteinGrams: 5.0, carbsGrams: 34.0, fatGrams: 14.0, servingUnit: '1 Kachori'),
    FoodNutritionData(name: 'Pav Bhaji', category: 'Street Food', caloriesPerServing: 400, proteinGrams: 9.0, carbsGrams: 54.0, fatGrams: 16.0, servingUnit: '2 Pav + Bhaji'),
    FoodNutritionData(name: 'Vada Pav', category: 'Street Food', caloriesPerServing: 290, proteinGrams: 6.0, carbsGrams: 42.0, fatGrams: 11.0, servingUnit: '1 Vada Pav'),
    FoodNutritionData(name: 'Pani Puri', category: 'Street Food', caloriesPerServing: 180, proteinGrams: 3.0, carbsGrams: 28.0, fatGrams: 6.0, servingUnit: '6 Puris'),
    FoodNutritionData(name: 'Bhel Puri', category: 'Street Food', caloriesPerServing: 210, proteinGrams: 5.0, carbsGrams: 38.0, fatGrams: 5.0, servingUnit: '1 Plate'),
    FoodNutritionData(name: 'Spring Rolls', category: 'Street Food', caloriesPerServing: 240, proteinGrams: 5.0, carbsGrams: 28.0, fatGrams: 12.0, servingUnit: '2 Rolls'),
    FoodNutritionData(name: 'Pakora', category: 'Street Food', caloriesPerServing: 260, proteinGrams: 6.0, carbsGrams: 26.0, fatGrams: 15.0, servingUnit: '1 Plate (100g)'),

    // --- FRUITS & NUTS ---
    FoodNutritionData(name: 'Apple / Fruit', category: 'Fruits & Nuts', caloriesPerServing: 95, proteinGrams: 0.5, carbsGrams: 25.0, fatGrams: 0.3, servingUnit: '1 Medium Apple'),
    FoodNutritionData(name: 'Banana', category: 'Fruits & Nuts', caloriesPerServing: 105, proteinGrams: 1.3, carbsGrams: 27.0, fatGrams: 0.3, servingUnit: '1 Medium Banana'),
    FoodNutritionData(name: 'Orange', category: 'Fruits & Nuts', caloriesPerServing: 62, proteinGrams: 1.2, carbsGrams: 15.0, fatGrams: 0.2, servingUnit: '1 Medium Orange'),
    FoodNutritionData(name: 'Mango', category: 'Fruits & Nuts', caloriesPerServing: 135, proteinGrams: 1.1, carbsGrams: 35.0, fatGrams: 0.6, servingUnit: '1 Slice / Medium'),
    FoodNutritionData(name: 'Watermelon', category: 'Fruits & Nuts', caloriesPerServing: 85, proteinGrams: 1.5, carbsGrams: 21.0, fatGrams: 0.4, servingUnit: '1 Wedge (250g)'),
    FoodNutritionData(name: 'Almonds (Handful)', category: 'Fruits & Nuts', caloriesPerServing: 160, proteinGrams: 6.0, carbsGrams: 6.0, fatGrams: 14.0, servingUnit: '23 Almonds (28g)'),
    FoodNutritionData(name: 'Walnuts (Handful)', category: 'Fruits & Nuts', caloriesPerServing: 185, proteinGrams: 4.3, carbsGrams: 3.9, fatGrams: 18.5, servingUnit: '14 Halves (28g)'),

    // --- DESSERTS & DRINKS ---
    FoodNutritionData(name: 'Gulab Jamun', category: 'Desserts', caloriesPerServing: 150, proteinGrams: 2.2, carbsGrams: 26.0, fatGrams: 4.5, servingUnit: '2 Jamuns'),
    FoodNutritionData(name: 'Rasgulla', category: 'Desserts', caloriesPerServing: 125, proteinGrams: 3.0, carbsGrams: 24.0, fatGrams: 1.5, servingUnit: '2 Rasgullas'),
    FoodNutritionData(name: 'Brownie', category: 'Desserts', caloriesPerServing: 240, proteinGrams: 3.5, carbsGrams: 32.0, fatGrams: 11.0, servingUnit: '1 Square'),
    FoodNutritionData(name: 'Ice Cream Scoop', category: 'Desserts', caloriesPerServing: 180, proteinGrams: 3.8, carbsGrams: 21.0, fatGrams: 9.5, servingUnit: '1 Scoop'),
    FoodNutritionData(name: 'Chocolate Cake', category: 'Desserts', caloriesPerServing: 350, proteinGrams: 4.5, carbsGrams: 48.0, fatGrams: 16.0, servingUnit: '1 Slice'),
    FoodNutritionData(name: 'Black Coffee', category: 'Beverages', caloriesPerServing: 5, proteinGrams: 0.3, carbsGrams: 0.0, fatGrams: 0.0, servingUnit: '1 Cup'),
    FoodNutritionData(name: 'Cold Coffee', category: 'Beverages', caloriesPerServing: 220, proteinGrams: 6.0, carbsGrams: 32.0, fatGrams: 8.0, servingUnit: '1 Glass'),
    FoodNutritionData(name: 'Chai / Tea', category: 'Beverages', caloriesPerServing: 75, proteinGrams: 2.0, carbsGrams: 11.0, fatGrams: 2.5, servingUnit: '1 Cup'),
    FoodNutritionData(name: 'Green Tea', category: 'Beverages', caloriesPerServing: 2, proteinGrams: 0.0, carbsGrams: 0.4, fatGrams: 0.0, servingUnit: '1 Cup'),
    FoodNutritionData(name: 'Mango Lassi', category: 'Beverages', caloriesPerServing: 240, proteinGrams: 6.5, carbsGrams: 38.0, fatGrams: 6.0, servingUnit: '1 Glass'),
    FoodNutritionData(name: 'Sweet Lassi', category: 'Beverages', caloriesPerServing: 210, proteinGrams: 6.0, carbsGrams: 32.0, fatGrams: 6.5, servingUnit: '1 Glass'),
  ];

  static FoodNutritionData findByName(String query) {
    final cleanQuery = query.toLowerCase().trim();

    // 1. Exact or contains match
    for (var item in items) {
      if (item.name.toLowerCase() == cleanQuery || cleanQuery.contains(item.name.toLowerCase())) {
        return item;
      }
    }

    // 2. Keyword fallback matching (Protein Shake, Whey, Egg, Biryani, Pizza, Burger, Dosa, Rice, etc.)
    if (cleanQuery.contains('protein') || cleanQuery.contains('shake') || cleanQuery.contains('whey')) {
      return findByName('Protein Shake');
    }
    if (cleanQuery.contains('egg') || cleanQuery.contains('omelette')) {
      return findByName('Scrambled Eggs');
    }
    if (cleanQuery.contains('biryani') || cleanQuery.contains('pulao')) {
      return findByName('Chicken Biryani');
    }
    if (cleanQuery.contains('paneer')) {
      return findByName('Paneer Butter Masala');
    }
    if (cleanQuery.contains('pizza')) {
      return findByName('Margherita Pizza');
    }
    if (cleanQuery.contains('burger')) {
      return findByName('Chicken Burger');
    }
    if (cleanQuery.contains('dosa')) {
      return findByName('Masala Dosa');
    }
    if (cleanQuery.contains('idli')) {
      return findByName('Idli');
    }
    if (cleanQuery.contains('salad')) {
      return findByName('Fresh Salad');
    }
    if (cleanQuery.contains('coffee')) {
      return findByName('Cold Coffee');
    }

    return FoodNutritionData(
      name: query,
      category: 'General Meal',
      caloriesPerServing: 250,
      proteinGrams: 12.0,
      carbsGrams: 30.0,
      fatGrams: 8.0,
      servingUnit: '1 Serving',
    );
  }
}
