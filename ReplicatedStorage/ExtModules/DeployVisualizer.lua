--[[Services]]
local RepStore = game:GetService("ReplicatedStorage")
local PlayerService = game:GetService("Players")
--[[Templates]]
local VisualizeBlockTemplate = Instance.new("Part") do
	VisualizeBlockTemplate.Size = Vector3.new(2,2,2)
	VisualizeBlockTemplate.Anchored = true
	VisualizeBlockTemplate.CanCollide = false
	VisualizeBlockTemplate.Locked = true
	VisualizeBlockTemplate.Color = Color3.fromRGB(0,0,0)
	VisualizeBlockTemplate.Transparency = .75
	VisualizeBlockTemplate.Material = Enum.Material.Neon
end 

local SubBlock = VisualizeBlockTemplate:Clone() do
	SubBlock.Size = Vector3.new(1,1,1)
	SubBlock.Transparency = .5
end
--[[Variables/Tables/Resources]]
local Modules = RepStore.Modules
local FNS = require(Modules.Functions)
local Relay = RepStore.Events.VSRelay

local function Effects()
	local Fade = VisualizeBlockTemplate:Clone() do
		FNS:TweenNew(Fade,{1,Enum.EasingStyle.Exponential},{Size = Vector3.new(1,1,1)*5})
	end
end


local Visualize = {}

function Visualize.new(parent, songid)
	local Newvisualizer = VisualizeBlockTemplate:Clone() do
		Newvisualizer.Position = parent.HumanoidRootPart.Position + Vector3.new(0,4,0)
		Newvisualizer.Parent = parent
	end
	
	local subbloc = SubBlock:Clone() do
		subbloc.Position = Newvisualizer.Position
		subbloc.Parent = Newvisualizer
	end
	
	local Light = Instance.new("PointLight",Newvisualizer) do
		Light.Range = 90
		Light.Shadows = false
	end
	
	
	local audio = FNS:CreateSFX(
		{
			SoundId = "rbxassetid://"..songid,
			RollOffMaxDistance = 300,
			RollOffMinDistance = 20,
			Parent = Newvisualizer,
			Looped = true,
			Volume = 1
		
		},
		
		nil, 
		false
	) 
	
	
	
	Relay:FireAllClients(audio,{Newvisualizer,subbloc},Light)
	
	PlayerService.PlayerAdded:Connect(function(plr)
		FNS:yield(1)
		Relay:FireClient(plr,audio,{Newvisualizer,subbloc})
	end)
	
	
	return Newvisualizer
end




return Visualize
