# Message Script for Godot Engine
# 2017 © Mur (https://murlab.github.io/)
# License: BSD 3-Clause License

extends Node

var type = "message"
export(String, FILE) var face
export(String, "Right", "Left") var pos = "Right"
export(String, MULTILINE) var text = "ChangeIt"

func _ready():
	pass
