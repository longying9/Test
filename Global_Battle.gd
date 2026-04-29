extends Node

signal battle_finished(is_win: bool) # 新增信号
var battle_scene=preload("res://Template/Battle.tscn")

var current_battle_p_data = {}
var current_battle_e_data = {}
var is_battle_win:bool
var is_battle_running: bool = false

func start_battle_auto_players(enemy_config: Dictionary):
	
	var p_config = {}
	var owned = GameData.owned_roles
	print(owned)
	var positions = [0, 2, 4, 1, 3, 5] # 预设的上阵位置优先级
	
	# 根据拥有数量，按优先级填坑
	for i in range(min(owned.size(), positions.size())):
		p_config[positions[i]] = owned[i]
		
	# 调用你原有的 start_battle
	start_battle(p_config, enemy_config)

func start_battle(p_config: Dictionary, e_config: Dictionary):
	is_battle_running=true
	print("【系统】战斗初始化开始")
	current_battle_p_data = _map_data(p_config)
	current_battle_e_data = _map_data(e_config)
	
	var container = get_tree().root.find_child("BattlePanel", true, false)
	if container:
		container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for child in container.get_children():
			child.queue_free()
		var battle_instance = battle_scene.instantiate()
		battle_instance.mouse_filter = Control.MOUSE_FILTER_IGNORE
		container.add_child(battle_instance)
	
# 在战斗结束信号触发时或清理战斗时
func clear_battle_panel():
	var container = get_tree().root.find_child("BattlePanel", true, false)
	if container:
		# 战斗结束：设置为 Ignore，让鼠标可以穿透它点击到下方的主菜单
		container.mouse_filter = Control.MOUSE_FILTER_IGNORE	

func wait_for_battle() -> bool:
	while is_battle_running:
		await Engine.get_main_loop().process_frame
	return is_battle_win	

func _map_data(config: Dictionary) -> Dictionary:
	var result = {}
	for pos in config:
		var val=config[pos]
		var role_res: Resource = null
		if val is String:
			# 如果是字符串（比如 "ZhangJiao"），则从文件夹加载
			role_res = load("res://Resource/Role/" + val + ".tres")
		elif val is Resource:
			# 如果已经是 Resource 对象（比如来自 owned_Players），直接引用
			role_res = val
		
		if role_res:
			result[int(pos)] = role_res
			# 打印调试信息，如果是 Resource 则打印其名字或路径
			var debug_name = role_res.resource_path.get_file() if role_res.resource_path != "" else "内存资源"
			print("加载成功: 位置 ", int(pos), " 角色 ", debug_name)
		else:
			print("❌ 加载失败: 位置 ", int(pos), " 的数据无效")
			
	return result
