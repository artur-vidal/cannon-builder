class_name AssemblyItem
extends TextureRect

# Essa classe é a base de todos os elementos na montagem de canhões. Eles podem ser
# movidos pelo mouse e ter espaços para encaixe de outros elementos (esse último)
# é opcional.

var parent: Control

var dragging: bool = false
var offset: Vector2

var snapped_to: AssemblySnapSlot
var original_size: Vector2

func _rebuild_snapped_layout() -> void:
	var container = $SnappedItemsContainer
	
	for child in container.get_children():
		child.queue_free()
	
	var snapped_items = get_snapped_items()
	if snapped_to:
		var add_to_container = func(cont, item):
			item.visible = false
			item.mouse_filter = Control.MOUSE_FILTER_IGNORE
			
			var new_texture = TextureRect.new()
			new_texture.texture = item.texture
			new_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
			new_texture.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			
			cont.add_child(new_texture)
		
		for i in range(0, snapped_items.size(), 2):
			var new_hbox = HBoxContainer.new()
			new_hbox.alignment = BoxContainer.ALIGNMENT_END
			new_hbox.custom_minimum_size.y = 16
		
			
			var first_item = snapped_items[i]
			add_to_container.call(new_hbox, first_item)
			
			if i + 1 < snapped_items.size():
				var second_item = snapped_items[i + 1]
				add_to_container.call(new_hbox, second_item)
			
			container.add_child(new_hbox)
	else:
		for item in snapped_items:
			item.visible = true
			item.mouse_filter = Control.MOUSE_FILTER_STOP

func get_hovered_slot() -> AssemblySnapSlot:
	for slot in get_tree().get_nodes_in_group("snap_slots"):
		if slot is AssemblySnapSlot:
			if not (slot.get_parent().snapped_to or slot.occupied) and \
			slot.get_global_rect().has_point(get_global_mouse_position()):
				return slot
	return null

func set_scale_to_slot(slot: AssemblySnapSlot) -> void:
	scale = Vector2.ONE / (original_size / slot.size)

func set_slots_visibility(visibility: bool) -> void:
	for child in get_children():
		if child is AssemblySnapSlot:
			child.visible = visibility

func get_snapped_items() -> Array:
	var snapped_items = []
	
	for item in get_tree().get_nodes_in_group("assembly_items"):
		for slot in get_children():
			if item.snapped_to == slot:
				snapped_items.append(item)
	
	return snapped_items

func snap_to(target_slot: AssemblySnapSlot) -> void:
	global_position = target_slot.global_position
	set_scale_to_slot(target_slot)
	
	set_slots_visibility(false)
	
	target_slot.occupied = true
	snapped_to = target_slot
	
	_rebuild_snapped_layout()

func unsnap() -> void:
	scale = Vector2.ONE
	
	set_slots_visibility(true)
	
	if snapped_to:
		snapped_to.occupied = false
	
	snapped_to = null
	_rebuild_snapped_layout()

func _ready() -> void:
	parent = get_parent()
	original_size = size

func _process(_delta: float) -> void:
	if snapped_to:
		set_slots_visibility(false)
		modulate.a = 1
		global_position = snapped_to.global_position
		
	elif dragging:
		set_slots_visibility(true)
		modulate.a = 1
		scale = Vector2.ONE
		global_position = get_global_mouse_position() - offset
		
		var hovered_slot = get_hovered_slot()
		if hovered_slot:
			set_slots_visibility(false)
			set_scale_to_slot(hovered_slot)
			var scaled_item_size = original_size * scale
			global_position = hovered_slot.global_position + (hovered_slot.size - scaled_item_size) / 2
			modulate.a = .5
			
	else:
		set_slots_visibility(true)
		modulate.a = 1
		scale = Vector2.ONE

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var global_mouse_pos = get_global_mouse_position()
		
		if event.is_pressed():
			grab_click_focus()
			unsnap()
			
			dragging = true
			offset = global_mouse_pos - global_position
			parent.move_child(self, parent.get_child_count())
			
		elif event.is_released():
			dragging = false
			var hovered_slot = get_hovered_slot()
			if hovered_slot:
				snap_to(hovered_slot)
