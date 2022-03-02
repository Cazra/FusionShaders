
// Pixel shader input structure
struct PS_INPUT {
    float4 Position   : POSITION;
    float2 Texture    : TEXCOORD0;
};

// Pixel shader output structure
struct PS_OUTPUT {
    float4 Color   : COLOR0;
};

// Global variables
sampler2D Tex0; // Used as backdrop, which is only visible through transparent pixels of srcImage.

// PS_VARIABLES
float4 color;

PS_OUTPUT ps_main( in PS_INPUT In ) {
    // Output pixel
    PS_OUTPUT Out;

    float4 srcColor = tex2D(Tex0, In.Texture);

    Out.Color.rgba = float4(srcColor.r + color.r,
                            srcColor.g + color.g,
                            srcColor.b + color.b,
                            srcColor.a);
    return Out;
}

// Effect technique
technique tech_main {
    pass P0 {
        // shaders
        VertexShader = NULL;
        PixelShader  = compile ps_2_a ps_main();
    }
}
