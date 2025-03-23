extends CanvasLayer
class_name MainMenu

signal exit
signal play
signal credits

var buttonIndex: int = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("esc"):
		_on_exit_pressed()
	elif event.is_action_pressed("accept"):
		var button = %Buttons.get_children().get(buttonIndex)
		button.emit_signal("pressed")

func _on_play_pressed() -> void:
	emit_signal("play")

func _on_settings_pressed() -> void:
	pass # Replace with function body.

func _on_credits_pressed() -> void:
	emit_signal("credits")

func _on_exit_pressed() -> void:
	emit_signal("exit")
