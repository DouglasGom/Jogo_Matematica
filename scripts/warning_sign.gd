extends Node2D

@onready var texture: Sprite2D = $texture
@onready var area_sign: Area2D = $area_sign
@onready var warning_label: Label = $warning_label


@export var dialog_text : Array[String]

var player_in_area := false

func _ready() -> void:
	texture.hide()
	warning_label.hide()

func _on_area_sign_body_entered(body: Node2D) -> void:
	if body.name == "player":
		texture.show()
		warning_label.show()
		player_in_area = true

func _on_area_sign_body_exited(body: Node2D) -> void:
	if body.name == "player":
		texture.hide()
		warning_label.hide()
		player_in_area = false
		
		if DialogManager.is_message_active and DialogManager.dialog_box != null:
			DialogManager.dialog_box.queue_free()
			DialogManager.is_message_active = false

func _unhandled_input(event: InputEvent) -> void:
	if player_in_area and event.is_action_pressed("interact"):
		if !DialogManager.is_message_active:
			texture.hide()
			warning_label.hide()
			DialogManager.start_message(global_position, dialog_text)
