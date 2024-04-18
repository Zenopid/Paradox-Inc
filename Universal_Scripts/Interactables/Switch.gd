class_name Switch extends Area2D

var is_on: bool = false

signal status_changed(activated: bool)
@export_enum ("Future", "Past") var timeline:String = "Future"
@onready var level: GenericLevel
@onready var on_sprite: Sprite2D = $OnSprite
@onready var off_sprite: Sprite2D = $OffSprite

func _ready():
	add_to_group("Switch")
	level = get_tree().get_first_node_in_group("CurrentLevel")
	level.connect("swapped_timeline", Callable(self, "swap_view"))
	if timeline == "Future":
		enable_future_collision()
	else:
		enable_past_collision()
	swap_view(level.current_timeline)

func swap_view(new_timeline):
	if new_timeline != timeline:
		visible = false
	else:
		visible = true 
#	if new_timeline == "Future":
#		enable_future_collision()
#	else:
#		enable_past_collision()

func enable_future_collision():
	set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, true)
	set_collision_layer_value(GlobalScript.collision_values.OBJECT_FUTURE, true)
	
	set_collision_layer_value(GlobalScript.collision_values.OBJECT_PAST, false)
	set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, false)
	
	set_collision_mask_value(GlobalScript.collision_values.PLAYER_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.PLAYER_PAST, false)
	
	set_collision_mask_value(GlobalScript.collision_values.ENTITY_FUTURE, true)
	set_collision_mask_value(GlobalScript.collision_values.ENTITY_PAST, false)
	

func enable_past_collision():
	set_collision_mask_value(GlobalScript.collision_values.OBJECT_FUTURE, false)
	set_collision_layer_value(GlobalScript.collision_values.OBJECT_FUTURE, false)
	
	set_collision_mask_value(GlobalScript.collision_values.OBJECT_PAST, true)
	set_collision_layer_value(GlobalScript.collision_values.OBJECT_PAST,true)
	
	set_collision_mask_value(GlobalScript.collision_values.PLAYER_FUTURE, false)
	set_collision_mask_value(GlobalScript.collision_values.PLAYER_PAST, true)
	
	set_collision_mask_value(GlobalScript.collision_values.ENTITY_FUTURE, false)
	set_collision_mask_value(GlobalScript.collision_values.ENTITY_PAST, true)

func _on_body_entered(body):
	is_on = true
	on_sprite.show()
	off_sprite.hide()
	emit_signal("status_changed", is_on)

func _on_body_exited(body):
	if !has_overlapping_bodies():
		is_on = false
		on_sprite.hide()
		off_sprite.show()
		emit_signal("status_changed", is_on)

func save() -> Dictionary:
	var switch_data = SaveSystem.get_var("Switch")
	if !switch_data:
		switch_data = {}
	var save_dict = {
		"monitoring": monitoring,
		"visible": visible,
		"is_on": is_on,
		"timeline": timeline,
		"name": name,
		"rotation": rotation,
		"global_position": global_position
	}
	switch_data[name] = save_dict
	SaveSystem.set_var("Switch", switch_data)
	return save_dict
#	SaveSystem.set_var(self.name, save_dict)

func load_from_file():
	var save_data = SaveSystem.get_var("Switch")
	if save_data:
		save_data = SaveSystem.get_var("Switch:" + name)
		if save_data:
			for i in save_data.keys():
				set(i, save_data[i])
	emit_signal("status_changed", is_on)
