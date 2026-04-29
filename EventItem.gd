extends Control

@onready var dialogue_label=$VBoxContainer/DialogueLabel
@onready var response_container=$VBoxContainer/ResponseContainer
var current_data:MonthlyEvent

var is_typing: bool = false
var is_battle_triggered=false
signal finished


func _ready()->void:
	DialogueManager.mutated.connect(func(mutation: Dictionary):
		# 使用 get() 安全访问，防止 Dictionary 报错
		var expression = str(mutation.get("expression", ""))
		
		# 检查执行的指令中是否包含你的战斗函数名
		if "start_battle" in expression:
			is_battle_triggered = true
			print("【信号监听】检测到战斗指令，标记已设为 true")
	)


func init_event(data:MonthlyEvent):
	current_data=data
	dialogue_label.text=""
	dialogue_label.bbcode_enabled=true
	dialogue_label.add_theme_font_size_override("normal_font_size", 24)
	
func start_typing():
	if is_typing: 
		return
	is_typing = true
	
	var line = await current_data.dialogue_file.get_next_dialogue_line(current_data.start_tag)
	
	while line:
		var name_str = "[color=gold]" + tr(line.character) + "：[/color]" if line.character != "" else ""
		var text_str = tr(line.text)
		var start_idx = dialogue_label.text.length()
		if dialogue_label.text != "":
			dialogue_label.text += "\n\n"
			start_idx = dialogue_label.text.length()
		dialogue_label.text += name_str + text_str
		
		dialogue_label.visible_characters = start_idx
		var duration = text_str.length() * 0.05
		var tween = create_tween()
		tween.tween_property(dialogue_label, "visible_characters", dialogue_label.text.length(), duration).from(start_idx)
		await tween.finished
		
		
		dialogue_label.visible_characters = -1
		
		if is_battle_triggered:
			print("【逻辑阻塞】检测到战斗指令，打字机循环暂停，等待战斗信号...")
			await GlobalBattle.battle_finished  # <--- 这里就是红绿灯，不亮绿灯不往下走
			is_battle_triggered = false        # 重置标记
			print("【逻辑恢复】战斗结束，读取后续剧情")
			
			# 战斗结束后，is_battle_win 已更新，此时再去取下一行（即 if/else 判断后的那行）
			line = await current_data.dialogue_file.get_next_dialogue_line(line.next_id)
			_force_scroll()
			continue # 跳过下面的逻辑，直接进入下一轮循环显示文本
		
		
		if line.responses.size() > 0:
			var next_id = await _show_responses(line.responses)
			if next_id == "":
				line = null
			else:
				line = await current_data.dialogue_file.get_next_dialogue_line(next_id)
		elif line.next_id != "":
			line = await current_data.dialogue_file.get_next_dialogue_line(line.next_id)
			_force_scroll()
		else:
			line = null
	
	is_typing = false
	finished.emit()

func _force_scroll():
	await get_tree().process_frame
	# 这里寻找主界面的 ScrollContainer
	var scroll = get_parent().get_parent() # 根据你的层级调整
	if scroll is ScrollContainer:
		scroll.scroll_vertical = scroll.get_v_scroll_bar().max_value
		
		

func _show_responses(responses: Array) -> String:
	# 1. 清理旧按钮
	for child in response_container.get_children():
		child.queue_free()
	
	# 2. 使用字典(Dictionary)来存储结果，确保闭包能正确读写变量
	var data = { "selected_id": "" }
	
	for response in responses:
		var btn = Button.new()
		btn.text = response.text
		btn.add_theme_font_size_override("font_size", 22)
		btn.custom_minimum_size.y = 60
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		response_container.add_child(btn)
		
		# --- 稳健的写法：分步创建 Callable ---
		var handler = func(id):
			data["selected_id"] = id
			print("【内部检查】已点击，ID赋值为: ", id)
		
		# 将参数绑定到函数上，再连接信号
		btn.pressed.connect(handler.bind(response.next_id))
	
	# 3. 等待变量被修改
	print("【逻辑追踪】正在等待玩家点击...")
	while data["selected_id"] == "":
		await get_tree().process_frame
	
	var result = data["selected_id"]
	print("【逻辑追踪】检测到变量变化，准备退出循环，返回 ID: ", result)
	
	# 4. 清理并返回
	for child in response_container.get_children():
		child.queue_free()
		
	return result


	
