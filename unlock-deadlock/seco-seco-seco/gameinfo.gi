"GameInfo"
{
	game 		"citadel"
	title 		"Citadel"
	type		multiplayer_only
	nomodels 1
	nohimodel 1
	nocrosshair 0
	hidden_maps
	{
		"test_speakers"			1
		"test_hardware"			1
	}
	nodegraph 0
	perfwizard 0
	tonemapping 0
	GameData	"citadel.fgd"

	PGIVersion "39A735A413003C88A806B364C32DFC6D077E551B9E4EC6C7B11D41E8E67BFA0C"

	Localize
	{
		DuplicateTokensAssert	1
	}

	SupportedLanguages
	{
		"brazilian" "3"
		"czech" "3"
		"english" "3"
		"french" "3"
		"german" "3"
		"italian" "3"
		"indonesian" "3"
		"japanese" "3"
		"koreana" "3"
		"latam" "3"
		"polish" "3"
		"russian" "3"
		"schinese" "3"
		"spanish" "3"
		"thai" "3"
		"turkish" "3"
		"ukrainian" "3"
	}
	
	FileSystem
	{	
		//
		// The code that loads this file automatically does a few things here:
		//
		// 1. For each "Game" search path, it adds a "GameBin" path, in <dir>\bin
		// 2. For each "Game" search path, it adds another "Game" path in front of it with _<language> at the end.
		//    For example: c:\hl2\cstrike on a french machine would get a c:\hl2\cstrike_french path added to it.
		// 3. If no "Mod" key, for the first "Game" search path, it adds a search path called "MOD".
		// 4. If no "Write" key, for the first "Game" search path, it adds a search path called "DEFAULT_WRITE_PATH".
		//

		//
		// Search paths are relative to the exe directory\..\
		//
	






// Deadlock Mod Manager - Start

		SearchPaths
        {  
            Game_Language       citadel_*LANGUAGE*
            Game                citadel/addons
            Mod                 citadel
            Write               citadel          
            Game                citadel
            Mod                 core
            Write               core
            Game                core        
        }
// Deadlock Mod Manager - End

		"UserSettingsPathID"		"USRLOCAL"
		"LegacyUserSettingsPathID"	"MOD"
	}
	
	MaterialSystem2
	{
		RenderModes
		{
			game Default
			game Forward
			game Deferred
			game Outline
			game Depth
			game FrontDepth
			game ShadowSilhouette

			dev ToolsVis // Visualization modes for all shaders (lighting only, normal maps only, etc.)
			dev ToolsWireframe // This should use the ToolsVis mode above instead of being its own mode\

			tools ToolsUtil // Meant to be used to render tools sceneobjects that are mod-independent, like the origin grid
		}
	}

	MaterialEditor
	{
		"DefaultShader" "environment_texture_set"
	}

	NetworkSystem
	{
		BetaUniverse
		{
			FakeLag			40
			FakeLoss		.1
			//FakeReorderPct 0.05
			//FakeReorderDelay 10
			//FakeJitter "low"
			// Turning off fake jitter for now while I work on making the CQ totally solid
			FakeReorderPct 0
			FakeReorderDelay 0
			FakeJitter "off"
		}

		"SkipRedundantChangeCallbacks"	"1"
	}

	RenderSystem
	{
		IndexBufferPoolSizeMB 32
		UseReverseDepth 1
		Use32BitDepthBuffer 0
		Use32BitDepthBufferWithoutStencil 0
		VulkanMutableSwapchain 1
		"LowLatency"								"1"
		"VulkanRequireSubgroupWaveOpSupport"		"1"
		"VulkanRequireDescriptorIndexing"			"1"
		"VulkanStagingPMBSizeLimitMB" "384"
		"VulkanOnlyTestProbability" "0"
		"VulkanDefrag"				"1"
		"MinStreamingPoolSizeMB"	"1024"
		"MinStreamingPoolSizeMBTools" "2048"
	}

	NVNGX
	{
		AppID 103371621
		SupportsDLSS 1
	}

	Engine2
	{
		HasModAppSystems 1
		Capable64Bit 1
		URLName citadel
		RenderingPipeline
		{
			SupportsMSAA 0
			DistanceField 1
		}
		PauseSinglePlayerOnGameOverlay 1
		PauseOnCtrlConsole 0 // Src2 issues a 'setpause' on holding down CTRL + toggleconsole key, disable this for Deadlock.
		DefensiveConCommands 1
		DisableLoadingPlaque 1
		LocalServerClientAccess 1

		"MapMaxCoord" "32768"
	}

	ContentBuilder
	{
		ResourceCompilerDirectXUsesWARP "0"
	}

	SoundSystem
	{
		SteamAudioEnabled            "1"
		WaveDataCacheSizeMB          "256"
		"UsePlatTime"            "1"
	}
	Sounds
	{
		HierarchicalEncodingFiles	 "1"
	}

	ToolsEnvironment
	{
		"Engine"	"Source 2"
		"ToolsDir"	"../sdktools"	// NOTE: Default Tools path. This is relative to the mod path.
	}
	
	pulse
	{
		"pulse_enabled"					"1"
	}

	Hammer
	{
		"fgd"					"citadel.fgd"	// NOTE: This is relative to the 'game' path.
		"GameFeatureSet"		"Citadel"
		"DefaultSolidEntity"	"trigger_multiple"
		"DefaultPointEntity"	"info_player_start"
		"NavMarkupEntity"		"func_nav_markup"
		"OverlayBoxSize"			"8"
		"TileMeshesEnabled"			"1"
		"RenderMode"				"ToolsVis"
		"CreateRenderClusters"		"1"
		"DefaultMinDrawVolumeSize"	"2048"
		"DefaultMinTrianglesPerCluster"	"16384"
		"TileGridSupportsBlendHeight"	"1"
		"TileGridBlendDefaultColor"	"0 255 0"
		"LoadScriptEntities" "0"
		"UsesBakedLighting" "1"
		"UseAnalyticGrid" "0"
		"SupportsDisplacementMapping" "0"
		"SteamAudioEnabled"				"1"
		"LatticeDeformerEnabled"		"1"
		"ShadowAtlasWidth" "16384"
		"ShadowAtlasHeight" "16384"
		"TimeSlicedShadowMapRendering" "1"
	}

	SoundTool
	{
		"DefaultSoundEventType" "src1_3d"

		SoundEventBaseOptions
		{
			"Base.Announcer.VO.2d" ""
			"Base.World.VO.Emitter.3d" ""
			"Base.Hero.VO.Ping.2d" ""
			"Base.Hero.VO.2d" ""
			"Base.Hero.VO.3d" ""
			"Base.Hero.VO.Ability.3d" ""
			"Base.Hero.VO.Ultimate.3d" ""
			"Base.Hero.VO.Dash.3d" ""
			"Base.Hero.VO.Effort.3d" ""
			"Base.Hero.VO.Pain.3d" ""
			"Base.Hero.VO.Melee.3d" ""
			"Base.Hero.VO.Death.3d" ""
		}
	}

	RenderPipelineAliases
	{
	}

	ResourceCompiler
	{
		// Overrides of the default builders as specified in code, this controls which map builder steps
		// will be run when resource compiler is run for a map without specifiying any specific map builder
		// steps. Additionally this controls which builders are displayed in the hammer build dialog.
		DefaultMapBuilders
		{
			"bakedlighting"	"1"	// Enable lightmapping during compile time		
			"envmap"	"0" // turned off since it currently causes an assert and doesn't work due to some build issue
			"nav"		"1"	// Generate nav mesh data
			"sareverb"      "0" // Bake Steam Audio reverb
			"sapaths"	"0" // Bake Steam Audio pathing
			"sacustomdata"	"1"	// Bake Steam Audio custom data
		}

		// Game specific steps run after the map has been built, in the order they are listed here
		GameSpecificPostMapBuildSteps
		{
			"pve_nav_cache"	"1"	// Bake the spots the PVE directors spawn things on
		}

		MeshCompiler
		{
			OptimizeForMeshlets 1
			TrianglesPerMeshlet 64	// Maximum valid value currently is 126
			UseMikkTSpace 1
			EncodeVertexBuffer 1
            EncodeVertexBufferVersion 1
            EncodeVertexBufferLevel 3
			EncodeIndexBuffer 1
			SplitDepthStream 1
		}

		WorldRendererBuilder
		{
			VisibilityGuidedMeshClustering      "1"
			MinimumTrianglesPerClusteredMesh    "8192"
			MinimumVerticesPerClusteredMesh     "8192"
			MinimumVolumePerClusteredMesh       "8192"       // ~20x20x20 cube
			MaxPrecomputedVisClusterMembership  "96"
			MaxCullingBoundsGroups              "128"
			UseAggregateInstances				"1"
			AggregateInstancingMeshlets			"1"
			BakePropsWithExtraVertexStreams		"1"
			MergeTranslucents					"1"
		}

		BakedLighting
		{
			Version 4
			ImportanceVolumeTransitionRegion 512            // distance we transition from high to low resolution charts 
			LightmapChannels
			{
				direct_light_shadows 1
				debug_chart_color 1
				directional_irradiance_sh2_dc 1
				
				directional_irradiance_sh2_r
				{
					CompressedFormat DXT1
				}
				
				directional_irradiance_sh2_g
				{
					CompressedFormat DXT1
				}
				
				directional_irradiance_sh2_b
				{
					CompressedFormat DXT1
				}
			}
			LightmapGutterSize 2 // For bicubic filtering
			UseStaticLightProbes 0
			LPVAtlas 1
		}

		SteamAudio
		{
			ReverbDefaults
			{
				GridGenerationType	"0"						// 0: Automatic, Everywhere, 1: Automatic, Use Probe Generation Volume, 2: Manual
				FilterUsingVolumes	"1"						// Filter Using Probe Exclusion Volumes ( boolean )
				FilterUsingNavMesh	"0"						// Filter Using NavMesh
				GridSpacing			"3.0"
				HeightAboveFloor	"1.5"
				RebakeOption		"0"						// 0: cleanup, 1: manual, 2: auto
				NumRays				"32768"
				NumBounces			"64"
				IRDuration			"1.0"
				AmbisonicsOrder		"1"
				ClusteringEnabled	"0"
				ClusteringCubemapResolution	"16.0"
				ClusteringDepthThreshold	"10.0"
			}
			PathingDefaults
			{
				GridGenerationType	"0"						// 0: Automatic, Everywhere, 1: Automatic, Use Probe Generation Volume, 2: Manual
				FilterUsingVolumes	"1"						// Filter Using Probe Exclusion Volumes ( boolean )
				FilterUsingNavMesh	"0"						// Filter Using NavMesh
				GridSpacing			"3.0"
				HeightAboveFloor	"1.5"
				RebakeOption		"0"						// 0: cleanup, 1: manual, 2: auto
				NumVisSamples		"1"
				ProbeVisRadius		"0"
				ProbeVisThreshold	"0.1"
				ProbeVisPathRange	"1000.0"
			}
			CustomDataDefaults
			{
				GridGenerationType	"0"						// 0: Automatic, Everywhere, 1: Automatic, Use Probe Generation Volume, 2: Manual
				FilterUsingVolumes	"1"						// Filter Using Probe Exclusion Volumes ( boolean )
				FilterUsingNavMesh	"1"						// Filter Using NavMesh
				GridSpacing		"6"
				HeightAboveFloor	"1.5"
				RebakeOption		"0"						// 0: cleanup, 1: manual, 2: auto
				BakeOcclusion		"0"						// 0: Disabled, 1: Enabled
				BakeDimensions		"1"						// 0: Disabled, 1: Enabled
				BakeMaterials		"0"						// 0: Disabled, 1: Enabled
				OcclusionPathing			"1"
				OcclusionReflection			"0"
				OcclusionReflectionRays		"16384"
				OcclusionReflectionBounces	"16"
				DimensionsOutsideThreshold	"0.02"
				
			}
			ProbeGenerationVolumeDefaults
			{
				Spacing			"3.0"
				Height			"1.5"
				HeightSpacing		"12"
				UseForReverb		"0"
				UseForPathing		"0"
				UseForCustomData	"1"
				FilterUsingVolumes	"1"
				FilterUsingNavMesh	"1"
			}
		}
		SoundEventScripts
		{
			OmitMetadataAndLineText "1"
		}
		SoundStackScripts
		{
			CompileStacksStrict "1"
		}
		VisBuilder
		{
			MaxVisClusters "4096"
			PreMergeOpenSpaceDistanceThreshold "128.0"
			PreMergeOpenSpaceMaxDimension "2048.0"
			PreMergeOpenSpaceMaxRatio "8.0"
			PreMergeSmallRegionsSizeThreshold "20.0"
		}

		VDataLocalization
		{
			GameOutputPath	"resource/localization/citadel_vdata"
			TokenPrefix		"Citadel_VData_"
		}
		
		TextureCompiler
		{
			//Compressor              "lz4"
			//CompressMipsOnDisk      "1"
			//CompressMinRatio        "95"
			AllowNP2Textures		"1"
			AllowPanoramaMipGeneration	"1"
			//PublicToolsDefaultMaxRes "2048"
		}
	}

	Source1Import
	{
		"forcevtxfileupconvert" 1
	}

	WorldRenderer
	{
		EnvironmentMaps					1
		EnvironmentMapFaceSize			256
		EnvironmentMapRenderSize		1024
		EnvironmentMapFormat			BC6H
		EnvironmentMapPreviewFormat 		BC6H
		EnvironmentMapColorSpace		linear
		EnvironmentMapMipProcessor		GGXCubeMapBlur
		// Build cubemaps into a cube array instead of individual cubemaps.
		"EnvironmentMapUseCubeArray" 	1
		"EnvironmentMapCacheSizeTools"  300
		BindlessSceneObjectDesc			CitadelBindlessDesc
		GrassCastsShadows				1
	}

	SceneSystem
	{
		GpuLightBinner 1
		FogCachedShadowAtlasWidth 2048
		FogCachedShadowAtlasHeight 2048
		FogCachedShadowTileSize 128
		GpuLightBinnerSunLightFastPath 1
		CSMCascadeResolution 2048
		SunLightManagerCount 0
		SunLightManagerCountTools 0
		DefaultShadowTextureWidth 6144
		DefaultShadowTextureHeight 6144
		DynamicShadowResolution 1

		TransformTextureRowCount	1024
		TransformTextureRowCountToolsMode 6144
		SunLightMaxCascadeSize		4
		SunLightShadowRenderMode	Depth
		NonTexturedGradientFog		1
		CubemapFog 1
		VolumetricFog 1
		FrameBufferCopyFormat R11G11B10F
		Tonemapping 0
		
		WellKnownLightCookies
		{
			"blank" "materials/effects/lightcookies/blank.vtex"
			"flashlight" "materials/effects/lightcookies/flashlight.vtex"
		}

		ComputeShaderSkinning 1
	}

	NavSystem
	{
		"NavTileSize" "128.0"
		"NavCellSize" "1.5"
		"NavCellHeight" "2.0"

		// Hull definitions live in scripts/nav_hulls.vdata
		// Preset definitions live in scripts/nav_hulls_presets.vdata
		"NavHullsPreset" "default"

		"NavRegionMinSize" "8"
		"NavRegionMergeSize" "20"
		"NavEdgeMaxLen" "1200"
		"NavEdgeMaxError" "51.0"
		"NavVertsPerPoly" "4"
		"NavDetailSampleDistance" "120.0"
		"NavDetailSampleMaxError" "2.0"
		"NavSmallAreaOnEdgeRemovalSize" "81.0"
	}

	AnimationSystem
	{
		"DisableServerInterpCompensation"	"1"
		"DisableAnimationScript" 	"1"
		"ServerPoseRecipeHistorySize"	"60"
		"ClientPoseRecipeHistorySize"	"60"

	}

	ModelDoc
	{
		"models_gamedata"			"models_gamedata.fgd"
		"features"					"modelconfig;gamepreview;wireframe_backfaces;distancefield"
	}

	Particles
	{
		"EnableParticleShaderFeatureBranching"	"1"
		"Float16HDRBackBuffer" "1"
		"PET_SupportFadingOpaqueModels" "1"
		"BindlessParticleShader" "1"
		"Features" "non_homogenous_forward_layer_only"
	}

	Physics
	{
		"EnableWorldCompounds"			"1"
	}
	
	ConVars
	{	 
"r_citadel_selection_outline2_alpha" "255"
citadel_player_outline_fade_range_max 20000
// ================ CORE QUALITY ================
r_farz "6000"
"gpu_level" "0"                     // Minimum Shader Details Level
"cpu_level" "0"                     // Minimum Effect Details Level
"mat_set_shader_quality" "0"

// ================ FOV ================
"r_aspectratio" "2.49"              // [ADJUST] FOV control: 1.33=70fov | 1.56=75fov | 1.75=80fov | 2.0=85fov | 2.15=90fov | 2.49=100fov | 3.0=110fov | 3.5=120fov

// ================ LIGHTING & SHADOWS ================
"r_directlighting" "0"
"r_ssao" "0"                        // Disable ambient occlusion
"r_shadows" "0"                     // [FPS IMPACT] 0=Off (max FPS) | 1=On (shadows enabled)
"r_rendersun" "0"
"lb_enable_shadow_casting" "0"      // [FPS IMPACT] 0=Off (shadows disabled, +FPS) | 1=On (shadow casting enabled)
"lb_csm_draw_alpha_tested" "0"
"lb_csm_draw_translucent" "0"
"lb_barnlight_shadowmap_scale" "0.1"
"lb_csm_cascade_size_override" "1"
"lb_dynamic_shadow_resolution_quantization" "12"
"lb_csm_override_staticgeo_cascades_value" "0"
"lb_csm_receiver_plane_depth_bias" "0.00002"
"lb_csm_receiver_plane_depth_bias_transmissive_backface" "0.0002"
"lb_sun_csm_size_cull_threshold_texels" "30"
"lb_dynamic_shadow_resolution_base" "256"
"lb_enable_fog_mixed_shadows" "0"
"r_citadel_sun_shadow_slope_scale_depth_bias" "1.0"
"r_lightmap_size_directional_irradiance" "4"
"r_size_cull_threshold_shadow" "100"
"csm_max_shadow_dist_override" "0"
"sc_cache_envmap_lpv_lookup" "1"
"cl_retire_low_priority_lights" "1"
"sc_disable_spotlight_shadows" "1"
"sc_disable_shadow_materials" "1"
"cl_globallight_shadow_mode" "0"
"lb_enable_dynamic_lights" "0"
"lb_enable_lights" "0"
"lb_enable_stationary_lights" "0"         // Disable stationary lights
"lb_max_visible_barn_lights_override" "0"
"lb_max_visible_envmaps_override" "4"
"lb_ssss_samples" "0"
"r_multiscattering" "1"                   // Disable multiscattering (only works with shadows disable)

// ================ SPARSE SHADOW TREE ================
"sparseshadowtree_enable_rendering" "0"
"sparseshadowtree_disable_for_viewmodel" "1"

// ================ DISTANCE FIELD ================
"r_citadel_distancefield_farfield_enable" "false"
"r_citadel_npr_outlines_max_dist" "120"

// ================ FOG & ATMOSPHERE ================
"r_enable_volume_fog" "0"
"r_enable_gradient_fog" "0"
"r_enable_cubemap_fog" "0"
"volume_fog_intermediate_textures_hdr" "0"

// ================ SKY & ENVIRONMENT ================
"r_draw3dskybox" "0"
"r_monitor_3dskybox" "0"
"r_world_wind_strength" "0"
"sv_waterdist" "0"

// ================ SSAO ================
"r_citadel_ssao_bent_normals" "false"
"r_citadel_ssao_denoise_passes" "0"
"r_citadel_ssao_quality" "0"
"r_citadel_ssao_radius" "0"
"r_citadel_ssao_thin_occluder_compensation" "0"

// ================ PARTICLE SYSTEM ================
"r_particle_max_detail_level" "0"
"r_particle_cables_cast_shadows" "0"
"r_RainParticleDensity" "0"
"r_physics_particle_op_spawn_scale" "0"
"r_particle_max_size_cull" "800"
"particle_cluster_nodraw" "1"
"r_particle_mixed_resolution_viewstart" "800"
"r_particle_max_draw_distance" "5000" // Lower = less particle range, more FPS
"r_particle_model_new8" "0"
"cl_show_splashes" "0"
"r_particle_skip_postsim" "1"
"r_limit_particle_job_duration" "1"
"cl_particle_sim_fallback_threshold_ms" "1" // [ADJUST] Lower = more aggressive fallback to simple particles (higher FPS, less detail)
"cl_particle_fallback_base" "10"
"cl_particle_fallback_multiplier" "10"
"cl_particle_sim_fallback_base_multiplier" "10"
"r_particle_min_timestep" "0.001" // [ADJUST] Lower = less particles glitch
 
// ================ PHYSICS & CLOTH ================
"cloth_update" "0"                   // [FPS IMPACT] 0=Off (cosmetic only, +FPS) | 1=On (cloth physics enabled)
"cloth_sim_on_tick" "0"
"presettle_cloth_iterations" "1"
"pred_cloth_pos_max" "1.0"           // Reduce cloth prediction
"pred_cloth_pos_multiplier" "0.1"
"pred_cloth_pos_strength" "0.1"
"pred_cloth_rot_high" "0.05"
"pred_cloth_rot_low" "0.005"
"pred_cloth_rot_multiplier" "0.2"
"cl_phys_timescale" "0"              // [FPS IMPACT] 0=Disable physics (max FPS) | 1=Normal physics | Lower = slower physics, less CPU
"cl_fasttempentcollision" "20"
"phys_threaded_cloth_bone_update" "1"
"phys_threaded_kinematic_bone_update" "1"
"phys_threaded_transform_update" "1"

// ================ RAGDOLL ================
"cl_ragdoll_limit" "0"              // Set it on console if ragdoll still lingers longer
"ragdoll_parallel_pose_control" "1"

// ================ MODEL & DECAL OPTIMIZATIONS ================
"r_drawmodeldecals" "0"
"r_character_decal_resolution" "1"
"r_decals" "0"                      // [ADJUST] Max decals visible: 0=No decals (max FPS) | 16=Low | 64=Medium | 256=High
"r_propsmaxdist" "800"
"props_break_max_pieces_perframe" "0"
"r_citadel_screenspace_particles_full_res" "0"
"r_citadel_gpu_culling_shadows" "1"
"skeleton_instance_lod_optimization" "1"
"r_size_cull_threshold" "1.2"
"r_hair_ao" "0"
"r_render_hair" "0"                   // [FPS IMPACT] 0=Off (max FPS boost, bald heroes) | 1=On (hair rendered)
"r_haircull_percent" "100"
"ik_final_fixup_enable" "0"
"ik_fabrik_align_chain" "0"
"cl_impacteffects" "0"
"enable_boneflex" "false"            // cloth flexing
"cl_eye_yaw_multiplier" "0"

// ================ LOD & CULLING ================
"sc_instanced_mesh_lod_bias" "10"     // [FPS IMPACT] Higher = lower quality models, more FPS | 0=High quality | 10=Low quality
"sc_instanced_mesh_lod_bias_shadow" "10" // Bias for LOD selection of instanced meshes in shadowmaps
"sc_instanced_mesh_motion_vectors" "0" // Set 1 if you use motion blur
"sc_instanced_mesh_size_cull_bias" "10" // Bias for size culling of instanced meshes
"sc_instanced_mesh_size_cull_bias_shadow" "10" // Bias for size culling instanced meshes in shadowmaps
"sc_fade_distance_scale_override" "180"
"sc_clutter_enable" "0"                   // [FPS IMPACT] 0=No debris/props (max FPS) | 1=Props visible (immersive)
"sc_aggregate_bvh_threshold" "64"         // Lower BVH threshold (default: 128)
"sc_layer_batch_threshold" "64"           // Lower batch threshold (default: 128)
"sc_layer_batch_threshold_fullsort" "80"

// ================ ROPE PHYSICS ================
"rope_collide" "0"
"rope_subdiv" "0"
"rope_wind_dist" "0"
"rope_smooth_enlarge" "0"
"rope_smooth_maxalpha" "0"
"rope_smooth_maxalphawidth" "0"
"rope_smooth_minalpha" "0"
"rope_smooth_minwidth" "0"
"r_ropetranslucent" "0"
"r_drawropes" "0"

// ================ TERRAIN & FOLIAGE ================
"r_grass_quality" "0"
"r_grass_start_fade" "0"
"r_grass_end_fade" "0"

// ================ UI & HUD ================
"panorama_disable_box_shadow" "1"
"r_dashboard_render_quality" "1"
"closecaption" "false"
"citadel_hud_objective_health_enabled" "2"  // [ADJUST] Objective health display: 0=Off | 1=Shrines only | 2=T1/T2 Towers | 3=Barracks
"citadel_boss_glow_disabled" "1"
"citadel_damage_offscreen_indicator_disabled" "0" // Set 1 to disable
"citadel_portrait_world_renderer_off" "false" // Set true to disable hero hud
"panorama_use_new_occlusion_invalidation" "1"
"panorama_temp_comp_layer_min_dimension" "128"
"panorama_max_overlay_fps" "30"
"panorama_max_fps" "60"               // [ADJUST] UI FPS cap - 0=Unlimited (smooth UI) | 30/60=Standard | Higher = smoother HUD but more CPU
"panorama_async_compute_mipgen" "1"
"citadel_damage_text_lifetime" "1.5"
"citadel_damage_text_lifetime_new" "0.75"
"citadel_damage_text_lifetime_accumulated_new" "2"
"citadel_show_new_damage_feedback_numbers" "1" // Set 1 to enable
"hud_free_cursor" "0"                // Reduces UI input delay in minimap/spectator modes (not sure if this is true)
"citadel_camera_soft_collision" "0"
"citadel_camera_wobble_disable" "1"
"citadel_unit_status_use_new" "1"
"mm_idle_show_warning_at_s" "999"   // How many seconds to wait before showing the idle warning dialog
"citadel_hideout_ball_show_juggle_count" "1"
"citadel_hideout_ball_show_juggle_fx" "1"

// ================ NETWORK & PREDICTION ================
"cl_prediction_savedata_postentitypacketreceived" "1"
"r_frame_sync_enable" "0"
"cl_clock_buffer_ticks" "0"          // Testing set 1 to smooth over packet loss
"cl_async_usercmd_send" "true"
"cl_smooth" "0"                      // [ADJUST] 0=No smoothing (lower input lag) | 1=Smoothing enabled (may add delay)
"cl_smoothtime" "0.01"
"cl_smooth_draw_debug" "0"
"cl_interp_parallel" "1"
"cl_parallel_readpacketentities" "1"
"cl_parallel_readpacketentities_threshold" "2"
"net_async_clientconnect" "1"
"engine_max_ticks_to_simulate" "33"

// ================ AI OPTIMIZATIONS ================
"ai_strong_optimizations_no_checkstand" "1"
"ai_expression_optimization" "1"

// ================ AUDIO ================
"audio_enable_vmix_mastering" "0"     // [FPS IMPACT] 0=Off (saves CPU, +FPS) | 1=On (audio mastering enabled)"
"dsp_volume" "0"                    // idk
"snd_occlusion_bounces" "0"
"snd_steamaudio_num_threads" "1"     // [ADJUST] Audio thread count - 1=Low CPU usage | Higher = better audio quality, more CPU
"snd_mix_async" "1"
"soundsystem_update_async" "1"

// ================ TEXTURE STREAMING ================
"r_texture_pool_size" "800"           // [ADJUST] VRAM usage in MB - Lower = less VRAM used, may cause texture pop-in | 512-1024 range
"r_texture_stream_mip_bias" "4"         // [FPS IMPACT] Higher = blurrier textures, more FPS | 0=High quality | 2=Balanced | 4=Low quality
"r_texture_lod_scale" "0"               // [FPS IMPACT] 0=High quality (sharp) | 2=Medium | 4=Low quality (blurry, max FPS)
"r_fallback_texture_lod_scale" "1"
"r_texture_budget_update_period" "0.05" // Faster texture streaming adjustment
"r_texture_pool_reduce_rate" "512"

// ================ MEMORY BUDGET ================
"r_texture_budget_dynamic" "1"          // Dynamic texture budget adjustment
"r_texture_budget_threshold" "0.8"

// ================ SHADER & RENDERING ================
"mat_async_shader_load" "1"
"r_renderdoc_auto_shader_pdbs" "0"
"sc_hdr_enabled_override" "0"
"r_texturefilteringquality" "0"
"r_max_portal_render_targets" "2"   // Set how many amount to render portals
"mat_colcorrection_disableentities" "0" // Disable map color-correction entities	 
		"rate"
		{
			"min"		"98304"
			"default"	"786432"
			"max"		"1000000"
		}
            		// Networking - General
		"sv_minrate"	"98304"
		"sv_maxunlag"	"0.500"
		"sv_maxunlag_player" "0.200"
		"sv_lagcomp_filterbyviewangle" "false"
		"cl_usesocketsforloopback" "1"
		"cl_poll_network_early" "0"
		"cq_buffer_bloat_msecs_max" "120"						// 7.68 ticks @64hz max cq bloat

		// Networking - Induced latency (pred offset)
		"cl_tickpacket_recvmargin_desired" "5" 					// 5 ms base, min. floor for protecting against thrashing the queue
		"cl_tickpacket_desired_queuelength" "1"					
		"cl_async_usercmd_send_disabled_recvmargin_min" "0.5"	// Additional frame since we do not use the async usercmd send (potentially unneccessary)
		"cl_clock_buffer_ticks"	"1"								// Buffer added to the simulation clock margin ( affects pred offset and cadence of client world ticks )
		"cl_interp_ratio" "0"
		"cl_async_usercmd_send" "false"							// We don't support early prediction at the moment, which async send requires

		// Nav gen
		"nav_gen_connect_dist_a" "2.0"

		// Spew warning when adding/removing classes to/from the top of the hierarchy
		"panorama_classes_perf_warning_threshold_ms" "0.75"

		// Panorama - enable minidumps on JS exceptions
		"panorama_js_minidumps" "1"
		// Enable the render target cache optimization.
		"panorama_disable_render_target_cache" "0"

		// Enable the composition layer optimization
		"panorama_skip_composition_layer_content_paint" "1"

		// Steam audio loading data
		"snd_steamaudio_load_reverb_data"		"0"
		"snd_steamaudio_load_pathing_data"		"0"
		"snd_steamaudio_load_occlusion_data"	"0"
		"snd_steamaudio_load_dimensions_data"	"1"
		"snd_steamaudio_load_materials_data"	"0"

		// Steam Audio project specific convars
		"snd_steamaudio_enable_custom_hrtf"			"0"
		"snd_steamaudio_active_hrtf"				"0"
		"snd_steamaudio_pathing_order"				"3"
		"snd_steamaudio_pathing_order_rendering"	"3"
		"snd_steamaudio_enable_pathing"				"0"
		"snd_steamaudio_enable_reverb"				"0"
		"snd_steamaudio_reverb_level_db"			"-6"
		"snd_steamaudio_enable_pathing"				"0"
		"snd_steamaudio_invalid_path_length"		"0.0"
		"snd_steamaudio_max_probes_customdata_dimensions"	"100000"
		"snd_steamaudio_dimensions_grid_height_max"			"100"
		"snd_steamaudio_baked_dimensions_probelookup_usealternate"	"1"
		"snd_steamaudio_custombake_dimensions_size_and_inout_bake_enabled" "1"
		"snd_steamaudio_custombake_dimensions_outsidefield_bake_enabled" "0"
		"snd_steamaudio_custombake_dimensions_smallsizefield_bake_enabled" "0"
		"snd_steamaudio_dimensions_max_ray_length"			"2500"
		"cl_disconnect_soundevent"				"citadel.convar.stop_all_game_layer_soundevents"
		"snd_event_browser_default_stack"		"citadel_default_3d"
		
		// voip
		"voice_in_process"			            "1"

		// Sound debugging
		"snd_report_audio_nan" "1"

		// Audio system settings
		"snd_sos_max_event_base_depth" "10"
		"sos_use_guid_filter" "1"

		"voice_always_sample_mic"               
		{
			"version"	"2"
			"default"	"0"
		}

		"reset_voice_on_input_stallout"         "0"
		"voice_input_stallout"                  "0.5"
		
		"audio_enclosure_calc_enabled"		"0"

		"sc_layer_batch_threshold_fullsort" "20"

		// Perf/Parallelism
		"iv_parallel_restore" "1"

		// For perf reasons, since we don't use source-based DSP:
		"disable_source_soundscape_trace"       "1"
	

		"fps_max"		"400"
		"fps_max_ui"	"120"

		"in_button_double_press_window" "0.3"

		// Convars that control spatialization of UI audio.
		"snd_ui_positional"								"1"
		"snd_ui_spatialization_spread"					"2.4"
		
		// sound volume rate change limiting
		"snd_envelope_rate"								"100.0"
		"snd_soundmixer_update_maximum_frame_rate" 		"0"

		//don't let people mess with speaker config settings.
		"speaker_config"
		{
			"min"		"0"
			"default"	"0"
			"max"		"2"
		}


		"snd_soundmixer"						"Default_Mix"
		"cloth_filter_transform_stateless" "0"

		"cl_joystick_enabled" "0"
		"panorama_joystick_enabled" "0"

		"snd_event_browser_focus_events" "true"

		"cl_max_particle_pvs_aabb_edge_length" "100"
		
		// Particles
		"cl_aggregate_particles" "true"
		"r_particle_batch_collections" "1"
		
		"citadel_enable_vdata_sound_preload" "true"

		"r_add_views_in_pre_output"		"1"

		// Disable Cubemap Brightening
		"lb_cubemap_normalization_max" 		"1"

		"update_all_keyframed_in_spatial_partition_update"	"0"
		"parallel_update_surrounding_bounds_in_spatial_partition_update"	"1"
		"always_perform_full_spatial_partition_update" "1"
		"cl_interp_parallel" "1"
		"parallel_perform_invalidate_physics" "1"
		"phys_agg_world_compounds" "0"

		"cl_updaterate" "128"
		"sv_parallel_checktransmit" "2"
		"net_gather_child_fields_only" "1"
	}

	Memory
	{
		"EstimatedMaxCPUMemUsageMB"	"1"
		"EstimatedMinGPUMemUsageMB"	"1"

		"ShowInsufficientPageFileMessageBox" "1"
		"ShowLowAvailableVirtualMemoryMessageBox" "1"
	}
}
