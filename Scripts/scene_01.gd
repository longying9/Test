extends Control

@onready var text_richlabel:RichTextLabel=$RichTextLabel
@onready var timer:Timer=$Timer
@onready var name_input=$name_input
@onready var random_name=$Random
@onready var game_start=$Game_Start
var full_text="[b][color=yellow]苍天已死，黄天当立。
岁在甲子，天下大吉。[/color][/b]

汉室倾颓，豪强并起，百姓如蒿草般被践踏。
巨鹿城外，张角兄弟暗传太平道，符水咒说，救得一时残喘，却救不得这腐朽人间。

官府盘剥，蝗灾连年，饿殍枕藉于道。
有人说，这是四百年的汉朝气数将尽。
也有人说，天命即将降于一位不凡之人——

就在这风雷暗涌的甲子年春天，
一声婴啼划破了破败山村的寂静。
没有天降异象，没有神龙护体，
只有一个平凡得不能再平凡的婴儿，睁开了眼睛。

村中老人口耳相传：“此子生逢乱世，要么草草夭折，要么……成就一番改天换命的大业。”

[b]你，就是那个婴儿。[/b]

多年后，你站在疮痍满目的中原大地上，
手里握着的，或许是剑，是笔，是符咒，又或者只是自己的拳头。

你的名字也会因为接下来的故事流芳百世

“请为这位乱世之子赐名”
[b][i]▶[color=red] [font_size=40]请输入输入你的名字：________"
var current_index=0
var player_name=""

func _ready() -> void:
	name_input.visible=false
	random_name.visible=false
	game_start.visible=false
	
	text_richlabel.bbcode_enabled=true
	text_richlabel.text=full_text
	text_richlabel.visible_characters=0
	
	timer.wait_time=0.05
	timer.timeout.connect(_add_next_char)
	name_input.text_changed.connect(_on_name_changed)
	random_name.pressed.connect(_on_random_name_pressed)
	game_start.pressed.connect(_on_game_start_pressed)
	timer.start()

func _add_next_char():
	if text_richlabel.visible_characters<text_richlabel.get_total_character_count():
		text_richlabel.visible_characters+=1
	else:
		_on_typing_done()
func _on_typing_done():
	timer.stop()
	name_input.visible=true
	random_name.visible=true
	name_input.grab_focus()#获得聚焦框
func _unhandled_input(event: InputEvent) -> void:#直接跳过开场白
	if event.is_action_pressed("Click"):
		if timer.is_stopped()==false:
			text_richlabel.visible_characters=-1
			_on_typing_done()
func _on_name_changed(_name:String):
	player_name=_name.strip_edges()
	if player_name:
		game_start.visible=true
func _on_random_name_pressed():
	var random_names=["鱼智", "欧飙", "翠锐", "赫语", "浮业", "边媚", "粘群", "瞿赐", "通起", "板含",
	"贲素怀", "岳芷雪", "尹欣荣", "冷云心", "斐力行", "泉慧云", "令狐杨", "子车卓",
	"万俟风", "端木三", "公叔高", "司空剑", "鲜于正初", "上官哲妍", "公西芮欣",
	"上官又槐", "闾丘葛菲", "司徒温韦"]
	var new_name=random_names[randi() % random_names.size()]
	name_input.text=new_name
	player_name=new_name
	game_start.visible=true
func _on_game_start_pressed():
	if !player_name:
		return
	GameData.player_name=player_name
	get_tree().change_scene_to_file("res://Scene/Scene-02.tscn")
