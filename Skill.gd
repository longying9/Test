extends Resource

class_name Skill

@export var skill_name:String
@export_multiline var description:String
@export var mp_cost:int
@export var power_multiple:String

func excute():
	print("使用了技能")
