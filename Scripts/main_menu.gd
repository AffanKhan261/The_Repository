extends Control

@onready var main_buttons: VBoxContainer = $MainButtons

@onready var settings: Panel = $Settings




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_buttons.visible = true
	settings.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://The_Repository/Scenes/story_line.tscn")


func _on_settings_pressed() -> void:
	main_buttons.visible = false
	settings.visible = true


func _on_how_to_play_pressed() -> void:
	get_tree().change_scene_to_file("res://The_Repository/Scenes/how_to_play.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_back_settings_pressed() -> void:
	_ready()
