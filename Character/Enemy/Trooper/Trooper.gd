class_name Trooper extends Enemy

@export var minimum_roll_chance:int = 20
@export var minimum_roll_chance_increase:int = 15
@export var maximum_roll_chance_increase:int = 30
@onready var roll_chance: int = minimum_roll_chance




func damage(amount, knockback: int = 0, knockback_angle: int = 0, hitstun: int = 0):
	super.damage(amount, knockback, knockback_angle, hitstun)
	var roll_rng = randi_range(0, 100)
	if roll_rng <= roll_chance:
		roll_chance = minimum_roll_chance
		states.transition_if_available(["Dodge"])
		return
	roll_chance += randi_range(minimum_roll_chance_increase, maximum_roll_chance_increase)
	if roll_chance > 100:
		roll_chance = 100
