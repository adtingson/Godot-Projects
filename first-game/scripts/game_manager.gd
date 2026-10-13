extends Node

@onready var label: Label = $Label

var score = 0

func add_point():
	score += 1
	label.text = "You have collected " + str(score) + " Coins!"
