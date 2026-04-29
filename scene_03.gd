extends Control

@onready var player_name=$HBoxContainer/PlayerName
@onready var player_gold=$HBoxContainer2/PlayerGold
@onready var player_time=$HBoxContainer/PlayerTime
@onready var market_button=$BottomBar/Market
@onready var role_button=$BottomBar/Role
@onready var event_button=$BottomBar/Event
@onready var equipment_button=$BottomBar/Equipment

const Scenes={
	"market":preload("res://Scene/InitialMarket.tscn"),
	"role":preload("res://Scene/InitialRole.tscn"),
	"event":preload("res://Scene/InitialEvent.tscn"),
	"equipment":preload("res://Scene/InitialEquipment.tscn")
}
@onready var content_container=$ContentContainer

var is_in_envent=false

func _ready() -> void:
	player_name.text=GameData.player_name
	update_gold_text(GameData.gold)
	Events.gold_changed.connect(_on_gold_changed)
	Events.request_toast.connect(show_toast)
	market_button.pressed.connect(_on_market_button_pressed)
	role_button.pressed.connect(_on_role_button_pressed)
	event_button.pressed.connect(_on_event_button_preseed)
	equipment_button.pressed.connect(_on_equipment_button_pressed)

func _on_gold_changed(new_gold_value:int):
	update_gold_text(new_gold_value)
	
func update_gold_text(value:int):
	player_gold.text="金币"+str(value)

func _on_market_button_pressed():
	switch_page("market")
	is_in_envent=false
func _on_role_button_pressed():
	switch_page("role")
	is_in_envent=false
func _on_event_button_preseed():
	if is_in_envent:
		return
	switch_page("event")
	is_in_envent=true
func _on_equipment_button_pressed():
	switch_page("equipment")
	is_in_envent=false

func switch_page(page_name:String):
	if GlobalBattle.is_battle_running:
		return
	GameData._save_data()
	for child in content_container.get_children():
		child.queue_free()
	var new_page=Scenes[page_name].instantiate()
	print(Scenes[page_name])
	content_container.add_child(new_page)
	new_page.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func show_toast(message:String):
	var label=Label.new()
	label.text=message
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.z_index=10
	label.global_position=get_viewport_rect().size/2-label.size/2
	add_child(label)
	var tween=create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", label.position.y - 50, 1.5)
	tween.tween_property(label, "modulate:a", 0.0, 1.5)
	tween.finished.connect(func(): label.queue_free())
