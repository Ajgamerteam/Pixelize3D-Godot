extends Sprite3D
 
@export var anim_col = 0
@export var section = 0
@onready var animation_player = $AnimationPlayer

@export var camera : Node3D
 
func _process(delta):
	anim(delta)

func anim(delta):
	if camera == null:
		return
	var p_fwd = -camera.global_transform.basis.z
	var fwd = global_transform.basis.z
	var left = global_transform.basis.x
 
	var l_dot = left.dot(p_fwd)
	var f_dot = fwd.dot(p_fwd)
	var above = 0
	var row = 0
	if f_dot < -0.85:
		row = 0 # front sprite
	elif f_dot > 0.85:
		row = 4 # back sprite
	else:
		if l_dot > 0:
			flip_h = true
		else :
			flip_h = false
		if abs(f_dot) < 0.3:
			row = 2 # left sprite
		elif f_dot < 0:
			row = 1 # forward left sprite
		else:
			row = 3 # back left sprite
	frame = anim_col + row*section
