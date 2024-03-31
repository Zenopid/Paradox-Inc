extends PlayerBaseState

var death_screen: ColorRect

var jump_node: Jump

@export var time_until_exit: float = 3
@export var time_until_death_processing: float = 3
var time_tracker: float = 0
var start_counter: bool = false
var processing_tracker: float = 0
var is_tweening: bool = false

func enter(_msg: = {}):
	super.enter()
	jump_node = state_machine.find_state("Jump")
	if entity.has_method("get_death_screen"):
		death_screen = entity.get_death_screen()
	time_tracker = 0
	processing_tracker = 0
	is_tweening = false
	entity.motion.x = 0

func physics_process(delta):
	processing_tracker += delta
	#print(processing_tracker)
	if processing_tracker >= time_until_death_processing:
		if !is_tweening:
			var tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(death_screen, "modulate:a", 1, 0.4)
			is_tweening = true
		if death_screen.modulate.a == 1:
			death_screen.get_node("DeathText").show()
			start_counter = true
	if start_counter:
		time_tracker += delta
		#print(time_tracker)
		if time_tracker >= time_until_exit:
			entity.death_logic()
	entity.motion.y += jump_node.get_gravity() * delta
	default_move_and_slide()
