if not GarbageCollector then
	GarbageCollector = class({})
	GarbageCollector.ACTIVE_PARTICLES = {}
end

local ignored_pfx_list = {}
ignored_pfx_list["particles/dev/empty_particle.vpcf"] = true

-- Call custom functions whenever CreateParticle is being called anywhere
local original_CreateParticle = CScriptParticleManager.CreateParticle
CScriptParticleManager.CreateParticle = function(self, sParticleName, iAttachType, hParent)

--	print("CreateParticle response:", sParticleName)

	if not ignored_pfx_list[sParticleName] then
		table.insert(GarbageCollector.ACTIVE_PARTICLES, {response, 0})
	end

	-- call the original function
	local response = original_CreateParticle(self, sParticleName, iAttachType, hParent)

	return response
end

-- Call custom functions whenever CreateParticleForTeam is being called anywhere
local original_CreateParticleForTeam = CScriptParticleManager.CreateParticleForTeam
CScriptParticleManager.CreateParticleForTeam = function(self, sParticleName, iAttachType, hParent, iTeamNumber, hCaster)
--	print("Create Particle (override):", sParticleName, iAttachType, hParent, iTeamNumber, hCaster)

	if not ignored_pfx_list[sParticleName] then
		table.insert(GarbageCollector.ACTIVE_PARTICLES, {response, 0})
	end

	-- call the original function
	local response = original_CreateParticleForTeam(self, sParticleName, iAttachType, hParent, iTeamNumber)

	return response
end

-- Call custom functions whenever CreateParticleForPlayer is being called anywhere
local original_CreateParticleForPlayer = CScriptParticleManager.CreateParticleForPlayer
CScriptParticleManager.CreateParticleForPlayer = function(self, sParticleName, iAttachType, hParent, hPlayer, hCaster)
--	print("Create Particle (override):", sParticleName, iAttachType, hParent, hPlayer, hCaster)

	if not ignored_pfx_list[sParticleName] then
		table.insert(GarbageCollector.ACTIVE_PARTICLES, {response, 0})
	end

	-- call the original function
	local response = original_CreateParticleForPlayer(self, sParticleName, iAttachType, hParent, hPlayer)

	return response
end

function GarbageCollector:OnThink()
	for k, v in pairs(GarbageCollector.ACTIVE_PARTICLES) do
		if v[2] >= 60 then
			ParticleManager:DestroyParticle(v[1], false)
			ParticleManager:ReleaseParticleIndex(v[1])
			table.remove(GarbageCollector.ACTIVE_PARTICLES, k)
		else
			GarbageCollector.ACTIVE_PARTICLES[k][2] = GarbageCollector.ACTIVE_PARTICLES[k][2] + 1
		end
	end
end
