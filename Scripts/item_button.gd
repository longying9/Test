extends Button

@onready var label_text=$VBoxContainer/Label

signal purchase_clicked(data:ItemData)

var item_data:ItemData

func _ready() -> void:
	self.pressed.connect(_on_buy_button_pressed)
func set_item(data:ItemData):
	item_data=data
	label_text.text=data.name+"\n"+str(data.price)+"金币"+"\n"+data.description+"\n"+"数量"+str(data.amount)
	
func _on_buy_button_pressed():
	purchase_clicked.emit(item_data)
