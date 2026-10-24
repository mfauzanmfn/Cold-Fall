extends PanelContainer

var tween: Tween
var MainParent
@onready var served_customer_count: Label = $VBoxContainer/ServedCustomerCount
@onready var earning: Label = $VBoxContainer/Earning

func _on_ui_visible():
	visible = true
	served_customer_count.text += str(MainParent.served_customer)
	animate_counter()

func animate_counter():
	if tween:
		tween.kill()
	
	var target = MainParent.earnings
	
	tween = create_tween()
	tween.set_parallel(false)
	tween.tween_method(_update_counter, 0, target, 0.8)

func _update_counter(value: int):
	earning.text = "Pendapatan: " + str(value) 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MainParent = get_parent()

func _on_home_button_pressed() -> void:
	get_tree().change_scene_to_file(SceneManager.SCENES["upgrade_scene"])
