extends TabBar

@onready var music_slider = $VBoxContainer/MusicSlider
@onready var general_sfx_slider = $VBoxContainer/GeneralSFXSlider
@onready var application_sfx_slider = $VBoxContainer/ApplicationSFXSlider
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	general_sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("General SFX")))
	application_sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Application SFX")))
	
	music_slider.value_changed.connect(on_music_volume_changed)
	general_sfx_slider.value_changed.connect(on_general_sfx_volume_changed)
	application_sfx_slider.value_changed.connect(on_application_sfx_volume_changed)

func on_music_volume_changed(val: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(val))

func on_general_sfx_volume_changed(val: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("General SFX"), linear_to_db(val))

func on_application_sfx_volume_changed(val: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Application SFX"), linear_to_db(val))
