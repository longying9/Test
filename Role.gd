extends Resource

class_name Role

@export var role_name:String
@export var title:String
@export_multiline var description:String 
@export var phy:int
@export var inte:int
@export var speed:int
@export var comp:int
var HP: int:
	get: return phy*10
var MP: int:
	get: return inte * 10
var attack: int:
	get: return phy * 3
var faqiang: int:
	get: return inte * 5
var fangyuli: int:
	get: return phy
var chushouspeed: int:
	get: return speed
@export var skills:Array[Skill]
