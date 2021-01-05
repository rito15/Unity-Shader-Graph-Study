/**************************************************************************************************
 * Basic Shapes
 **************************************************************************************************/
// 직사각형 : 좌하단, 우상단 정점 좌표
float Rect(float2 uv, float2 p1, float2 p2, float smoothness)
{
    float2 center = (p1 + p2) * 0.5;
    float  width  = (p2.x - p1.x) * 0.5;
    float  height = (p2.y - p1.y) * 0.5;
    
    float rect = smoothstep(width,   width - smoothness, abs(uv.x - center.x)); // 세로
         rect *= smoothstep(height, height - smoothness, abs(uv.y - center.y)); // 가로
    
    return rect;
}

/**************************************************************************************************
 * Digit Debug
 **************************************************************************************************/
// 기본 : 한 칸 채우기
float DigitSquare(float2 uv, float2 center, float unit)
{
    unit *= 0.5;
    float rect = 1.- step(unit + 0.0001, abs(uv.x - center.x));
         rect *= 1.- step(unit + 0.0001, abs(uv.y - center.y));
    return rect;
}

// 점
float DigitDot(float2 uv, float2 pivot, float unit)
{
    return DigitSquare(uv, pivot + unit * 0.5, unit);
}

// 마이너스
float DigitMinus(float2 uv, float2 pivot, float unit)
{
    float2 pivotPoint = pivot + unit * 0.5;
    float m = DigitSquare(uv, pivotPoint + unit * float2(0.0, 2.0), unit) +
              DigitSquare(uv, pivotPoint + unit * float2(1.0, 2.0), unit) +
              DigitSquare(uv, pivotPoint + unit * float2(2.0, 2.0), unit);
    return saturate(m);
}

// 숫자 표현 - pivot : 좌측 하단 기준점, unit : 단위 길이, digit : 정수 1개
float Digit(float2 uv, float2 pivot, float unit, int digit)
{
    float2 pivotPoint = pivot + unit * 0.5;
    
    // Full Rect
    float dgRect = Rect(uv, pivot, pivot + unit * float2(3.0, 5.0), 0.0001);
    
    // Dots
    float dg00 = DigitSquare(uv, pivotPoint, unit);
    float dg01 = DigitSquare(uv, pivotPoint + unit * float2(0.0, 1.0), unit);
    float dg02 = DigitSquare(uv, pivotPoint + unit * float2(0.0, 2.0), unit);
    float dg03 = DigitSquare(uv, pivotPoint + unit * float2(0.0, 3.0), unit);
    float dg04 = DigitSquare(uv, pivotPoint + unit * float2(0.0, 4.0), unit);
    float dg10 = DigitSquare(uv, pivotPoint + unit * float2(1.0, 0.0), unit);
    float dg11 = DigitSquare(uv, pivotPoint + unit * float2(1.0, 1.0), unit);
    float dg12 = DigitSquare(uv, pivotPoint + unit * float2(1.0, 2.0), unit);
    float dg13 = DigitSquare(uv, pivotPoint + unit * float2(1.0, 3.0), unit);
    float dg14 = DigitSquare(uv, pivotPoint + unit * float2(1.0, 4.0), unit);
    float dg20 = DigitSquare(uv, pivotPoint + unit * float2(2.0, 0.0), unit);
    float dg21 = DigitSquare(uv, pivotPoint + unit * float2(2.0, 1.0), unit);
    float dg22 = DigitSquare(uv, pivotPoint + unit * float2(2.0, 2.0), unit);
    float dg23 = DigitSquare(uv, pivotPoint + unit * float2(2.0, 3.0), unit);
    float dg24 = DigitSquare(uv, pivotPoint + unit * float2(2.0, 4.0), unit);
    
    // Digit 0 ~ 9
    float digit0 = dgRect - dg11 - dg12 - dg13;
    float digit1 = dg10 + dg11 + dg12 + dg13 + dg14; //dg20 + dg21 + dg22 + dg23 + dg24;
    float digit2 = dgRect - dg03 - dg11 - dg13 - dg21;
    float digit3 = dgRect - dg01 - dg03 - dg11 - dg13;
    float digit4 = dgRect - dg00 - dg01- dg10 - dg11 - dg13 - dg14;
    
    float digit5 = dgRect - dg01 - dg11 - dg13 - dg23;
    float digit6 = dgRect - dg11 - dg13 - dg23;
    float digit7 = dgRect - dg00 - dg01 - dg10 - dg11- dg12 - dg13;
    float digit8 = dgRect - dg11 - dg13;
    float digit9 = dgRect - dg01 - dg11 - dg13;
    
    switch(digit)
    {
        case 0: return saturate(digit0);
        case 1: return saturate(digit1);
        case 2: return saturate(digit2);
        case 3: return saturate(digit3);
        case 4: return saturate(digit4);
        case 5: return saturate(digit5);
        case 6: return saturate(digit6);
        case 7: return saturate(digit7);
        case 8: return saturate(digit8);
        case 9: return saturate(digit9);
    }
    return 0.;
}

// 대상 숫자 리턴 - unit : 한 칸 단위, value : 대상 값, cipher : 소수부 출력 자릿수
float DebugValue(float2 uv, float2 pos, float unit, float value, int cipher)
{
    uv -= pos;
    
    float digits = 0.; // 결괏값
    float2 cursor = float2(0., 0.);// 현재 커서 위치
    float2 space  = float2(unit * 4., 0.); // 공백
    
    // 음수처리
    if(value < 0.)
    {
     	digits += DigitMinus(uv, cursor, unit);
        cursor += space;
        value = -value;
    }
    
    int   valueN = int(value); 	// 정수부
    float valueF = frac(value); // 소수부
    
    bool printOn = false;
    
    // 정수부가 0일 경우
    if(valueN == 0)
    {
     	digits += Digit(uv, cursor, unit, 0);
        cursor += space;
    }
    else
    {
        // 정수부 출력
        for(int div = 1000000000; div > 0; div /= 10)
        {
            int d = valueN / div;

            if(d > 0 || printOn)
            {
                printOn = true;
                digits += Digit(uv, cursor, unit, d);
                cursor += space;

                valueN -= (d * div);
            }
        }
    }
    
    // 소숫점
    if(cipher > 0)
    {
        digits += DigitDot(uv, cursor, unit);
        cursor += space * 0.5;
    }
    
    // 소수부 출력
    for(int i = 1; i <= cipher; i++)
    {
        int d = int(valueF / 0.1);
        digits += Digit(uv, cursor, unit, d);
        cursor += space;
        valueF = frac(valueF * 10.);
    }
    
    return digits;
}

// override : 소숫점 4자리 표현
void DebugValue_float(float2 uv, float2 pos, float unit, float value, out float digits)
{
 	digits = DebugValue(uv, pos, unit, value, 4);   
}

/*
// Float2 debug
void DebugValue2_float(float2 uv, float2 pos, float unit, float2 value2, out float digits)
{
    // 음수 부호 있는 경우, 양수들만 1칸 우측으로 이동
    float2 m = ceil(step(0., value2));
    
    // 모두 양수인 경우에는 제자리
    if(m == float2(1., 1.))
        m = float2(0.);
    
    digits = DebugValue(uv - float2(m.x * unit * 4., unit * 6.),  pos, unit, value2.x, 4);
    digits += DebugValue(uv - float2(m.y * unit * 4., 0.       ),  pos, unit, value2.y, 4);
}

// Float3 debug with color
float3 DebugValue(float2 uv, float2 pos, float unit, float3 value3)
{
    float3 m = ceil(step(0., value3));
    if(m == float3(1., 1., 1.))
        m = float3(0.);
    
    float digits = DebugValue(uv - float2(m.x * unit * 4., unit * 12.), pos, unit, value3.x, 4);
         digits += DebugValue(uv - float2(m.y * unit * 4., unit * 6.),  pos, unit, value3.y, 4);
         digits += DebugValue(uv - float2(m.z * unit * 4., 0.),         pos, unit, value3.z, 4);
    
    return (saturate(value3) + .1) * digits;
}

// Float4 debug with color
float3 DebugValue(float2 uv, float2 pos, float unit, float4 value4)
{
    float4 m = ceil(step(0., value4));
    if(m == float4(1., 1., 1., 1.))
        m = float4(0.);
    
    float digits = DebugValue(uv - float2(m.x * unit * 4., unit * 18.), pos, unit, value4.x, 4);
         digits += DebugValue(uv - float2(m.y * unit * 4., unit * 12.), pos, unit, value4.y, 4);
         digits += DebugValue(uv - float2(m.z * unit * 4., unit * 6.),  pos, unit, value4.z, 4);
         digits += DebugValue(uv - float2(m.w * unit * 4., 0.),         pos, unit, value4.w, 4);
          
    return value4.rgb * digits;
}
*/