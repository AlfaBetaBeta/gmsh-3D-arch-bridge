/*************************************************************************************************************
 *
 *  Macro Bridge3D3Span
 *
 *  Automated generation of a full 3D 3-span segment of a bridge, creating the Physical entities necessary for
 *  ingestion into the FE engine for analysis (dynamic in this example)
 *
 *************************************************************************************************************/
// MESH A 3-SPAN SEGMENT OF THE REFERENCE BRIDGE AS FULL 3D MODEL VIA Y-EXTRUSIONS (SPANDREL + INNER BULK + SPANDREL)

// NOTES:	* XZ GEOMETRY AND LOADS DEFINED IN ANOTHER MACRO (Bridge2D3Span) WITH THE EXCEPTION OF THE PARAPET
//			* THE ONLY GEOMETRIC PARAMETERS NEEDED HERE RELATE TO THE PARAPET OR THE Y-EXTRUSIONS.
//			  ANY OTHER INPUT PARAMETER IS CARRIED ALONG FROM PREVIOUS MACROS 
//			* THE PHYSICAL VOLUMES FOR MATERIAL GROUPS ARE ASSIGNED AS FOLLOWS
//					g_msnr   = arches + hex.skewbacks + piers + parapet THROUGHOUT
//					g_bkspdr = BACKING VOLUMES INSIDE SPANDREL WALLS
//					g_bkbulk = BACKING VOLUMES BETWEEN SPANDREL WALLS
//					g_bfspdr = BACKFILL VOLUMES INSIDE SPANDREL WALLS
//					g_bfbulk = BACKFILL VOLUMES BETWEEN SPANDREL WALLS
//					g_sk15   = wedge.skewbacks THROUGHOUT
//					g_bllst  = BALLAST BETWEEN SPANDRELS

Macro Bridge3D3Span

/*
IN:		WSp    	   = Width of the spandrel wall
		NLSp   	   = Number of layers along WSp (in Y) upon discretisation

		HPp    	   = Height of the parapet, measured from the top of the backfill
		NLPp   	   = Number of layers along HPp (in Z) upon discretisation

		WBf[]  	   = List of width values of the successive internal extrusions along Y
        NLBf[] 	   = Number of layers along Wbf[] (in Y) upon discretisation
		LdBf[] 	   = List indicating which widths of WBf[] sustain load
		             (==0 if not, !=0 if indeed)

		ELTh   	   = Thickness of the elastic layer
		NLEL   	   = Number of elmt layers to discretise the elastic layer
	
		+ other args carried along from previous macros

INOUT:	S_SK[] 	   = List with Surfaces forming the skewbacks (2D)]
		S_PR[] 	   = List with Surfaces forming the piers (2D)]
		S_AR[] 	   = List with Surfaces forming the arches (2D)]
		S_BK[] 	   = List with Surfaces forming the backing 'area' (2D)]
		S_BF[] 	   = List with Surfaces forming the backfill 'area' (2D)]

OUT:	S_Yext[]   = List of ALL Surfaces at Y=WSp
		S_abtbk[]  = List of Surfaces at the backing 'abutments'
		S_base[]   = List of Surfaces at the pier bases
		S_abtarc[] = List of Surfaces at the arch 'abutments'
		S_abtbf[]  = List of Surfaces at the backfill 'abutments'
		S_abtpp[]  = List of Surfaces at the parapet 'abutments'
		S_load[]   = List of Surfaces forming the load strips

		V_BK[]     = List of Volumes forming the backings
		V_PR[]	   = List of Volumes forming the piers
		V_SK[]	   = List of ALL Volumes forming the skewbacks
		V_SK20[]   = List of WEDGE Volumes forming the skewbacks
		V_SK15[]   = List of HEXAHEDRAL Volumes forming the skewbacks
		V_AR[]	   = List of Volumes forming forming the arches
		V_BF[]	   = List of Volumes forming the backfill
		V_PP[]	   = List of Volumes forming the parapet
		V_EL[]	   = List of Volumes forming the elastic layer

		extBK[]	   = List with all entities arising from extrusion of backings
		extPR[]	   = List with all entities arising from extrusion of piers
		extSK[]	   = List with all entities arising from extrusion of skewbacks
		extAR[]	   = List with all entities arising from extrusion of arches
		extBF[]	   = List with all entities arising from extrusion of backfill
		extPP1[]   = List with all entities arising from 1st extrusion for parapet
		extPP2[]   = List with all entities arising from 2nd extrusion for parapet
		S_PP[]	   = List of Surfaces forming the top of the backfill 'area'
		extEL[]	   = Z-extrusion to create the elastic layer
	
		+ Physical entities + output from embedded macros
*/
//------------------------------------------------------------------------------
// INITIALISE Surface LISTS FOR THE SIDES (Y=0 & Y=total.width)
S_Ymin[] = Surface "*"; // << All these Surfaces already exist via macro Brdg2D3Sp
S_Ymax[] = {};

// INITIALISE Surface/Volume LISTS FOR ALL EXTRUSIONS, TO BE UPDATED STAGEWISE
V_BK[] = {};
S_abtbk[] = {};

V_PR[] = {};
S_base[] = {};

V_SK[] = {};
V_SK20[] = {};
V_SK15[] = {};

V_AR[] = {};
S_abtarc[] = {};

V_BF[] = {};
S_load[] = {};
S_abtbf[] = {};

V_PP[] = {};
S_abtpp[] = {};

S_load[] = {};

V_EL[] = {};

S_sp2bf[] = {};
S_sp2el[] = {};
S_sp2ar[] = {};
S_sp2sk[] = {};
S_bf2ar[] = {};
S_bk2ar[] = {};
S_bk2sk[] = {};
//------------------------------------------------------------------------------
// CREATE 1st SPANDREL WALL
Call Bridge3D3SpanSpandrels;

// STORE THE SURFACES REPRESENTING CONTACT 1stSPANDREL-BACKFILL
S_sp2bf[] += { S_BF[] };
// STORE THE SURFACES REPRESENTING CONTACT 1stSPANDREL-BALLAST
S_sp2el[] += { extPP1[ {4 : (#extPP1[]-1) : 6} ] };
// STORE THE SURFACES REPRESENTING CONTACT 1stSPANDREL-ARCHES
S_sp2ar[] += { extAR[ {5 : #extAR[]-1 : 6*(TL1-1)} ] };
// AUX VARIABLES
auxsp2sk1 = 4+5*(TL1-2)+6*(aux1-TL1+1)+6;
auxsp2sk2 = 4+5*(TL1-2)+6*(aux1-TL1+1)+6*aux2sk+(5*(TL1-1)+6*(aux1-TL1+1))*2+6;
// STORE THE SURFACES REPRESENTING CONTACT 1stSPANDREL-SKEWBACKS
If (aux2sk != 0)
	S_sp2sk[] += { extSK[ {auxsp2sk1 : auxsp2sk1+6*(aux2sk-1) : 6*(TL1-1) } ] };
	S_sp2sk[] += { extSK[ {auxsp2sk2 : auxsp2sk2+6*(aux2sk-1) : 6*(TL1-1) } ] };
EndIf

// UPDATE S_Ymin[] TO INCLUDE THE PARAPET SURFACE AT Y=0
S_Ymin[] = {S_Ymin[], extPP1[{2:#extPP1[]-1:6}], extPP2[{2:#extPP2[]-1:6}]};
//------------------------------------------------------------------------------
// CREATE INNER BULK OF THE BRIDGE
Call Bridge3D3SpanInnerBulk;
// SUBROUTINE Brdg3D3SpBCKFL_EL UPDATES S_bf2ar[], S_bk2ar[] AND S_bk2sk[]

// STORE THE SURFACES REPRESENTING CONTACT BACKFILL-2ndSPANDREL
S_sp2bf[] += {S_BF[]};
//------------------------------------------------------------------------------
// CREATE 2nd SPANDREL WALL
Call Bridge3D3SpanSpandrels;

// STORE THE SURFACES REPRESENTING CONTACT 2ndSPANDREL-BALLAST
S_sp2el[] += { extPP1[ {2 : (#extPP1[]-1) : 6} ] };
// STORE THE SURFACES REPRESENTING CONTACT 2ndSPANDREL-ARCHES
S_sp2ar[] += { extAR[ {5 : #extAR[]-1 : 6*(TL1-1)} ] };
// STORE THE SURFACES REPRESENTING CONTACT 2ndSPANDREL-SKEWBACKS
If (aux2sk != 0)
	S_sp2sk[] += { extSK[ {auxsp2sk1 : auxsp2sk1+6*(aux2sk-1) : 6*(TL1-1) } ] };
	S_sp2sk[] += { extSK[ {auxsp2sk2 : auxsp2sk2+6*(aux2sk-1) : 6*(TL1-1) } ] };
EndIf

// UPDATE S_Ymax[]
S_Ymax[] = {S_Yext[]};
//------------------------------------------------------------------------------
// CREATE PHYSICAL ENTITIES FOR LATER CONVERSION INTO INPUT DATAFILE FOR FE ENGINE
//
// MATERIAL GROUPS
Physical Volume("g_msnr") = V_AR[];
Physical Volume("g_msnr") += V_SK20[];
Physical Volume("g_msnr") += V_PR[];
Physical Volume("g_msnr") += V_PP[];

Physical Volume("g_bkspdr") = V_BK[ {0 : (6*aux3+2*aux2bk)-1} ];
Physical Volume("g_bkspdr") += V_BK[ {#V_BK[]-(6*aux3+2*aux2bk) : #V_BK[]-1} ];
Physical Volume("g_bkbulk") = V_BK[ {6*aux3+2*aux2bk : #V_BK[]-(6*aux3+2*aux2bk)-1} ];

Physical Volume("g_bfspdr") = { V_BF[0], V_BF[#V_BF[]-1] };
Physical Volume("g_bfbulk") = V_BF[{1 : #V_BF[]-2}];

Physical Volume("g_sk15") = V_SK15[];

Physical Volume("g_bllst") = V_EL[];

// SURFACES TO BECOME INTERFACES (SEE REPO gmsh-crack-generator)
Physical Surface("g_sp2bf") = S_sp2bf[];
Physical Surface("g_sp2el") = S_sp2el[];
Physical Surface("g_sp2ar") = S_sp2ar[];
Physical Surface("g_sp2sk") = S_sp2sk[];
Physical Surface("g_bf2ar") = S_bf2ar[];
Physical Surface("g_bk2ar") = S_bk2ar[];
Physical Surface("g_bk2sk") = S_bk2sk[];
Physical Surface("s2in") = {S_sp2bf[], S_sp2el[], S_sp2ar[], S_sp2sk[], S_bf2ar[], S_bk2ar[], S_bk2sk[]};

// SELF WEIGHT
Physical Volume("init_udl1_0_0_-0.00002") = { V_AR[], V_PR[], V_SK[], V_PP[] };
Physical Volume("init_udl1_0_0_-0.00002") += { V_BF[0], V_BF[#V_BF[]-1] };
Physical Volume("init_udl1_0_0_-0.00002") += { V_BK[] };
Physical Volume("init_udl1_0_0_-0.000015") = V_BF[{1 : #V_BF[]-2}];
Physical Volume("init_udl1_0_0_-0.000012") = V_EL[];

// ESSENTIAL BOUNDARY CONDITIONS
Physical Surface("r_x+y+z") = S_base[];
Physical Surface("r_x+y+z") += S_abtarc[];

Physical Surface("r_x") = S_abtbk[];
Physical Surface("r_x") += S_abtbf[];
Physical Surface("r_x") += S_abtpp[];

// INITIAL CONDITIONS
Physical Surface("init_z_d_-1.88") = S_load[];  // Initial displacement
Physical Surface("init_z_v_-0.1") = S_load[];   // Initial velocity

// DYNAMIC LOADING
Physical Surface("dyna_z_a_c1_0.0") = S_load[]; // Acceleration curve

// UNCOMMENT IF ANY (OR BOTH) OF THE SIDES (Y=0 AND/OR Y=total.width) NEED TO BE RESTRAINED IN Y 
//Physical Surface("r_y") = S_Ymin[];
//Physical Surface("r_y") += S_Ymax[];
//------------------------------------------------------------------------------

Return
