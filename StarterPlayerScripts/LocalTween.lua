--[[Services]]
local TweenService = game:GetService("TweenService")
local RepStore = game:GetService("ReplicatedStorage")
local PlayerService = game:GetService("Players")
local Serv = require(RepStore.Modules.Functions)
--[[Variables]]
local Player = PlayerService.LocalPlayer
local Relay = RepStore.Events.Relay
local Relay2 = RepStore.Events.Relay2
local Relay3 = RepStore.Events.Relay3
local VSRelay = RepStore.Events.VSRelay
--[[Info]]
local VisualizerInfo = TweenInfo.new(.2,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,true)
local SecondInfo = TweenInfo.new(3,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,-1,true)
local ThirdInfo = TweenInfo.new(.3,Enum.EasingStyle.Linear,Enum.EasingDirection.InOut,0,false)



local function FireBack(State,Client)
	if Client == Player and Client ~= nil then
		Relay:FireServer(Client.Name)
	end
end

local function LocalTween(Object,Info,Changes,Client)
	print("hello")
	local NewInfo = TweenInfo.new(unpack(Info))

	local Effect = TweenService:Create(Object,
		NewInfo,
		Changes
	) Effect:Play()

	Effect.Completed:Connect(function(State)
		FireBack(State,Client)
	end)
end 


local function ClientPart(InstanceProps)
	local self = Instance.new("Part")
	local Parent = InstanceProps.Parent
	InstanceProps["Parent"] = nil
	for Params = 1, #InstanceProps do
		local Var = InstanceProps[Params]
		self[Params] = Var
	end self.Parent = Parent
end 


local function ClientPosition(Part,secndpart)
	Part.Position = secndpart.Position
end 



local function VisualizerTween(SongInst,Parts,Light)
	local Effect,s,nextsize,LightTween,Colors = nil,1,nil
	local part1

	local rot = Vector3.new(math.random(-180,180),math.random(-180,180),math.random(-180,180))

	for _,k in pairs(Parts) do
		k.Orientation = rot
		part1 = k
		local Spin = TweenService:Create(k,
			SecondInfo,
			{
				CFrame = k.CFrame * CFrame.fromAxisAngle(k.Position,math.rad(180))
			}
		)
		Spin:Play()
	end

	while SongInst.Playing do
		s = math.clamp(SongInst.PlaybackLoudness*(math.random(1,7)*0.01),1,2)
		local rand = Vector3.new(math.random(1,2),math.random(1,2),math.random(1,2))*s
		for _,part in pairs(Parts) do
			local NextColor = Color3.new(math.random(0,s),math.random(0,s),math.random(0,s))
			Effect = TweenService:Create(part,
				VisualizerInfo,
				{
					Size = part.Size+rand,

				}
			) Effect:Play()
			
			Colors = TweenService:Create(part,
				ThirdInfo,
				{
					Color = NextColor
				}
			) Colors:Play()

			LightTween = TweenService:Create(Light,
				ThirdInfo,
				{
					Color = NextColor
				}
			) LightTween:Play()
		end 


		Effect.Completed:Wait()
	end
end 
VSRelay.OnClientEvent:Connect(VisualizerTween)



Relay.OnClientEvent:Connect(LocalTween)
Relay2.OnClientEvent:Connect(ClientPart)
Relay3.OnClientEvent:Connect(ClientPosition)