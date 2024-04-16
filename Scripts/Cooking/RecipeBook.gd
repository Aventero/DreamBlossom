class_name RecipeBook
extends Node3D

@onready var page : PageUI = $"Book Viewport/Page"

var _current_page : int = 0

func _ready():
	await RenderingServer.frame_post_draw
	
	# Get first recipe to display
	var recipe : Recipe = RecipeManager.get_instance().get_recipe(0)
	display_recipe(recipe)

func disable_recipe_cook():
	queue_free()

func display_recipe(recipe : Recipe):
	# Set recipe name
	page.set_recipe_name(recipe.name)
	
	# Fill input icons
	page.fill_recipe_input(recipe.input)
	
	# Fill output icons
	page.fill_recipe_output(recipe.output)

func _on_next_page_button_pressed(_button):
	_flip_page(1)

func _on_prev_page_button_pressed(_button):
	_flip_page(-1)

func _flip_page(offset : int):
	var new_page : int = _current_page + offset
	
	# Check if page is valid
	if new_page < 0 or new_page >= RecipeManager.get_instance().get_recipe_count():
		return
	
	# Clear current page
	page.clear_icons()
	
	# Display new page
	var recipe : Recipe = RecipeManager.get_instance().get_recipe(new_page)
	display_recipe(recipe)
	
	_current_page = new_page
