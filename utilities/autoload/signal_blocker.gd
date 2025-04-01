# InputBlocker.gd (autoload)
extends Node

var blocked := false

func block():
	blocked = true
	# This will make _input() not be called on any nodes
	get_tree().root.set_process_input(false)

func unblock():
	blocked = false
	get_tree().root.set_process_input(true)
