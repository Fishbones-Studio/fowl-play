## Enemy: A basic enemy that can take damage and die.
extends Enemy

const ENEMY_TYPE: EnemyEnums.EnemyTypes = EnemyEnums.EnemyTypes.REGULAR


func _ready() -> void:
	super()
	
