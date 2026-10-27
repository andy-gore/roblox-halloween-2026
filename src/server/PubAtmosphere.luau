--!strict
-- Applied only in the temporary greybox Play datamodel; Stop restores Studio lighting.
local Atmosphere = {}
function Atmosphere.apply()
    local lighting = game:GetService("Lighting")
    lighting.ClockTime, lighting.Brightness = 21, 2
    lighting.Ambient = Color3.fromRGB(63, 55, 75)
    lighting.OutdoorAmbient = Color3.fromRGB(63, 72, 105)
    lighting.ExposureCompensation = -0.05
    lighting.GlobalShadows = true
    lighting.FogColor = Color3.fromRGB(34, 38, 61)
    lighting.FogStart, lighting.FogEnd = 100, 350
    local grade = Instance.new("ColorCorrectionEffect")
    grade.Name = "LastOrdersGothicGrade"
    grade.Contrast, grade.Saturation = 0.1, -0.12
    grade.TintColor = Color3.fromRGB(255, 240, 227)
    grade.Parent = lighting
    local bloom = Instance.new("BloomEffect")
    bloom.Name = "LastOrdersCandleBloom"
    bloom.Intensity, bloom.Size, bloom.Threshold = 0.18, 16, 1.8
    bloom.Parent = lighting
end
return Atmosphere
