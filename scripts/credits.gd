extends Control

@onready var back: Button = $back

func _ready() -> void:
	pass 


func _process(delta: float) -> void:
	pass



func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://extras/title_screen.tscn")
