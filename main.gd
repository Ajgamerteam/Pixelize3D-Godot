extends Control

var dir = ''
@export var player_canvas_path: NodePath
@export var file_button_path: NodePath

@export var position_ui_path: NodePath
@export var rotation_ui_path: NodePath
@export var scale_ui_path: NodePath
@export var menu_button_path : NodePath

var player_canvas: Control
var file_button: MenuButton
var menu_button : MenuButton
var position_ui: HBoxContainer
var rotation_ui: HBoxContainer
var scale_ui: HBoxContainer

var player_node: Node3D
var color_shader: ColorRect
var player_transform: Node3D

@export var cam : Camera3D
@export var spr : Sprite3D

var iter = 8
var save_as_scene = true
signal path_update

func _ready():
	player_canvas = find_child('Renderscene')
	file_button = get_node(file_button_path)
	position_ui = get_node(position_ui_path)
	rotation_ui = get_node(rotation_ui_path)
	scale_ui = get_node(scale_ui_path)
	menu_button = get_node(menu_button_path)
	color_shader = player_canvas.find_child("ColorShader")
	player_node = player_canvas.find_child("Player")
	file_button.connect("model_load_triggered", _on_model_load_triggered)
	
	player_transform = player_canvas.find_child("Player")
	
	var c = Callable(self,"file_drop_path")
	get_tree().get_root().connect('files_dropped',c)
	update_player_transform(player_node)


func _on_background_shader_toggled(button_pressed):
	if not button_pressed:
		color_shader.hide()
	else:
		color_shader.show()


func _on_run_annimation_button_down():
	render()

func render():
	if save_as_scene == false:
		var arr : Array
		menu_button.file_menu(1)
		dir = await path_update
		dir += '/'
		arr = await player_canvas.get_all_animation_frames()
		print(arr.size())
		var anime_names = arr[1] as Array
		var images = arr[0] as Array
		for i in anime_names.size():
			var img: Image
			img = images[i]
			var path = dir + anime_names[i] + ".png"
			img.save_png(path)
	else :
		var arr : Array
		menu_button.file_menu(1)
		dir = await path_update
		dir += '/'
		arr = await player_canvas.get_all_animation_frames()
		var images = arr[0] as Array
		var anime_names = arr[1] as Array
		var frames = arr[2]
		var state = arr[3]
		var length = arr[4]
		var fps = arr[5]
		for i in anime_names.size():
			var img: Image
			img = images[i]
		var anim = add_animation(frames,state,length,fps,anime_names)
		anim.name = "AnimationPlayer"
		for i in anime_names.size():
				var img: Image
				img = images[i]
				var imag_path = dir + anime_names[i] + ".png"
				img.save_png(imag_path)
		var p = PackedScene.new()
		if player_canvas.iter != 5:
			$Sprite3D.set_script(null)
		var dub = spr.duplicate(15)
		dub.add_child(anim)
		anim.set_owner(dub)
		anim.root_node = '..'
		p.pack(dub)
		var path = dir + 'Sprite.tscn'
		ResourceSaver.save(p,path,2)
		for i in anime_names.size():
			var img: Image
			img = images[i]
			var image_path = dir + anime_names[i] + ".png"
			img.save_png(image_path)

func add_animation(frames : Array,state : String,length : Array,fps : float,names : Array):
	var lib = AnimationLibrary.new()
	var animation_player = AnimationPlayer.new()
	var step = 1.0/fps
	for i in frames.size():
		var animation = Animation.new()
		var track_index = animation.add_track(Animation.TYPE_VALUE)
		animation.value_track_set_update_mode(track_index,Animation.UPDATE_DISCRETE)
		
		animation.length = length[i] + step
		var num_of_frames = frames[i]
		var slice = frames[i]
		if state == "eight":
			slice = slice/iter
		var pos = 0.0
		for x in slice:
			if state == "eight":
				animation.track_set_path(track_index, ".:anim_col")
				animation.track_insert_key(track_index, pos, x as int)
			else :
				animation.track_set_path(track_index, ".:frame")
				animation.track_insert_key(track_index, pos, x as int)
			pos += step
		#var rectw_index = animation.add_track(Animation.TYPE_VALUE)
		var rect_index = animation.add_track(Animation.TYPE_VALUE)
		var hfr = animation.add_track(Animation.TYPE_VALUE)
		var vfr = animation.add_track(Animation.TYPE_VALUE)
		var sec = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(rect_index, ".:region_rect")
		
		animation.value_track_set_update_mode(hfr,Animation.UPDATE_DISCRETE)
		animation.value_track_set_update_mode(vfr,Animation.UPDATE_DISCRETE)
		animation.value_track_set_update_mode(sec,Animation.UPDATE_DISCRETE)
		
		var rec = Rect2(0.0,0.0,num_of_frames*512.0,num_of_frames*512.0) as Rect2
		animation.track_insert_key(rect_index, 0.0, rec)
		
		var s = 0
		if num_of_frames == 1:
			s = 1
		else : 
			s = int(pow(num_of_frames,0.5)) + 1
		animation.track_set_path(hfr, ".:hframes")
		animation.track_insert_key(hfr, 0.0, s)
		
		animation.track_set_path(vfr, ".:vframes")
		animation.track_insert_key(vfr, 0.0, s)
		
		animation.track_set_path(sec, ".:section")
		animation.track_insert_key(sec, 0.0, slice)
		
		animation.track_get_interpolation_type(animation.INTERPOLATION_NEAREST)
		
		lib.add_animation(names[i],animation)
	animation_player.add_animation_library('',lib)
	return animation_player

func _on_model_load_triggered(path : String):
	if path.ends_with(".gltf") or path.ends_with(".glb"):
		var state = GLTFState.new()
		var importer = GLTFDocument.new()
		importer.append_from_file(path, state)
		var node = importer.generate_scene(state)
		node.transform = player_node.transform
		var node_parent = player_node.get_parent()
		find_child("Player").free()
		player_node = node
		player_node.name = "Player"
		var c = node.find_child('Camera')
		if c != null:
			new_camera(c)
		var ani = node.find_child("AnimationPlayer")
		if ani == null:
			creat_empty_animation(node)
		node_parent.add_child(node)
		node.set_owner(node_parent)
		update_player_transform(node)

func creat_empty_animation(node : Node3D):
	var animation = Animation.new()
	animation.length = 0.0
	var animationplayer = AnimationPlayer.new()
	var lib = AnimationLibrary.new()
	lib.add_animation("icon",animation)
	animationplayer.add_animation_library('',lib)
	animationplayer.name = "AnimationPlayer"
	animationplayer.root_node = ".."
	node.add_child(animationplayer)
	animationplayer.set_owner(node)

func new_camera(c : Camera3D):
	cam.transform = c.transform
	cam.projection = c.projection
	cam.fov = c.fov

func update_player_transform(node):
	player_transform = node as Node3D
	position_ui.transform = player_transform.position
	rotation_ui.transform = player_transform.rotation_degrees
	scale_ui.transform = player_transform.scale

func file_drop_path(files):
	_on_model_load_triggered(files[0])

func _on_position_transform_changed(_transform):
	player_transform.position=_transform

func _on_rotation_transform_changed(_transform):
	player_transform.rotation_degrees=_transform

func _on_scale_transform_changed(_transform):
	player_transform.scale=_transform

func _on_file_dialog_dir_selected(dir):
	emit_signal('path_update',str(dir))

func _on_scene_toggled(toggled_on):
	save_as_scene = toggled_on
