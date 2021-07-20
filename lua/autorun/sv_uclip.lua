-- Written by Team Ulysses, http://ulyssesmod.net/
module( "Uclip", package.seeall )
if not SERVER then return end

util.AddNetworkString("UclipOwnershipUpdate")

hasCPPI = false -- Common Prop Protection Interface to check for ownership

-- We'll check status of protectors in this init
function initUclip()
	hasCPPI = (type( CPPI ) == "table")
	
	if not hasCPPI then
		noProtection = true
		net.Start("UclipOwnershipUpdate")
		net.Broadcast()
	end
end
hook.Add( "Initialize", "UclipInitialize", initUclip )

-- Tell them there's no prop protection in the event there isn't.
function initialSpawn( ply )
	if noProtection then
		net.Start("UclipOwnershipUpdate")
		net.Send(ply)
	end
end
hook.Add( "PlayerInitialSpawn", "UclipInitialSpawn", initialSpawn )

-- This function checks the protector to see if ownership has changed from what we think it is. Notifies player for c-side prediction too.
function updateOwnership( ply, ent )
	if noProtection then return end -- No point on going on
	if not ent.Uclip then ent.Uclip = {} end -- Initialize table

	local owns
	if hasCPPI then
		owns = ent:CPPICanPhysgun( ply )
	end
	
	if owns == false then -- More convienent to store as nil, takes less memory and bandwidth!
		owns = nil
	end
	
	if ent.Uclip[ ply ] ~= owns then
		ent.Uclip[ ply ] = owns
		net.Start("UclipOwnershipUpdate")
		net.WriteEntity(ent)
		net.WriteBool(owns)
		net.Send(ply)
	end
end
