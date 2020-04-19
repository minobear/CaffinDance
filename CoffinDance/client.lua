local isDead = false
local commState = false

if Config.EnableCommand then
	RegisterCommand("coffindance", function(source, args, rawCommand)
		if not commState then
			commState = true
			StartCoffinDance("Command")
		else
			commState = false
			EndCoffinDance()
		end
	end, false)
end


Citizen.CreateThread(function()
	if Config.StartWhenDeath then
		while true do
		Wait(500)		
			if (not isDead and NetworkIsPlayerActive(PlayerId()) and IsPedFatallyInjured(PlayerPedId())) then	
				isDead = true
				StartCoffinDance("Death")
			elseif (isDead and NetworkIsPlayerActive(PlayerId()) and not IsPedFatallyInjured(PlayerPedId())) then
				isDead = false	
				EndCoffinDance()			
			end
		end
	end
end)

function StartCoffinDance(type)	
	local playerPed = PlayerPedId()
	local coffinModel = GetHashKey(Config.CoffinModel)
	local pedModel = GetHashKey(Config.DancerPedModel)	
	RequestModel(coffinModel)
	while not HasModelLoaded(coffinModel) do
		Citizen.Wait(1)
	end		
	RequestModel(pedModel)
	while not HasModelLoaded(pedModel) do
		Citizen.Wait(1)
	end				
	local coords = GetEntityCoords(playerPed)
	if Config.PlayMusic then
		TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 8.0, 'CoffinDance', 0.2)
	end
	if type == "Death" then
		Wait(1000)
		mainPed = CreatePed(4, pedModel, coords.x, coords.y, coords.z, 3374176, false, true)
	else
		mainPed = CreatePed(4, pedModel, coords.x+1.0, coords.y, coords.z, 3374176, false, true)
	end	
	SetEntityVisible(mainPed, false, false)
	ped = CreatePed(4, pedModel, coords.x+1.0, coords.y, coords.z, 3374176, false, true)
	ped2 = CreatePed(4, pedModel, coords.x+1, coords.y-1, coords.z, 3374176, false, true)
	ped3 = CreatePed(4, pedModel, coords.x-1, coords.y+1, coords.z, 3374176, false, true)
	ped4 = CreatePed(4, pedModel, coords.x+1, coords.y+1, coords.z, 3374176, false, true)
	ped5 = CreatePed(4, pedModel, coords.x+0.5, coords.y+1, coords.z, 3374176, false, true)
	ped6 = CreatePed(4, pedModel, coords.x+1, coords.y+0.5, coords.z, 3374176, false, true)
	coffin = CreateObject(coffinModel, 1.0, 1.0, 1.0, 1, 1, 0)	
	SetPedState(mainPed);SetPedState(ped);SetPedState(ped2);SetPedState(ped3);SetPedState(ped4)
	PedDancing(ped);PedDancing(ped2);PedDancing(ped3);PedDancing(ped4);PedDancing(ped5);PedDancing(ped6)
	Citizen.Wait(200)
	AttachEntityToEntity(coffin, mainPed, 28422, 0.0, -1.05, 0.95, 1.0, 0.0, -1.4, 1, 1, 0, true, 2, 1)
	AttachEntityToEntity(ped, coffin, 28422, -0.6, -0.75, -0.95, 1.0, 0.0, -1.4, 1, 1, 0, true, 2, 1)
	AttachEntityToEntity(ped2, coffin, 28422, 0.6, 0.75, -0.95, 1.0, 0.0, -1.4, 1, 1, 0, true, 2, 1)
	AttachEntityToEntity(ped3, coffin, 28422, -0.6, 0.75, -0.95, 1.0, 0.0, -1.4, 1, 1, 0, true, 2, 1)
	AttachEntityToEntity(ped4, coffin, 28422, 0.6, -0.75, -0.95, 1.0, 0.0, -1.4, 1, 1, 0, true, 2, 1)	
	AttachEntityToEntity(ped5, coffin, 28422, 0.6, 0.0, -0.95, 1.0, 0.0, -1.4, 1, 1, 0, true, 2, 1)	
	AttachEntityToEntity(ped6, coffin, 28422, -0.6, -0.0, -0.95, 1.0, 0.0, -1.4, 1, 1, 0, true, 2, 1)	
	Wait(1000)
	PedDancing(ped);PedDancing(ped2);PedDancing(ped3);PedDancing(ped4);PedDancing(ped5);PedDancing(ped6)
	if type == "Death" then				
		local coords = GetEntityCoords(playerPed)
		SetEntityCoords(mainPed, coords.x, coords.y, coords.z, 3374176)
		if not Config.MusicEndAutoClear then
			Wait(15000)
			EndCoffinDance()
		end
	end
end

function EndCoffinDance()
	DeleteEntity(coffin)
	DeleteEntity(mainPed);DeleteEntity(ped);DeleteEntity(ped2);DeleteEntity(ped3);DeleteEntity(ped4);DeleteEntity(ped5);DeleteEntity(ped6)
end

function SetPedState(thePed)
	local playerPed = PlayerId()	
	local GroupHandle = GetPlayerGroup(PlayerId())
	SetEntityNoCollisionEntity(thePed, PlayerPedId(), false)
	SetEntityInvincible(thePed, true)
	SetPedCanBeTargetted(thePed, false)
	SetBlockingOfNonTemporaryEvents(thePed, true)
	SetEntityAsMissionEntity(thePed)
	SetPedAsGroupLeader(playerPed, GroupHandle)
	SetPedAsGroupMember(thePed, GroupHandle)	
end

function PedDancing(thePed)
	local aniBase = "anim@amb@casino@mini@dance@dance_solo@female@var_b@"
	local ani = "high_center"
	RequestAnimDict(aniBase)
	while not HasAnimDictLoaded(aniBase) do
		Citizen.Wait(1)
	end		
	TaskPlayAnim(thePed, aniBase, ani, 8.0, 0.0, -1, 1, 0, 0, 0, 0)	
end
