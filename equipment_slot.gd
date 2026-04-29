extends Button

@onready var label_text=$RichTextLabel

var item_data:ItemData
signal request_view_detail(data:ItemData,pos:Vector2)
func _ready() -> void:
	self.pressed.connect(_on_pressed)
	
func _update_slot(data:ItemData):
	item_data=data
	label_text.mouse_filter=Control.MOUSE_FILTER_IGNORE
	if item_data:
		label_text.text=data.name+"\n"+str(data.amount)
		self.disabled=false
	else:
		label_text.text=""
		self.disabled=true

func _on_pressed():
	if item_data:
		var spawn_pos=global_position+Vector2(size.x+10,0)
		request_view_detail.emit(item_data,spawn_pos)
