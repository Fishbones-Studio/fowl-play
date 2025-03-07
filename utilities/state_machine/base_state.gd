## Base class for all state implementations in a state machine pattern.
##
## **Note:** This class should not be used directly. Always create child classes.
class_name BaseState
extends Node

## Handles input events for state-specific behavior.
##
## **Must be overridden** in child classes that need input handling.
##
## Parameters:
##  _event: Input event to process.
func input(_event: InputEvent) -> void:
	pass


## Called every frame with delta time.
##
## **Must be overridden** in child classes that need frame-based updates.
##
## Parameters:
##  _delta: Time elapsed since previous frame in seconds.
func process(_delta: float) -> void:
	pass


## Called every physics frame with delta time.
##
## **Must be overridden** in child classes that need physics updates.
##
## Parameters:
##  _delta: Time elapsed since previous physics frame in seconds.
func physics_process(_delta: float) -> void:
	pass


## Called when leaving this state.
##
## Use this to clean up any state-specific resources or reset temporary state.
## **Must be overridden** in child classes if needed.
func exit() -> void:
	pass


