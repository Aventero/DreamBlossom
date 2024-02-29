class_name DigSpotLookup
extends Node

static var dictionary = {}

static func add(digSpot : DigSpot, plant : Node3D = null) -> void:
	dictionary[digSpot] = plant

static func remove(digSpot : DigSpot) -> void:
	dictionary.erase(digSpot)

static func get_dig_spot(plant : Node3D) -> DigSpot:
	return dictionary.find_key(plant)

static func get_plant(digSpot : DigSpot) -> Node3D:
	return dictionary.get(digSpot)
