class_name  Item

var name : String
var amount : int

func init_item(item_name: String, item_quantity: int):
	name = item_name
	amount = item_quantity

func update_amount(new_amount: int):
	amount += new_amount
