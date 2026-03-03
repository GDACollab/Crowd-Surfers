extends Panel
class_name DialogueChoiceButton

@export var transitionType : Tween.TransitionType
const TRANSITION_SPEED := 0.2
var choiceText : String
var choiceIndex : int

func _ready():
	$Label.text = choiceText

func _highlight():
	modulate = Color.WHITE
	var t = create_tween()
	t.tween_property(self, "scale", Vector2(1.2, 1.2), TRANSITION_SPEED).set_trans(transitionType)

func _unhighlight():
	modulate = Color.DIM_GRAY
	var t = create_tween()
	t.tween_property(self, "scale", Vector2(1, 1), TRANSITION_SPEED).set_trans(transitionType)
