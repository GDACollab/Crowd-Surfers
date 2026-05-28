extends Node

@export var artist_name: String
@export var art: Texture2D
@export var description: String

@onready var artist_name_text: RichTextLabel = $ArtistNamePanel/ArtistName
@onready var art_image: TextureRect = $Art
@onready var description_text: RichTextLabel = $DescriptionPanel/Description

func _ready() -> void:
	artist_name_text.text = "[i]" + artist_name
	art_image.texture = art
	description_text.text = "[i]" + description
