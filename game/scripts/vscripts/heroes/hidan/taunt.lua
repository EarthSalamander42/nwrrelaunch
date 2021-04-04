--[[Author: Pizzalol
	Date: 09.02.2015.
	Forces the target to attack the caster
]]
function taunt( keys )
	local caster = keys.caster
	local target = keys.target

	-- Clear the force attack target
	target:SetForceAttackTarget(nil)

	-- Give the attack order if the caster is alive
	-- otherwise forces the target to sit and do nothing
	if caster:IsAlive() then
		local order = 
		{
			UnitIndex = target:entindex(),
			OrderType = DOTA_UNIT_ORDER_ATTACK_TARGET,
			TargetIndex = caster:entindex()
		}

		ExecuteOrderFromTable(order)
	else
		target:Stop()
	end

	-- Set the force attack target to be the caster
	target:SetForceAttackTarget(caster)
end

-- Clears the force attack target upon expiration
function tauntEnd( keys )
	local target = keys.target

	target:SetForceAttackTarget(nil)
end
--[[Author: LearningDave
	Date: November, 2th 2015.
	Increases the Str of the caster for each attack received.
]]
function growStrength( keys )
	local caster = keys.caster
	local attacker = keys.attacker
	local str_duration = keys.ability:GetLevelSpecialValueFor( "str_duration", ( keys.ability:GetLevel() - 1 ) )
	keys.ability.removeIt = true
	if attacker:IsHero() then
		keys.ability.bonusStr = keys.ability.bonusStr + 3
		keys.ability.removeIt = false
		Timers:CreateTimer( str_duration, function()
          	keys.ability.bonusStr = keys.ability.bonusStr - 3
          	if keys.ability.removeIt then 
          		keys.caster:RemoveModifierByName(keys.modifier_name)
          	end
			return nil
		end
		)
	else 
		keys.ability.bonusStr = keys.ability.bonusStr + 2
		keys.ability.removeIt = true
		Timers:CreateTimer( str_duration, function()
          	keys.ability.bonusStr = keys.ability.bonusStr - 2
          	if keys.ability.removeIt then 
          		keys.caster:RemoveModifierByName(keys.modifier_name)
          	end
			return nil
		end
		)
	end

	keys.ability:ApplyDataDrivenModifier(keys.caster, keys.caster, keys.modifier_name, {Duration = str_duration})
	keys.caster:SetModifierStackCount(keys.modifier_name, caster, keys.ability.bonusStr)
end
--[[Author: LearningDave
	Date: November, 2th 2015.
	Initates the variables for growStrength
]]
function initiateTaunt( keys )
	keys.ability.bonusStr = 0
	keys.ability.removeIt = false
end


function tauntEnemies( keys )
	
	local caster = keys.caster
	local target = keys.target
	local ability = keys.ability

	local radius = keys.ability:GetLevelSpecialValueFor( "radius", ( keys.ability:GetLevel() - 1 ) )

	local abbility1 = caster:FindAbilityByName("special_bonus_hidan_1")
	if abbility1:IsTrained() then
		radius = radius + 70
	end

	local duration = keys.ability:GetLevelSpecialValueFor( "duration", ( keys.ability:GetLevel() - 1 ) )

	local targets = FindUnitsInRadius(
		caster:GetTeamNumber(), 
		caster:GetAbsOrigin(), 
		nil, 
		radius, 
		DOTA_UNIT_TARGET_TEAM_ENEMY, 
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, 
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 
		0, 
		false
	)

	for _, unit in pairs(targets) do
		ability:ApplyDataDrivenModifier(caster, unit, "modifier_beserkers_call_enemy_datadriven", {duration = duration})
	end


end