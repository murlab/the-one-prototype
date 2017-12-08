# Player Script for Godot Engine
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

const MAX_SPEED = 300

var speed = 0
var velocity = Vector2()

var target_pos = Vector2()
var target_direction = Vector2()
var is_moving = false

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

var clothes1
var clothes2

func _ready():
	grid = get_parent()
	type = grid.PLAYER
	
	clothes1 = get_node("Clothes_1")
	clothes1.set_hidden(true)
	clothes2 = get_node("Clothes_2")
	clothes2.set_hidden(false)
	
	playerAnim = clothes2
	
	#var anim = playerAnim.get_animation()
	#print (anim)
	
	playerSnd = get_node("Sound")
	actionMenu = get_node("ActionMenu")
	
	actionMenu.set_hidden(true)
	
	var snd_step = load("Sound/Step.ogg")
	playerSnd.set_stream(snd_step)
	
	set_fixed_process(true)

func _fixed_process(delta):
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
			
			#elif Input.is_action_pressed("action"):
			elif btnAction.check() == g._CONT_RELEASED_:
				actionMenuData = grid.getEvents(get_pos(), lastDirection)
				actionMenuActive = true
				actionMenu.showMenu()

	if not is_moving and direction != Vector2():
		target_direction = direction.normalized()
		if grid.is_cell_vacant(get_pos(), direction):
			target_pos = grid.update_child_pos(get_pos(), direction, type)
			is_moving = true
			anim = "Move" + animDir
			playerSnd.stop()
			playerSnd.play()
		else:
			anim = "Idle" + animDir
			playerSnd.stop()

	elif is_moving:
		speed = MAX_SPEED
		velocity = speed * target_direction * delta

		var pos = get_pos()
		var distance_to_target = pos.distance_to(target_pos)
		var move_distance = velocity.length()
		
		if move_distance > distance_to_target:
			velocity = target_direction * distance_to_target
			is_moving = false
			anim = "Idle" + animDir

		move(velocity)
		
	if anim != animNew:
		animNew = anim
		playerAnim.play(anim)

func setPosition(pPos, pDir):
	speed = 0
	is_moving = false
	set_pos(pPos)
	setFace(pDir)

func setFace(aDir):
	animDir = aDir
	anim = "Idle" + animDir
	playerAnim.play(anim)
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
