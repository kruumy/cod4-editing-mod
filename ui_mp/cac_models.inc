
/* ================================================================================= */
/* ================================ LOADOUT DISPLAY ================================ */
/* ================================================================================= */
// UI art: Julian version 2 - first pass

// CAC loadout main frame =================

	#define PERK_ALIGN		
	
	#define LOADOUT_PLATING( py, ph, vis_gradient_top, vis_gradient_bottom ) \
			LOADOUT_PLATING_RAW( ((-(270 - RIGHTITEM_OFFSET))-80) 38, 0, py, (270+8), ph, RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP, vis_gradient_top, vis_gradient_bottom )

	// background frame --------
	//PREPROC_SHADER_DRAW_ALIGNED( -4 12 (270+8) 326 RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP, ((-(270 - RIGHTITEM_OFFSET))-80) 38, "gradient_center", 0.3 0.3 0.325 0.6, 0, 0, 0 0 0 0 ) 

	//PREPROC_SHADER_DRAW_ALIGNED( -24 -4 -20 358 RIGHTITEM_ALIGN VERTICAL_ALIGN_TOP, ((-(270 - RIGHTITEM_OFFSET))-80) 38, "gradient", 1 1 1 0.65, 0, 0, 0 0 0 0 )
	
	// top bar 
	//LOADOUT_PLATING( 4, 20, 0, 1 )
	
	// bottom bar
	//LOADOUT_PLATING( 346, 16, 1, 0 )
	
	//PREPROC_SHADER_DRAW_ALIGNED( -20 32 300 300 LOADOUT_ALIGN, ORIGIN_LOADOUT, "models_0006", 1 1 1 1, 0, 1, 1 1 1 1)

//visible when( tablelookup( "mp/statstable.csv", 1, STAT_CAC_SPECIALTY_EQUIPMENT, 4 ) == "specialty_specialgrenade" )