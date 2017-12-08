# Global Script for Godot Engine
# 2017 © Mur (https://murlab.github.io/)
# License: BSD 3-Clause License

extends Node

var _RELEASED_ = 0				# не нажата вообще
var _PRESSED_ = 1				# нажали первый раз
var _PRESSED_CONT_ = 2			# нажали и удерживают
var _CONT_RELEASED_ = 3			# только что отпустили


var FLAG_MIPMAPS = 1 			# Generate mipmaps, to enable smooth zooming out of the texture.
var FLAG_REPEAT = 2 			# Repeat (instead of clamp to edge).
var FLAG_FILTER = 4 			# Turn on magnifying filter, to enable smooth zooming in of the texture.
var FLAG_VIDEO_SURFACE = 4096 	# Texture is a video surface.
var FLAGS_DEFAULT = 7 			# Default flags. Generate mipmaps, repeat, and filter are enabled.
var FLAG_ANISOTROPIC_FILTER = 8	#
var FLAG_CONVERT_TO_LINEAR = 16	#
var FLAG_MIRRORED_REPEAT = 32	#

var COMPRESS_BC = 0
var COMPRESS_PVRTC2 = 1
var COMPRESS_PVRTC4 = 2
var COMPRESS_ETC = 3
var FORMAT_GRAYSCALE = 0
var FORMAT_INTENSITY = 1
var FORMAT_GRAYSCALE_ALPHA = 2
var FORMAT_RGB = 3
var FORMAT_RGBA = 4
var FORMAT_INDEXED = 5
var FORMAT_INDEXED_ALPHA = 6
var FORMAT_YUV_422 = 7
var FORMAT_YUV_444 = 8
var FORMAT_BC1 = 9
var FORMAT_BC2 = 10
var FORMAT_BC3 = 11
var FORMAT_BC4 = 12
var FORMAT_BC5 = 13
var FORMAT_PVRTC2 = 14
var FORMAT_PVRTC2_ALPHA = 15
var FORMAT_PVRTC4 = 16
var FORMAT_PVRTC4_ALPHA = 17
var FORMAT_ETC = 18
var FORMAT_ATC = 19
var FORMAT_ATC_ALPHA_EXPLICIT = 20
var FORMAT_ATC_ALPHA_INTERPOLATED = 21
var FORMAT_CUSTOM = 22
var INTERPOLATE_NEAREST = 0
var INTERPOLATE_BILINEAR = 1
var INTERPOLATE_CUBIC = 2

func _ready():
	pass
