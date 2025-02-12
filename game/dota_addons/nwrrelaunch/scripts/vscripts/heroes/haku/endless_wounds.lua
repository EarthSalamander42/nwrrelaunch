haku_endless_wounds = haku_endless_wounds or class({})


LinkLuaModifier("modifier_haku_endless_needles_victim_counter", "heroes/haku/endless_wounds.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_haku_endless_needles_victim_counter_counter", "heroes/haku/endless_wounds.lua", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("modifier_haku_endless_needles_caster", "heroes/haku/endless_wounds.lua", LUA_MODIFIER_MOTION_NONE)


function haku_endless_wounds:GetAbilityTextureName()
	return "haku_endless_wounds"
end

function haku_endless_wounds:GetBehavior()
	return DOTA_ABILITY_BEHAVIOR_PASSIVE
end

function haku_endless_wounds:OnUpgrade()
	-- if self:GetOwner() == self:GetCaster() then
	-- 	self:GetCaster():AddNewModifier(self:GetCaster(), self, "modifier_haku_endless_needles_caster", {})
	-- end
end

function haku_endless_wounds:GetIntrinsicModifierName()
	return "modifier_haku_endless_needles_caster"
end

function haku_endless_wounds:ApplyStacks(target, stacks)
	if not target:HasModifier("modifier_haku_endless_needles_victim_counter") then
		target:AddNewModifier(self:GetCaster(),
							  self,
							  "modifier_haku_endless_needles_victim_counter", 
							  {duration = self:GetSpecialValueFor("duration")})
	else
		local counter = target:FindModifierByNameAndCaster("modifier_haku_endless_needles_victim_counter", self:GetCaster())
		local current_stacks = counter:GetStackCount()
		local sum = current_stacks + stacks
		local threshold = self:GetSpecialValueFor("threshold")
		if sum > threshold then
			stacks = math.max(threshold - current_stacks, 0)
		end
	end
	if stacks > 0 then
		for i=1,stacks do
			target:AddNewModifier(self:GetCaster(),
								self,
								"modifier_haku_endless_needles_victim", 
								{duration = self:GetSpecialValueFor("duration")})
		end
	end
end


modifier_haku_endless_needles_caster = modifier_haku_endless_needles_caster or class({})

function modifier_haku_endless_needles_caster:IsHidden() return false end
function modifier_haku_endless_needles_caster:IsPassive() return true end

function modifier_haku_endless_needles_caster:DeclareFunctions()
	return {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
end

function modifier_haku_endless_needles_caster:OnCreated()
	-- Ability properties
	self.caster = self:GetCaster()
	self.ability = self:GetAbility()
	self.stacks = 0

	-- todo fix
	-- self:GetCaster():SetRangedProjectileName("particles/units/heroes/haku/haku_base_attack_wounds_active.vpcf")
end

function modifier_haku_endless_needles_caster:OnAttackLanded( keys )

		local target = keys.target
		local caster = keys.attacker

		if caster == self.caster or (keys.attacker:GetOwner() ~= nil and keys.attacker:GetOwner():GetName() == "npc_dota_hero_drow_ranger") then
			self.stacks_per_attack = self:GetAbility():GetSpecialValueFor("stacks_per_attack")
			self.duration = self:GetAbility():GetSpecialValueFor("duration")
			self.threshold = self:GetAbility():GetSpecialValueFor("threshold")
			self.stack_modifier = "modifier_haku_endless_needles_victim_counter"

			self:GetAbility():ApplyStacks(target, self.stacks_per_attack)
				
		end
	
end

modifier_haku_endless_needles_victim_counter = class({})

function modifier_haku_endless_needles_victim_counter:IsHidden() return false end
function modifier_haku_endless_needles_victim_counter:IsPurgable() return true end
function modifier_haku_endless_needles_victim_counter:IsDebuff() return true end

function modifier_haku_endless_needles_victim_counter:OnCreated(keys)
	-- Ability properties
	self.current_stacks = 0
	self.slow = self:GetAbility():GetSpecialValueFor("ms_slow_per_stack")
	if self:GetCaster():FindAbilityByName("special_bonus_haku_1"):GetLevel() > 0 then
		self.slow = self:GetAbility():GetSpecialValueFor("ms_slow_per_stack_special")
	end
	if IsServer() then
		-- add stack modifier

		self.duration = self:GetAbility():GetSpecialValueFor("duration")

		self.slow_vfx = ParticleManager:CreateParticle("particles/units/heroes/haku/haku_wounds_debuff.vpcf",
												  PATTACH_ABSORIGIN_FOLLOW,
												  self:GetAbility():GetCaster())
		ParticleManager:SetParticleControlEnt(self.slow_vfx, 0, self:GetParent(), PATTACH_POINT_FOLLOW, "origin", self:GetParent():GetOrigin(), true )
	end

end

function modifier_haku_endless_needles_victim_counter:Onremoved()
	ParticleManager:DestroyParticle(self.slow_vfx, false)
	ParticleManager:ReleaseParticleIndex(self.slow_vfx)
end
function modifier_haku_endless_needles_victim_counter:OnDestroy() end

function modifier_haku_endless_needles_victim_counter:ChangeStacks(change)
	local current_stacks = self:GetStackCount()
	self:SetStackCount(current_stacks + change)
	self.current_stacks = current_stacks + change
	ParticleManager:SetParticleControl(self.slow_vfx, 1, Vector(self.current_stacks, 0, 0))

	if current_stacks + change >= 0 then
		self:SetDuration(self.duration, true)
	end
end

function modifier_haku_endless_needles_victim_counter:DeclareFunctions()
    return {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE
    }
end

function modifier_haku_endless_needles_victim_counter:GetModifierMoveSpeedBonus_Percentage()
	if IsClient() then
		print(self.slow * self.current_stacks)
	end
	
    return  self.slow * self:GetStackCount()
end

modifier_haku_endless_needles_victim = class({})

function modifier_haku_endless_needles_victim:IsHidden() return true end
function modifier_haku_endless_needles_victim:IsPurgable() return true end
function modifier_haku_endless_needles_victim:IsDebuff() return true end

function modifier_haku_endless_needles_victim:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function modifier_haku_endless_needles_victim:OnCreated(keys)
	target = self:GetParent()
	if IsServer() then
		counter = target:FindModifierByNameAndCaster("modifier_haku_endless_needles_victim_counter", self:GetCaster())
		counter:ChangeStacks(1)
	end	
end

function modifier_haku_endless_needles_victim:OnRemoved()
	target = self:GetParent()
	if IsServer() then
		counter = target:FindModifierByNameAndCaster("modifier_haku_endless_needles_victim_counter", self:GetCaster())
		if counter ~= nil then
			counter:ChangeStacks(-1)
		end
	end	
end

function modifier_haku_endless_needles_victim:OnDestroy()
end