# Event Box Script for Godot Engine
# 2017 © Mur (https://murlab.github.io/)
# License: BSD 3-Clause License

extends Node2D

export(String, FILE) var eventImage
export(String, FILE) var eventScenario

export(bool) var viewFromLeft = true
export(bool) var viewFromRight = true
export(bool) var viewFromUp = true
export(bool) var viewFromDown = true

var eventStep = 0

export(String, "below", "same", "above") var playerPosition = "below"

var eventData = {}
var labelName
var labelStep

func _ready():
	labelName = get_node("Name")
	labelStep = get_node("Step")
	if eventImage != null and eventImage != "":
		var spr = get_node("Sprite")
		var texture = load(eventImage)
		spr.set_texture(texture)
	
	if eventScenario != null and eventScenario != "":
		eventData = load(eventScenario).instance().getElements()
		#labelName.set_text(eventData.name)
		#labelStep.set_text("Шаг:" + str(eventStep))

func getStepData():
	return eventData.steps[eventStep]

func setStep(st):
	eventStep = st
	labelStep.set_text("Шаг:" + str(eventStep))
