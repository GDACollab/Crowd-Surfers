extends Panel
class_name DialogueChoiceButton

var choiceText : String
var choiceIndex : int

func _ready():
	$Label.text = choiceText
