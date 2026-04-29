extends CanvasLayer

@onready var container=$PanelContainer/ScrollContainer/VBoxContainer

var current_target:String=""

func _ready() -> void:
	hide()
	
func open_menu(items:Array[ItemData],target_name:String):
	current_target=target_name
	if container:
		for child in container.get_children():
			child.queue_free()

	for item in items:
		var btn = Button.new()
		btn.text=item.name+"\n"+str(item.amount)
		container.add_child(btn)
		btn.pressed.connect(func():_on_button_click(item))
	show()
func _on_button_click(item:ItemData):
	Events.wear_equipment.emit(item,current_target)
	hide()
