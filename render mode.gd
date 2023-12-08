extends MenuButton

@onready var renderscene = $"../../../VSplitContainer/PanelContainer/Renderscene"
@onready var main = $"../../../../../../.."


func _ready():
	var popup = get_popup() 
	popup.connect("id_pressed", file_menu)


func file_menu(id):
	match id:
		0:
			renderscene.state = 'one'
			$Label.text  = 'Seperate Animations'
		1:
			renderscene.state = 'all'
			$Label.text = "All as a Spritesheet"
		2:
			renderscene.state = 'eight'
			renderscene.iter = 5
			main.iter = 5
			$Label.text = "Five direction(Good for 8 Direction movement)"
		3:
			renderscene.state = 'eight'
			renderscene.iter = 8
			main.iter = 8
			$Label.text = "Isometric directions true 8 direction"
