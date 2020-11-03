float N21(float2 p)
{
    p = frac(p * float2(123.34, 345.45));
    p += dot(p, p + 34.345);
    return frac(p.x * p.y);
}

// 레이어 : 하나의 물방울 효과 UV 세트
float3 Layer(float2 Size, float2 UV, float t)
{
    float2 aspect = float2(2, 1);     // 가로 타일링 2배
    float2 uv = UV * float2(Size.x, Size.y) * aspect;
    uv.y += t * 0.25;

    // UV를 타일링하여, gv는 각각 타일링 된 영역의 uv로 사용
    float2 gv = frac(uv) - 0.5;

    // 각각의 gv 박스에 서로 다른 고윳값 배정
    float2 id = floor(uv);

    // 노이즈(0 ~ 1 범위) => 각각의 gv마다 물방울이 다르게 떨어지도록
    float n = N21(id);
    t += n * 6.2831; // sin 그래프는 2pi 주기이므로 주기별 랜덤 반복

    float w = UV.y * 10;
    float x = (n - 0.5) * 0.6; // -0.3 ~ 0.3 범위 랜덤 값 => 0.4였으나, 잘리는 현상 발견하여 수정
    //x = (0.3 - abs(x));        // 0 ~ 0.3 범위로 조정

    // x : 좌우 offset : sin(3x) * sin(x^6)
    // 불규칙하게 좌우 이동하는 그래프
    x += x * (sin(3 * w) * pow(sin(w), 6) * 0.45);

    // y : 상하 offset : -sin(x + sin(x + sin(x) * 0.5)) * 0.45
    // 내려갈 때는 빠르고 올라갈 때는 느린 그래프
    float y = -sin(t + sin(t + sin(t) * 0.5)) * 0.45;

    // 물방울 하단이 좀더 부드러운 타원꼴을 나타내게 함
    // 각각 -x를 해주는 이유 : x 좌표가 이동해도 형태를 유지하기 위해
    y -= (gv.x - x) * (gv.x - x);

    // gv : 세로로 긴 타원, gv / aspect : 동그란 원
    float2 dropPos = (gv - float2(x, y)) / aspect;
    float drop = smoothstep(0.05, 0.03, length(dropPos));   // 물방울 생성

    float2 trailPos = (gv - float2(x, t * 0.25)) / aspect;
    trailPos.y = (frac(trailPos.y * 8) - 0.5) / 8; // 물방을 궤적들을 y 방향으로 8번 타일링(반복)
    float trail = smoothstep(0.03, 0.01, length(trailPos)); // 물방울 궤적들 그려주기

    float fogTrail = smoothstep(-0.05, 0.05, dropPos.y); // trail이 drop보다 아래 있는 경우는 그리지 않음
    fogTrail *= smoothstep(0.5, y, gv.y);                // trail에 gradient 효과(위에 있을수록 더 희미해지게)
    trail *= fogTrail;

    // 물방울을 따라 물 자국 남기기
    fogTrail *= smoothstep(0.05, 0.04, abs(dropPos.x));

    // Drop + Trail 모두 계산된 결과
    float2 offset = drop * dropPos + trail * trailPos + fogTrail * 0.001;

    return float3(offset, fogTrail);
}

// float2 Size
// float2 UV
// float2 GrabUV : 원래는 grabPass 사용
// float Time
// float _DropSpeed
// float _LayerCount = 3
// float _Blur : (0, 1) = 0.15
// float _BlurResolution = 32
// float _Distortion : (-5, 5) = -5
// float _Brightness : (0, 1) = 0.9
// sampler2D _GrabTexture : OpaqueTexture
void RainyWindow_float(float2 Size, float2 UV, float2 GrabUV, float Time, float _DropSpeed, float _LayerCount, float _Blur, float _BlurResolution,
float _Distortion, float _Brightness, Texture2D _GrabTexture, SamplerState ss, out float4 outColor)
{
    float4 col = 0;
    float t = fmod(Time, 7200); // 2시간마다 반복
    t *= _DropSpeed; // 물방울 떨어지는 속도 계수 곱해주기

    float3 drops = Layer(Size, UV, t);

    for (float num = 1; num < _LayerCount; num++)
    {
        drops += Layer(Size, UV * 1.23 * num, t * (1 + num * 0.2));
    }

    float2 dropOffset = drops.xy;
    float fogTrail = drops.z;

    float fade = 1 - saturate(fwidth(UV) * 100);


    // MipMap을 이용한 블러 효과
    float blur = _Blur * 7 * (1 - fogTrail * fade);

    //col = tex2Dlod(_MainTex, float4(UV + dropOffset * _Distortion, 0, blur));

    float2 projUv = GrabUV;//i.grabUv.xy / i.grabUv.w;
    projUv += dropOffset * (_Distortion * fade); // Grab에 물방울 추가

    blur *= 0.01;

    const float numSamples = _BlurResolution;  // 샘플 개수에 따라 블러 해상도 증가
    float a = N21(UV) * 6.2831; // 회전 시작 값 : 노이즈 기반으로 설정
    for (float num = 0; num < numSamples; num++)
    {
        float2 offs = float2(sin(num), cos(num)) * blur;

        // 거리가 같은 원 위의 지점들로 이동시켜 블러하는 것이 아니라,
        // 랜덤 위치로 텍스쳐를 샘플링시켜 블러 효과 만들기
        float d = frac(sin((num + 1) * 546.0) * 5424.0);
        d = sqrt(d);
        offs *= d;

        //col += tex2D(_GrabTexture, projUv + offs);
        col += SAMPLE_TEXTURE2D(_GrabTexture, ss, projUv + offs);
        a++;
    }
    col /= numSamples;

    outColor = col * _Brightness;
}