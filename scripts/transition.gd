extends CanvasLayer

@onready var color_rect: ColorRect = $color_rect

# FADE OUT: Escurece a tela e depois troca de cena
func change_scene(path: String, delay: float = 0.5):
	var scene_transition = get_tree().create_tween()
	# Anima o alpha_value até 1.0 (100% preto)
	scene_transition.tween_property(color_rect, "alpha_value", 1.0, 0.5).set_delay(delay)
	await scene_transition.finished
	assert(get_tree().change_scene_to_file(path) == OK)
	
# FADE IN: Clareia a tela quando a nova cena carrega
func show_new_scene():
	var show_transition = get_tree().create_tween()
	# Começa no 1.0 (preto) e anima até o 0.0 (transparente)
	show_transition.tween_property(color_rect, "alpha_value", 0.0, 0.5).from(1.0)
