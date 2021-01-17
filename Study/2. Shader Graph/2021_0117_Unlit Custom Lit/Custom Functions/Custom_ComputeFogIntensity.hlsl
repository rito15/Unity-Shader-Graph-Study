void ComputeFogIntensity_float(in float fogFactor, out float fogIntensity)
{
    fogIntensity = 1;

#if defined(FOG_EXP)
    fogIntensity = saturate(exp2(-fogFactor));

#elif defined(FOG_EXP2)
    fogIntensity = saturate(exp2(-fogFactor * fogFactor));

#elif defined(FOG_LINEAR)
    fogIntensity = fogFactor;

#endif
}
