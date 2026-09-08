cbuffer Uniform_Block: register(b0, space1) {
	float4x4 matrix_transform: packoffset(c0);
};

struct Input {
	float3 in_tex_coord: TEXCOORD0;
};

struct Output {
	float3 tex_coord: TEXCOORD0;
	float4 position: SV_Position;
};

Output main(float3 in_tex_coord: TEXCOORD0) {
	Output output;
	output.tex_coord = in_tex_coord;
	output.position  = mul(matrix_transform, float4(in_tex_coord, 1.0));
	return output;
}

#ifdef BREAK_SHADER
choke
#endif
