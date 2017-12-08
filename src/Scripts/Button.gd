# Button Script for Godot Engine
# 2017 © Mur (https://murlab.github.io/)
# License: BSD 3-Clause License

extends Node2D

var InputStates = preload("res://Scripts/InputStates.gd")

export(String) var showButton = "0"

var imgColumns = 3
var imgRows = 4

var checkKey
var releasedSpr
var pressedSpr

var sPlay
var parent
var cursorSpr

var keyMapping = {
	"7":0,
	"8":1,
	"9":2,
	"4":3,
	"5":4,
	"6":5,
	"1":6,
	"2":7,
	"3":8,
	"Del":9,
	"0":10,
	"Enter":11
}

var pressed = 0

func _ready():
	checkKey = InputStates.new("numPad" + str(showButton))
	
	releasedSpr = get_node("Released")
	pressedSpr = get_node("Pressed")
	cursorSpr = get_node("Cursor")
	cursorSpr.set_z(100)
	
	pressedSpr.set_hidden(true)
	
	var releasedImg = Image()
	releasedImg.load("res://Images/KeyLocker/keyReleased.png")
	
	var pressedImg = Image()
	pressedImg.load("res://Images/KeyLocker/keyPressed.png")

	var btnWidth = releasedImg.get_width() / imgColumns
	var btnHeight = releasedImg.get_height() / imgRows
	
	var btnRow = keyMapping[str(showButton)] / imgColumns
	var btnColumn = keyMapping[str(showButton)] - btnRow * imgColumns

	var cutPos = Vector2(btnColumn*btnWidth,btnRow*btnHeight)
	var cutSize = Vector2(btnWidth, btnHeight)
	
	var tmpImg = Image(btnWidth, btnHeight, false, g.FORMAT_RGBA)
	tmpImg.blit_rect(releasedImg, Rect2(cutPos, cutSize), Vector2(0,0))

	var releasedTexture = ImageTexture.new()
	releasedTexture.create_from_image(tmpImg)
	releasedTexture.set_flags(g.FLAG_REPEAT)
	releasedSpr.set_texture(releasedTexture)
	
	tmpImg.blit_rect(pressedImg, Rect2(cutPos, cutSize), Vector2(0,0))
	var pressedTexture = ImageTexture.new()
	pressedTexture.create_from_image(tmpImg)
	pressedTexture.set_flags(g.FLAG_REPEAT)
	pressedSpr.set_texture(pressedTexture)
	
	var sample = load("res://Sound/Pik.wav")
	var sLib = SampleLibrary.new()
	sPlay = SamplePlayer.new()
	sLib.add_sample("sample", sample)
	sPlay.set_sample_library(sLib)
	sPlay.set_default_volume(2)
	
	hideCursor()
	
	set_fixed_process(true)

func _fixed_process(delta):
	if not parent.is_hidden():
		var keyState = checkKey.check()
	
		if  keyState == g._PRESSED_:
			press()
	
		elif keyState == g._PRESSED_CONT_ or pressed == 1:
			releasedSpr.set_hidden(true)
			pressedSpr.set_hidden(false)
			pressed = 2
	
		elif keyState == g._CONT_RELEASED_ or pressed == 2:
			pressed = 0
			release()

func press():
	pressed = 1
	sPlay.play("sample")
	cursorSpr.set_pos(Vector2(19,4))
	parent.updateCursors(showButton)

func release():
	releasedSpr.set_hidden(false)
	pressedSpr.set_hidden(true)
	cursorSpr.set_pos(Vector2(18,3))
	parent.keyBack(showButton)

func setParent(node):
	parent = node

func showCursor():
	cursorSpr.set_hidden(false)

func hideCursor():
	cursorSpr.set_hidden(true)
