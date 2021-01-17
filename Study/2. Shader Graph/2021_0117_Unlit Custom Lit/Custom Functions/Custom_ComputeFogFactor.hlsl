void ComputeFogFactor_float(in float z, out float fogFactor)
{
    float clipZ_01 = UNITY_Z_0_FAR_FROM_CLIPSPACE(z);

#if defined(FOG_LINEAR)
    fogFactor = saturate(clipZ_01 * unity_FogParams.z + unity_FogParams.w);

#elif defined(FOG_EXP) || defined(FOG_EXP2)
    fogFactor = (unity_FogParams.x * clipZ_01);

#else
    fogFactor = 0.0h;

#endif
}