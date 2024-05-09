class_name Portal extends Area2D


@export var sister_portal: Portal 
@onready var cd = $Cooldown

var player: Player
var current_level: GenericLevel
var portal_opened: bool = false

@onready var collision_box:CollisionShape2D = $CollisionShape2D

func init(charac, level): 
	player = charac
	current_level = level
	
func _on_body_entered(body):
	if is_open() and off_cooldown() and sister_portal.is_open():
		if body is Player:
			pass
			#portals sorta ruin platforming... maybe in some form but not here.
#			current_level.emit_signal("swap_timeline")
#			player.velocity = Vector2(player.velocity.y * -1,player.velocity.x * -1)
#			move_object(body)
		elif body is MoveableObject and !body.sleeping:
#				body.swap_timeline() 
#				body.start_warp_cooldown()
			close()
			sister_portal.close()
			body.swap_timeline()
			body.set_new_location(sister_portal.position)
			set_cooldowns()

func set_cooldowns():
	sister_portal.cd.start()
	cd.start()

func is_open():
	return portal_opened

func change_portal_state():
	portal_opened = !portal_opened
	if !portal_opened:
		close()
	else:
		open()

func off_cooldown():
	return true if cd.is_stopped() else false

func close():
	portal_opened = false
	set_deferred("visible",false)  
	collision_box.set_deferred("disabled",true)

func open():
	portal_opened = true
	set_deferred("visible",true)  
	collision_box.set_deferred("disabled",false)
