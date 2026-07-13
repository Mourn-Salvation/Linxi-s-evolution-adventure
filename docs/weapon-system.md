# Weapon System

## Body Arsenal

Linxi's body is her permanent weapon. In Red Night, Claws unlock after she drinks the blue vial; Tail, waist bone blades, voice attacks, and later forms are progression unlocks. Body attacks are designed around directional `W/A/S/D + J` commands; until individual move definitions are authored, `J` uses the current claw combo.

The current claw combo is implemented as three fast stages. A single `J` press performs only the current stage, deals one damage event, locks movement briefly, then returns Linxi to idle/walk if the player does not continue the chain.

## Human Weapon Slot

Human-made weapons are temporary mission pickups and represent Linxi holding onto human habits. There is one temporary slot and no inventory or reload action.

- Guns carry only their map-authored ammunition. Every shot consumes one round whether or not it overlaps a target. At zero ammunition, Linxi immediately drops the gun and returns to her body weapon.
- Armed human enemies can drop their weapon when they enter knocked-down state. A dropped knife becomes a normal `F` pickup and uses the shared `dropped_knife` prop asset.
- Knives are thrown once with `J`. The blade spins through the fake-3D lane as a projectile, deals `4` damage on impact, briefly stuns the target, and knocks surviving enemies backward. The knife breaks after the throw whether it impacts an enemy, leaves the combat area, or falls to the ground under gravity; the temporary slot is cleared immediately.
- Linxi has exactly one temporary human-weapon slot. Picking up another weapon with `F` drops the currently held weapon beside her as an active ground pickup, preserving its remaining ammunition/uses, then equips the new one. Dropped weapon props render slightly above knocked-down enemy poses so the pickup remains readable.
- The equipped temporary weapon and its remaining uses transfer through ordinary within-stage map checkpoints in `route_checkpoint.temporary_weapon`. Flying projectiles and dropped ground pickups remain local to their source map. Stage-boundary/shelter transitions do not carry temporary weapons, so human weapons never become permanent safe-house equipment.
