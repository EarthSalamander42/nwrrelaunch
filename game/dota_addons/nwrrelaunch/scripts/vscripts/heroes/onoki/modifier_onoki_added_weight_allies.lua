modifier_onoki_added_weight_allies = class({})

--------------------------------------------------------------------------------
-- Classifications
function modifier_onoki_added_weight_allies:IsHidden()
	return false
end

function modifier_onoki_added_weight_allies:IsDebuff()
	return false
end

function modifier_onoki_added_weight_allies:IsStunDebuff()
	return false
end

function modifier_onoki_added_weight_allies:IsPurgable()
	return true
end

--------------------------------------------------------------------------------
-- Initializations
function modifier_onoki_added_weight_allies:OnCreated( kv )
	-- references
	self.speed_bonus_perc = self:GetAbility():GetSpecialValueFor( "speed_bonus_perc" )

	if not IsServer() then return end

	-- play effects
	local sound_cast = "Hero_Dark_Seer.Surge"
	EmitSoundOn( sound_cast, self:GetParent() )
end

function modifier_onoki_added_weight_allies:OnRefresh( kv )
	self:OnCreated( kv )
end

function modifier_onoki_added_weight_allies:OnRemoved()
end

function modifier_onoki_added_weight_allies:OnDestroy()
end

--------------------------------------------------------------------------------
-- Modifier Effects
function modifier_onoki_added_weight_allies:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE ,
	}

	return funcs
end

function modifier_onoki_added_weight_allies:GetModifierMoveSpeedBonus_Percentage()
	return self.speed_bonus_perc
end


--------------------------------------------------------------------------------
-- Status Effects
function modifier_onoki_added_weight_allies:CheckState()
	local state = {	}

	return state
end

--------------------------------------------------------------------------------
-- Graphics & Animations
function modifier_onoki_added_weight_allies:GetEffectName()
	return "particles/units/heroes/hero_dark_seer/dark_seer_surge.vpcf"
end

function modifier_onoki_added_weight_allies:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end