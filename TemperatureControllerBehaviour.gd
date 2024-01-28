class_name TemperatureControllerBehaviour
extends Node

@export var ambient_change_rate: float = 0.1
@export var heating_change_rate: float = 1.5
@export var ambient_temperature: float = 22

@export var water_temperature: float = 15 
@export var onButton: Button
@export var offButton: Button
@export var heatReadout: RichTextLabel
@export var water_animation_player: AnimationPlayer
@export var heating_particules: GPUParticles2D
@export var commands_readout: TextEdit

signal heating_changed(new_heating_status)

var heating: bool = false
var heating_time:= 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	onButton.pressed.connect(_on_button_pressed)
	offButton.pressed.connect(_off_button_pressed)
	
	heating_changed.connect(_on_heating_status_changed)
	water_animation_player.play("heating")
	water_animation_player.pause()
	commands_readout.insert_text_at_caret("ready")
	


func _process(delta):
	if water_temperature < ambient_temperature:
		water_temperature += ambient_change_rate * delta
	else:
		water_temperature -= ambient_change_rate * delta

	if heating:
		water_temperature += heating_change_rate * delta
		heating_particules.amount_ratio = (water_temperature - 80) / 20
		heating_time += delta
	
	heatReadout.text = "%3.1f\u00B0C" % water_temperature 

	water_animation_player.seek(water_temperature, true)



func _on_button_pressed():
	if not heating:
		print("On pressed")
		
		heating = true
		heating_time = 0.0
		heating_changed.emit(heating)

		
	
func _off_button_pressed():
	if heating:
		print("Off pressed")
		heating = false
		heating_changed.emit(heating)


func _on_heating_status_changed(is_heating):
	onButton.disabled = is_heating
	offButton.disabled = not is_heating
	heating_particules.set_emitting(is_heating)
	
func execute_command(command_string: String):
	print("Command recieved: " + command_string)	
	commands_readout.insert_text_at_caret("\n" + command_string)

	var dynamic_expression = Expression.new()
	dynamic_expression.parse(command_string + "()")
	var result = dynamic_expression.execute([], self)
	print(result)
	return result

func status():
	print("status check")
	return str("temperature: ", str(water_temperature).pad_decimals(1), ", ", 
			   "heating status: ", "heating" if heating else "standby", ", ",
				"heating time (s): ", str(heating_time).pad_decimals(1))
	
func heat():
	_on_button_pressed()
	return "heating"
	
func standby():
	_off_button_pressed()
	return "standby"

