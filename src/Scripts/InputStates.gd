# Input States Script for Godot Engine
# 2017 © Mur (https://murlab.github.io/)
# License: BSD 3-Clause License

### class for input handling. Returns 4 button states
var inputName
var statePrev
var stateCurrent
#var input

var outputState
#var stateOld

### Get the input name and store it
func _init(var inputName):
	self.inputName = inputName
	
### check the input and compare it with previous states
func check():
	#input = Input.is_action_pressed(self.inputName)
	statePrev = stateCurrent
	#stateCurrent = input
	stateCurrent = Input.is_action_pressed(self.inputName)
	
	#stateOld = outputState
	
	if not statePrev and not stateCurrent:
		outputState = g._RELEASED_ ### Released: просто отжата
	if not statePrev and stateCurrent:
		outputState = g._PRESSED_ ### Just Pressed: первый раз нажали
	if statePrev and stateCurrent:
		outputState = g._PRESSED_CONT_### Pressed: нажали и держат
	elif statePrev and not stateCurrent:
		outputState = g._CONT_RELEASED_ ### Just Released: держали и отпустили
	
	return outputState
