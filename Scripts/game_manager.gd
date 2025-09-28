extends Node

var score = 0

var fruits = 0

@onready var score_label: Label = $ScoreLabel
@onready var fruits_label: Label = $FruitsLabel


func add_score():
	score += 1
	score_label.text = "You collected " + str(score) + " coins!"

func add_fruits():
	fruits += 1
	fruits_label.text = "You have " + str(fruits) + " fruits for survival..."
