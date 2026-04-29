extends PanelContainer

@export var role_data:Role
@onready var role_name:RichTextLabel=$VBoxContainer/Role/Role_Name
@onready var role_quali:RichTextLabel=$VBoxContainer/Role/Role_Quali
@onready var role_property:RichTextLabel=$VBoxContainer/Role/Role_Property 
@onready var detail_panel=$VBoxContainer/Detail
@onready var role_detail_info=$VBoxContainer/Role
@onready var weapon_slot:Button=$VBoxContainer/Detail/VBoxContainer/Weapon
@onready var weapon_text:RichTextLabel=$VBoxContainer/Detail/VBoxContainer/Weapon/RichTextLabel
@onready var armor_slot:Button=$VBoxContainer/Detail/VBoxContainer/Armor
@onready var armor_text:RichTextLabel=$VBoxContainer/Detail/VBoxContainer/Armor/RichTextLabel
@onready var shoe_slot:Button=$VBoxContainer/Detail/VBoxContainer/Shoe
@onready var shoe_text:RichTextLabel=$VBoxContainer/Detail/VBoxContainer/Shoe/RichTextLabel
@onready var ZDSkill:RichTextLabel=$VBoxContainer/Detail/VBoxContainer/ZhuDongSkill
@onready var BDSkill:RichTextLabel=$VBoxContainer/Detail/VBoxContainer/BeiDongSkill

func _ready() -> void:
	detail_panel.visible=false
	role_detail_info.pressed.connect(_on_role_info_pressed)
	weapon_slot.pressed.connect(func():_on_slot_pressed(ItemData.ItemType.Weapon))
	armor_slot.pressed.connect(func():_on_slot_pressed(ItemData.ItemType.Armor))
	shoe_slot.pressed.connect(func():_on_slot_pressed(ItemData.ItemType.Shoe))
	Events.wear_equipment.connect(_on_wear_equipment)
	update_role_detail(role_data)
	
func init_slot():
	if role_data:
		update_role_detail(role_data)
	
func update_role_detail(role:Role):
	role_name.text = "[b][font_size=40]%s[/font_size][/b]" % role.role_name
	role_quali.text="体魄"+str(role.phy)+"智力"+str(role.inte)+"速度"+str(role.speed)+"悟性"+str(role.comp)
	role_property.text="生命值"+str(role.HP)+"法力值"+str(role.MP)+"攻击力"+str(role.attack)+"法强"+str(role.faqiang)+"防御力"+str(role.fangyuli)+"出手速度"+str(role.chushouspeed)
	ZDSkill.text="主动技能"
	BDSkill.text="被动技能"


func _on_role_info_pressed():
	toggle_detail()
		
func toggle_detail():
	detail_panel.visible = !detail_panel.visible

func _on_slot_pressed(type:ItemData.ItemType):
	var _list:Array[ItemData]=[]
	for item in GameData.inventory:
		if item.type==type:
			_list.append(item)
	if _list.size()>0:
		SelectionMenu.open_menu(_list,role_data.role_name)
	else:
		Events.request_toast.emit("没有同类型装备")

func _on_wear_equipment(item:ItemData,target_name:String):
	if target_name !=role_data.role_name:
		return
	
	GameData.consume_item(item)
	match item.type:
		ItemData.ItemType.Weapon:
			weapon_text.text = item.name
		ItemData.ItemType.Armor:
			armor_text.text = item.name
		ItemData.ItemType.Shoe:
			shoe_text.text = item.name
	Events.request_toast.emit(target_name + "穿上了" + item.name)
	
