-- Load CB_DEBUG Value
local CB_DEBUG = rawget(_G, "CB_DEBUG") and _G.CB_DEBUG or false

-- Load Screen Helpers
local Screen = require "helpers/ScreenHelpers"

-- Piper Tags
-- bunnyman, houndfriend
local mustTag = {}
local notTags = {'mandrake','baby','werepig','guard','spiderqueen'}
local tags = {'manrabbit','pig','beefalo','rocky','spider'}

-- Get Possible Followers
local CB_GetPotentialFollowers = function(inst, radius, force)

	-- Do Nothing If instance not Valid or too many followers
	if not inst
		or not inst:IsValid()
		or not inst.components.leader
	then return end
	
	-- Check if monster
	local ismonster = inst:HasTag("monster")
	
	-- Set Force Leader Addition
	force = type(force) == "boolean" and force or false
	
	-- Get location of leader
	local x,y,z = inst.Transform:GetWorldPosition()
	
	-- Print Debug info
	if CB_DEBUG then
		print(string.format("Looking Followers At: %f %f %d",x,y,z))
	end

	local ents = TheSim:FindEntities(x,y,z, radius, mustTag, notTags, tags)
	--local ents = TheSim:FindEntities(x,y,z, radius)
	local canidate = {}
	for k, v in pairs(ents) do
		if v ~= inst
			and v:IsValid()
			and v.entity:IsVisible()
			and not v:HasTag("structure")
			and v.components
			and v.components.health
			and not v.components.health:IsDead()
			and v.components.follower
			and not inst.components.leader:IsFollower(v)
		then
			local good = true
			good = (force or not v.components.follower.leader) or false	-- Not Already A follower Or Forced Ownership
			good = (ismonster == v:HasTag("monster")) or false	-- Leader Monster And Follower Both Same Type
			
			if good then
				if CB_DEBUG then
					print(string.format("Found: %s with GUID %s and prefab %s",v.name,v.GUID,v.prefab))
				end
				table.insert(canidate,v)								-- Add Follower
			end
		end
	end
	
	-- No possible cannidate found
	if #canidate <= 0 then return end
	
	-- Return potential cannidates
	return canidate
end


-- Add Follower To Leader
local CB_AddFollower = function(leader,follower)
	
	-- Get Heard If Its A Heard Member
	local followers = {}
	if follower.components and follower.components.herdmember then
		local herd = follower.components.herdmember:GetHerd()
		if herd and herd.components.herd then
			for k,_ in pairs(herd.components.herd.members) do
				if k:IsValid() then table.insert(followers,k) end
            end
		end
	end
	
	-- Add Original Follower if there was no herd
	if #followers == 0 then table.insert(followers,follower) end
	
	-- Get Current Number of followers
	local count_followers = leader.components.leader.numfollowers
	
	-- Dont Add Too Many Followers If we have atleast one followers 
	if count_followers > 0
		and (#followers + count_followers) > TUNING.CHEAT_BOX.PIPER_MODE_MAX_FOLLOWERS
	then
		leader.components.talker:Say(GetString(leader.prefab,"CB_PIPER_MODE","CROWDED"))
		if CB_DEBUG then print(string.format("%s many members in herd",#followers)) end
		return
	end
	
	-- Say status
	leader.components.talker:Say(GetString(leader.prefab,"CB_PIPER_MODE"))
	
	-- Add Make Friend Sound
	follower.SoundEmitter:PlaySound("dontstarve/common/makeFriend")
	
	-- Add Followers
	for _,v in pairs(followers) do

		-- Print Debug Message
		if CB_DEBUG then
			local follower_no = leader.components.leader.numfollowers+1
			print(string.format("Adding Follower[%s] %s With GUID %s",follower_no,v.name,v.GUID))
		end
	
		-- Add Follower
		leader.components.leader:AddFollower(v)
	
		-- Add Loyality Time To Follower
		local followtime = v.components.follower.maxfollowtime or 1
		v.components.follower:AddLoyaltyTime(followtime)

		-- Wake Up If Sleep
		if v.components.sleeper:IsAsleep() then
			v.components.sleeper:WakeUp()
		end
	
		-- Remove Follower Target
		if v.components.combat and v.components.combat.target then
			v.components.combat:SetTarget(nil)
		end
	end
end


-- Piper Mode
local CB_PiperMode = function(inst)

	-- Exit If Piper Mode Disabled
	if not TUNING.CHEAT_BOX.FLAG_PIPER_MODE then return end
	
	-- Do nothing if Activator not pressed
	-- if not TheInput:IsKeyDown(KEY_piper) then return end
	
	-- Exit If PlayerHud Missing
	if not (Screen.IsHudScreen() or Screen.IsPauseScreen()) then return end
	
	-- Set Leader
	local Leader = (inst and inst:HasTag("player")) and inst or GetPlayer()
	
	-- Do Nothing If Missing Leader Component or Too Many Followers
	if not Leader.components
		or not Leader.components.leader
		or Leader.components.leader.numfollowers >= TUNING.CHEAT_BOX.PIPER_MODE_MAX_FOLLOWERS
	then return end
	
	-- Set radius to search for follower
	local radius = TUNING.CHEAT_BOX.RANGE_PIPER_MODE
	
	-- Get Potential Followers
	local canidate = CB_GetPotentialFollowers(Leader, radius)
	
	if canidate and #canidate > 0 then
		for _,v in ipairs(canidate) do

			-- Add Follower
			CB_AddFollower(Leader,v)
			
			-- Exit If Too Max Followers Reached
			if Leader.components.leader.numfollowers >= TUNING.CHEAT_BOX.PIPER_MODE_MAX_FOLLOWERS then break end
		end
	end
end

return CB_PiperMode