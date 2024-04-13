extends Area2D

signal reached_checkpoint()

@export var disabled_color: Color
@export var enabled_color: Color

@export var heal_amount: int = 25

var checkpoint_reached:bool

@export_enum("Future", "Past")var timeline:String = "Future"

@onready var vfx: Line2D = $Laser
var status_loaded_from_file:bool = false 
func _ready():
	if SaveSystem.get_var(self.name) == null:
		vfx.default_color = disabled_color
	

func _on_body_entered(body):
	if body is Player:
		if !checkpoint_reached:
			checkpoint_reached = true
			body.set_spawn(Vector2(position.x, position.y - 30), timeline)
			body.respawn_timeline = timeline
			body.heal(heal_amount)
			vfx.default_color = enabled_color
#			GlobalScript.emit_signal("update_settings")
			GlobalScript.emit_signal("save_game_state")
			set_deferred("monitoring",false)
			set_deferred("monitorable", false)
			emit_signal("reached_checkpoint")

func save():
	var save_dict = {
		"position": global_position,
		"checkpoint_reached": checkpoint_reached,
		"heal_amount": heal_amount,
	}
	SaveSystem.set_var(self.name, save_dict)

func load_from_file():
	var save_file = SaveSystem.get_var(self.name)
	if save_file:
		for i in save_file.keys():
			set(i, save_file[i])
