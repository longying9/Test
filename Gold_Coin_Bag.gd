extends ItemData

@export var money_value:int=200

func use():
	GameData.gold+=money_value
	Events.gold_changed.emit(GameData.gold)
	return true
