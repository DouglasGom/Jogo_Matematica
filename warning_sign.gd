extends Node2D

@onready var texture: Sprite2D = $texture
@onready var area_sign: Area2D = $area_sign
@onready var warning_label: Label = $warning_label


# Esta variável vai aparecer no Inspetor do Godot para CADA placa
@export var dialog_text : Array[String]

# Variável de controle para saber se o jogador está na área
var player_in_area := false

func _ready() -> void:
	# Garante que o ícone comece invisível
	texture.hide()
	warning_label.hide()

# Conecte o sinal "body_entered" do nó 'area_sign' a esta função
func _on_area_sign_body_entered(body: Node2D) -> void:
	if body.name == "player":
		texture.show()
		warning_label.show()
		player_in_area = true

# Conecte o sinal "body_exited" do nó 'area_sign' a esta função
func _on_area_sign_body_exited(body: Node2D) -> void:
	if body.name == "player":
		texture.hide()
		warning_label.hide()
		player_in_area = false
		
		# Cancela o diálogo caso o jogador saia de perto da placa no meio da conversa
		if DialogManager.is_message_active and DialogManager.dialog_box != null:
			DialogManager.dialog_box.queue_free()
			DialogManager.is_message_active = false

# Lida apenas com o clique do botão
func _unhandled_input(event: InputEvent) -> void:
	if player_in_area and event.is_action_pressed("interact"):
		if !DialogManager.is_message_active:
			texture.hide()
			warning_label.hide()
			# Agora ele envia o texto personalizado DESTA placa específica para o manager
			DialogManager.start_message(global_position, dialog_text)
