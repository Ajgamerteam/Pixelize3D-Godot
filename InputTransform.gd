extends Control

signal transformChanged(_transform)
@export var transformName:String = "undefined"

var transform = Vector3.ZERO : set = _set_transform, get = _get_transform
@onready var transformX = $LabelScale/ScaleX
@onready var transformY = $LabelScale/ScaleY
@onready var transformZ = $LabelScale/ScaleZ
@onready var labelName = $LabelScale

func _ready():
	labelName.text = transformName

func _on_scale_x_text_changed(new):
	transform.x = float(new)
	emit_signal("transformChanged",transform)

func _on_scale_y_text_changed(new):
	transform.y = float(new)
	emit_signal("transformChanged",transform)

func _on_scale_z_text_changed(new):
	transform.z = float(new)
	emit_signal("transformChanged",transform)

func _set_transform(value):
	transform = value
	transformX.placeholder_text = str(value.x)
	transformY.placeholder_text = str(value.y)
	transformZ.placeholder_text = str(value.z)

func _get_transform():
	return transform
