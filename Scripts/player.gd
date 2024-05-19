extends CharacterBody2D

var health: int = 100
var speed: int = 100
var acceleration: int = 200
var friction: int = 100
var current_dir = "none"
var player_alive = true
var enemy_in_range = false
var attack_in_progress = false
var enemy_attack_cooldown = true
var last_input_direction = Vector2(0, 0)

@onready var hitbox = $hitbox
@onready var healthbar = $HealthBar
@onready var attack_cooldown = $Attack_cooldown
@onready var deal_attack_timer = $deal_attack_timer
@onready var animated_sprite = $AnimatedSprite2D
@export var knockbackPower: int = 1000
@onready var effects = $Effects
@onready var hurtTimer = $hurtTimer

func _ready():
	animated_sprite.play("Front Idle")
	healthbar.init_health(health)
	effects.play("RESET")

func _set_health():
	if health <= 0:
		player_alive = false
		healthbar.health = 0
	else:
		healthbar.health = health

func player():
	pass

func _physics_process(delta):
	if player_alive:
		var input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		enemy_attack()
		_set_health()
		Attack()
		player_movement(input, delta)
		update_animations(input)
		move_and_slide()
	else:
		death()

func _on_hitbox_area_entered(area):
	if player_alive:
		knockback(hitbox.get_parent().velocity)
		effects.play("hurtBlink")
		hurtTimer.start()
		await hurtTimer.timeout
		effects.play("RESET")

func _on_hitbox_body_entered(body):
	if body.has_method("enemy"):
		enemy_in_range = true

func _on_hitbox_body_exited(body):
	if body.has_method("enemy"):
		enemy_in_range = false

func enemy_attack():
	if enemy_in_range and enemy_attack_cooldown:
		health -= 20
		enemy_attack_cooldown = false
		print("player health = ", health)
		attack_cooldown.start()

func _on_attack_cooldown_timeout():
	enemy_attack_cooldown = true

func Attack():
	if Input.is_action_pressed("Attack") and not attack_in_progress:  # Assuming "attack" is the correct action name
		global.player_current_attack = true
		attack_in_progress = true
		deal_attack_timer.start()

func _on_deal_attack_timer_timeout():
	deal_attack_timer.stop()
	global.player_current_attack = false
	attack_in_progress = false

func knockback(enemyVelocity: Vector2):
	var knockbackDirection = (enemyVelocity - self.velocity).normalized() * knockbackPower
	self.velocity = knockbackDirection

func player_movement(input, delta):
	if input != Vector2.ZERO:
		var running = Input.is_action_pressed("run")
		if running:
			self.velocity = self.velocity.move_toward(input * speed * 1.4, delta * acceleration)
		else:
			self.velocity = self.velocity.move_toward(input * speed, delta * acceleration)
	else:
		self.velocity = self.velocity.move_toward(Vector2.ZERO, delta * friction)

func death():
	if player_alive == false and animated_sprite.animation != "Death":
		print("Player is dying")
		animated_sprite.play("Death")
		self.velocity = Vector2.ZERO
		var timer = get_tree().create_timer(1)
		timer.connect("timeout", Callable(self, "_on_death_timeout"))

func _on_death_timeout():
	print("Player has died")
	queue_free()

func update_animations(input):
	if player_alive:
		if Input.is_action_pressed("Attack"):  # Replace "attack" with the actual attack action name
			if last_input_direction.y == -1:
				animated_sprite.play("Back Attack")
			elif last_input_direction.y == 1:
				animated_sprite.play("Front Attack")
			else:
				animated_sprite.play("Side Attack")
		elif not attack_in_progress:  # Only allow movement/idle animations if not attacking
			if input.x != 0:
				animated_sprite.flip_h = input.x < 0
				animated_sprite.play("Side Walk")
				last_input_direction = Vector2(input.x, 0)
			elif input.y == -1:
				animated_sprite.play("Back Walk")
				last_input_direction = Vector2(0, -1)
			elif input.y == 1:
				animated_sprite.play("Front Walk")
				last_input_direction = Vector2(0, 1)
			else:
				if last_input_direction.y == -1:
					animated_sprite.play("Back Idle")
				elif last_input_direction.y == 1:
					animated_sprite.play("Front Idle")
				else:
					animated_sprite.play("Side Idle")
