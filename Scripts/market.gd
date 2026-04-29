extends Control

@onready var base_merchant=$VBoxContainer/Merchant
@onready var base_markets=$VBoxContainer/Product
@onready var confirm_dialog=$ConfirmationDialog

@export var current_merchant:MerchantData

var selected_item:ItemData

func _ready() -> void:
	confirm_dialog.confirmed.connect(_on_confirmation_dialog_confirmed)
	if current_merchant:
		load_merchant_shop(current_merchant)

func load_merchant_shop(merchant:MerchantData):
	base_merchant.text=merchant.name+merchant.description
	for child in base_markets.get_children():
		child.queue_free()
	for data in merchant.inventory:
		create_item_slot(data)
func create_item_slot(data:ItemData):
	var slot_scene=preload("res://Template/ItemButton.tscn")
	var slot=slot_scene.instantiate()
	slot.custom_minimum_size=Vector2(240,128)
	base_markets.add_child(slot)
	slot.set_item(data)
	if slot.has_signal("purchase_clicked"):
		slot.purchase_clicked.connect(_on_buy_requested)
func _on_buy_requested(data:ItemData):
	selected_item=data
	if GameData.gold>=selected_item.price:
		confirm_dialog.dialog_text = "是否花费 " + str(data.price) + " 金币购买 " + data.name + "？"
		confirm_dialog.popup_centered()
	else:
		Events.request_toast.emit("金币不足，购买失败")
	
	
func _on_confirmation_dialog_confirmed():
	if selected_item:
		if GameData.gold>=selected_item.price:
			selected_item.amount-=1
			selected_item.set_item(selected_item)
			GameData.gold-=selected_item.price
			Events.gold_changed.emit(GameData.gold)
			GameData.add_item(selected_item)
			GameData._save_data()
			Events.request_toast.emit("购买成功")
		else:
			Events.request_toast.emit("购买的瞬间发现金币不够了")
