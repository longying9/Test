extends PanelContainer

var current_data:ItemData

@onready var name_label=$VBoxContainer/ItemName
@onready var desc_label=$VBoxContainer/ItemDescription
@onready var use_button=$VBoxContainer/Use
@onready var close_button=$VBoxContainer/Close


func _ready() -> void:
	self.hide()
	use_button.pressed.connect(_on_use_button_preseed)
	close_button.pressed.connect(_on_close_button_pressed)

func show_item(item:ItemData):
	current_data=item
	name_label.text=item.name
	desc_label.text=item.description
	self.show()
	
func _on_use_button_preseed():
	if current_data:
		var success=current_data.use()
		if success:
			current_data.amount-=1
			if current_data.amount<=0:
				GameData.remove_item(current_data)
				get_tree().call_group("InitialEquipment","refresh_inventory")
				self.hide()
				return
			get_tree().call_group("InitialEquipment","refresh_inventory")
			show_item(current_data)
			
func _on_close_button_pressed():
	self.hide()
			
