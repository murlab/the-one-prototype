# Play Script for Godot Engine
# 2017 © Mur (https://murlab.github.io/)
# License: BSD 3-Clause License

extends Node

var type = "play"
export(Sample) var sample
export(float,  0.0, 16.0, 0.2) var volume = 1.0

func _ready():
	pass
