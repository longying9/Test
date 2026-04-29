extends Node
const SAVE_PATH="res://Data/savedata.tres"

var player_name=""
var phy_value:int=0
var inte_value:int=0
var speed_value:int=0
var comp_value:int=0
var inventory:Array[ItemData]=[]
var gold:int=0:
	set(value):
		gold=value
		Events.gold_changed.emit(gold)
var owned_roles:Array[Role]=[]
var current_event_index:int=0

#存档系列
func _save_data():
	var new_save=SaveData.new()
	new_save.player_name=player_name
	new_save.phy=phy_value
	new_save.inte=inte_value
	new_save.speed=speed_value
	new_save.comp=comp_value
	new_save.inventory=inventory
	new_save.owned_roles=owned_roles
	new_save.gold=gold
	new_save.current_event_index=GameData.current_event_index
	var result=ResourceSaver.save(new_save,SAVE_PATH)
	if result==OK:
		print("保存成功")
	else:
		print("保存失败")
func _load_data():
	if not FileAccess.file_exists(SAVE_PATH):
		print("未发现存档")
		return
	var loaded_data=load(SAVE_PATH) as SaveData
	
	if loaded_data:
		player_name=loaded_data.player_name
		phy_value=loaded_data.phy
		inte_value=loaded_data.inte
		speed_value=loaded_data.speed
		comp_value=loaded_data.comp
		inventory=loaded_data.inventory
		owned_roles=loaded_data.owned_roles
		current_event_index=loaded_data.current_event_index
		gold=loaded_data.gold
		
		
#商店系列		
func add_item(data:ItemData):
	for i in inventory:
		if i.name==data.name:
			i.amount+=data.amount
			return
	var new_item=data.duplicate()
	inventory.append(new_item)
	
func consume_item(item:ItemData):
	var index=inventory.find(item)
	if index!=-1:
		inventory[index].amount -=1
		if inventory[index].amount <= 0:
			inventory.remove_at(index)
		_save_data()
	else:
		Events.request_toast.emit("错误：尝试消耗仓库中不存在的物品")

func remove_item(data:ItemData):
	var index=inventory.find(data)
	if index!=-1:
		inventory.remove_at(index)
		_save_data()

#武将系列
func recruit_role(new_role:Role):
	if not owned_roles.has(new_role):
		owned_roles.append(new_role)
		_save_data()
		Events.request_toast.emit("成功招募武将"+new_role.role_name)

func create_protagonist(p_name:String,p_phy:int,p_inte:int,p_speed:int,p_comp:int):
	var new_player=Role.new()
	new_player.role_name=p_name
	new_player.title="乱世之子"
	new_player.phy=p_phy
	new_player.inte=p_inte
	new_player.speed=p_speed
	new_player.comp=p_comp
	owned_roles.append(new_player)
	_save_data()
