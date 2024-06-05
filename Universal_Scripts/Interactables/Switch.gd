class_name Switch extends Area2D

var activated: bool = false

const UNFOCUSED_PRIORITY: int = -5
const FOCUSED_PRIORITY: int = 0

signal status_changed(activated: bool )
@export_enum ("Paradox", "Future", "Past") var timeline:String = "Future"
@export var on_sprite_paradox_color:Color
@export var off_sprite_paradox_color:Color
@onready var level: GenericLevel
@onready var on_sprite: Sprite2D = $OnSprite
@onready var off_sprite: Sprite2D = $OffSprite
@onready var activation_count: int = 0

@onready var is_paradox:bool = false 

func _ready():
	add_to_group("Switch")
	level = get_tree().get_first_node_in_group("CurrentLevel")
	if timeline == "Future":
		set_collision(true, false)
	elif timeline == "Past":
		set_collision(false, true)
	else:
		set_collision(true, true)
		is_paradox = true 
		on_sprite.modulate = on_sprite_paradox_color
		off_sprite.modulate = off_sprite_paradox_color
	swap_view(level.current_timeline)
	if !is_paradox:
		level.connect("swapped_timeline", Callable(self, "swap_view"))

func swap_view(new_timeline):
	if is_paradox:
		modulate.a = 1
		return
	if new_timeline != timeline:
		modulate.a = 0.35
	else:
		modulate.a = 1

func set_collision(f_value:bool, p_value:bool):
	set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, f_value)
	set_collision_layer_value(GlobalScript.collision_values.OBJECT_FUTURE, f_value)
	
	set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, p_value)
	set_collision_layer_value(GlobalScript.collision_values.OBJECT_PAST, p_value)
	
	set_collision_layer_value(GlobalScript.collision_values.OBJECT_FUTURE, f_value)
	set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, p_value)
	
	set_collision_mask_value(GlobalScript.collision_values.PLAYER_FUTURE, f_value)
	set_collision_mask_value(GlobalScript.collision_values.PLAYER_PAST, p_value)
	
	set_collision_mask_value(GlobalScript.collision_values.ENTITY_FUTURE, f_value)
	set_collision_mask_value(GlobalScript.collision_values.ENTITY_PAST, p_value)
	


func _on_body_entered(body):
	activated = true
	on_sprite.show()
	off_sprite.hide()
	emit_signal("status_changed", activated)

func _on_body_exited(body):
	if !has_overlapping_bodies():
		activated = false
		on_sprite.hide()
		off_sprite.show()
		emit_signal("status_changed", activated)

