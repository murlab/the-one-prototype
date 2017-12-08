# Root Script for Godot Engine
# 2017 © Mur (https://murlab.github.io/)
# License: BSD 3-Clause License

extends Node

func _ready():
	pass

func getElements():
	var steps = get_node("steps").get_children()
	var elements = getSteps(steps)
	elements["name"] = get_node("name").get("eventName")
	#print (elements.to_json())
	return elements
	
func getSteps(steps):
	var elements = {}
	elements["steps"] = []
	for action in (steps):
		var step = {}
		var aChildren = {}
		for child in action.get_children():
			var cName = child.get_name()
			aChildren[cName] = getSubElements(child.get_children())
		step["actions"] = aChildren
		elements["steps"].append(step)

	return elements
#--------------------------------------------------
func getSubElements(childs):
	var cData = []
	for el in childs:
		#print (el.get_name())
		var elData = {}
		elData["type"] = el.get("type")
		if el.get("type") == "message":
			elData["face"] = el.get("face")
			elData["pos"] = el.get("pos")
			elData["text"] = el.get("text")

		elif el.get("type") == "nextStep":
			elData["step"] = el.get("step")
		
		elif el.get("type") == "select":
			elData["text"] = el.get("text")
			var items = []
			for item in el.get_children():
				var subSteps = item.get_children()
				var action = getSubElements(subSteps)
				items.append({"name":item.get("name"), "action":action})
			elData["items"] = items
		
		elif el.get("type") == "play":
			elData["sample"] = el.get("sample").get_path()
			elData["volume"] = el.get("volume")
			
		elif el.get("type") == "keylock":
			elData["unlockCode"] = el.get("unlockCode")
			var items = {}
			for item in el.get_children():
				var subSteps = item.get_children()
				var action = getSubElements(subSteps)
				items[item.get_name()] = {"action":action}
			elData["items"] = items

		cData.append(elData)
		
	return cData
#--------------------------------------------------
