class_name BattleDamageKind
extends RefCounted


const DIRECT: StringName = &"direct"
const PERIODIC: StringName = &"periodic"


static func is_valid(
	damage_kind: StringName
) -> bool:
	return (
		damage_kind == DIRECT
		or damage_kind == PERIODIC
	)
