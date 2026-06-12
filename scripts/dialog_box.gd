extends MarginContainer

@onready var letter_time_display: Timer = $letter_time_display
@onready var text_label: Label = $label_margin/text_label

var MAX_WIDTH = 256

var text = ""
var letter_index = 0

var letter_display_time := 0.07
var space_display_time := 0.05
var punctuation_display_time := 0.02

signal text_display_finished()

func display_text(text_to_display: String):
	text = text_to_display
	
	# Colocamos todo o texto, mas escondemos as letras
	text_label.text = text_to_display
	text_label.visible_characters = 0 
	letter_index = 0 
	
	# TRUQUE ANTI-PISCAR: Deixa a caixa 100% invisível temporariamente
	modulate.a = 0 
	
	await get_tree().process_frame
	custom_minimum_size.x = min(size.x, MAX_WIDTH)
	
	if size.x > MAX_WIDTH:
		text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await get_tree().process_frame 
		custom_minimum_size.y = size.y
		
	# Faz a matemática para subir a caixa acima da placa
	global_position.x -= size.x / 2
	global_position.y -= size.y + 24
	
	# Agora que ela está no lugar certo, nós a revelamos!
	modulate.a = 1
	
	display_letter()

func display_letter():
	if letter_index >= text.length():
		return
		
	# Aumenta a quantidade de letras reveladas na tela
	letter_index += 1
	text_label.visible_characters = letter_index
	
	if letter_index >= text.length():
		text_display_finished.emit()
		letter_time_display.stop() 
		return
		
	# Verifica qual foi a letra que acabou de aparecer
	match text[letter_index - 1]:
		"!", "?", ",", ".":
			letter_time_display.start(punctuation_display_time)
		" ":
			letter_time_display.start(space_display_time)
		_:
			letter_time_display.start(letter_display_time)
	
	
func _on_letter_time_display_timeout() -> void:
	display_letter()
