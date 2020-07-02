extends KinematicBody2D

var a 
var ms 
var f
var gravity 
var jumpForce 
var dashing = false
var startDash = true

var vl = Vector2.ZERO
var inpv = Vector2()

var st = MOVE
onready var pa = $AnimationPlayer
onready var ta = $AnimationTree
onready var sa = ta.get("parameters/playback")

enum{
	MOVE,
	DASH
}

var ji

func _ready() -> void:
	ta.active = true

func _physics_process(delta: float) -> void:
	match st:
		MOVE:
			move_state(delta)
		DASH:
			dash_state(delta)
	vl = move_and_slide(vl, Vector2.UP)

func move_state(delta):
	
	if not is_on_floor():
		ms = 475
		a = 600
		f = 800
		gravity = 1900
	else:
		ms = 200
		a = 500
		f= 600
		jumpForce = 900
	
	ji = Input.is_action_just_released("jump") and vl.y < 0.0
	
	inpv = Vector2(Input.get_action_strength("right")-Input.get_action_strength("left"),
		-1.0 if Input.is_action_just_pressed("jump") and is_on_floor() else 0.0)
	
	if Input.is_action_just_pressed("dash") and dashing == false and startDash == true:
		st = DASH
	
	if inpv != Vector2.ZERO:
		if is_on_floor():
			sa.travel("walk")
		vl = vl.move_toward(inpv * ms, a * delta)
	elif is_on_floor():
		sa.travel("idle")
		vl = vl.move_toward(Vector2.ZERO, f* delta)
	else:
		pass
	
	if inpv.y == -1.0:
		vl.y = jumpForce * inpv.y
		sa.travel("jump")
	#if ji:
	#	vl.y = 0.0
	
	
	vl.y += gravity * get_physics_process_delta_time()
	
	if inpv.x == -1.0:
		$AnimatedSprite.scale.x = -0.2
	elif inpv.x == 1.0:
		$AnimatedSprite.scale.x = 0.2
	
	print(inpv)
	

func dash_state(delta):
	var dashDir = $AnimatedSprite.scale.x * 5
	dashing = true
	vl.x = 1500 * dashDir
	vl.y = 0
	sa.travel("dash")
	yield(get_tree().create_timer(.2),"timeout")
	vl.x = lerp(vl.x,170*dashDir,0.3)
	st = MOVE
	dashing = false
	startDash = false
	yield(get_tree().create_timer(0.1),"timeout")
	startDash=true
