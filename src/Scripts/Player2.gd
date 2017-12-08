# Player 2 Script for Godot Engine
# 2017 © Mur (https://murlab.github.io/)
# License: BSD 3-Clause License

extends KinematicBody2D

var InputStates = preload("res://Scripts/InputStates.gd")
var btnUp = InputStates.new("btnUp")
var btnDown = InputStates.new("btnDown")
var btnLeft = InputStates.new("btnLeft")
var btnRight = InputStates.new("btnRight")
var btnAction = InputStates.new("btnAction")

var direction = Vector2()
var lastDirection = direction

const MAX_SPEED = 250

var speed = 0
var velocity = Vector2()

var target_pos = Vector2()
var target_direction = Vector2()
var is_moving = false

var playerSpr
var playerAnim

var anim = ""
var animNew = ""
var animDir = "Down"

var playerSnd
var actionMenu
var actionMenuActive = false
var actionMenuData

var type
var grid

#var aMoveDown = []
#var aMoveLeft = []
#var aMoveRight = []
#var aMoveUp = []

#var aIdleDown = []
#var aIdleLeft = []
#var aIdleRight = []
#var aIdleUp = []

var animation01 = {}

var timer = 0
var rate = .11		# Every half second
var frame = 0
var frameCount

var frameInfo

func _ready():
	grid = get_parent()
	type = grid.PLAYER
	
	playerSpr = get_node("Sprite")
	playerSnd = get_node("Sound")
	actionMenu = get_node("ActionMenu")
	frameInfo =  get_node("FrameInfo")
	
	actionMenu.set_hidden(true)
	
	var snd_step = load("Sound/Step2.ogg")
	playerSnd.set_stream(snd_step)

	var playerImg01 = Image()
	playerImg01.load("res://Images/Player2/Player_01.png")
	
	var playerTextures = []
	
	var frameColums = 4
	var frameRows = 4

	var frameWidth = playerImg01.get_width() / frameColums
	var frameHeight = playerImg01.get_height() / frameRows
	var cutSize = Vector2(frameWidth, frameHeight)

	var i = 0
	for row in range(frameRows):
		for column in range(frameColums):
			var cutPos = Vector2(column * frameWidth, row * frameHeight)
			
			var tmpImg = Image(frameWidth, frameHeight, false, g.FORMAT_RGBA)
			tmpImg.blit_rect(playerImg01, Rect2(cutPos, cutSize), Vector2(0,0))
			
			playerTextures.append([])
			playerTextures[i] = ImageTexture.new()
			playerTextures[i].create_from_image(tmpImg)
			playerTextures[i].set_flags(g.FLAG_REPEAT)
			i += 1
	
	animation01["IdleDown"] = [ playerTextures[1]]
	animation01["IdleLeft"] = [ playerTextures[5]]
	animation01["IdleRight"] = [ playerTextures[9]]
	animation01["IdleUp"] = [ playerTextures[13]]
	
	animation01["MoveDown"] = [ playerTextures[1], playerTextures[2], playerTextures[3], playerTextures[0]]
	animation01["MoveLeft"] = [ playerTextures[5], playerTextures[6], playerTextures[7], playerTextures[4]]
	animation01["MoveRight"] = [ playerTextures[9], playerTextures[10], playerTextures[11], playerTextures[8]]
	animation01["MoveUp"] = [ playerTextures[13], playerTextures[14], playerTextures[15], playerTextures[12]]
	
	frame = 0
	playerAnim = animation01["IdleDown"]


	set_fixed_process(true)

func _fixed_process(delta):
	
	timer += delta
	if(timer >= rate):
		frameCount = playerAnim.size()
		timer -= rate
		frame += 1
		if(frame == frameCount):
			frame = 0
		#frameInfo.set_text(str(frame))
		#var time = OS.get_ticks_msec();
		#print(time, " Frame: ", frame, " moving:", is_moving)
		playerSpr.set_texture(playerAnim[frame])
	
	
	direction = Vector2()
	speed = 0
	
	if not grid.actionRunning:
		if actionMenuActive:
			if actionMenu.isCanceld:
				actionMenuActive = false
			elif actionMenu.isSelected:
				grid.setAction(actionMenuData.actions[actionMenu.getSelectedItem()])
				grid.action()
				actionMenuActive = false
		else:
			if btnUp.check() == g._PRESSED_CONT_:
				direction.y = -1
				lastDirection = direction
				animDir = "Up"
			
			elif btnDown.check() == g._PRESSED_CONT_:
				direction.y = 1
				lastDirection = direction
				animDir = "Down"
			
			elif btnLeft.check() == g._PRESSED_CONT_:
				direction.x = -1
				lastDirection = direction
				animDir = "Left"
				
			elif btnRight.check() == g._PRESSED_CONT_:
				direction.x = 1
				lastDirection = direction
				animDir = "Right"
			
			elif btnAction.check() == g._CONT_RELEASED_:
				actionMenuData = grid.getEvents(get_pos(), lastDirection)
				actionMenuActive = true
				actionMenu.showMenu()

	if not is_moving:
		if direction != Vector2():
			target_direction = direction.normalized()
			if grid.is_cell_vacant(get_pos(), direction):
				target_pos = grid.update_child_pos(get_pos(), direction, type)
				is_moving = true
				anim = "Move" + animDir
				playerSnd.play()
			else:
				anim = "Idle" + animDir
				playerSnd.stop()
		else:
			anim = "Idle" + animDir
			playerSnd.stop()

	elif is_moving:
		speed = MAX_SPEED
		velocity = speed * target_direction * delta

		var pos = get_pos()
		var distance_to_target = ceil(pos.distance_to(target_pos))
		var move_distance = ceil(velocity.length())
		
		
		if move_distance > distance_to_target:
			#print ("move_distance=", move_distance, " distance_to_target=", distance_to_target)
			velocity = target_direction * distance_to_target
			is_moving = false
			#anim = "Idle" + animDir
			#playerSnd.stop()

		move(velocity)
		
	if anim != animNew:
		animNew = anim
		frame = 0
		playerAnim = animation01[anim]

func setPosition(pPos, pDir):
	speed = 0
	is_moving = false
	set_pos(pPos)
	setFace(pDir)

func setFace(aDir):
	animDir = aDir
	anim = "Idle" + animDir
	frame = 0
	playerAnim = animation01[anim]
	direction = Vector2()
	if animDir == "Up":
		direction.y = -1
		lastDirection = direction
	elif animDir == "Down":
		direction.y = 1
		lastDirection = direction
	elif animDir == "Left":
		direction.x = -1
		lastDirection = direction
	elif animDir == "Right":
		direction.x = 1
		lastDirection = direction
