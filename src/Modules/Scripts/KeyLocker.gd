# KeyLocker Script for Godot Engine
# 2017 © Mur (https://murlab.github.io/)
# License: BSD 3-Clause License

extends Node2D

var InputStates = preload("res://Scripts/InputStates.gd")
var btnUp = InputStates.new("btnUp")
var btnDown = InputStates.new("btnDown")
var btnLeft = InputStates.new("btnLeft")
var btnRight = InputStates.new("btnRight")
var btnAction2 = InputStates.new("btnAction2")

var lockedStr = preload("res://Sound/Buzzer1.ogg")
var unLockedStr = preload("res://Sound/KeyLockOpen.ogg")

var keyMapping = [
	"7",  "8", "9",
	"4",  "5", "6",
	"1",  "2", "3",
	"Del","0", "Enter"
]

var unlockCode = "123"

var indicator

var isBusy = false
var isUnlocked = false

var bg
var parent
var sPlay
var smPlay
var aPlay

var isPlaySound = false
var buttons

var curX = 2
var curY = 3

func _ready():
	buttons = get_node("Panel").get_children()
	for button in buttons:
		button.setParent(self)
		
	indicator = get_node("Indicator")
	indicator.set_text("")
	
	bg = get_node("Background")
	
	sPlay = get_node("StreamPlayer")
	aPlay = get_node("AnimationPlayer")
	
	var sample = load("res://Sound/cursor.wav")
	var sLib = SampleLibrary.new()
	smPlay = SamplePlayer.new()
	sLib.add_sample("cursor", sample)
	smPlay.set_sample_library(sLib)
	smPlay.set_default_volume(2)
	
	set_hidden(true)

	set_fixed_process(true)

func _fixed_process(delta):
	if not is_hidden():
		if isPlaySound:
			if not sPlay.is_playing():
				hideKeyLocker()
		
		elif aPlay.get_current_animation() == "hideKeyLocker" and not aPlay.is_playing():
			isBusy = false
			set_hidden(true)
			
		elif btnUp.check() == g._CONT_RELEASED_:
			curY -= 1
			if curY < 0:
				curY = 3
			setCursor()
		elif btnDown.check() == g._CONT_RELEASED_:
			curY += 1
			if curY > 3:
				curY = 0
			setCursor()
		elif btnLeft.check() == g._CONT_RELEASED_:
			curX -= 1
			if curX < 0:
				curX = 2
			setCursor()
		elif btnRight.check() == g._CONT_RELEASED_:
			curX += 1
			if curX > 2:
				curX = 0
			setCursor()
		elif btnAction2.check() == g._CONT_RELEASED_:
			for button in buttons:
				if not button.cursorSpr.is_hidden():
					button.press()
	
func keyBack(key):
	var iPrev = indicator.get_text()
	if key == "Del":
		if iPrev.length() > 0:
			iPrev = iPrev.substr(0,iPrev.length()-1)
			indicator.set_text(iPrev)
	
	elif key == "Enter":
		if iPrev == unlockCode:
			indicator.set_text("Open")
			isUnlocked = true
			sPlay.set_stream(unLockedStr)
			sPlay.set_volume(4)
			sPlay.play()
			
		else:
			indicator.set_text("Error")
			isUnlocked = false
			sPlay.set_stream(lockedStr)
			sPlay.set_volume(4)
			sPlay.play()

		isPlaySound = true
	else:
		iPrev += key
		if iPrev.length() > 8:
			iPrev = iPrev.substr(1,8)
		indicator.set_text(iPrev)

func showKeyLocker(newCode, p):
	parent = p
	#createBg()
	unlockCode = newCode
	indicator.set_text("")
	isBusy = true
	isUnlocked = false
	isPlaySound = false
	set_hidden(false)
	aPlay.play("showKeyLocker")
	updateCursors(keyMapping[curY*3 + curX])

func hideKeyLocker():
	isPlaySound = false
	aPlay.play("hideKeyLocker")

func setCursor():
	updateCursors(keyMapping[curY*3 + curX])
	smPlay.play("cursor")

func updateCursors(active):
	for button in buttons:
		if button.showButton == active:
			button.showCursor()
		else:
			button.hideCursor()

func createBg():
	var capture = parent.getShot()
	#print (capture)
	
	var bgTexture = ImageTexture.new()
	bgTexture.create_from_image(capture)
	bgTexture.set_flags(g.FLAG_REPEAT)
	bg.set_texture(bgTexture)
