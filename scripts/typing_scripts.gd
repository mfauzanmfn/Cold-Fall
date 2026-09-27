extends Control

@onready var cust_container: HBoxContainer = $VBoxContainer/GridContainer/HBoxContainer
@onready var slot_1: Control = $VBoxContainer/GridContainer/HBoxContainer/slot1
@onready var slot_2: Control = $VBoxContainer/GridContainer/HBoxContainer/slot2
@onready var typo_shield_marker: TextureRect = $TypoShield_Marker
@onready var medium_word_marker: TextureRect = $MediumWord_marker

const CUST_PANEL = preload("uid://ba5t8skrj86ph")
@onready var timer_progress_bar: TextureProgressBar = $TimerProgressBar
var timer_wait_time: float

var cust_pool = [
	{"cust_texture": preload("res://assets/typing_assets/test_texture/test_char/cust_type_1.png")},
	{"cust_texture": preload("res://assets/typing_assets/test_texture/test_char/cust_type_2.png")},
	{"cust_texture": preload("res://assets/typing_assets/test_texture/test_char/cust_type_3.png")}
]
var item_pool 
var selected_customer
var unselected_customer_letter_index: int = 0
var served_customer: int = 0
var max_cust_count: int = 2
var curr_cust_count: int = 0
var combo: int = 0
var earnings: int = 0

@onready var timer: Timer = $Timer
@onready var timer_label: Label = $Timer_Label
@onready var delay_timer: Timer = $DelayTimer

var success_delay
var fail_delay
var time_penalty: float = 5.0
var gameover: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	item_pool = ItemPools.get_unlocked_items()
	selected_customer = create_random_customer()
	slot_1.add_child(selected_customer)
	selected_customer.set_next_character(selected_customer.current_letter_index)
	selected_customer.set_pointer_visible(true)
	
	success_delay = selected_customer.success_effect.lifetime
	fail_delay = selected_customer.fail_effect.lifetime
	
	slot_2.add_child(create_random_customer())
	timer_wait_time = timer.wait_time
	timer.start()
	
	if Player_Data.typo_shield:
		typo_shield_marker.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer_label.text = "%d" % timer.time_left
	timer_progress_bar.value = 100 * (timer_wait_time - timer.time_left)/timer_wait_time

func create_random_customer() -> Panel:
	var cust_entry_number: int = randi() % cust_pool.size()
	var cust_entry = cust_pool[cust_entry_number]
	
	var item_entry_number: int = randi() % item_pool.size()
	var item_entry = item_pool[item_entry_number]
	
	var panel = CUST_PANEL.instantiate()
	panel.selected.connect(_on_customer_pressed)
	panel.exited.connect(_on_customer_exited)
	
	var customer_timer = panel.get_node("Timer")
	panel.set_meta("timer", customer_timer)
		
	
	var center = panel.get_child(0)
	var cust_texture = center.get_child(2)
	var order_text = cust_texture.get_child(1)
	
	cust_texture.texture_normal = cust_entry.cust_texture
	order_text.text = item_entry.text
	panel.order_price = item_entry.price
	
	return panel

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo() and not gameover and delay_timer.is_stopped():
		if event.keycode == KEY_ESCAPE:
			timer.paused = !timer.paused
			return
		if OS.is_debug_build():
			if event.keycode == KEY_ENTER:
				timer.stop()
				timer.timeout.emit()
				return
			elif event.keycode == KEY_BACKSLASH:
				Player_Data.typo_shield = true
				typo_shield_marker.visible = true
				return
			elif event.keycode == KEY_BACKSPACE:
				ItemPools.unlocked_groups.append("Medium")
				medium_word_marker.visible = true
				item_pool = ItemPools.get_unlocked_items()
		
		var typed_event = event.unicode
		if typed_event == 0:
			return
		var key_typed = char(typed_event).to_upper()
		var prompt = selected_customer.get_prompt()
		var next_character = prompt[selected_customer.current_letter_index].to_upper()
		
		if key_typed == next_character:
			selected_customer.current_letter_index += 1
			selected_customer.set_next_character(selected_customer.current_letter_index)
			if selected_customer.current_letter_index == prompt.length():
				combo += 1
				if combo <= 2:
					earnings += selected_customer.order_price
				elif combo <= 5:
					earnings += selected_customer.order_price * 1.2
				else :
					earnings += selected_customer.order_price * 1.5
				
				var customer_timer = selected_customer.get_meta("timer")
				var finished_customer = selected_customer
				customer_timer.paused = true
				delay_timer.wait_time = success_delay
				delay_timer.start()
				finished_customer.success_effect.emitting = true
				await delay_timer.timeout
				
					
				finished_customer.selected.disconnect(_on_customer_pressed)
				finished_customer.exited.disconnect(_on_customer_exited)
				
				var slot = finished_customer.get_parent()
				var was_selected = (finished_customer == selected_customer)
				if was_selected:
					finished_customer.queue_free()
					selected_customer = create_random_customer()
					slot.add_child(selected_customer)
					selected_customer.set_next_character(selected_customer.current_letter_index)
					selected_customer.set_pointer_visible(true)
					
				else:
					finished_customer.set_pointer_visible(false)
					finished_customer.queue_free()
					finished_customer = create_random_customer()
					slot.add_child(finished_customer)
					finished_customer.set_next_character(finished_customer.current_letter_index)
				served_customer += 1
			else:
				if prompt[selected_customer.current_letter_index].to_upper() == " ":
					selected_customer.current_letter_index += 1
					selected_customer.set_next_character(selected_customer.current_letter_index)
		else:
			if Player_Data.typo_shield:
				print("used typo shield")
				Player_Data.typo_shield = false
				typo_shield_marker.visible = false
				return
			selected_customer.current_letter_index = 0
			delay_timer.wait_time = fail_delay
			delay_timer.start()
			selected_customer.fail_effect.emitting = true
			await delay_timer.timeout
			combo = 0
			selected_customer.set_next_character(selected_customer.current_letter_index)


func _on_timer_timeout() -> void:
	gameover = true
	slot_1.get_child(0).queue_free()
	slot_2.get_child(0).queue_free()
	print("selesai")
	print("Jumlah berhasil: ", served_customer)
	print("Jumlah Penghasilan: ", earnings)
	print("Total uang dimiliki: ", Player_Data.money)
	
func _on_customer_pressed(panel: Panel):
	selected_customer.set_pointer_visible(false)
	selected_customer = panel
	selected_customer.set_pointer_visible(true)
	selected_customer.set_next_character(selected_customer.current_letter_index)
	
func _on_customer_exited(panel: Panel):
	var panel_slot = panel.get_parent()
	if panel == selected_customer:
		selected_customer.queue_free()
		selected_customer = create_random_customer()
		panel_slot.add_child(selected_customer)
		selected_customer.set_next_character(selected_customer.current_letter_index)	
		selected_customer.set_pointer_visible(true)
	else:
		panel.queue_free()
		panel = create_random_customer()
		panel_slot.add_child(panel)
		panel.set_next_character(panel.current_letter_index)	
