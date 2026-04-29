extends RichTextLabel

func  _ready() -> void:
	bbcode_enabled=true
	self.meta_clicked.connect(_on_mouse_clicked)
	
	update_menu_display()
	
func update_menu_display():
	var menu_text = "[url=start_game]开始游戏[/url]\n"
	if FileAccess.file_exists(GameData.SAVE_PATH):
		menu_text+="[url=load_game]加载存档[/url]\n"
	menu_text += "[url=game_setting]游戏设置[/url]\n"
	menu_text += "[url=quit_game]离开游戏[/url]"
	self.text=menu_text
func _on_mouse_clicked(meta):
	if meta=="start_game":
		get_tree().change_scene_to_file("res://Scene/Scene-01.tscn")
	elif meta=="load_game":
		GameData._load_data()
		print("加载游戏")
		get_tree().change_scene_to_file("res://Scene/Scene-03.tscn")
	elif meta=="game_setting":
		print("游戏设置")
	elif meta=="quit_game":
		get_tree().quit()
