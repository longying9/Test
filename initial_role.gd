extends Control


@onready var role_list_container=$ScrollContainer/VBoxContainer

const ROLE_SLOT_SCENE=preload("res://Template/Role_slot.tscn")

func _ready() -> void:
	refresh_role_list()
	
func refresh_role_list():
	for child in role_list_container.get_children():
		child.queue_free()

	for role_data in GameData.owned_roles:
		var slot_instance=ROLE_SLOT_SCENE.instantiate()
		role_list_container.add_child(slot_instance)
		slot_instance.role_data=role_data
		slot_instance.init_slot()
