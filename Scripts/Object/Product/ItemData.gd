extends Resource

class_name ItemData

enum ItemType{
	Weapon,
	Armor,
	Shoe,
	Props
}

@export var name:String=""
@export var price:int=0
@export_multiline() var description:String=""
@export var type:ItemType=ItemType.Weapon
@export var amount:int=1

func use():
	print("使用了物品")
	return true
