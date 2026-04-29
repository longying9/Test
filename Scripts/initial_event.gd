extends Control
@onready var scroll_vbox = $ScrollContainer/VBoxContainer
const EVENT_TEMPLATE = preload("res://Template/Event.tscn")

@export var month_events:Array[MonthlyEvent]

func _ready() -> void:
	load_current_events()
	
func load_current_events():
	var idx =GameData.current_event_index
	if idx >=0 and idx<month_events.size():
		var event=month_events[idx]
		var item = EVENT_TEMPLATE.instantiate()
		scroll_vbox.add_child(item)
		item.init_event(event)
		_scroll_to_bottom()
		item.start_typing()
		await item.finished
		GameData.current_event_index+=1
		GameData._save_data()
	else:
		Events.request_toast.emit("当前没有更多事件了")

func _scroll_to_bottom():
	await get_tree().process_frame
	var scroll_bar = $ScrollContainer.get_v_scroll_bar()
	$ScrollContainer.scroll_vertical = scroll_bar.max_value
