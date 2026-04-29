extends Control

@export var Base_shopconfig:ShopConfig
@export var Rare_shopconfig:ShopConfig

func _ready() -> void:
	if Base_shopconfig:
		create_shop(Base_shopconfig, Vector2(0, 50))
	if Rare_shopconfig:
		create_shop(Rare_shopconfig, Vector2(0, 600))

func create_shop(config:ShopConfig,pos:Vector2):
	if not config:
		return
	var shop=config.layout_template.instantiate()
	add_child(shop)
	shop.position=pos
	
	if "current_merchant" in shop:
		shop.current_merchant=config.merchant_data
		shop.load_merchant_shop(config.merchant_data)
