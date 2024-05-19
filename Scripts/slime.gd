extends CharacterBody2D

@export var endPoint: Marker2D
@onready var animated_sprite = $AnimatedSprite2D
@onready var healthbar = $HealthBar
@onready var take_damage_cooldown = $take_damage_cooldown
@onready var detection_area = $detection_area
@onready var hitbox = $Hitbox

var speed: int = 20
var limit = 0.5
var health: int = 100
var startPosition
var endPosition
var player_in_range = false
var can_take_damage = true
var player = null
var player_chase = false
var dead = false
var last_input_direction = Vector2(0, 0)

func _ready():
	startPosition = position
	endPosition = endPoint.global_position
	healthbar.init_health(health)
	_set_health()  # Initialize the health bar

func _on_detection_area_body_entered(body):
	if body.has_method("player"):  # Assuming the player is in a group named "Player"
		player = body
		player_chase = true

func _on_detection_area_body_exited(body):
	if body.has_method("player"):
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
	if not can_take_damage or player_chase:  # If the enemy is attacking or chasing the player
		return  # Do not change the animation during attack or chase
	else:
		animated_sprite.play("Walk")

func handleCollision():
	# Handle collision if needed
	pass

func enemy():
	pass

func _set_health():
	healthbar.health = health
	if health <= 0:
		healthbar.health = 0  # Ensure health does not go below zero
		dead = true

func _physics_process(delta):
	updateVelocity()
	move_and_slide()
	handleCollision()
	updateAnimation()
	deal_damage()
	_set_health()  # Update health bar each frame

	if player_chase:
		position += (player.global_position - position).normalized() * speed * delta

		move_and_slide()
	if dead:
		if animated_sprite.animation != "Death":
			animated_sprite.play("Death")
			self.velocity = Vector2.ZERO
			take_damage_cooldown.stop()
			var timer = get_tree().create_timer(1)
			timer.connect("timeout", Callable(self, "_on_death_timeout"))

func _on_death_timeout():
	queue_free()

func _on_hitbox_body_entered(body):
	if body.has_method("player"):
		player_in_range = true

func _on_hitbox_body_exited(body):
	if body.has_method("player"):
		player_in_range = false

func deal_damage():
	if player_in_range and global.player_current_attack and can_take_damage:
		health -= 20
		animated_sprite.play("Hit")
		take_damage_cooldown.start()
		can_take_damage = false
		print("Slime health = ", health)
		_set_health()  # Update health after taking damage

func _on_take_damage_cooldown_timeout():
	can_take_damage = true
