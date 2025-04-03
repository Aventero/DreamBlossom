@icon("res://Textures/EditorIcons/Grid.png")
class_name PlantGrid
extends StaticBody3D

@export var debug_grid : bool
@export var flip_z : bool
@export var centered : bool
@export var width : float
@export var height : float
@export var cellsize : float = 0.1875

var width_cells : int
var height_cells : int
var data : Array[GridCell]

# Weed
var current_weed_amount : int = 0

var center_offset : Vector3

func _ready():
	get_child(1).top_level = true
	
	# Flip z axis
	if flip_z:
		scale.z *= 1
	
	# Init data array
	width_cells = int(width) / cellsize
	height_cells = int(height) / cellsize
	data.resize(width_cells * height_cells)
	
	center_offset = Vector3(width / 2.0, 0.0, height / 2.0)
	
	# Set data for each cell
	for i in data.size():
		data[i] = GridCell.new()
		data[i].grid = self
		data[i].index = i
		data[i].position = _get_cell_position(i)
	
	# Draw debug grid if needed
	if debug_grid:
		_draw_debug_grid()

func _draw_debug_grid():
	for i in data.size():
		var pos : Vector2i = data[i].position
		
		# Spawn debug cube
		var cube : MeshInstance3D = MeshInstance3D.new()
		var cube_mesh : BoxMesh = BoxMesh.new()
		cube_mesh.size = Vector3(cellsize * 0.9, 0.05, cellsize * 0.9)
		cube.mesh = cube_mesh
		add_child(cube)
		
		if centered:
			cube.position = Vector3(float(pos.x) * cellsize, 0, float(pos.y) * cellsize) + Vector3(cellsize/2.0, 0, cellsize/2.0) - center_offset
		else:
			cube.position = Vector3(float(pos.x) * cellsize, 0, float(pos.y) * cellsize) + Vector3(cellsize/2.0, 0, cellsize/2.0)

func get_cell(_position : Vector3) -> GridCell:
	position = to_local(_position)
	
	if centered:
		position += center_offset
	
	var column : int = int(floor(position.x / cellsize))
	var row : int = int(floor(position.z / cellsize))
	
	# 2x2 Snapping
	column = floor(column / 2.0) * 2.0
	row = floor(row / 2.0) * 2.0
	
	var index : int = row * width_cells + column
	
	if _is_index_valid(index):
		return data[index]
	return null

func get_cell_by_index(index : int) -> GridCell:
	if _is_index_valid(index):
		return data[index]
	return null

func _is_index_valid(index : int) -> bool:
	if index < 0 or index >= data.size():
		return false
	return true

func get_placement_position(cell : GridCell, _width : int) -> Vector3:
	var local_position : Vector3 = Vector3(
										float(cell.position.x) * cellsize,
										0,
										float(cell.position.y) * cellsize)
	
	if centered:
		local_position -= center_offset
	
	if _width % 2 == 0:
		local_position += Vector3(cellsize, 0, cellsize)
	else:
		local_position += Vector3(cellsize / 2.0, 0, cellsize / 2.0)
	
	return to_global(local_position)

func is_placement_allowed(cell : GridCell, _width : int) -> bool:
	# Check on null reference
	if not cell:
		return false
	
	var cells : Array[GridCell] = get_cells(cell, _width, false)
	
	if cells.size() == 0:
		return false
	
	for current_cell in cells:
		if current_cell.state == GridCell.CELLSTATE.OCCUPIED:
			return false
	
	return true

func _get_cell(_position : Vector2i) -> GridCell:
	var index : int = _position.y * width_cells + _position.x
	
	if _is_index_valid(index):
		return data[index]
	return null

func _is_position_valid(_position : Vector2i) -> bool:
	if _position.x < 0 or _position.x >= width_cells:
		return false
	
	if _position.y < 0 or _position.y >= height_cells:
		return false
	
	return true

func set_state(cell : GridCell, _width : int, state : GridCell.CELLSTATE) -> void:
	# Check on null reference
	if not cell:
		return
	
	var cells : Array[GridCell] = get_cells(cell, _width)
	
	for current_cell in cells:
		current_cell.state = state

func get_cells(cell : GridCell, _width : int, break_on_null = true) -> Array[GridCell]:
	# Check on null reference
	if not cell:
		return []
	
	var offset : int = floor(_width / 2.0 - 0.5)
	var corner : Vector2i = cell.position - Vector2i(offset, offset)
	
	var cells : Array[GridCell] = []
	
	# Check all cells if they are currently occupied
	for y in range(0, _width):
		for x in range(0, _width):
			var cell_pos : Vector2i = corner + Vector2i(x, y)
			
			if not _is_position_valid(cell_pos):
				if break_on_null:
					return []
			else:
				var current_cell : GridCell = _get_cell(cell_pos)
				cells.push_back(current_cell)
	
	return cells

func _get_cell_position(index : int):
	var x : int = index % width_cells
	var y : int = index / width_cells
	
	return Vector2i(x, y)

func find_inbound_cell(cell : GridCell, _width : int) -> GridCell:
	# Get all surrounding cells inside of bounds
	var surrounding_cells : Array[GridCell] = get_cells(cell, 5, false)
	
	var min_dist : float = INF
	var min_index : int = -1
	
	for i in surrounding_cells.size():
		var nearby : Array[GridCell] = get_cells(surrounding_cells[i], _width, true)
		
		# This is the case if all found cells are in bounds
		if nearby.size() > 0:
			var dir : Vector2i = cell.position - surrounding_cells[i].position
			
			if dir.length() < min_dist:
				min_dist = dir.length()
				min_index = i
	
	if min_index != -1:
		return surrounding_cells[min_index]
	
	return null

func get_free_cells() -> Array[GridCell]:
	var free_cells : Array[GridCell] = []
	
	for cell in data:
		if cell.state == GridCell.CELLSTATE.FREE:
			free_cells.append(cell)
	
	return free_cells

func get_nearby_free_cell(cell : GridCell) -> GridCell:
	# Get all surrounding cells
	var surrounding_cells : Array[GridCell] = get_cells(cell, 3, false)
	var possible_cells : Array[GridCell]
	
	for s_cell in surrounding_cells:
		if s_cell.state == GridCell.CELLSTATE.FREE:
			possible_cells.append(s_cell)
	
	# Check if there is a empty cell nearby
	if possible_cells.size() == 0:
		return null
	
	# Return random free cell
	return possible_cells[randi_range(0, possible_cells.size() - 1)]
