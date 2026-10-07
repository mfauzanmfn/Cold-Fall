extends Control

@onready var cust_container: HBoxContainer = $VBoxContainer/GridContainer/HBoxContainer
@onready var slot_1: Control = $VBoxContainer/GridContainer/SlotContainer/slot1
@onready var slot_2: Control = $VBoxContainer/GridContainer/SlotContainer/slot2
@onready var slot_3: Control = $VBoxContainer/GridContainer/SlotContainer/slot3

@onready var typo_shield_marker: TextureRect = $TypoShield_Marker
@onready var medium_word_marker: TextureRect = $MediumWord_marker

var angka: Dictionary = {
	"satu" : "1",
	"dua" : "2",
	"tiga" : "3",
	"empat" : "4",
	"lima" : "5",
	"enam" : "6",
	"tujuh" : "7",
	"delapan" : "8",
	"sembilan" : "9",
	"sepuluh" : "10"
}

@onready var slot_container: HBoxContainer = $VBoxContainer/GridContainer/SlotContainer
var slot_count

const CUST_PANEL = preload("uid://ba5t8skrj86ph")
@onready var timer_progress_bar: TextureProgressBar = $TimerProgressBar
var timer_wait_time: float


const CUSTOMER_POOL = preload("res://scripts/Resource/CustomerPool.gd")

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
	item_pool = OrdersPool.get_unlocked_items()
	slot_count = slot_container.get_child_count() 
	selected_customer = create_random_customer()
	slot_1.add_child(selected_customer)
	selected_customer.set_next_character(selected_customer.current_letter_index)
	
	success_delay = selected_customer.success_effect.lifetime
	fail_delay = selected_customer.fail_effect.lifetime
	
	slot_2.add_child(create_random_customer())
	slot_2.get_child(0).become_unselected()
	
	slot_3.add_child(create_random_customer())
	slot_3.get_child(0).become_unselected()
	
	timer_wait_time = timer.wait_time
	timer.start()
	
	if Player_Data.typo_shield:
		typo_shield_marker.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer_label.text = "%d" % timer.time_left
	timer_progress_bar.value = 100 * (timer_wait_time - timer.time_left)/timer_wait_time

func create_random_customer() -> Panel:
	var cust_entry_number: int = randi() % CUSTOMER_POOL.cust_pool.size()
	var cust_entry = CUSTOMER_POOL.cust_pool[cust_entry_number]
	
	var menus = item_pool.keys()
	
	var menu_name = menus[randi() % menus.size()]
	var menu_chosen = item_pool[menu_name]
	
	var difficulties = menu_chosen.keys()
	var weights = PackedFloat32Array([70.0, 30.0])
	var rng = RandomNumberGenerator.new()
	var difficulty_chosen = difficulties[rng.rand_weighted(weights)]
	
	var orders = menu_chosen[difficulty_chosen]
	var selected_order = orders[randi() % orders.size()]
	
	var panel = CUST_PANEL.instantiate()
	panel.selected.connect(_on_customer_switch)
	panel.exited.connect(_on_customer_exited)
	
	var customer_timer = panel.get_node("Timer")
	panel.set_meta("timer", customer_timer)
		
	
	var center = panel.get_child(0)
	var cust_texture = center.get_child(2)
	var order_text = cust_texture.get_child(1)
	
	panel.normal = cust_entry.normal
	panel.dissapointed = cust_entry.dissapointed
	cust_texture.texture_normal = panel.normal
	order_text.text = selected_order.text
	panel.order_price = selected_order.price
	
	return panel

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		timer.paused = !timer.paused
		for slot in slot_container.get_children():
			slot.get_child(0).timer.paused = !slot.get_child(0).timer.paused
		return
	if Input.is_action_just_pressed("arrow_up") and Player_Data.booster_available:
		selected_customer.prompt.text = booster_active(selected_customer.prompt.text, selected_customer.current_letter_index)
		selected_customer.set_next_character(selected_customer.current_letter_index)
		Player_Data.booster_available = false
		
	if OS.is_debug_build():
		if Input.is_action_just_pressed("ui_accept"):
			timer.stop()
			timer.timeout.emit()
			return
		elif Input.is_action_just_pressed("backlash"):
			Player_Data.typo_shield = true
			typo_shield_marker.visible = true
			return
		#elif Input.is_action_just_pressed("ui_text_backspace"):
			#OrdersPool.unlocked_groups.append("Medium")
			#medium_word_marker.visible = true
			#item_pool = OrdersPool.get_unlocked_items()
	if Input.is_action_just_pressed("switch_right"):
		var switch_to = selected_customer.get_parent().get_index() + 1
		if switch_to >= slot_count:
			switch_to = 0
		_on_customer_switch(slot_container.get_child(switch_to).get_child(0))
	elif Input.is_action_just_pressed("switch_left"):
		var switch_to = selected_customer.get_parent().get_index() - 1
		if switch_to < 0:
			switch_to = slot_count-1
		_on_customer_switch(slot_container.get_child(switch_to).get_child(0))
		
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo() and not gameover and delay_timer.is_stopped():
		var typed_event = event.unicode
		if typed_event == 0:
			return
		var key_typed = char(typed_event).to_upper()
		var prompt = selected_customer.get_prompt()
		var next_character = prompt[selected_customer.current_letter_index].to_upper()
		
		if key_typed == next_character:
			if selected_customer.timer.time_left < 5:
				selected_customer.order_price = selected_customer.order_price * (4/5)
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
				
					
				finished_customer.selected.disconnect(_on_customer_switch)
				finished_customer.exited.disconnect(_on_customer_exited)
				
				var slot = finished_customer.get_parent()
				var was_selected = (finished_customer == selected_customer)
				if was_selected:
					finished_customer.queue_free()
					selected_customer = create_random_customer()
					slot.add_child(selected_customer)
					selected_customer.set_next_character(selected_customer.current_letter_index)
					
				else:
					finished_customer.become_unselected()
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
			selected_customer.char_texture.texture_normal = selected_customer.dissapointed
			selected_customer.fail_effect.emitting = true
			await delay_timer.timeout
			combo = 0
			selected_customer.set_next_character(selected_customer.current_letter_index)


func _on_timer_timeout() -> void:
	gameover = true
	for slot in slot_container.get_children():
		slot.get_child(0).queue_free()
	print("selesai")
	print("Jumlah berhasil: ", served_customer)
	print("Jumlah Penghasilan: ", earnings)
	print("Total uang dimiliki: ", Player_Data.money)
	
func _on_customer_switch(panel: Panel):
	selected_customer.become_unselected()
	selected_customer = panel
	selected_customer.become_selected()
	selected_customer.set_next_character(selected_customer.current_letter_index)
	
func _on_customer_exited(panel: Panel):
	var panel_slot = panel.get_parent()
	if panel == selected_customer:
		selected_customer.queue_free()
		selected_customer = create_random_customer()
		panel_slot.add_child(selected_customer)
		selected_customer.set_next_character(selected_customer.current_letter_index)	
		selected_customer.become_selected()
	else:
		panel.queue_free()
		panel = create_random_customer()
		panel_slot.add_child(panel)
		panel.set_next_character(panel.current_letter_index)	
		panel.become_unselected()

func booster_active(text, current_letter_index: int) -> String:
	var result = []
	for word in text.split(" "):
		var stripped = word.strip_edges().rstrip(".,!?;:")
		var suffix = word.substr(stripped.length())
		var word_index = text.find(stripped)

		if angka.has(stripped.to_lower()):
			if word_index >= current_letter_index and word_index != -1:
				result.append(angka[stripped.to_lower()] + suffix)
			else:
				result.append(word)
		else:
			result.append(word)
			
	return " ".join(result)
