#define LIGHTING_DATA
#include "$ENGINE$\ParticleVertex.bslinc"
#include "$ENGINE$\GBufferOutput.bslinc"

shader Surface
{
	mixin ParticleVertex;
	mixin GBufferOutput;

	code
	{
		[alias(gAlbedoTex)]
		SamplerState gAlbedoSamp;
		
		[alias(gNormalTex)]
		SamplerState gNormalSamp;
		
		[alias(gRoughnessTex)]
		SamplerState gRoughnessSamp;
		
		[alias(gMetalnessTex)]
		SamplerState gMetalnessSamp;
	
		[alias(gEmissiveMaskTex)]
		SamplerState gEmissiveMaskSamp;	
		
		Texture2D gAlbedoTex = white;
		Texture2D gNormalTex = normal;
		Texture2D gRoughnessTex = white;
		Texture2D gMetalnessTex = black;
		Texture2D gEmissiveMaskTex = black;
		
		cbuffer MaterialParams
		{
			float2 gUVOffset = { 0.0f, 0.0f };
			float2 gUVTile = { 1.0f, 1.0f };
			[color][hdr]
			float3 gEmissiveColor = { 1.0f, 1.0f, 1.0f };
		};
		
		void fsmain(
			in VStoFS input, 
			out float4 OutSceneColor : SV_Target0,
			out GBufferData OutGBuffer)
		{
			float2 uv = input.uv0 * gUVTile + gUVOffset;
		
			float3 normal = normalize(gNormalTex.Sample(gNormalSamp, uv) * 2.0f - float3(1, 1, 1));
			float3 worldNormal = calcWorldNormal(input, normal);
		
			SurfaceData surfaceData;
			surfaceData.albedo = gAlbedoTex.Sample(gAlbedoSamp, uv);
			surfaceData.worldNormal.xyz = worldNormal;
			surfaceData.roughness = gRoughnessTex.Sample(gRoughnessSamp, uv).x;
			surfaceData.metalness = gMetalnessTex.Sample(gMetalnessSamp, uv).x;
			surfaceData.mask = gLayer;
			surfaceData.velocity = 0.0f; // Note: No velocity for particles yet, but this should be added
			
			OutSceneColor = float4(gEmissiveColor * gEmissiveMaskTex.Sample(gEmissiveMaskSamp, uv).x, 1);
			OutGBuffer = encodeGBuffer(surfaceData);
		}	
	};
};
