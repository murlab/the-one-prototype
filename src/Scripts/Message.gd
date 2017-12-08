# Message Script for Godot Engine
# 2017 © Mur (https://murlab.github.io/)
# License: BSD 3-Clause License

extends Node2D

#export(Sample) var CursorSample

var InputStates = preload("res://Scripts/InputStates.gd")
var btnAction = InputStates.new("btnAction")
var btnCancel = InputStates.new("btnCancel")

var textLabel
var winAnim
var next
var nextAnim
var wavPlayer
var avatar

var msg = ""
var printPos = 0
var printStr = ""
var printEnable = false
var avatarPlace = "Right"
var avatarFace = "Empty"
var avatarDefW = 0
var avatarDefH = 0

var isBusy = false

func _ready():
	avatar = get_node("Avatar")
	textLabel = get_node("Text")
	winAnim = get_node("WinAnim")
	next = get_node("Next")
	nextAnim = get_node("NextAnim")
	wavPlayer = get_node("SamplePlayer")
	textLabel.set_hidden(true)
	
	var aTexture = avatar.get_texture()
	avatarDefW = aTexture.get_width()
	avatarDefH = aTexture.get_height()
	
	next.set_hidden(true)
	nextAnim.stop()
	
	set_fixed_process(true)

func _fixed_process(delta):
	if is_visible():
		if not winAnim.is_playing() and not printEnable:
			if winAnim.get_current_animation() == "Show" + avatarPlace:
				printEnable = true
				textLabel.set_hidden(false)
			else:
				printEnable = false
				set_hidden(true)
				isBusy = false

		if printEnable:
			if printPos < msg.length():
				if btnAction.check() == g._CONT_RELEASED_:
					printPos = msg.length()
					textLabel.set_text(msg)
				else:
					printStr += msg[printPos]
					printPos +=1
					textLabel.set_text(printStr)
					if not wavPlayer.is_active():
						wavPlayer.play("click")
					
			elif not next.is_visible():
				next.set_hidden(false)
				nextAnim.play("jump" + avatarPlace)
				
			elif next.is_visible():
				if btnAction.check() == g._CONT_RELEASED_ or btnCancel.check() == g._CONT_RELEASED_:
					printEnable = false
					nextAnim.stop()
					next.set_hidden(true)
					hideMessage()
	else:
		textLabel.set_hidden(true)

func showMessage(message, aName, aPlace):
	isBusy = true
	avatarFace = aName
	avatarPlace = aPlace
	var newFace = load(avatarFace)
	avatar.set_texture(newFace)
	var w = newFace.get_width()
	var h = newFace.get_height()
	if aPlace == "Right":
		avatar.set_flip_h(false)
	else:
		w = avatarDefW
		avatar.set_flip_h(true)
	avatar.set_offset(Vector2(-w, -h))
	next.set_hidden(true)
	nextAnim.stop()
	msg = message
	printPos = 0
	printStr = ""
	textLabel.set_text(printStr)
	printEnable = false
	winAnim.play("Show" + avatarPlace)
	set_hidden(false)
	
func hideMessage():
	winAnim.play("Hide" + avatarPlace)
