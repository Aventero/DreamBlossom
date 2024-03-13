class_name GridCell
extends Resource

signal state_change(state)

# Grid in which cell exists
var grid : PlantGrid

# Index in grid
var index : int
# Position in grid
var position : Vector2i

# Current state
var state : CELLSTATE = CELLSTATE.FREE:
	set(value):
		state = value
		
		# Emit state change signal
		state_change.emit(state)

enum CELLSTATE
{
	FREE,
	RESERVED,
	OCCUPIED
}
