extends CanvasLayer

# Este sinal vai gritar para o Boss: "Ele acertou!" (true) ou "Ele errou!" (false)
signal question_answered(is_correct: bool)

@onready var question_label: Label = $Control/background/question_label
@onready var btn_1: Button = $Control/background/VBoxContainer/btn_1
@onready var btn_2: Button = $Control/background/VBoxContainer/btn_2
@onready var btn_3: Button = $Control/background/VBoxContainer/btn_3
@onready var btn_4: Button = $Control/background/VBoxContainer/btn_4

var current_question_index = 0
var correct_answer_index = 0

# Banco de dados das suas 5 perguntas
var questions = [
	{
		"text": "1. Converta 00011101 para hexadecimal.",
		"options": ["A) 1D", "B) 1E", "C) F4", "D) EA"],
		"correct": 0 
	},
	{
		"text": "2. Qual o resultado de 1001 AND 1111?",
		"options": ["A) 1000", "B) 1100", "C) 1001", "D) 0011"],
		"correct": 2
	},
	{
		"text": "3. O barramento de dados é:",
		"options": ["Unidirecional", "De controle", "De endereço.", "Bidirecional."],
		"correct": 3
	},
	{
		"text": "4. O que é o contador de programa (PC)?",
		"options": ["Armazena o endereço da próxima instrução.", "Armazena os dados da memória", "Armazena o resultado da ULA.", "Armazena a instrução atual."],
		"correct": 0
	},
	{
		"text": "5. Qual o tipo de acesso da instrução STA:",
		"options": ["MEM(end) ← PC", "AC ← MEM(end)", "MEM(end) ← AC", "AC ← AC + MEM(end)"],
		"correct": 2
	}
]

func _ready():
	# Começa invisível
	hide()
		
	# Conecta os botões via código usando funções lambda (Godot 4)
	btn_1.pressed.connect(func(): check_answer(0))
	btn_2.pressed.connect(func(): check_answer(1))
	btn_3.pressed.connect(func(): check_answer(2))
	btn_4.pressed.connect(func(): check_answer(3))

func show_question():
	# Pausa todo o jogo (exceto este nó, porque marcamos Process como Always)
	get_tree().paused = true 
		
		# Pega a pergunta atual
	if current_question_index < questions.size():
		var q = questions[current_question_index]
		question_label.text = q["text"]
		btn_1.text = q["options"][0]
		btn_2.text = q["options"][1]
		btn_3.text = q["options"][2]
		btn_4.text = q["options"][3]
		correct_answer_index = q["correct"]
		show()
	else:
			# Se já acabaram as perguntas, apenas despausa
		get_tree().paused = false

func check_answer(index: int):
	# Esconde o ecrã e despausa o jogo IMEDIATAMENTE antes de enviar o sinal
	hide()
	get_tree().paused = false 
	
	if index == correct_answer_index:
		print("Acertou!")
		current_question_index += 1 # Avança para a próxima pergunta
		emit_signal("question_answered", true)
	else:
		print("Errou! O Boss vai recuperar vida.")
		# Se errar, NÃO avança o current_question_index, para ele tentar a mesma pergunta (ou pode avançar se preferir que mude)
		emit_signal("question_answered", false)
