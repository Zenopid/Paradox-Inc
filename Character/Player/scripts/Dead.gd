extends PlayerBaseState

var death_screen: ColorRect

var jump_node: Jump

@export var time_until_exit: float = 3
@export var time_until_death_processing: float = 3
var time_tracker: float = 0
var start_counter: bool = false
var processing_tracker: float = 0
var is_tweening: bool = false


func init(current_entity: Entity, s_machine: EntityStateMachine):
	super.init(current_entity,s_machine)
	jump_node = s_machine.find_state("Jump")
	death_screen = entity.get_death_screen()


func enter(_msg: = {}):
	GlobalScript.stop_music()
	super.enter()
	time_tracker = 0
	processing_tracker = 0
	is_tweening = false
	entity.velocity.x = 0

func physics_process(delta):
	processing_tracker += delta
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
		if time_tracker >= time_until_exit:
			Input.set_custom_mouse_cursor(null)
			GlobalScript.emit_signal("game_over")
	entity.velocity.y += jump_node.get_gravity() 
	entity.move_and_slide()

func conditions_met() -> bool:
	return (entity.health < 0)
