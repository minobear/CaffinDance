local isDead = false
local commState = false

if Config.EnableCommand then
	RegisterCommand("coffindance", function(source, args, rawCommand)
		if not commState then
			commState = true
			if Config.PlayMusic then
				if Config.PlayMusicOnlyOnSelf then
					TriggerServerEvent('InteractSound_SV:PlayOnSource', 'CoffinDance', 0.2)
				else
					TriggerServerEvent('InteractSound_SV:PlayWithinDistance', Config.PlayMusicDistance, 'CoffinDance', 0.2)
				end
			end				
			StartCoffinDance("Command")					
		else
			commState = false
			TriggerServerEvent("CoffinDance:syncEndCoffinDance", globalCoffNet, globalPedNet, globalPedNet2, globalPedNet3, globalPedNet4, globalPedNet5, globalPedNet6, globalMainPed)
		end
	end, false)
end


Citizen.CreateThread(function()
	if Config.StartWhenDeath then
		while true do
		Wait(500)		
			if (not isDead and NetworkIsPlayerActive(PlayerId()) and IsPedFatallyInjured(PlayerPedId())) then	
				isDead = true
				if Config.PlayMusic then
					if Config.PlayMusicOnlyOnSelf then
						TriggerServerEvent('InteractSound_SV:PlayOnSource', 'CoffinDance', 0.2)
					else
						TriggerServerEvent('InteractSound_SV:PlayWithinDistance', Config.PlayMusicDistance, 'CoffinDance', 0.2)
					end
				end						
				StartCoffinDance("Death")			
			elseif (isDead and NetworkIsPlayerActive(PlayerId()) and not IsPedFatallyInjured(PlayerPedId())) and not Config.AutoClearWhenMusicEnd then
				isDead = false	
				if not Config.AutoClearWhenMusicEnd then
					TriggerServerEvent("CoffinDance:syncEndCoffinDance", globalCoffNet, globalPedNet, globalPedNet2, globalPedNet3, globalPedNet4, globalPedNet5, globalPedNet6, globalMainPed)		
				end
			end
		end
	end
end)

function StartCoffinDance(type)	
	local playerPed = PlayerPedId()
	local coords = GetEntityCoords(playerPed)
	local coffinModel = GetHashKey(Config.CoffinModel)
	local pedModel = GetHashKey(Config.DancerPedModel)
	local coffinObj = CreateObject(coffinModel, 1.0, 1.0, 1.0, 1, 1, 0)
	if type == "Death" then
		Wait(1000)
		mainPedObj = CreatePed(4, pedModel, coords.x, coords.y, coords.z, 3374176, true, false)
	else
		mainPedObj = CreatePed(4, pedModel, coords.x+1.0, coords.y, coords.z, 3374176, true, false)
	end		
	local pedObj = CreatePed(4, pedModel, coords.x+1.0, coords.y, coords.z, 3374176, true, false)
	local pedObj2 = CreatePed(4, pedModel, coords.x+1, coords.y-1, coords.z, 3374176, true, false)
	local pedObj3 = CreatePed(4, pedModel, coords.x-1, coords.y+1, coords.z, 3374176, true, false)
	local pedObj4 = CreatePed(4, pedModel, coords.x+1, coords.y+1, coords.z, 3374176, true, false)
	local pedObj5 = CreatePed(4, pedModel, coords.x+0.5, coords.y+1, coords.z, 3374176, true, false)
	local pedObj6 = CreatePed(4, pedModel, coords.x+1, coords.y+0.5, coords.z, 3374176, true, false)	
	local pedNet = PedToNet(pedObj);local pedNet2 = PedToNet(pedObj2);local pedNet3 = PedToNet(pedObj3)
	local pedNet4 = PedToNet(pedObj4);local pedNet5 = PedToNet(pedObj5);local pedNet6 = PedToNet(pedObj6)
	local mainPedNet = PedToNet(mainPedObj)
	local coffNet = ObjToNet(coffinObj)
	TriggerServerEvent("CoffinDance:syncSpawnPeds", coords, type, coffNet, pedNet, pedNet2, pedNet3, pedNet4, pedNet5, pedNet6, mainPedNet)	
end

RegisterNetEvent('CoffinDance:SpawnPeds')
AddEventHandler('CoffinDance:SpawnPeds', function(coords, type, coffNet, pedNet, pedNet2, pedNet3, pedNet4, pedNet5, pedNet6, mainPedNet)
	local playerPed = PlayerPedId()
	local myCoords = GetEntityCoords(playerPed)
	if Vdist(coords.x, coords.y, coords.z, myCoords.x, myCoords.y, myCoords.z) < 30.0 then
		local playerPed = PlayerPedId()		
		local pedModel = GetHashKey(Config.DancerPedModel)
		local coffinModel = GetHashKey(Config.CoffinModel)		
		RequestModel(coffinModel)
		while not HasModelLoaded(coffinModel) do
			Citizen.Wait(1)
		end		
		RequestModel(pedModel)
		while not HasModelLoaded(pedModel) do
			Citizen.Wait(1)
		end		
		globalCoffNet = coffNet; globalPedNet = pedNet; globalPedNet2 = pedNet2; globalPedNet3 = pedNet3; globalPedNet4 = pedNet4; globalPedNet5 = pedNet5; globalPedNet6 = pedNet6
		globalMainPed = mainPedNet
		coffin = NetToObj(globalCoffNet)
		ped = NetToPed(globalPedNet); ped2 = NetToPed(globalPedNet2); ped3 = NetToPed(globalPedNet3); ped4 = NetToPed(globalPedNet4); ped5 = NetToPed(globalPedNet5); ped6 = NetToPed(globalPedNet6)				
		mainPed = NetToPed(globalMainPed)
		SetEntityVisible(mainPed, false, false)
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
			if Config.AutoClearWhenMusicEnd then
				Wait(15000)
				TriggerServerEvent("CoffinDance:syncEndCoffinDance", globalCoffNet, globalPedNet, globalPedNet2, globalPedNet3, globalPedNet4, globalPedNet5, globalPedNet6, globalMainPed)
			end
		end		
	end
end)

RegisterNetEvent('CoffinDance:endCoffinDance')
AddEventHandler('CoffinDance:endCoffinDance', function(coffNet, pedNet, pedNet2, pedNet3, pedNet4, pedNet5, pedNet6, mainPedNet)
	local playerPed = PlayerPedId()
	local myCoords = GetEntityCoords(playerPed)
	local coffinObj = NetToObj(coffNet)
	local pedObj = NetToPed(pedNet); local pedObj2 = NetToPed(pedNet2); local pedObj3 = NetToPed(pedNet3); local pedObj4 = NetToPed(pedNet4); local pedObj5 = NetToPed(pedNet5); local pedObj6 = NetToPed(pedNet6)		
	local mainPedObj = NetToPed(mainPedNet)	
	DeleteEntity(coffinObj)
	DeleteEntity(mainPedObj);DeleteEntity(pedObj);DeleteEntity(pedObj2);DeleteEntity(pedObj3);DeleteEntity(pedObj4);DeleteEntity(pedObj5);DeleteEntity(pedObj6)	
end)

function SetPedState(thePed)
	local playerPed = PlayerId()	
	local GroupHandle = GetPlayerGroup(PlayerId())
	SetEntityNoCollisionEntity(thePed, PlayerPedId())
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
