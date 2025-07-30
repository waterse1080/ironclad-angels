class_name HowToPlayScreen
extends Control

var menus: Array[Control] = []
var current_menu: int = 0

@onready var back_button: Button = $UpperLeftContainer/MainMenuButton
@onready var prev_button: Button = $MiddleLeftContainer/PreviousButton
@onready var next_button: Button = $MiddleRightContainer/NextButton

@onready var basic_controls: Control = $BasicControls
@onready var objective: Control = $Objective

func _ready() -> void:
	menus = [basic_controls, objective]

	back_button.pressed.connect(close_menu)
	prev_button.pressed.connect(prev_menu)
	next_button.pressed.connect(next_menu)

func adjust_menu(adjust: int) -> void:
	current_menu += adjust
	while current_menu > menus.size()-1:
		current_menu -= menus.size()
	while current_menu < 0:
		current_menu += menus.size()
	for menu in menus:
		menu.visible = false
	menus[current_menu].visible = true

func next_menu() -> void:
	adjust_menu(1)

func prev_menu() -> void:
	adjust_menu(-1)

func gain_focus() -> void:
	back_button.grab_focus()
	current_menu = 0
	adjust_menu(0)

func close_menu() -> void:
	visible = false
