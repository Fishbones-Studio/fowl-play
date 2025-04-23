class_name ItemPreviewContainer extends VBoxContainer

@onready var shop_preview_label: Label = %ItemPreviewLabel
@onready var shop_preview_icon: TextureRect = %ItemPreviewIcon
@onready var shop_preview_type: Label = %ItemPreviewType
@onready var shop_preview_description: RichTextLabel = %ItemPreviewDescription
@onready var shop_preview_stats: RichTextLabel = %ItemPreviewStats


func setup(item: BaseResource) -> void:
	shop_preview_label.text = item.name
	if item.icon: shop_preview_icon.texture = item.icon
	shop_preview_type.text = ItemEnums.item_type_to_string(item.type)
	shop_preview_description.text = item.description

	# Clear previous stats and hide the label initially
	shop_preview_stats.text = ""
	shop_preview_stats.visible = false

	var stats_text: String = ""

	if item is RangedWeaponResource:
		stats_text += "Damage: %d\n" % item.damage
		stats_text += "Windup: %.2fs\n" % item.windup_time
		stats_text += "Duration: %.2fs\n" % item.attack_duration
		stats_text += "Cooldown: %.2fs\n" % item.cooldown_time
		if item.fire_rate_per_second > 0.0:
			stats_text += "Fire Rate: %.1f/s\n" % item.fire_rate_per_second
		stats_text += "Max Range: %.1fm\n" % item.max_range
		if item.allow_continuous_fire:
			stats_text += "Continuous Fire: Yes\n"
		if item.allow_early_release:
			stats_text += "Early Release: Yes\n"

	elif item is MeleeWeaponResource:
		stats_text += "Damage: %d\n" % item.damage
		stats_text += "Windup: %.2fs\n" % item.windup_time
		stats_text += "Duration: %.2fs\n" % item.attack_duration
		stats_text += "Cooldown: %.2fs\n" % item.cooldown_time

	elif item is AbilityResource:
		stats_text += "Cooldown: %.1fs\n" % item.cooldown

	elif item is InRunUpgradeResource:
		stats_text = item.get_bonus_string()

	# Update the stats label if there's text to show
	stats_text = stats_text.strip_edges() # Remove leading/trailing whitespace
	print(stats_text)
	if not stats_text.is_empty():
		shop_preview_stats.text = stats_text
		shop_preview_stats.visible = true
