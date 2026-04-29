extends Control

@onready var player_name=$Name
@onready var quali=$Quali

@onready var hp_text=$Status/HP
@onready var mp_text=$Status/MP
@onready var atk_text=$Status/ATK
@onready var ap_text=$Status/AP
@onready var def_text=$Status/DEF
@onready var attack_speed=$Status/ATKSPEED

@onready var phy_text=$Quali/Physique
@onready var phy_slider=$Quali/Physique/HSlider
@onready var inte_text=$Quali/Intelligence
@onready var inte_slider=$Quali/Intelligence/HSlider
@onready var speed_text=$Quali/Speed
@onready var speed_slider=$Quali/Speed/HSlider
@onready var comp_text=$Quali/Comprehension
@onready var comp_slider=$Quali/Comprehension/HSlider

@onready var description=$Description
@onready var game_start=$Next_level
@onready var confirm_dialog=$Next_level/Saveconfirmdialog
var total_points=20#总点数为20

func _ready() -> void:
	player_name.text=GameData.player_name+str(":乱世之子")
	quali.text="资质"+"初始资质点数为"+str(total_points)
	phy_slider.value=5
	inte_slider.value=5
	speed_slider.value=5
	comp_slider.value=5
	
	phy_slider.value_changed.connect(_on_phy_changed)
	inte_slider.value_changed.connect(_on_inte_changed)
	speed_slider.value_changed.connect(_on_speed_changed)
	comp_slider.value_changed.connect(_on_comp_changed)
	game_start.pressed.connect(_on_next_level)
	confirm_dialog.confirmed.connect(_on_confirm_dialog_confirmed)

	_update_ui_display()
	
	description.text="[font_size=24]注：生命值=体魄*10，攻击力=体魄*3，防御力=体魄，武将的体魄相对来说较高\n法力值=智力*10，法强=智力*5，文将的智力相对来说较高\n出手速度=速度(速度相同时，主角方先移动)\n而悟性影响了每次升级对这三个的影响。比如生命值100，体魄4，悟性3，每次升级hp+体魄*悟性。1级100hp，2级则为100+4*3*1=112，3级则为112+4*3*2=136。悟性越高，角色成长速度越快。"
func _on_phy_changed(value):
	var int_value=_get_allowed_value(phy_slider)
	phy_text.text="体魄"+"\n"+str(int_value)
	hp_text.text="生命值"+"\n"+str(int_value*10)
	atk_text.text="攻击力"+"\n"+str(int((int_value*3)))
	def_text.text="防御力"+"\n"+str(int_value)
	
func _on_inte_changed(value):
	var int_value=_get_allowed_value(inte_slider)
	inte_text.text="智力"+"\n"+str(int_value)
	mp_text.text="法力值"+"\n"+str(int_value*10)
	ap_text.text="法强"+"\n"+str(int((int_value*5)))
	
func _on_speed_changed(value):
	var int_value=_get_allowed_value(speed_slider)
	speed_text.text="速度"+"\n"+str(int_value)
	attack_speed.text="出手速度"+"\n"+str(int_value)

func _on_comp_changed(value):
	var int_value=_get_allowed_value(comp_slider)
	comp_text.text="悟性"+"\n"+str(int_value)

func _get_allowed_value(current_slider:HSlider)->int:
	var other_total=0
	var all_sliders=[phy_slider,inte_slider,speed_slider,comp_slider]
	
	for s in all_sliders:
		if s!=current_slider:
			other_total+=s.value
	var max_allowed=total_points-other_total
	max_allowed=clamp(max_allowed,1,10)
	
	if current_slider.value>max_allowed:
		current_slider.value_changed.disconnect(_on_current_changed_proxy(current_slider))
		current_slider.value=max_allowed
		current_slider.value_changed.connect(_on_current_changed_proxy(current_slider))
	
	var currrent_total=other_total+current_slider.value
	quali.text="资质:初始资质20/已分配:"+str(currrent_total)
	
	return int(current_slider.value)

func _on_current_changed_proxy(s):
	if s == phy_slider: return _on_phy_changed
	if s == inte_slider: return _on_inte_changed
	if s == speed_slider: return _on_speed_changed
	return _on_comp_changed

func _update_ui_display():
	_on_phy_changed(phy_slider.value)
	_on_inte_changed(inte_slider.value)
	_on_speed_changed(speed_slider.value)
	_on_comp_changed(comp_slider.value)
	
func _on_next_level():
	confirm_dialog.popup_centered()

func _on_confirm_dialog_confirmed():
	GameData.phy_value=phy_slider.value
	GameData.inte_value=inte_slider.value
	GameData.speed_value=speed_slider.value
	GameData.comp_value=comp_slider.value
	GameData.create_protagonist(GameData.player_name,GameData.phy_value,GameData.inte_value,GameData.speed_value,GameData.comp_value)
	GameData._save_data()
	print("游戏开始")
	get_tree().change_scene_to_file("res://Scene/Scene-03.tscn")
