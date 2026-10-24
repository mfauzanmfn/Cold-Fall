extends Node

const SAVE_PATH = "user://save.json"

func save_game():
	var data = {
		"player" : Player_Data.to_dict(),
		"unlocked_groups": OrdersPool.to_dict()
	}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		return
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return	
	var text = file.get_as_text()
	file.close()
	
	var data = JSON.parse_string(text)
	if data == null or typeof(data) != TYPE_DICTIONARY:
		return
		
	Player_Data.from_dict(data.get("player", {}))
	OrdersPool.from_dict(data.get("unlocked_groups", {}))

func delete_save():
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
