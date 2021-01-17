void AdditionalLights_half(half3 WorldPos, half3 WorldNormal, half3 WorldView, out half3 Diffuse)
{
    half3 diffuseColor = 0;
    
#ifndef SHADERGRAPH_PREVIEW
    WorldNormal = normalize(WorldNormal);
    WorldView = SafeNormalize(WorldView);
    int pixelLightCount = GetAdditionalLightsCount();

    for (int i = 0; i < pixelLightCount; ++i)
    {
        Light light = GetAdditionalLight(i, WorldPos);
        half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
        diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal);
    }
#endif

    Diffuse = diffuseColor;
}