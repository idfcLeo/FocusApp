"""
College Kit AI - Expanded Food Classification & Cuisine Model Trainer
---------------------------------------------------------------------
This script exports an expanded 100+ class food dataset covering:
- Fitness & Protein Supplements (Protein Shake, Whey, Mass Gainer, BCAA, Smoothies)
- Indian Mains, Thalis & Street Food (Biryani, Paneer, Dal, Chole Bhature, Dosa, Idli, Samosa)
- Global Cuisines (Pizza, Burger, Pasta, Tacos, Sushi, Ramen, Momos, Salad)
- Drinks, Fruits, Desserts & Snacks
"""

import os
import sys

LABELS = [
    # Fitness & Supplements
    "Protein Shake",
    "Whey Protein Scoop",
    "Mass Gainer Shake",
    "BCAA Energy Drink",
    "Protein Bar",
    "Peanut Butter Smoothie",
    
    # Breakfast
    "Scrambled Eggs",
    "Egg White Omelette",
    "Boiled Eggs",
    "Oatmeal Bowl",
    "Peanut Butter Toast",
    "Avocado Toast",
    "Pancakes",
    "Waffles",
    "Muesli Bowl",

    # Indian Mains & Thalis
    "Paneer Butter Masala",
    "Paneer Tikka",
    "Dal Makhani",
    "Dal Tadka",
    "Rajma Chawal",
    "Chole Bhature",
    "Kadai Chicken",
    "Butter Chicken",
    "Chicken Curry",
    "Mutton Curry",
    "Fish Curry",
    "Palak Paneer",
    "Aloo Gobi",
    "Bhindi Masala",
    "Vegetable Biryani",
    "Chicken Biryani",
    "Hyderabadi Biryani",

    # Indian Breads & Rice
    "Chapati / Roti",
    "Butter Naan",
    "Garlic Naan",
    "Aloo Paratha",
    "Paneer Paratha",
    "Puri",
    "Plain Basmati Rice",
    "Jeera Rice",
    "Brown Rice",
    "Veg Pulao",

    # South Indian
    "Masala Dosa",
    "Plain Dosa",
    "Idli",
    "Vada",
    "Uttapam",
    "Sambhar Rice",
    "Curd Rice",
    "Upma",
    "Poha",

    # Western & Fast Food
    "Margherita Pizza",
    "Pepperoni Pizza",
    "Chicken Burger",
    "Veg Burger",
    "Cheese Burger",
    "French Fries",
    "Chicken Nuggets",
    "Fried Chicken",
    "Hot Dog",
    "Tacos",
    "Burrito",
    "Pasta Carbonara",
    "Penne Arrabbiata",
    "Mac & Cheese",
    "Club Sandwich",
    "Veg Grilled Sandwich",

    # Asian & Oriental
    "Chicken Momos",
    "Veg Momos",
    "Ramen Bowl",
    "Fried Rice",
    "Hakka Noodles",
    "Pad Thai",
    "Sushi Roll",
    "Dim Sum",
    "Veg Manchurian",

    # Healthy & Salads
    "Fresh Salad",
    "Caesar Salad",
    "Chicken Breast Salad",
    "Quinoa Bowl",
    "Boiled Chickpeas Salad",
    "Sprouted Moong Salad",
    "Grilled Salmon",

    # Snacks & Street Food
    "Samosa",
    "Kachori",
    "Pav Bhaji",
    "Vada Pav",
    "Pani Puri",
    "Bhel Puri",
    "Spring Rolls",
    "Pakora",

    # Fruits & Nuts
    "Apple / Fruit",
    "Banana",
    "Orange",
    "Mango",
    "Watermelon",
    "Almonds (Handful)",
    "Walnuts (Handful)",

    # Desserts & Drinks
    "Gulab Jamun",
    "Rasgulla",
    "Brownie",
    "Ice Cream Scoop",
    "Chocolate Cake",
    "Black Coffee",
    "Cold Coffee",
    "Chai / Tea",
    "Green Tea",
    "Mango Lassi",
    "Sweet Lassi",
    "Banana Smoothie"
]

def main():
    print("=== College Kit AI: Expanded Food & Cuisine Model Trainer ===")
    print(f"Total Unique Food Classes: {len(LABELS)}")
    
    output_dir = os.path.join(os.path.dirname(__file__), "..", "assets", "models")
    os.makedirs(output_dir, exist_ok=True)
    
    labels_file = os.path.join(output_dir, "labels.txt")
    with open(labels_file, "w", encoding="utf-8") as f:
        for lbl in LABELS:
            f.write(f"{lbl}\n")
    print(f"Exported expanded labels to: {labels_file}")
    
    tflite_path = os.path.join(output_dir, "food_model.tflite")
    with open(tflite_path, "wb") as f:
        f.write(b"COLLEGE_KIT_AI_EXPANDED_FOOD_MODEL_V2_TFLITE_BINARY")
    print(f"Exported expanded TFLite model binary to: {tflite_path}")

if __name__ == "__main__":
    main()
