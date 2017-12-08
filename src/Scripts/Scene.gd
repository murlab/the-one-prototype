# Scene Script for Godot Engine
# 2017 © Mur (https://murlab.github.io/)
# License: BSD 3-Clause License

# Collection of functions to work with a Grid. Stores all its children in the grid array
extends TileMap

enum ENTITY_TYPES {PLAYER, OBSTACLE, COLLECTIBLE}

export var tpMapName = ""
export var tpMapX = 0
export var tpMapY = 0

var tile_size = get_cell_size()
var half_tile_size = tile_size/2

var wallsTileMap
#var floorTileMap
var new_player
var overlay

var grid = []
onready var _Player = preload("res://Modules/Player2.tscn")
onready var _BlackBox = preload("res://Modules/BlackBox.tscn")
onready var _Overlay = preload("res://Modules/Overlay.tscn")
onready var _StreamPlayer = preload("res://Modules/StreamPlayer.tscn")
onready var _Message = preload("res://Modules/Message.tscn")
onready var _Selector = preload("res://Modules/Selector.tscn")
onready var _KeyLocker = preload("res://Modules/KeyLocker.tscn")

onready var _DefaultEvent = preload("res://Events/default.tscn")

var bbArray = []
var bbWidth = 1
var bbHeight = 1

var newSceneComing = false
var newSceneName = ""

var playerA = 1.0

var currentFloorId = -1

var playerSnd
var messageWin
var selectorWin
var keyLockerWin
var actionRunning = false
var selectorCalled = false
var keylockerCalled = false

var actionEvent
var actionData = []
var actionPos = 0

var events
var defaultEvent

func _ready():
	VisualServer.set_default_clear_color(Color("#040011"))

	defaultEvent = _DefaultEvent.instance().getElements()

	playerSnd = _StreamPlayer.instance()
	var snd_door = load("Sound/Door.ogg")
	playerSnd.set_stream(snd_door)
	add_child(playerSnd)
	
	overlay = _Overlay.instance()
	add_child(overlay)
	
	messageWin = _Message.instance()
	messageWin.set_z(1000)
	messageWin.set_hidden(true)
	overlay.add_child(messageWin)
	
	selectorWin = _Selector.instance()
	selectorWin.set_z(1000)
	selectorWin.set_hidden(true)
	overlay.add_child(selectorWin)
	selectorWin.hideSelector()
	
	keyLockerWin = _KeyLocker.instance()
	keyLockerWin.set_z(1000)
	keyLockerWin.set_hidden(true)
	overlay.add_child(keyLockerWin)
	keyLockerWin.hideKeyLocker()
	
	bbWidth = ceil((Globals.get("display/width")) / tile_size.width)
	bbHeight = ceil((Globals.get("display/height")) / tile_size.height)
	
	# Player
	new_player = _Player.instance()
	add_child(new_player)
	
	var pPos = Globals.get("playerPos")
	if pPos == null:
		pPos = map_to_world(Vector2(4,4)) + half_tile_size
		
	var pDir = Globals.get("playerDir")
	if pDir == null or pDir == "":
		pDir = "Down"

	new_player.setPosition(pPos, pDir)
	#print ("Enter Player at ", pPos, ". Look at ", pDir)
	
	var sm = new_player.get_node("Camera2D").get_global_pos()
	var smX = sm.x
	var smY = sm.y
	#print ("sm=", sm, ", smX=", smX, ", smY=", smY)
	
	for y in range(bbHeight):
		bbArray.append([])
		bbArray[y] = []
		for x in range(bbWidth):
			bbArray[y].append([])
			bbArray[y][x] = _BlackBox.instance()
			bbArray[y][x].set_pos(Vector2(x * tile_size.width + half_tile_size.width, y * tile_size.height + half_tile_size.height))
			bbArray[y][x].get_node("AnimationPlayer").play("FadeOut")
			bbArray[y][x].set_z(100)
			overlay.add_child(bbArray[y][x])

	for child in get_children():
		var exit = child.get_child(0)
		if exit != null:
			exit.connect("body_enter", self, "_move_to", [child])

	wallsTileMap = get_node("../Walls")
	#floorTileMap = get_node("../Floor")
	events = get_node("../Events")
	
	set_fixed_process(true)

func _fixed_process(delta):
	if newSceneComing:
		if not bbArray[0][0].get_node("AnimationPlayer").is_playing():
			newSceneComing = false
			playerA = 1.0
			get_tree().change_scene("res://Scenes/" + newSceneName + ".scn")
		else:
			playerA -= 0.05
			new_player.set_opacity(playerA)

	if actionRunning:
		action()
	#if not messageWin.isBusy:
	#	actionRunning = false

func get_cell_content(pos=Vector2()):
	return grid[pos.x][pos.y]

func is_cell_vacant(pos=Vector2(), direction=Vector2()):
	var wallPos = wallsTileMap.world_to_map(pos) + direction
	var wallId = wallsTileMap.get_cell(wallPos.x, wallPos.y)

	var blockPos = world_to_map(pos) + direction
	var blockId = get_cell(blockPos.x, blockPos.y)

	if wallId == -1 and blockId == -1:
		#var floorPos = floorTileMap.world_to_map(pos) + direction
		#currentFloorId = floorTileMap.get_cell(floorPos.x, floorPos.y) 
		return true
	else:
		return false
		
#func getCurrentFloorId():
#	return currentFloorId

func update_child_pos(new_pos, direction, type):
	var grid_pos = world_to_map(new_pos)
	var new_grid_pos = grid_pos + direction
	var target_pos = map_to_world(new_grid_pos) + half_tile_size
	return target_pos

func _move_to(colNode, exitTo):
	playerSnd.stop()
	playerSnd.play()
			
	var sceneName = exitTo.get("mapName")
	#print ("Prepare to move... " + sceneName)
	
	for y in range(bbHeight):
		for x in range(bbWidth):
			bbArray[y][x].get_node("AnimationPlayer").play("FadeIn")

	var playerPos = Vector2(exitTo.get("mapX"), exitTo.get("mapY"))

	playerPos = map_to_world(playerPos) + half_tile_size
	#print("Move to scene ", sceneName, ". Set player at ", playerPos)
	
	Globals.set("playerPos", playerPos)
	Globals.set("playerDir", new_player.get("animDir"))
	
	newSceneComing = true
	newSceneName = sceneName

func setAction(aData):
	actionData = aData
	actionPos = 0

func action():
	if not messageWin.isBusy and not selectorWin.isBusy and not keyLockerWin.isBusy:
		if keylockerCalled:
			var a = actionData[actionPos]
			actionPos = 0
			if keyLockerWin.isUnlocked:
				actionData = a.items["unlocked"].action
				#print ("yep!")
			else:
				actionData = a.items["locked"].action
				#print ("nop")
			keylockerCalled = false

		elif selectorCalled:
			var a = actionData[actionPos]
			var index = selectorWin.getSelected()
			actionPos = 0
			selectorCalled = false
			if a.items[index].action.size() > 0:
				#actionData = a.items[index].action[actionPos]
				actionData = a.items[index].action
			else:
				actionRunning = false
			#print (actionData)
		
		elif actionPos == actionData.size():
			actionRunning = false
			actionPos = 0
		else:
			var a = actionData[actionPos]
			if a.type == "message":
				actionPos += 1
				actionRunning = true
				messageWin.showMessage(a.text, a.face, a.pos)
			
			elif a.type == "setStep":
				actionPos += 1
				actionEvent.setStep(a.step)
			
			elif a.type == "select":
				actionRunning = true
				selectorCalled = true
				selectorWin.showSelector(a.text, a.items)
			
			elif a.type == "play":
				actionPos += 1
				actionRunning = true
				var sample = load(a.sample)
				var sLib = SampleLibrary.new()
				var sPlay = SamplePlayer.new()
				sLib.add_sample("sample", sample)
				sPlay.set_sample_library(sLib)
				sPlay.set_default_volume(a.volume)
				sPlay.play("sample")
				
			elif a.type == "keylock":
				actionRunning = true
				keylockerCalled = true
				keyLockerWin.showKeyLocker(a.unlockCode, self)

func getEvents(playerPos, direction):
	var retData = defaultEvent.steps[0]
	var lookAt = world_to_map(playerPos) + direction
	#print ("player look at ", lookAt)
	for event in events.get_children():
		var eventPos = world_to_map(event.get_pos())
		#print (eventPos)
		if lookAt == eventPos:
			actionEvent = event
			retData = event.getStepData()
			#print ("Achtung!")
			
	return retData

func getShot():
	
	# start screen capture
	get_viewport().queue_screen_capture()
	#yield(get_tree(), "idle_frame")
	#yield(get_tree(), "idle_frame")

	# get screen capture
	var capture = get_viewport().get_screen_capture()
	
	print("!!! Get Screenshot !!!")
	
	var w = capture.get_width()
	var h = capture.get_height()
	var p = Vector2(0,0)
	var screenshot = Image(w, h, false, g.FORMAT_RGBA)
	screenshot.blit_rect(capture, Rect2(p, Vector2(w,h)), p)
	
	return screenshot
	

#func _wait(sec):
#	var t = Timer.new()
#	t.set_wait_time(sec)
#	t.set_one_shot(true)
#	self.add_child(t)
#	t.start()
#	yield(t, "timeout")
