extends RichTextLabel
class_name FighterSlot

signal clicked(node:FighterSlot)
@onready var button=$Button

var player_data:Role

var current_hp:int
var current_mp:int
var is_alive:bool=true
var buffs:Array=[]
var debuffs:Array=[]
var has_acted:bool=false# 本回合是否已经行动过

func _ready() -> void:
	button.pressed.connect(_on_button_pressed)

func init_fighter(role:Role) -> void:
	player_data=role
	if player_data==null:
		self.modulate.a = 0.0
		self.button.visible=false
		return
	current_hp=player_data.HP
	current_mp=player_data.MP
	is_alive = true
	self.modulate = Color.WHITE # 确保不是死亡的灰色
	update_UI()
	
func update_UI():
	self.text=player_data.role_name+"\n"+str(current_hp)+"\n"+str(current_mp)
	
func _on_button_pressed():
	if !is_alive:
		return
	clicked.emit(self)
	
func set_highlight(active:bool):
	if active:
		self.add_theme_stylebox_override("normal", load("res://Template/highlight_style.tres"))
	else:
		self.remove_theme_stylebox_override("normal")

func take_damage(raw_damage:int):
	var real_damage=max(1,raw_damage-player_data.fangyuli)
	current_hp = max(0, current_hp - real_damage)
	
	update_UI()
	# 这里可以加个小动画，比如文字闪烁一下
	if current_hp <= 0:
		handle_death()

func apply_status_effects():
	for effect in debuffs:
		if effect == "Poison": # 举例：中毒
			take_damage(5)

func cast_skill() -> bool:
	# 这里简单模拟一个技能消耗
	var cost = player_data.skills[0].mp_cost
	if current_mp >= cost:
		current_mp -= cost
		update_UI()
		return true # 释放成功
	else:
		Events.request_toast.emit("内力不足")
		return false # 释放失败


func handle_death():
	# 变灰或者改变文本样式提示阵亡
	is_alive=false
	self.modulate = Color(0.5, 0.5, 0.5, 0.7) 
	Events.request_toast.emit(player_data.role_name+"倒下了")
	self.text=("已力竭")
