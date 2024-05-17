extends CharacterBody2D

const speed = 100
var current_dir = "none"

@onready var healthbar = $HealthBar

var enemy_in_range = false
var enemy_attack_cooldown = true
var player_alive = true
var health = 200
var attack_ip = false


func _ready():
	$AnimatedSprite2D.play("Front Idle")
	healthbar.init_health(health)

func _set_health():
	if health <= 0:
		queue_free()
		print("player has died")
	else:
		healthbar.health = health

func player():
	pass

@warning_ignore("unused_parameter")
func _physics_process(delta):
	playerMovement()
	enemy_attack()
	_set_health()
	Attack()

func playerMovement():
	if Input.is_action_pressed("ui_right"):
		current_dir = "right"
		playAnim(1)
		velocity.x = speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		current_dir = "left"
		playAnim(1)
		velocity.x = -speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		current_dir = "down"
		playAnim(1)
		velocity.y = speed
		velocity.x = 0
	elif Input.is_action_pressed("ui_up"):
		current_dir = "up"
		playAnim(1)
		velocity.y = -speed
		velocity.x = 0
	else:
		playAnim(0)
		velocity.x = 0
		velocity.y = 0
	
	move_and_slide()

func playAnim(Movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D
	
	if dir == "right":
		anim.flip_h = false
		if Movement == 1:
			anim.play("Side Walk")
		elif Movement == 0:
			if attack_ip == false:
				anim.play("Side Idle")
			
	if dir == "left":
		anim.flip_h = true
		if Movement == 1:
			anim.play("Side Walk")
		elif Movement == 0:
			if attack_ip == false:
				anim.play("Side Idle")
			
	if dir == "down":
		if Movement == 1:
			anim.play("Front Walk")
		elif Movement == 0:
			if attack_ip == false:
				anim.play("Front Idle")
			
	if dir == "up":
		if Movement == 1:
			anim.play("Back Walk")
		elif Movement == 0:
			if attack_ip == false:
				anim.play("Back Idle")


func _on_hitbox_body_entered(body):
	if body.has_method("Enemy"):
		enemy_in_range = true


func _on_hitbox_body_exited(body):
	if body.has_method("Enemy"):
		enemy_in_range = false
		
func enemy_attack():
	if enemy_in_range and enemy_attack_cooldown == true:
		health = health - 20
		enemy_attack_cooldown = false
		$Attack_cooldown.start()


func _on_attack_cooldown_timeout():
	enemy_attack_cooldown = true

func Attack():
	var dir = current_dir
	
	if Input.is_action_pressed("Attack"):
		global.player_current_attack = true
		attack_ip = true
		if dir == "right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("Side Attack")
			$deal_attack_timer.start()
		if dir == "left":
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("Side Attack")
			$deal_attack_timer.start()
		if dir == "down":
			$AnimatedSprite2D.play("Front Attack")
			$deal_attack_timer.start()
		if dir == "up":
			$AnimatedSprite2D.play("Back Attack")
			$deal_attack_timer.start()

func _on_deal_attack_timer_timeout():
	$deal_attack_timer.stop()
	global.player_current_attack = false
	attack_ip = false
