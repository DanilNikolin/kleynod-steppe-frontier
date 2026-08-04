@tool
class_name HeroCoreEffect
extends BattleEffect


## Marker-эффект.
## Общий EffectResolver не знает его конкретной механики:
## он передаёт Resource в HeroCoreRuntimeState получателя.


func get_presentation_text() -> String:
	return "• Изменяет уникальную механику героя."
