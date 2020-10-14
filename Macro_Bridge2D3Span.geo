/*********************************************************************
 *
 *  Macro Bridge2D3Span
 *
 *  Automated generation of a 3-span bridge (2D strip)
 *
 *********************************************************************/
// MESH A BRIDGE STRIP DEFINED IN THE (Y=0) PLANE, CONSISTING OF:
// * 3 ARCHES
// * 2 EDGE BACKINGS
// * 2 FULL BACKINGS OVER PIERS (3 OR 4 EDGES)
// * 2 PIERS
// * BACKFILL
// * BALLAST

// NOTES:	* LOADS DEFINED ON TOP OF THE BACKFILL VIA A PREVIOUS MACRO
//	  	* SYSTEM OF COORDINATES ASSUMED TO BE:
//			X=0 ==> CENTRE OF MIDDLE SPAN
//			Z=0 ==> BASE OF PIERS LEVEL
//	  	* AS IT IS, THE CURRENT MACRO ASSUMES CONSTANT R/CLEAR SPAN.
//	    	  THIS CAN BE CHANGED BY RESORTING TO A DIFFERENT Initialiser MACRO

Macro Bridge2D3Span

/*
IN:		PH    = Pier height
		CSp   = Clear span (SEE NOTE ABOVE)
		ARs   = Arch rise
		R     = Radius of arch to intrados (SEE NOTE ABOVE)
		PWd   = Pier width (normally constant, otherwise pier under 1st skewback)
		L_z   = Z-shift from Point p001
		L_x1  = X-shift of Point p003 wrt p001
		L_x2  = X-shift of Points p004 & p005 wrt p001
		L_x3  = X-shift of Point p006 wrt p004 & p005 
		Hbk   = Height of the backing (measured from the top of pier)
		Hbf   = Height of the backfill (measured from the top of skewback)
		LdL[] = List of X coordinates of the load centres (along -X direction)
		WdL[] = List of widths for the spreading of each load

		TL1   = Number of Points across the ring width
       		[TL2   = Number of Points along central portion of skewback/backing
			    **may be omitted if skewbacks/backings have only 3 edges**]
		TL3   = Number of Points along arch segment adjacent to backing
		TL4   = Number of Points along arch segment adjacent to backfill
		NLPr  = Number of layers in the Z direction when extruding the pier
       		[TL5   = **optional, omitted by default, see notes on macro BfUStr**]

OUT:		S_SK[] = List with Surfaces forming the skewbacks
		S_PR[] = List with Surfaces forming the piers
		S_AR[] = List with Surfaces forming the arches
		S_BK[] = List with Surfaces forming the backings
		S_BF[] = List with Surfaces forming the backfill

		+ output from embedded macros
*/
//------------------------------------------------------------------------------
// INITIALISE Surface LISTS TO STORE DIFFERENT MATERIALS/GROUPS
S_SK[] = {};
S_PR[] = {};
S_AR[] = {};
S_BK[] = {};
S_BF[] = {};
//------------------------------------------------------------------------------
// INITIAL POINT FROM WHICH TO START GEOMETRY GENERATION
p001 = newp; Point(p001) = {-CSp/2-Fabs(L_x3)-Fabs(L_x2), 0, PH+Fabs(L_z)};
//------------------------------------------------------------------------------
// 1st SKEWBACK
Call Trapezium2DFromPoint;

// UPDATE SKEWBACK Surface LIST
S_SK[] = {S_SK[], S1[], S2[], S3[]};	// << S2[] MAY BE EMPTY (THEN IGNORED) 
//------------------------------------------------------------------------------
// 1st PIER
PL[] = {L2_1[], L2_2[], L2_3[]};	// << L2_2[] MAY BE EMPTY (THEN IGNORED)
Call Pier2DFromEdge;

// UPDATE PIER Surface LIST
S_PR[] = {S_PR[], SP[]};
//------------------------------------------------------------------------------
// 1st ARCH GENERATED 'BACKWARDS' (-X DIRECTION) FROM 1st SKEWBACK
L[] = L3[];
Call Arch2DfromEdge;
LA1a1[] = La1[];
LA1a2[] = La2[];
LA1a3[] = La3[];

// UPDATE ARCH Surface LIST
S_AR[] = {S_AR[], SA[]};
//------------------------------------------------------------------------------
// EDGE BACKING OVER 1st ARCH
Lbk2[] = LA1a3[];
Call Backing1;

// UPDATE INPUT LIST FOR BACKFILL LATER
Lbkarc[] = {-Lbk4_3[], -LA1a2[{#LA1a2[]-1:0:-1}]};

// UPDATE BACKING Surface LIST
S_BK[] = {S_BK[], SB3[]};
//------------------------------------------------------------------------------
// 2nd ARCH GENERATED 'FORWARDS' (+X DIRECTION) FROM 1st SKEWBACK
L[] = L1[];
Call Arch2DfromEdge;
LA2a1[] = La1[];
LA2a2[] = La2[];
LA2a3[] = La3[];

// UPDATE ARCH Surface LIST
S_AR[] = {S_AR[], SA[]};
//------------------------------------------------------------------------------
// BACKING OVER 1st PIER
Lbk1[] = LA2a1[];
Lbk2[] = -LA1a1[{#LA1a1[]-1:0:-1}];
Lbk3[] = L4[];			// << L4[] MAY BE EMPTY (THEN IGNORED)
If (L_x2 == 0)
	Call Backing2;
Else
	Call Backing3;
EndIf

// UPDATE INPUT LIST FOR BACKFILL LATER
Lbkarc[] = {Lbkarc[], Lbk4_3[{#Lbk4_3[]-1:0:-1}]};
Lbkarc[] = {Lbkarc[], Lbk4_2[{#Lbk4_2[]-1:0:-1}]}; // << Lbk4_2[] MAY BE EMPTY
Lbkarc[] = {Lbkarc[], Lbk4_1[]};
Lbkarc[] = {Lbkarc[], LA2a2[]};

// UPDATE BACKING Surface LIST
S_BK[] = {S_BK[], SB1[], SB2[], SB3[]};	// << SB2[] MAY BE EMPTY (THEN IGNORED)
//------------------------------------------------------------------------------
// 2nd SKEWBACK
L3[] = L0[];
Call Trapezium2DFromEdge;

// UPDATE SKEWBACK Surface LIST
S_SK[] = {S_SK[], S1[], S2[], S3[]};	// << S2[] MAY BE EMPTY (THEN IGNORED)
//------------------------------------------------------------------------------
// 2nd PIER
PL[] = {L2_1[], L2_2[], L2_3[]};	// << L2_2[] MAY BE EMPTY (THEN IGNORED)
Call Pier2DFromEdge;

// UPDATE PIER Surface LIST
S_PR[] = {S_PR[], SP[]};
//------------------------------------------------------------------------------
// 3rd ARCH GENERATED 'FORWARDS' (+X DIRECTION) FROM 2nd SKEWBACK
L[] = L1[];
Call Arch2DfromEdge;
LA3a1[] = La1[];
LA3a2[] = La2[];
LA3a3[] = La3[];

// UPDATE ARCH Surface LIST
S_AR[] = {S_AR[], SA[]};
//------------------------------------------------------------------------------
// BACKING OVER 2nd PIER
Lbk1[] = LA3a1[];
Lbk2[] = LA2a3[];
Lbk3[] = L4[];		// << L4[] MAY BE EMPTY (THEN IGNORED)
If (L_x2 == 0)
	Call Backing2;
Else
	Call Backing3;
EndIf

// UPDATE INPUT LIST FOR BACKFILL LATER
Lbkarc[] = {Lbkarc[], Lbk4_3[{#Lbk4_3[]-1:0:-1}]};
Lbkarc[] = {Lbkarc[], Lbk4_2[{#Lbk4_2[]-1:0:-1}]}; // << Lbk4_2[] MAY BE EMPTY
Lbkarc[] = {Lbkarc[], Lbk4_1[]};
Lbkarc[] = {Lbkarc[], LA3a2[]};

// UPDATE BACKING Surface LIST
S_BK[] = {S_BK[], SB1[], SB2[], SB3[]};	// << SB2[] MAY BE EMPTY (THEN IGNORED)
//------------------------------------------------------------------------------
// EDGE BACKING OVER 3rd ARCH
Lbk2[] = LA3a3[];
Call Backing1;

// UPDATE BACKING Surface LIST
S_BK[] = {S_BK[], SB3[]};
//------------------------------------------------------------------------------
// BACKFILL
Lbkarc[] = {Lbkarc[], Lbk4_3[{#Lbk4_3[]-1:0:-1}]};
Call BackfillUnstructured;

// UPDATE BACKFILL Surface LIST
S_BF[] = {S_BF[], Sbf};
//------------------------------------------------------------------------------

Return
