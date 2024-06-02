class_name HealthBar extends Control

const FLASH_RATE = 0.05
const N_FLASHES = 4

@onready var health_over = $HealthOver
@onready var health_under = $HealthUnder


@export var entity: Entity 

@export var healthy_color: Color = Color.GREEN
@export var caution_color:Color = Color.YELLOW
@export var danger_color:Color = Color.RED
@export var pulse_color:Color = Color.DARK_RED
@export var flash_color:Color = Color.ORANGE_RED
@export var caution_zone:float = 0.5
@export var danger_zone:float = 0.2
@export var will_pulse:bool = false

func init(max_health:int ):
	health_over.max_value = max_health
	health_under.max_value = max_health
	health_over.value = max_health
	health_under.value = max_health


func _on_health_updated(health, amount: int = 0):
	health_over.value = health
	var update_tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	update_tween.tween_property(health_under, "value", health, 0.5)
	_assign_color(health)
	if amount > 0:
		_flash_damage()
	
func _assign_color(health):
#	var pulse_tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	if health < health_over.max_value * danger_zone:
		health_over.tint_progress = danger_color
	elif health < health_over.max_value * caution_zone:
		health_over.tint_progress = caution_color
	else:
		health_over.tint_progress = healthy_color

func _on_max_health_updated(max_health):
	health_over.max_value = max_health

func _flash_damage():
	for i in range (N_FLASHES * 2):
		var color = health_over.tint_progress if i % 2 == 1 else flash_color
		var time = FLASH_RATE * i + FLASH_RATE
		var flash_tween = get_tree().create_tween()
		flash_tween.tween_property(health_over,"tint_progress", color, time )
