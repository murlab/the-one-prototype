# Action Menu Script for Godot Engine
# 2017 © Mur (https://murlab.github.io/)
# License: BSD 3-Clause License

extends Node2D

var InputStates = preload("res://Scripts/InputStates.gd")
var btnUp = InputStates.new("btnUp")
var btnDown = InputStates.new("btnDown")
var btnLeft = InputStates.new("btnLeft")
var btnRight = InputStates.new("btnRight")
var btnAction = InputStates.new("btnAction")
var btnCancel = InputStates.new("btnCancel")

var aniPlay
var menuItems
var helper
var wavPlayer
var visible = false
var cursorPos = 0
var showUpdate = true

var isCanceld = false
var isSelected = false
var _isCanceld = false
var _isSelected = false

func _ready():
	aniPlay = get_node("AnimationPlayer")
	menuItems = [ \
		{"name":"kick", "item":get_node("Kick"), "help":"Ударить"}, \
		{"name":"look", "item":get_node("Look"), "help":"Осмотреть"}, \
		{"name":"make", "item":get_node("Make"), "help":"Сделать"}, \
		{"name":"speak", "item": get_node("Speak"), "help":"Говорить"}, \
		]
	helper = get_node("Helper")
	wavPlayer = get_node("SamplePlayer")
	set_hidden(true)
	helper.set_text("")
	set_fixed_process(true)

func _fixed_process(delta):
	if visible:
		if not aniPlay.is_playing():
			if showUpdate:
					helper.set_opacity(1)
					helper.set_self_opacity(1)
					showUpdate = false
					updatePos()

			if btnAction.check() == g._CONT_RELEASED_:
				_isSelected = true
				hideMenu()
				
			elif btnCancel.check() == g._CONT_RELEASED_:
				_isCanceld = true
				hideMenu()

			elif btnLeft.check() == g._CONT_RELEASED_:
				cursorPos -= 1
				if cursorPos < 0:
					cursorPos = menuItems.size()-1
				updatePos()
				wavPlayer.play("cursor")
	
			elif btnRight.check() == g._CONT_RELEASED_:
				cursorPos += 1
				if cursorPos == menuItems.size():
					cursorPos = 0
				updatePos()
				wavPlayer.play("cursor")
	else:
		if not aniPlay.is_playing():
			set_hidden(true)
			isCanceld = _isCanceld
			isSelected = _isSelected

func updatePos():
	for id in range(menuItems.size()):
		if id == cursorPos:
			menuItems[id].item.set_opacity(1)
			helper.set_text(menuItems[id].help)
		else:
			menuItems[id].item.set_opacity(0.6)

func showMenu():
	isCanceld = false
	isSelected = false
	_isCanceld = false
	_isSelected = false
	wavPlayer.play("push_in")
	set_hidden(false)
	visible = true
	aniPlay.play("show")
	helper.set_text(menuItems[cursorPos].help)

func hideMenu():
	wavPlayer.play("push_out")
	aniPlay.play("hide")
	visible = false
	showUpdate = true

func getSelectedItem():
	return menuItems[cursorPos].name
