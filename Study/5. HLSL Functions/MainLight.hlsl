void GetLightingInformation_float(out float3 Direction, out float3 Color,out float Attenuation)
{
    Light light = GetMainLight();
    Direction = light.direction;
    Attenuation = light.distanceAttenuation;
    Color = light.color;
}