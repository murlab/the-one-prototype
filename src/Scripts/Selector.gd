# Selector Script for Godot Engine
# 2017 © Mur (https://murlab.github.io/)
# License: BSD 3-Clause License

extends Node2D

var InputStates = preload("res://Scripts/InputStates.gd")
var btnUp = InputStates.new("btnUp")
var btnDown = InputStates.new("btnDown")
var btnLeft = InputStates.new("btnLeft")
var btnRight = InputStates.new("btnRight")
var btnAction = InputStates.new("btnAction")

var itemsBg
var itemsCursor

var texts
var cursor
var cursorBg
var qestion
var winAnim

var itemsSize = 0
var cursorPos = 0
var isBusy = false

var wavPlayer

var cursorFrames

var rePos = [
	[], 	# 0 пунктов
	[		# 1 пункт
		1	# 1 → 1
	], 
	[		# 2 пункта
		1,	# 1 → 1
		2	# 2 → 2
	], 	
	[		# 3 пункта
		1,	# 1 → 1
		3,	# 2 → 3
		2	# 3 → 2
	], 	
	[		# 4 пункта
		4,	# 1 → 4
		3,	# 2 → 3
		2,	# 3 → 2
		1	# 4 → 1
	], 	
	[		# 5 пунктов
		5,	# 1 → 5
		2,	# 2 → 2
		4,	# 3 → 4
		3,	# 4 → 3
		1	# 5 → 1
	], 	
	[ 	# 6 пунктов
		6,	# 1 → 6
		5,	# 2 → 5
		4,	# 3 → 4
		3,	# 4 → 3
		2,	# 5 → 2
		1,	# 6 → 1
	],
]

func _ready():

	itemsBg = [
		load("Images/Selector/Items_0.png"),
		load("Images/Selector/Items_1.png"),
		load("Images/Selector/Items_2.png"),
		load("Images/Selector/Items_3.png"),
		load("Images/Selector/Items_4.png"),
		load("Images/Selector/Items_5.png"),
		load("Images/Selector/Items_6.png")
	]
	
	itemsCursor = [
		load("Images/Selector/Top.png"),
		load("Images/Selector/Middle.png"),
		load("Images/Selector/Bottom.png")
	]

	qestion = get_node("Question")
	winAnim = get_node("WinAnim")
	cursor = get_node("Cursor")
	cursorBg = get_node("CursorBg")
	wavPlayer = get_node("SamplePlayer")
	
	texts = [
		[	# если 0 пунктов
		],
		[	# если 1 пункт
			get_node("Text_1")
		],
		[	# если 2 пункта
			get_node("Text_1"),
			get_node("Text_3")
		],
		[	# если 3 пункта
			get_node("Text_1"),
			get_node("Text_3"),
			get_node("Text_4")
		],
		[	# если 4 пункта
			get_node("Text_1"),
			get_node("Text_3"),
			get_node("Text_4"),
			get_node("Text_6")
		],
		[	# если 5 пунктов
			get_node("Text_1"),
			get_node("Text_2"),
			get_node("Text_3"),
			get_node("Text_4"),
			get_node("Text_6")
		],
		[	# если 6 пунктов
			get_node("Text_1"),
			get_node("Text_2"),
			get_node("Text_3"),
			get_node("Text_4"),
			get_node("Text_5"),
			get_node("Text_6")
		]
	]
	
	cursorFrames = [
		[	# если 0 пунктов 
		],
		[	# если 1 пункт
			{"frame":0, "flip":false}	#pos 1
		],
		[	# если 2 пункта
			{"frame":0, "flip":false},	#pos 1
			{"frame":2, "flip":false}	#pos 2
		],
		[	# если 3 пункта
			{"frame":0, "flip":false},	#pos 1
			{"frame":2, "flip":false},	#pos 2
			{"frame":2, "flip":true}	#pos 3
		],
		[	# если 4 пункта
			{"frame":0, "flip":false},	#pos 1
			{"frame":2, "flip":false},	#pos 2
			{"frame":2, "flip":true},	#pos 3
			{"frame":0, "flip":true}	#pos 4
		],
		[	# если 5 пунктов
			{"frame":0, "flip":false},	#pos 1
			{"frame":1, "flip":false},	#pos 2
			{"frame":2, "flip":false},	#pos 3
			{"frame":2, "flip":true},	#pos 4
			{"frame":0, "flip":true}	#pos 5
		],
		[	# если 6 пунктов
			{"frame":0, "flip":false},	#pos 1
			{"frame":1, "flip":false},	#pos 2
			{"frame":2, "flip":false},	#pos 3
			{"frame":2, "flip":true},	#pos 4
			{"frame":1, "flip":true},	#pos 5
			{"frame":0, "flip":true}	#pos 5
		]
	]
	
	# обнуляем все 6 пунктов
	for text in texts[6]:
		text.set_text("")

	set_fixed_process(true)

func _fixed_process(delta):
	if is_visible():
		if not winAnim.is_playing():
			if winAnim.get_current_animation() == "Hide":
				set_hidden(true)
				isBusy = false
			else:
				if btnDown.check() == g._CONT_RELEASED_:
					cursorPos += 1
					if cursorPos > itemsSize:
						cursorPos = 1
					updateCursor()
					wavPlayer.play("cursor")
					
				elif btnUp.check() == g._CONT_RELEASED_:
					cursorPos -= 1
					if cursorPos == 0:
						cursorPos = itemsSize
					updateCursor()
					wavPlayer.play("cursor")
				
				elif btnRight.check() == g._CONT_RELEASED_ or btnLeft.check() == g._CONT_RELEASED_:
					cursorPos = rePos[itemsSize][cursorPos-1]
					updateCursor()
					wavPlayer.play("cursor")

				elif btnAction.check() == g._CONT_RELEASED_:
					hideSelector()


func updateCursor():
#	var pos = 0
#	var flip = false
#	if itemsSize == 2:
#		
#	elif itemsSize == 6:
#		if cursorPos > 3:
#			flip = true
#			pos = 6 - cursorPos
#		else:
#			pos = cursorPos - 1

	var cf = cursorFrames[itemsSize][cursorPos-1]
									
	cursor.set_texture(itemsCursor[cf.frame])
	cursor.set_flip_h(cf.flip)
	
	for i in range(itemsSize):
		if i == cursorPos-1:
			texts[itemsSize][i].add_color_override("font_color", Color("#ffffff"))
		else:
			texts[itemsSize][i].add_color_override("font_color", Color("#2c4c76"))

func showSelector(question, answers):
	isBusy = true
	qestion.set_text(question)
	itemsSize = answers.size()
	cursorBg.set_texture(itemsBg[itemsSize])
	for i in range(6):
		texts[6][i].set_text("")

	for i in range(texts[itemsSize].size()):
			texts[itemsSize][i].set_text(answers[i].name)
	cursorPos = 1
	updateCursor()
	set_hidden(false)
	winAnim.play("Show")
	
func hideSelector():
	winAnim.play("Hide")
	
func getSelected():
	return cursorPos-1

