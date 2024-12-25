extends Node2D

# Nó de controle principal para animações e estados. Este script gerencia animações de personagens e responde a sinais globais.

# Referências automáticas a nós da cena (carregados com @onready para otimizar desempenho)
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var chris_base: AnimatedSprite2D = $SubViewport/Chris_base
@onready var frontshot_puppet_hand: AnimatedSprite2D = $SubViewport/Frontshot_Puppet_Hand

# Variável exportada e observada para alternar o estado de "elbow" (usando propriedades)
@export var elbow: bool:
	get: return _elbow
	set(value):
		_set_elbow(value)

# Sinal para indicar que o nó está livre (não ocupado)
signal free

# Variáveis de estado
var busy: bool = false  # Indica se o nó está ocupado com uma animação
var _elbow: bool  # Estado interno do cotovelo (elbow)

# Configurações e conexões iniciais ao entrar na cena
func _ready() -> void:
	# Conecta sinais globais e internos ao script
	SignalBus.attacking.connect(_on_pop)
	animation_player.animation_started.connect(_on_animation_started)
	animation_player.animation_finished.connect(_on_animation_finished)

# Função para definir o estado "elbow" (cotovelo)
func _set_elbow(value: bool) -> void:
	var current_frame = chris_base.get_frame()
	var start_time = chris_base.get_frame_progress()  # Salva o progresso atual da animação
	_elbow = value  # Atualiza o estado interno
	print("Elbow status:", _elbow)

	# Atualiza as animações com base no novo estado
	if _elbow:
		chris_base.play("elbow")
	else:
		chris_base.play("noelbow")

	# Sincroniza outras animações
	frontshot_puppet_hand.play("default")
	frontshot_puppet_hand.set_frame_and_progress(current_frame, start_time)
	chris_base.set_frame_and_progress(current_frame, start_time)

# Manipula o início das animações (atualiza o estado de "busy")
func _on_animation_started(_animation_name: String) -> void:
	busy = true

# Manipula o fim das animações e emite o sinal "free"
func _on_animation_finished(_animation_name: String) -> void:
	busy = false
	emit_signal("free")

# Responde a um sinal global de ataque (SignalBus.attacking)
func _on_pop() -> void:
	# Se não estiver ocupado, executa ações baseadas no AttackTrack global
	if !busy:
		match Global.AttackTrack:
			1:
				show()
				Global.player_has_control = false
				SignalBus.emit_signal("pop_open")
			2, 3:
				animation_player.play(str(Global.AttackTrack - 1))  # Toca animações específicas
	else:
		# Aguarda o nó estar livre e tenta novamente
		await free
		_on_pop()

# Reverte animações e atualiza o AttackTrack global (ação de "cum")
func cummed() -> void:
	if !busy:  # Garante que nenhuma animação está em execução
		match Global.AttackTrack:
			1:
				hide()
				Global.player_has_control = true
			2, 3:
				animation_player.play_backwards(str(Global.AttackTrack - 1))  # Reverte animações

		# Atualiza estados globais
		Global.AttackTrack = max(0, Global.AttackTrack - 1)  # Reduz o contador global de ataques
		SignalBus.emit_signal("puppet_cummed")  # Emite sinal global para informar a conclusão
		Global.AttackOrder.pop_front()  # Remove a primeira ação da fila
	else:
		# Se ocupado, aguarda o nó estar livre e tenta novamente
		print("Esperando para processar cum...")
		await free
		print("Processando cum novamente...")
		cummed()

# Responde a eventos de entrada do jogador (cliques ou teclas)
func _input(event: InputEvent) -> void:
	if visible and Input.is_action_just_released("ui_accept"):
		print("Ativando 'cum'")
		cummed()
