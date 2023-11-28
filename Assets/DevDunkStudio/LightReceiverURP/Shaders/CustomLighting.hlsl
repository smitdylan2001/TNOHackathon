#ifndef CUSTOM_LIGHTING_INCLUDED
#define CUSTOM_LIGHTING_INCLUDED

// @Cyanilux | https://github.com/Cyanilux/URP_ShaderGraphCustomLighting
// Note this version of the package assumes v12+ due to usage of "Branch on Input Connection" node
// For older versions, see branches on github repo!

#ifndef SHADERGRAPH_PREVIEW
	#if UNITY_VERSION < 202220
	/*
	GetMeshRenderingLayer() is only available in 2022.2+
	Previous versions need to use GetMeshRenderingLightLayer()
	*/
	uint GetMeshRenderingLayer(){
		return GetMeshRenderingLightLayer();
	}
	#endif
#endif

/*
- Handles additional lights (e.g. additional directional, point, spotlights)
- For custom lighting, you may want to duplicate this and swap the LightingLambert / LightingSpecular functions out. See Toon Example below!
- To work in the Unlit Graph, the following keywords must be defined in the blackboard :
	- Boolean Keyword, Global Multi-Compile "_ADDITIONAL_LIGHT_SHADOWS"
	- Boolean Keyword, Global Multi-Compile "_ADDITIONAL_LIGHTS"
- To support Forward+ path,
	- Boolean Keyword, Global Multi-Compile "_FORWARD_PLUS" (2022.2+)
*/
void AdditionalLights_float(float3 SpecColor, float Smoothness, float3 WorldPosition, float3 WorldNormal, float3 WorldView, half4 Shadowmask, bool UseMainLight,
							out float3 Diffuse, out float3 Specular) {
	float3 diffuseColor = 0;
	float3 specularColor = 0;
#ifndef SHADERGRAPH_PREVIEW
	float NewSmoothness = exp2(10 * Smoothness + 1);
	uint pixelLightCount = GetAdditionalLightsCount();
	uint meshRenderingLayers = GetMeshRenderingLayer();

	#if USE_FORWARD_PLUS
	for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++) {
		FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK
		Light light = GetAdditionalLight(lightIndex, WorldPosition, Shadowmask);
	#ifdef _LIGHT_LAYERS
		if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
	#endif
		{
		//PBR Estimate
			float3 attenuatedLightColor = light.color * (light.distanceAttenuation); 
			diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal); 
			specularColor += LightingSpecular(attenuatedLightColor, light.direction, WorldNormal, WorldView, float4(SpecColor, 0), NewSmoothness);
		}
	}
	#endif

	// For Foward+ the LIGHT_LOOP_BEGIN macro will use inputData.normalizedScreenSpaceUV, inputData.positionWS, so create that:
	InputData inputData = (InputData)0;
	float4 screenPos = ComputeScreenPos(TransformWorldToHClip(WorldPosition));
	inputData.normalizedScreenSpaceUV = screenPos.xy / screenPos.w;
	inputData.positionWS = WorldPosition;

	if(UseMainLight){
		Light mainLight = GetMainLight();
		// Blinn-Phong
		float3 attenuatedLightColor = mainLight.color * (mainLight.distanceAttenuation);
		specularColor += LightingSpecular(attenuatedLightColor, mainLight.direction, WorldNormal, WorldView, float4(SpecColor, 0), NewSmoothness);
		specularColor *= Smoothness;
	}

	LIGHT_LOOP_BEGIN(pixelLightCount)
		Light light = GetAdditionalLight(lightIndex, WorldPosition, Shadowmask);
	#ifdef _LIGHT_LAYERS
		if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
	#endif
		{
			//PBR Estimate
			float3 attenuatedLightColor = light.color * (light.distanceAttenuation);
			diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal);
			specularColor += LightingSpecular(attenuatedLightColor, light.direction, WorldNormal, WorldView, float4(SpecColor, 0), NewSmoothness);
		}
	LIGHT_LOOP_END
#endif

	Diffuse = diffuseColor;
	Specular = specularColor;
}

void AdditionalLights_half(half3 SpecColor, half Smoothness, half3 WorldPosition, half3 WorldNormal, half3 WorldView, half4 Shadowmask, bool UseMainLight,
							out half3 Diffuse, out half3 Specular) {
	half3 diffuseColor = 0;
	half3 specularColor = 0;
#ifndef SHADERGRAPH_PREVIEW
	half NewSmoothness = exp2(10 * Smoothness + 1);
	uint pixelLightCount = GetAdditionalLightsCount();
	uint meshRenderingLayers = GetMeshRenderingLayer();

	#if USE_FORWARD_PLUS
	for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++) {
		FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK
		Light light = GetAdditionalLight(lightIndex, WorldPosition, Shadowmask);
	#ifdef _LIGHT_LAYERS
		if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
	#endif
		{
			// BRP estimate
			half3 attenuatedLightColor = light.color * (light.distanceAttenuation); 
			diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal); 
			specularColor += LightingSpecular(attenuatedLightColor, light.direction, WorldNormal, WorldView, half4(SpecColor, 0), NewSmoothness);
		}
	}
	#endif

	// For Foward+ the LIGHT_LOOP_BEGIN macro will use inputData.normalizedScreenSpaceUV, inputData.positionWS, so create that:
	InputData inputData = (InputData)0;
	half4 screenPos = ComputeScreenPos(TransformWorldToHClip(WorldPosition));
	inputData.normalizedScreenSpaceUV = screenPos.xy / screenPos.w;
	inputData.positionWS = WorldPosition;

	if(UseMainLight){
		Light mainLight = GetMainLight();
		half3 attenuatedLightColor = mainLight.color * (mainLight.distanceAttenuation);
		specularColor += LightingSpecular(attenuatedLightColor, mainLight.direction, WorldNormal, WorldView, half4(SpecColor, 0), NewSmoothness);
		specularColor *= Smoothness;
	}
	

	LIGHT_LOOP_BEGIN(pixelLightCount)
		Light light = GetAdditionalLight(lightIndex, WorldPosition, Shadowmask);
	#ifdef _LIGHT_LAYERS
		if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
	#endif
		{
			// BRP estimate
			half3 attenuatedLightColor = light.color.rgb * (light.distanceAttenuation); 
			diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal);
			specularColor += LightingSpecular(attenuatedLightColor, light.direction, WorldNormal, WorldView, half4(SpecColor, 0), NewSmoothness);
		}
	LIGHT_LOOP_END
#endif

	Diffuse = diffuseColor;
	Specular = specularColor;
}

void AdditionalLightsNoSpecular_float(float3 WorldPosition, float3 WorldNormal, half4 Shadowmask,
							out float3 Diffuse) {
	float3 diffuseColor = 0;
	float3 specularColor = 0;
#ifndef SHADERGRAPH_PREVIEW
	uint pixelLightCount = GetAdditionalLightsCount();
	uint meshRenderingLayers = GetMeshRenderingLayer();

	#if USE_FORWARD_PLUS
	for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++) {
		FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK
		Light light = GetAdditionalLight(lightIndex, WorldPosition, Shadowmask);
	#ifdef _LIGHT_LAYERS
		if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
	#endif
		{
		//PBR Estimate
			half3 attenuatedLightColor = light.color * (light.distanceAttenuation); 
			diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal);
		}
	}
	#endif

	// For Foward+ the LIGHT_LOOP_BEGIN macro will use inputData.normalizedScreenSpaceUV, inputData.positionWS, so create that:
	InputData inputData = (InputData)0;
	float4 screenPos = ComputeScreenPos(TransformWorldToHClip(WorldPosition));
	inputData.normalizedScreenSpaceUV = screenPos.xy / screenPos.w;
	inputData.positionWS = WorldPosition;

	LIGHT_LOOP_BEGIN(pixelLightCount)
		Light light = GetAdditionalLight(lightIndex, WorldPosition, Shadowmask);
	#ifdef _LIGHT_LAYERS
		if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
	#endif
		{
			//PBR Estimate
			half3 attenuatedLightColor = light.color * (light.distanceAttenuation); 
			diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal);
		}
	LIGHT_LOOP_END
#endif

	Diffuse = diffuseColor;
}

void AdditionalLightsNoSpecular_half(half3 WorldPosition, half3 WorldNormal, half4 Shadowmask,
							out half3 Diffuse) {
	half3 diffuseColor = 0;
	half3 specularColor = 0;
#ifndef SHADERGRAPH_PREVIEW
	uint pixelLightCount = GetAdditionalLightsCount();
	uint meshRenderingLayers = GetMeshRenderingLayer();

	#if USE_FORWARD_PLUS
	for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++) {
		FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK
		Light light = GetAdditionalLight(lightIndex, WorldPosition, Shadowmask);
	#ifdef _LIGHT_LAYERS
		if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
	#endif
		{
			// BRP estimate
			half3 attenuatedLightColor = light.color * (light.distanceAttenuation); 
			diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal); 
		}
	}
	#endif

	// For Foward+ the LIGHT_LOOP_BEGIN macro will use inputData.normalizedScreenSpaceUV, inputData.positionWS, so create that:
	InputData inputData = (InputData)0;
	half4 screenPos = ComputeScreenPos(TransformWorldToHClip(WorldPosition));
	inputData.normalizedScreenSpaceUV = screenPos.xy / screenPos.w;
	inputData.positionWS = WorldPosition;

	LIGHT_LOOP_BEGIN(pixelLightCount)
		Light light = GetAdditionalLight(lightIndex, WorldPosition, Shadowmask);
	#ifdef _LIGHT_LAYERS
		if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
	#endif
		{
			// BRP estimate
			half3 attenuatedLightColor = light.color * (light.distanceAttenuation); 
			diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal); 
			
		}
	LIGHT_LOOP_END
#endif

	Diffuse = diffuseColor;
}

void AdditionalLightsAndShadow_float(float3 SpecColor, float Smoothness, float3 WorldPosition, float3 WorldNormal, float3 WorldView, half4 Shadowmask, bool UseMainLight,
							out float3 Diffuse, out float3 Specular, out float3 MainSpecular, out float ShadowAtten, out float mainLightShadowAtten) {
	float3 diffuseColor = 0;
	float3 specularColor = 0;
	MainSpecular = 0;
	mainLightShadowAtten = 0;
	ShadowAtten = 1;
#ifndef SHADERGRAPH_PREVIEW
	float NewSmoothness = exp2(10 * Smoothness + 1);
	uint pixelLightCount = GetAdditionalLightsCount();
	uint meshRenderingLayers = GetMeshRenderingLayer();

	#if USE_FORWARD_PLUS
	for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++) {
		FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK
		Light light = GetAdditionalLight(lightIndex, WorldPosition, Shadowmask);
	#ifdef _LIGHT_LAYERS
		if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
	#endif
		{
		//PBR Estimate
			float3 attenuatedLightColor = light.color.rgb * (light.distanceAttenuation); 
			diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal);
			specularColor += LightingSpecular(attenuatedLightColor, light.direction, WorldNormal, WorldView, float4(SpecColor, 0), NewSmoothness);
			if(light.distanceAttenuation != 0 && dot(WorldNormal,_AdditionalLightsPosition[lightIndex].xyz) > 0)
			{
				ShadowAtten *= light.shadowAttenuation;
			}
		}
	}
	#endif

	if(UseMainLight){
		Light mainLight = GetMainLight();
		// Blinn-Phong
		float3 attenuatedLightColor = mainLight.color * (mainLight.distanceAttenuation);
		MainSpecular += LightingSpecular(attenuatedLightColor, mainLight.direction, WorldNormal, WorldView, float4(SpecColor, 0), NewSmoothness);
		specularColor *= Smoothness;
	}

	#if defined(_MAIN_LIGHT_SHADOWS_SCREEN) && !defined(_SURFACE_TYPE_TRANSPARENT)
			float4 shadowCoord = ComputeScreenPos(TransformWorldToHClip(WorldPosition));
		#else
			float4 shadowCoord = TransformWorldToShadowCoord(WorldPosition);
		#endif		
		   
		#if VERSION_GREATER_EQUAL(10, 1)
			mainLightShadowAtten = MainLightShadow(shadowCoord, WorldPosition, half4(1,1,1,1), _MainLightOcclusionProbes);
		#else
			mainLightShadowAtten = MainLightRealtimeShadow(shadowCoord);
		#endif

	// For Foward+ the LIGHT_LOOP_BEGIN macro will use inputData.normalizedScreenSpaceUV, inputData.positionWS, so create that:
	InputData inputData = (InputData)0;
	float4 screenPos = ComputeScreenPos(TransformWorldToHClip(WorldPosition));
	inputData.normalizedScreenSpaceUV = screenPos.xy / screenPos.w;
	inputData.positionWS = WorldPosition;

	LIGHT_LOOP_BEGIN(pixelLightCount)
		Light light = GetAdditionalLight(lightIndex, WorldPosition, Shadowmask);
	#ifdef _LIGHT_LAYERS
		if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
	#endif
		{
			//PBR Estimate
			float3 attenuatedLightColor = light.color.rgb * (light.distanceAttenuation);
			diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal);
			specularColor += LightingSpecular(attenuatedLightColor, light.direction, WorldNormal, WorldView, float4(SpecColor, 0), NewSmoothness);
			if(light.distanceAttenuation != 0 && dot(WorldNormal,_AdditionalLightsPosition[lightIndex].xyz) > 0)
			{
				ShadowAtten *= light.shadowAttenuation;
			}
		}
	LIGHT_LOOP_END
#endif

	Diffuse = diffuseColor;
	Specular = specularColor;
}

void AdditionalLightsAndShadow_half(half3 SpecColor, half Smoothness, half3 WorldPosition, half3 WorldNormal, half3 WorldView, half4 Shadowmask, bool UseMainLight,
							out half3 Diffuse, out half3 Specular, out float3 MainSpecular,  out half ShadowAtten, out half mainLightShadowAtten) {
	half3 diffuseColor = 0;
	half3 specularColor = 0;
	MainSpecular = 0;
	mainLightShadowAtten = 0;
	ShadowAtten = 1;
#ifndef SHADERGRAPH_PREVIEW
	half NewSmoothness = exp2(10 * Smoothness + 1);
	uint pixelLightCount = GetAdditionalLightsCount();
	uint meshRenderingLayers = GetMeshRenderingLayer();

	#if USE_FORWARD_PLUS
	for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++) {
		FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK
		Light light = GetAdditionalLight(lightIndex, WorldPosition, Shadowmask);
	#ifdef _LIGHT_LAYERS
		if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
	#endif
		{
		//PBR Estimate
			half3 attenuatedLightColor = light.color.rgb * (light.distanceAttenuation); 
			diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal);
			specularColor += LightingSpecular(attenuatedLightColor, light.direction, WorldNormal, WorldView, half4(SpecColor, 0), NewSmoothness);
			if(light.distanceAttenuation != 0 && dot(WorldNormal,_AdditionalLightsPosition[lightIndex].xyz) > 0)
			{
				ShadowAtten *= light.shadowAttenuation;
			}
		}
	}
	#endif

	if(UseMainLight){
		Light mainLight = GetMainLight();
		// Blinn-Phong
		float3 attenuatedLightColor = mainLight.color * (mainLight.distanceAttenuation);
		MainSpecular += LightingSpecular(attenuatedLightColor, mainLight.direction, WorldNormal, WorldView, float4(SpecColor, 0), NewSmoothness);
		MainSpecular *= Smoothness;
	}

	#if defined(_MAIN_LIGHT_SHADOWS_SCREEN) && !defined(_SURFACE_TYPE_TRANSPARENT)
			half4 shadowCoord = ComputeScreenPos(TransformWorldToHClip(WorldPosition));
		#else
			half4 shadowCoord = TransformWorldToShadowCoord(WorldPosition);
		#endif		
		   
		#if VERSION_GREATER_EQUAL(10, 1)
			mainLightShadowAtten = MainLightShadow(shadowCoord, WorldPosition, half4(1,1,1,1), _MainLightOcclusionProbes);
		#else
			mainLightShadowAtten = MainLightRealtimeShadow(shadowCoord);
		#endif

	// For Foward+ the LIGHT_LOOP_BEGIN macro will use inputData.normalizedScreenSpaceUV, inputData.positionWS, so create that:
	InputData inputData = (InputData)0;
	half4 screenPos = ComputeScreenPos(TransformWorldToHClip(WorldPosition));
	inputData.normalizedScreenSpaceUV = screenPos.xy / screenPos.w;
	inputData.positionWS = WorldPosition;

	LIGHT_LOOP_BEGIN(pixelLightCount)
		Light light = GetAdditionalLight(lightIndex, WorldPosition, Shadowmask);
	#ifdef _LIGHT_LAYERS
		if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
	#endif
		{
			//PBR Estimate
			half3 attenuatedLightColor = light.color.rgb * (light.distanceAttenuation);
			diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal);
			specularColor += LightingSpecular(attenuatedLightColor, light.direction, WorldNormal, WorldView, half4(SpecColor, 0), NewSmoothness);
			if(light.distanceAttenuation != 0 && dot(WorldNormal,_AdditionalLightsPosition[lightIndex].xyz) > 0)
			{
				ShadowAtten *= light.shadowAttenuation;
			}
		}
	LIGHT_LOOP_END
#endif

	Diffuse = diffuseColor;
	Specular = specularColor;
}

void AdditionalLightsAndShadowNoSpecular_float(float3 WorldPosition, float3 WorldNormal, half4 Shadowmask,
							out float3 Diffuse, out float ShadowAtten, out float mainLightShadowAtten) {
	float3 diffuseColor = 0;
	mainLightShadowAtten = 0;
	ShadowAtten = 1;
#ifndef SHADERGRAPH_PREVIEW
	uint pixelLightCount = GetAdditionalLightsCount();
	uint meshRenderingLayers = GetMeshRenderingLayer();

	#if USE_FORWARD_PLUS
	for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++) {
		FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK
		Light light = GetAdditionalLight(lightIndex, WorldPosition, Shadowmask);
	#ifdef _LIGHT_LAYERS
		if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
	#endif
		{
		//PBR Estimate
			float3 attenuatedLightColor = light.color.rgb * (light.distanceAttenuation); 
			diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal);
			if(light.distanceAttenuation != 0 && dot(WorldNormal,_AdditionalLightsPosition[lightIndex].xyz) > 0)
			{
				ShadowAtten *= light.shadowAttenuation;
			}
		}
	}
	#endif

	#if defined(_MAIN_LIGHT_SHADOWS_SCREEN) && !defined(_SURFACE_TYPE_TRANSPARENT)
			float4 shadowCoord = ComputeScreenPos(TransformWorldToHClip(WorldPosition));
		#else
			float4 shadowCoord = TransformWorldToShadowCoord(WorldPosition);
		#endif		
		   
		#if VERSION_GREATER_EQUAL(10, 1)
			mainLightShadowAtten = MainLightShadow(shadowCoord, WorldPosition, half4(1,1,1,1), _MainLightOcclusionProbes);
		#else
			mainLightShadowAtten = MainLightRealtimeShadow(shadowCoord);
		#endif

	// For Foward+ the LIGHT_LOOP_BEGIN macro will use inputData.normalizedScreenSpaceUV, inputData.positionWS, so create that:
	InputData inputData = (InputData)0;
	float4 screenPos = ComputeScreenPos(TransformWorldToHClip(WorldPosition));
	inputData.normalizedScreenSpaceUV = screenPos.xy / screenPos.w;
	inputData.positionWS = WorldPosition;

	LIGHT_LOOP_BEGIN(pixelLightCount)
		Light light = GetAdditionalLight(lightIndex, WorldPosition, Shadowmask);
	#ifdef _LIGHT_LAYERS
		if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
	#endif
		{
			//PBR Estimate
			float3 attenuatedLightColor = light.color.rgb * (light.distanceAttenuation);
			diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal);
			if(light.distanceAttenuation != 0 && dot(WorldNormal,_AdditionalLightsPosition[lightIndex].xyz) > 0)
			{
				ShadowAtten *= light.shadowAttenuation;
			}
		}
	LIGHT_LOOP_END
#endif

	Diffuse = diffuseColor;
}

void AdditionalLightsAndShadowNoSpecular_half(half3 WorldPosition, half3 WorldNormal, half4 Shadowmask,
							out half3 Diffuse, out half ShadowAtten, out half mainLightShadowAtten) {
	half3 diffuseColor = 0;
	mainLightShadowAtten = 0;
	ShadowAtten = 1;
#ifndef SHADERGRAPH_PREVIEW
	uint pixelLightCount = GetAdditionalLightsCount();
	uint meshRenderingLayers = GetMeshRenderingLayer();

	#if USE_FORWARD_PLUS
	for (uint lightIndex = 0; lightIndex < min(URP_FP_DIRECTIONAL_LIGHTS_COUNT, MAX_VISIBLE_LIGHTS); lightIndex++) {
		FORWARD_PLUS_SUBTRACTIVE_LIGHT_CHECK
		Light light = GetAdditionalLight(lightIndex, WorldPosition, Shadowmask);
	#ifdef _LIGHT_LAYERS
		if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
	#endif
		{
		//PBR Estimate
			half3 attenuatedLightColor = light.color.rgb * (light.distanceAttenuation); 
			diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal);
			if(light.distanceAttenuation != 0 && dot(WorldNormal,_AdditionalLightsPosition[lightIndex].xyz) > 0)
			{
				ShadowAtten *= light.shadowAttenuation;
			}
		}
	}
	#endif

	#if defined(_MAIN_LIGHT_SHADOWS_SCREEN) && !defined(_SURFACE_TYPE_TRANSPARENT)
			half4 shadowCoord = ComputeScreenPos(TransformWorldToHClip(WorldPosition));
		#else
			half4 shadowCoord = TransformWorldToShadowCoord(WorldPosition);
		#endif		
		   
		#if VERSION_GREATER_EQUAL(10, 1)
			mainLightShadowAtten = MainLightShadow(shadowCoord, WorldPosition, half4(1,1,1,1), _MainLightOcclusionProbes);
		#else
			mainLightShadowAtten = MainLightRealtimeShadow(shadowCoord);
		#endif

	// For Foward+ the LIGHT_LOOP_BEGIN macro will use inputData.normalizedScreenSpaceUV, inputData.positionWS, so create that:
	InputData inputData = (InputData)0;
	half4 screenPos = ComputeScreenPos(TransformWorldToHClip(WorldPosition));
	inputData.normalizedScreenSpaceUV = screenPos.xy / screenPos.w;
	inputData.positionWS = WorldPosition;

	LIGHT_LOOP_BEGIN(pixelLightCount)
		Light light = GetAdditionalLight(lightIndex, WorldPosition, Shadowmask);
	#ifdef _LIGHT_LAYERS
		if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
	#endif
		{
			//PBR Estimate
			half3 attenuatedLightColor = light.color.rgb * (light.distanceAttenuation);
			diffuseColor += LightingLambert(attenuatedLightColor, light.direction, WorldNormal);
			if(light.distanceAttenuation != 0 && dot(WorldNormal,_AdditionalLightsPosition[lightIndex].xyz) > 0)
			{
				ShadowAtten *= light.shadowAttenuation;
			}
		}
	LIGHT_LOOP_END
#endif

	Diffuse = diffuseColor;
}
#endif