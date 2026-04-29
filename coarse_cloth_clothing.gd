extends ItemData

@export var add_phy:int=1

func use():
	GameData.phy_value+=add_phy
