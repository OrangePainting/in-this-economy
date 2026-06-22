extends TabBar

@onready var music_slider = $MusicSlider
@onready var sfx_slider = $SFXSlider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))
	
	music_slider.value_changed.connect(on_music_volume_changed)
	sfx_slider.value_changed.connect(on_sfx_volume_changed)

func on_music_volume_changed(val: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(val))

func on_sfx_volume_changed(val: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(val))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
