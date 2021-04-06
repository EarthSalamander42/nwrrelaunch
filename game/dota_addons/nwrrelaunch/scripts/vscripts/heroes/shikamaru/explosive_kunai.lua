function explosive_kunai_post_vision( keys )
	-- Variables
	local ability = keys.ability
	local target = keys.target_points[ 1 ]
	local duration = ability:GetLevelSpecialValueFor( "vision_duration", ( ability:GetLevel() - 1 ) )
	local radius = ability:GetLevelSpecialValueFor( "vision_radius", ( ability:GetLevel() - 1 ) )

	-- Create unit to reference the point
	ability:CreateVisibilityNode( target, radius, duration )
end

function applyDamage( keys )
	local target_point = keys.target_points[1]
	local ability = keys.ability
	local caster = keys.caster
	local radius = ability:GetLevelSpecialValueFor("radius",ability:GetLevel() - 1)
	local targets = FindUnitsInRadius(
		keys.caster:GetTeamNumber(), 
		target_point, 
		nil, 
		radius, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		0, 
		0, 
		false
	)

	local damage = ability:GetLevelSpecialValueFor("damage",ability:GetLevel() - 1)

	local ability5 = caster:FindAbilityByName("special_bonus_shikamaru_5")
	if ability5:IsTrained() then
		damage = damage + 240
	end

	for _, unit in pairs(targets) do
		local damage_table = {}
		damage_table.attacker = caster
		damage_table.damage_type = DAMAGE_TYPE_MAGICAL
		damage_table.ability = ability
		damage_table.victim = unit
		damage_table.damage = damage

		ApplyDamage(damage_table)
	end
end