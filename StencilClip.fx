
// Pixel shader input structure
struct PS_INPUT {
    float4 Position   : POSITION;
    float2 Texture    : TEXCOORD0;
};

// Pixel shader output structure
struct PS_OUTPUT {
    float4 Color   : COLOR0;
};

struct BYTE {
bool bit0;
bool bit1;
bool bit2;
bool bit3;
bool bit4;
bool bit5;
bool bit6;
bool bit7;
};

BYTE int2BYTE(in int x) {
  BYTE Out;
  Out.bit0 = (x % 2) == 1;
  Out.bit1 = ((x/2) % 2) == 1;
  Out.bit2 = ((x/4) % 2) == 1;
  Out.bit3 = ((x/8) % 2) == 1;
  Out.bit4 = ((x/16) % 2) == 1;
  Out.bit5 = ((x/32) % 2) == 1;
  Out.bit6 = ((x/64) % 2) == 1;
  Out.bit7 = ((x/128) % 2) == 1;
  return Out;
}

int BYTE2int(in BYTE x) {
  int Out = 0;
  if (x.bit0) Out += 1;
  if (x.bit1) Out += 2;
  if (x.bit2) Out += 4;
  if (x.bit3) Out += 8;
  if (x.bit4) Out += 16;
  if (x.bit5) Out += 32;
  if (x.bit6) Out += 64;
  if (x.bit7) Out += 128;
  return Out;
}

BYTE bitwiseOR(in BYTE x, in BYTE y) {
  BYTE Out;
  Out.bit0 = x.bit0 || y.bit0;
  Out.bit1 = x.bit1 || y.bit1;
  Out.bit2 = x.bit2 || y.bit2;
  Out.bit3 = x.bit3 || y.bit3;
  Out.bit4 = x.bit4 || y.bit4;
  Out.bit5 = x.bit5 || y.bit5;
  Out.bit6 = x.bit6 || y.bit6;
  Out.bit7 = x.bit7 || y.bit7;
  return Out;
}

// Global variables
sampler2D Tex0;
sampler2D bgTex : register(s1);

// PS_VARIABLES
float4 stencilColor;
float tolerance;

PS_OUTPUT ps_main( in PS_INPUT In ) {
    // Output pixel
    PS_OUTPUT Out;
    float4 bg = tex2D(bgTex, In.Texture);
    float4 fg = tex2D(Tex0, In.Texture);

    float dist = (bg.r - stencilColor.r) * (bg.r - stencilColor.r) +
                 (bg.g - stencilColor.g) * (bg.g - stencilColor.g) +
                 (bg.b - stencilColor.b) * (bg.b - stencilColor.b);

    Out.Color.rgba = fg.rgba;
    if (dist > tolerance * tolerance)
      Out.Color.rgba = 0.0f;

    return Out;
}

// Effect technique
technique tech_main
{
    pass P0
    {
        // shaders
        VertexShader = NULL;
        PixelShader  = compile ps_2_a ps_main();
    }
}
