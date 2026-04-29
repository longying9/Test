extends Control

@onready var grid_container=$ScrollContainer/GridContainer
@onready var detail_panel=$PanelContainer
var equipment_slot=preload("res://Template/Equipment_slot.tscn")


func _ready() -> void:
	refresh_inventory()
	
func refresh_inventory():
	for child in grid_container.get_children():
		child.queue_free()
		
	for item in GameData.inventory:
		var slot=equipment_slot.instantiate()
		
		grid_container.add_child(slot)
		slot._update_slot(item)
		if slot.has_signal("request_view_detail"):
			slot.request_view_detail.connect(_on_slot_request_detail)
			
func _on_slot_request_detail(data:ItemData,pos:Vector2):
	detail_panel.show_item(data)
	detail_panel.global_position=pos
	var screen_width = get_viewport_rect().size.x
	var panel_width = detail_panel.size.x
	if detail_panel.global_position.x + panel_width > screen_width:
		# 如果右边塞不下了，就显示在格子的左边
		detail_panel.global_position.x = pos.x - panel_width - 20 
