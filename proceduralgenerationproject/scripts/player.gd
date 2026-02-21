extends CharacterBody2D


const SPEED = 200
#const JUMP_VELOCITY = -300.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Add the gravity.

	#if not is_on_floor():
	#	velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("jump") and is_on_floor():
	#	velocity.y = JUMP_VELOCITY

	# get input dir: (0.0, 0.0), (0.0, 1.0), (1.0, 0.0), (-1.0, 0.0)
	var direction = Input.get_vector("go_left", "go_right", "go_up", "go_down")
	velocity = direction * SPEED
	
	# flip the Sprite
	if direction.x > 0:
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true

	# Play animations
	#if is_on_floor():
	#	if direction == 0:
	animated_sprite.play("idle")
		#else:
		#	animated_sprite.play("run")
	#else:
		#animated_sprite.play("jump")

	# Apply movement
	#if direction:
	#	velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

# setter variable for zooming in and out
var zoom : bool = true:
	set(value):
		zoom = value
		if value:
			$Camera2D.zoom = Vector2(4, 4)
		else:
			$Camera2D.zoom = Vector2(2.5, 2.5)

func _input(event):
	if event is InputEventKey and event.is_pressed():
		# zooming in and out pressing Z
		if event.keycode == KEY_Z:
			zoom = !zoom
		
