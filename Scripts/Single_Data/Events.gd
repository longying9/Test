extends Node

const ZhangJiao=preload("res://Resource/Role/ZhangJiao.tres")

signal gold_changed(new_value:int)
signal wear_equipment(item:ItemData,target_role_name:String)
signal request_toast(message:String)
