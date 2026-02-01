--[[
 .____                  ________ ___.    _____                           __                
 |    |    __ _______   \_____  \\_ |___/ ____\_ __  ______ ____ _____ _/  |_  ___________ 
 |    |   |  |  \__  \   /   |   \| __ \   __\  |  \/  ___// ___\\__  \\   __\/  _ \_  __ \
 |    |___|  |  // __ \_/    |    \ \_\ \  | |  |  /\___ \\  \___ / __ \|  | (  <_> )  | \/
 |_______ \____/(____  /\_______  /___  /__| |____//____  >\___  >____  /__|  \____/|__|   
         \/          \/         \/    \/                \/     \/     \/                   
          \_Welcome to LuaObfuscator.com   (Alpha 0.10.9) ~  Much Love, Ferib 

]]--

local RunService = game:GetService("RunService");
local Players = game:GetService("Players");
local UserInputService = game:GetService("UserInputService");
local Workspace = game:GetService("Workspace");
local LocalPlayer = Players.LocalPlayer;
local Camera = Workspace.CurrentCamera;
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua", true))();
local Settings = {Aimbot=false,WallCheck=true,ESP=false,Fly=false,FlySpeed=40,FOV=80,AimPart="Head"};
local Window = WindUI:CreateWindow({Title="Bulkahackers",Folder="Bulkahackers",Icon="rbxassetid://134384554225463",NewElements=true,HideSearchBar=false,OpenButton={Title="Bulkahackers",CornerRadius=UDim.new(1, 0),StrokeThickness=2.5,Enabled=true,Draggable=true,Scale=0.55,Color=ColorSequence.new(Color3.fromHex("#FF2D55"), Color3.fromHex("#FF5E89"))},Topbar={Height=48,ButtonsType="Mac"}});
local Combat = Window:Tab({Title="Combat",Icon="rbxassetid://120306472146156"});
local Visual = Window:Tab({Title="Visuals",Icon="rbxassetid://119096461016615"});
local Move = Window:Tab({Title="Movement",Icon="rbxassetid://92190299966310"});
local Misc = Window:Tab({Title="Misc"});
Combat:Toggle({Title="Aimbot (hold RMB)",Default=false,Callback=function(v)
	Settings.Aimbot = v;
end});
Combat:Toggle({Title="Wall Check",Default=true,Callback=function(v)
	Settings.WallCheck = v;
end});
Combat:Dropdown({Title="Aim Part",Values={"Head","HumanoidRootPart","UpperTorso","LowerTorso"},Value="Head",Callback=function(v)
	Settings.AimPart = v;
end});
Visual:Toggle({Title="ESP",Default=false,Callback=function(v)
	Settings.ESP = v;
end});
Move:Toggle({Title="Fly",Default=false,Callback=function(v)
	Settings.Fly = v;
end});
Misc:Button({Title="Copy Discord Invite",Callback=function()
	if setclipboard then
		setclipboard("discord.gg/qBA4chAaSq");
		WindUI:Notify({Title="Copied!",Content="discord.gg/qBA4chAaSq",Duration=4});
	end
end});
Misc:Keybind({Title="Toggle UI",Value="RightShift",Callback=function()
	Window:Toggle();
end});
local fovCircle = Drawing.new("Circle");
fovCircle.Thickness = 2;
fovCircle.NumSides = 60;
fovCircle.Color = Color3.fromRGB(255, 80, 120);
fovCircle.Transparency = 0.7;
fovCircle.Filled = false;
local function isVisible(part)
	if not Settings.WallCheck then
		return true;
	end
	local rayParams = RaycastParams.new();
	rayParams.FilterDescendantsInstances = {(LocalPlayer.Character or {})};
	rayParams.FilterType = Enum.RaycastFilterType.Exclude;
	local dir = (part.Position - Camera.CFrame.Position).Unit * 5000;
	local result = Workspace:Raycast(Camera.CFrame.Position, dir, rayParams);
	return (result == nil) or result.Instance:IsDescendantOf(part.Parent);
end
RunService.RenderStepped:Connect(function()
	fovCircle.Position = UserInputService:GetMouseLocation();
	fovCircle.Radius = Settings.FOV;
	fovCircle.Visible = Settings.Aimbot;
	if (Settings.Aimbot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)) then
		local closest, minDist = nil, Settings.FOV + 1;
		for _, p in Players:GetPlayers() do
			if ((p == LocalPlayer) or not p.Character or not p.Character:FindFirstChild(Settings.AimPart)) then
				continue;
			end
			local part = p.Character[Settings.AimPart];
			local screen, onScreen = Camera:WorldToViewportPoint(part.Position);
			if onScreen then
				local dist = (Vector2.new(screen.X, screen.Y) - fovCircle.Position).Magnitude;
				if ((dist < minDist) and isVisible(part)) then
					minDist = dist;
					closest = part;
				end
			end
		end
		if closest then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position);
		end
	end
end);
local ESP_Data = {};
local function CleanupESP(player)
	if ESP_Data[player] then
		if ESP_Data[player].highlight then
			pcall(function()
				ESP_Data[player].highlight:Destroy();
			end);
		end
		if ESP_Data[player].billboard then
			pcall(function()
				ESP_Data[player].billboard:Destroy();
			end);
		end
		if ESP_Data[player].connection then
			ESP_Data[player].connection:Disconnect();
		end
		ESP_Data[player] = nil;
	end
end
local function CreateOrUpdateESP(player)
	if (player == LocalPlayer) then
		return;
	end
	CleanupESP(player);
	local char = player.Character or player.CharacterAdded:Wait();
	if not char then
		return;
	end
	local root = char:WaitForChild("HumanoidRootPart", 8);
	local head = char:WaitForChild("Head", 8);
	local hum = char:WaitForChild("Humanoid", 8);
	if not (root and head and hum) then
		return;
	end
	local hl = Instance.new("Highlight");
	hl.Name = "BulkESP";
	hl.FillColor = Color3.fromRGB(255, 80, 120);
	hl.OutlineColor = Color3.fromRGB(255, 220, 220);
	hl.FillTransparency = 0.65;
	hl.OutlineTransparency = 0.2;
	hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop;
	hl.Adornee = char;
	hl.Parent = char;
	local bb = Instance.new("BillboardGui");
	bb.Name = "BulkInfo";
	bb.Adornee = head;
	bb.Size = UDim2.new(0, 160, 0, 60);
	bb.StudsOffset = Vector3.new(0, 3.5, 0);
	bb.AlwaysOnTop = true;
	bb.Parent = head;
	local nameLbl = Instance.new("TextLabel", bb);
	nameLbl.Size = UDim2.new(1, 0, 0.35, 0);
	nameLbl.BackgroundTransparency = 1;
	nameLbl.TextColor3 = Color3.new(1, 1, 1);
	nameLbl.TextStrokeTransparency = 0.6;
	nameLbl.TextScaled = true;
	nameLbl.Font = Enum.Font.SourceSansBold;
	nameLbl.Text = player.Name;
	local healthLbl = Instance.new("TextLabel", bb);
	healthLbl.Size = UDim2.new(1, 0, 0.35, 0);
	healthLbl.Position = UDim2.new(0, 0, 0.35, 0);
	healthLbl.BackgroundTransparency = 1;
	healthLbl.TextColor3 = Color3.new(0, 1, 0);
	healthLbl.TextStrokeTransparency = 0.7;
	healthLbl.TextScaled = true;
	healthLbl.Text = "HP: ???";
	local distLbl = Instance.new("TextLabel", bb);
	distLbl.Size = UDim2.new(1, 0, 0.3, 0);
	distLbl.Position = UDim2.new(0, 0, 0.7, 0);
	distLbl.BackgroundTransparency = 1;
	distLbl.TextColor3 = Color3.new(0.9, 0.9, 0.9);
	distLbl.TextStrokeTransparency = 0.7;
	distLbl.TextScaled = true;
	distLbl.Text = "?? studs";
	ESP_Data[player] = {highlight=hl,billboard=bb,healthLabel=healthLbl,distLabel=distLbl,connection=nil};
	local conn = RunService.Heartbeat:Connect(function()
		if (not Settings.ESP or not bb.Parent or not hum.Parent) then
			CleanupESP(player);
			return;
		end
		local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1);
		healthLbl.Text = "HP: " .. math.floor(hum.Health) .. " (" .. math.floor(pct * 100) .. "%)";
		healthLbl.TextColor3 = Color3.fromHSV(pct * 0.3, 0.9, 1);
		local dist = "??";
		if (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then
			dist = math.floor((root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude);
		end
		distLbl.Text = dist .. " studs";
	end);
	ESP_Data[player].connection = conn;
end
local function RefreshESP()
	if not Settings.ESP then
		for player in pairs(ESP_Data) do
			CleanupESP(player);
		end
		return;
	end
	for _, player in Players:GetPlayers() do
		if player.Character then
			CreateOrUpdateESP(player);
		end
	end
end
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		if Settings.ESP then
			task.delay(0.3, function()
				CreateOrUpdateESP(player);
			end);
		end
	end);
end);
Players.PlayerRemoving:Connect(CleanupESP);
task.spawn(function()
	while true do
		RefreshESP();
		task.wait(0.5);
	end
end);
RunService.RenderStepped:Connect(function()
	if (not Settings.Fly or not LocalPlayer.Character) then
		return;
	end
	local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart");
	if not hrp then
		return;
	end
	local move = Vector3.new();
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then
		move += Camera.CFrame.LookVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then
		move -= Camera.CFrame.LookVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then
		move -= Camera.CFrame.RightVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then
		move += Camera.CFrame.RightVector
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
		move += Vector3.new(0, 1, 0)
	end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
		move -= Vector3.new(0, 1, 0)
	end
	if (move.Magnitude > 0) then
		hrp.Velocity = move.Unit * Settings.FlySpeed * 6;
	else
		hrp.Velocity = Vector3.new();
	end
end);
WindUI:Notify({Title="Bulkahackers",Content="Loaded • Aimbot FOV now smaller (80)",Duration=5});
print("Bulkahackers loaded!");
