--[[Services]]
local StarterPlayer = game:GetService("StarterPlayer").StarterPlayerScripts
local PlayerService = game:GetService("Players")
local RepStore = game:GetService("ReplicatedStorage")
local ServStore = game:GetService("ServerStorage")
local Debris = game:GetService("Debris")
--[[Modules]]
local F = require(RepStore.Modules.Functions)
local Lightning = require(RepStore.ExtModules.LightningBolt)
--[[Folder]]
local FXStorage = ServStore:FindFirstChild("FXStorage")
--[[Info for tweens]]
local FireInfo = {1.5,Enum.EasingStyle.Sine,Enum.EasingDirection.Out}
local TempInfo = {.5,Enum.EasingStyle.Linear,Enum.EasingDirection.Out}


local Library = {}

function Library:BurnEffect(Player,Parent,BurnAmount,Size,Time,AltColor)
	for i = 1,BurnAmount or 15 do
		local Fire = FXStorage.Fire:Clone() do
			Fire.Size *= math.clamp(Size or 2,.5,3)
			Fire.Position = Parent.Position
			Fire.Color = AltColor or Fire.Color
			Fire.Orientation *= math.random(-180,180)
			Fire.Parent = workspace.temp
		end Debris:AddItem(Fire,3)
		
		F:TweenNew(Fire,
			FireInfo,
			{Size = Vector3.new(0,0,0),
				Transparency = 1,
				CFrame = Fire.CFrame * CFrame.fromAxisAngle(Fire.Position,math.rad(math.random(-180,180))),
				Position = Fire.Position + Vector3.new(0,5,0)
			}
		)
		F:TweenNew(Fire,
			FireInfo,
			{Color = Color3.fromRGB(31, 31, 31)
			}
		)
		
		F:yield(Time or .1)
	end
end

function Library.LightningNew(att1,att2,segs,color)
	Lightning.new(att1,att2,segs,color)
end

function Library:Phaser(Parent,Part,Amount,Time,Color)
	
	local model = Instance.new("Model",workspace.temp)
	
	for Phase = 1, Amount or 15 do
		local ClonedPart = Part:Clone() do
			ClonedPart.Anchored = true
			ClonedPart.CanCollide = false
			ClonedPart.Massless = true
			ClonedPart.Material = Enum.Material.Neon
			ClonedPart.Orientation = Parent.Orientation
			ClonedPart.Color = Color or Color3.fromRGB(0,0,0)
			ClonedPart.Parent = model
		end

		F:CoCreate(function()
			
			F:PositionClient(ClonedPart,Parent)

			F:TweenNew(ClonedPart,
				{.1,Enum.EasingStyle.Elastic},
				{Transparency = 0,
				Size = ClonedPart.Size*1.1
				}
			)

			F:yield(.1)
			
			local ranpos = ClonedPart.Position + ClonedPart.CFrame.UpVector*15 + ClonedPart.CFrame.LookVector*-5 + Vector3.new(1,1,1)*math.random(-2,2)

			F:TweenNew(ClonedPart,
				TempInfo,
				{Size = Part.Size*2,
					Transparency = 1,
					Position = ranpos,
					CFrame = ClonedPart.CFrame * CFrame.fromAxisAngle(ranpos,math.rad(math.random(-90,90)))
				}
			)

		end)

		F:yield(.1)

		Debris:AddItem(ClonedPart, Time or 1)

	end
end


return Library
