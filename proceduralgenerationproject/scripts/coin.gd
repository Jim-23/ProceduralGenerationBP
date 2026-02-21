extends Area2D


@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _on_body_entered(body: Node2D) -> void:
	# only react to the player
	if not body is CharacterBody2D:
		return

	# disable monitoring so it can't be triggered again mid-animation
	monitoring = false
	$CollisionShape2D.set_deferred("disabled", true)

	animation_player.play("pickup")
