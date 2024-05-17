extends CharacterBody2D

var speed = 20
var limit = 0.5
var health = 100
@export var endPoint: Marker2D
@onready var animations = $AnimatedSprite2D
var startPosition
var endPosition
@onready var healthbar = $HealthBar
var player_in_range = false
var can_take_damage = true
var player = null
var player_chase = false

func _ready():
	startPosition = position
	endPosition = endPoint.global_position
	healthbar.init_health(health)
	_set_health() # Call _set_health() in _ready() to initialize health bar

func _on_detection_area_body_entered(body):
	player = body
	player_chase = true

func _on_detection_area_body_exited():
	player = null
	player_chase = false

func changeDirection():
	var tempEnd = endPosition
	endPosition = startPosition
	startPosition = tempEnd

func updateVelocity():
	var moveDirection = endPosition - position
	if moveDirection.length() < limit:
		changeDirection()
	velocity = moveDirection.normalized() * speed

func updateAnimation():
	animations.play("Walk")

func handleCollision():
	# Handle collision if needed
	pass

func _set_health():
	healthbar.health = health
	if health <= 0:
		queue_free()

func Enemy():
	pass

@warning_ignore("unused_parameter")
func _physics_process(delta):
	updateVelocity()
	move_and_slide()
	handleCollision()
	updateAnimation()
	deal_damage()
	_set_health() # Update health bar each frame

	if player_chase:
		position += (player.position - position) / (speed * 2)
		animations.play("Walk")
		move_and_collide(Vector2.ZERO)

func _on_hitbox_body_entered(body):
	if body.has_method("player"):
		player_in_range = true

func _on_hitbox_body_exited(body):
	if body.has_method("player"):
		player_in_range = false

func deal_damage():
	if player_in_range and global.player_current_attack and can_take_damage: # Add a check for player's attack
		health -= 20
		$take_damage_cooldown.start()
		can_take_damage = false
		print("Slimne health = ", health)
		if health <= 0:
			animations.play("Death") # Play death animation
			$take_damage_cooldown.stop() # Stop any further damage while playing the death animation
			@warning_ignore("redundant_await")
			await($AnimatedSprite2D) # Wait for the death animation to finish
			queue_free() # Free the enemy from memory after death animation

func _on_take_damage_cooldown_timeout():
	can_take_damage = true

