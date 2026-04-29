extends Node

signal player_action_finished
@onready var player_grids=$PanelContainer/VBoxContainer2/Player/GridContainer.get_children()
@onready var enemy_grids=$PanelContainer/VBoxContainer2/Enemy/GridContainer.get_children()
@onready var skill_ui =$PanelContainer/PanelContainer/Skill
@onready var role_name=$PanelContainer/PanelContainer/Skill/role_name
@onready var putonggongji:Button=$PanelContainer/PanelContainer/Skill/PuTongGongJi

var active_player_units:Dictionary={}
var active_enemy_units:Dictionary={}
var action_queue:Array=[]
var current_actor:FighterSlot=null
var selected_skill:Dictionary={}

func _ready() -> void:
	skill_ui.hide()
	putonggongji.pressed.connect(_on_normal_attack_pressed)
	spawn_team(GlobalBattle.current_battle_p_data, GlobalBattle.current_battle_e_data)
	sort_action_queue()
	excute_action_queue()
func start_battle():
	# 使用 Global 里的数据
	spawn_team(GlobalBattle.current_battle_p_data, GlobalBattle.current_battle_e_data)
	sort_action_queue()
	excute_action_queue()



func spawn_team(player_data:Dictionary,enemy_data:Dictionary):
	setup_side(player_grids,player_data,active_player_units)
	setup_side(enemy_grids, enemy_data, active_enemy_units)
	
func setup_side(grids: Array, data: Dictionary, active_registry: Dictionary):
	active_registry.clear()
	
	for i in range(grids.size()):
		var slot =grids[i]
		if data.has(i):
			slot.modulate.a = 1.0
			slot.visible=true
			slot.init_fighter(data[i])
			active_registry[i] = slot
			if not slot.clicked.is_connected(_on_target_selected):
				slot.clicked.connect(_on_target_selected)
		else:
			slot.modulate.a = 0.0
			slot.current_hp = 0
			
func sort_action_queue():
	action_queue.clear()
	var all_units = active_player_units.values() + active_enemy_units.values()
	var valid_units = all_units.filter(func(u): return u != null and u.player_data != null)
	# 按出手速度排序 (chushouspeed)
	valid_units.sort_custom(func(a, b):
		return a.player_data.chushouspeed > b.player_data.chushouspeed
	)
	action_queue = valid_units
	print("行动队列已就绪，单位数量: ", action_queue.size())

func excute_action_queue():
	await get_tree().create_timer(0.2).timeout
	# 如果队列是空的，直接判负或退出，防止死循环
	if action_queue.is_empty():
		print("错误：行动队列为空，强制结束战斗")
		_force_end_battle()
		return
	while true:
		for unit in action_queue:
			if unit.current_hp <= 0:
				continue
			
			current_actor = unit
			current_actor.set_highlight(true)
			
			if unit in active_player_units.values():
				skill_ui.show()
				role_name.text = unit.player_data.role_name
				await self.player_action_finished
				skill_ui.hide()
			else:
				await handle_enemy_ai(unit)
			
			current_actor.set_highlight(false)
			await get_tree().create_timer(0.6).timeout
			
			# ✅ 只在这里检查，不在循环开头检查
			if check_battle_result() != "continue":
				return
		
		# ✅ 每轮结束后也检查一次
		if check_battle_result() != "continue":
			return
func _force_end_battle():
	GlobalBattle.is_battle_win = false
	GlobalBattle.battle_finished.emit(false)
	get_parent().queue_free()
func _on_normal_attack_pressed():
	if current_actor == null:
		return
	selected_skill = {
		"type": "PuTongGongJi", 
		"damage": current_actor.player_data.attack
	}
	selected_skill = {"type": "PuTongGongJi", "damage": current_actor.player_data.attack}
func _on_target_selected(target_unit):
	if selected_skill.is_empty():
		return
	if target_unit in active_enemy_units.values():
		if target_unit.current_hp <= 0: return # 别打死人
		
		# --- 正式造成伤害 ---
		target_unit.take_damage(selected_skill.damage)
		
		# --- 动作完成，重置状态 ---
		selected_skill = {} 
		player_action_finished.emit() # 这会结束 excute_action_queue 里的 await
	else:
		print("请点击敌人目标，不要点队友")

func handle_enemy_ai(enemy):
	await get_tree().create_timer(1.0).timeout
	# 简单的 AI：随机寻找一个活着的玩家
	var alive_players = active_player_units.values().filter(func(u): return u.current_hp > 0)
	if alive_players.size() > 0:
		var target = alive_players.pick_random()
		target.take_damage(enemy.player_data.attack)

func check_battle_result() -> String:
	if current_actor == null: 
		return "continue"
	var p_alive = active_player_units.values().any(func(u): return u.current_hp > 0)
	var e_alive = active_enemy_units.values().any(func(u): return u.current_hp > 0)
	
	if not e_alive:
		Events.request_toast.emit("胜利！")
		GlobalBattle.is_battle_win = true
		GlobalBattle.is_battle_running = false
		GlobalBattle.battle_finished.emit(true) # 告诉大家赢了
		get_parent().queue_free()
		return "win"
	if not p_alive:
		Events.request_toast.emit("失败...")
		GlobalBattle.is_battle_win = false # 记录失败
		GlobalBattle.is_battle_running = false
		GlobalBattle.battle_finished.emit(false) # 告诉大家输了
		get_parent().queue_free()
		return "lose"
	return "continue"

# 统一处理战斗结束
func _finish_battle(win: bool):
	GlobalBattle.is_battle_win = win
	# 关键：手动拉起对话框，跳转到 Post_Battle 标签
	var dialogue_res = load(GlobalBattle.current_dialogue_path)
	# 确保这里调用的是你项目中实际使用的 Balloon 场景
	DialogueManager.show_example_dialogue_balloon(dialogue_res, "Post_Battle")
	# 发出信号（保留给其他系统用）
	GlobalBattle.battle_finished.emit(win)
	# 销毁战斗
	get_parent().queue_free()
	GlobalBattle.clear_battle_panel()
