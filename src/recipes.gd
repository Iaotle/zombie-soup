class_name Recipe

var _name : String
var _price : int
var _ingredients : Array[String] = []

func init_receipe(name: String, price: int, ingredients: Array[String]):
	_name = name;
	_price = price;
	for i in ingredients:
		_ingredients.append(i)
	print("[+]Receipe: ", name, " |", price, " Bullets | ingredients: ")
	for i in _ingredients:
		print(i);
