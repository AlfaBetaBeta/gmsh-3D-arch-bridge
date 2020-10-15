/***********************************************************************************************************************
 *
 *  Macro Backing2
 *
 *  Automated generation of the backing contour from 2 EDGES (sides only) (regular quads and distorted triangular elmts)
 *
 ***********************************************************************************************************************/
// MESH A BACKING CONTOUR WITH REGULAR QUADS AND TRIANGULAR ELMTS (WHEREBY NO VERTEX IS A RADIAL ORIGIN)

// BACKING DEFINED IN THE XZ PLANE (Y=0), STARTING FROM 2 CIRCULAR ARCH EDGES AND WITHOUT SKEWBACK HORIZONTAL EDGE.

// NOTES:	* THE 2 EDGES MUST EXIST, I.E. THE INPUT LISTS MUST BE NON-EMPTY
//		* CASES WITH 1 OR 3 EDGES ARE TREATED ON SEPARATE MACROS
//		* TL3 IS NORMALLY INHERITED FROM PREVIOUS MACROS

Macro Backing2

/*
IN:		Lbk1[] 		  = List of (transfinite) Lines in edge salient arch - backing
		Lbk2[] 		  = List of (transfinite) Lines in edge incoming arch - backing
		TL3    		  = Number of Points on transfinite curved edges Lbk1[], Lbk2[]
	
OUT: 		dzL[]	          = Aux list with Z intervals between p001 and p003
		dx1L[]	          = Aux list with X intervals between p001 and p003
		dx3L[]	          = Aux list with X intervals between p004 and p006
	
		p001, xyz001[]    = Corner Point and its coordinates
		p003, xyz003[]    = Corner Point and its coordinates
		p004, xyz004[]    = Corner Point and its coordinates
		p006, xyz006[]    = Corner Point and its coordinates
		L	          = Aux variable for Line definition
		p[]	          = Aux Point list
		xyzS[], xyzE[]    = Aux Point coordinates list
		pS[], pEt[], pE[] = Aux Point lists
		Lbk12[] 	  = Line list of internal 'edge'
		Lbk4_1[] 	  = Line list (part of top edge)
		Lbk4_2[]	  = Line List (WILL BE RETURNED EMPTY AS THERE IS NO CENTRAL
			            RECTANGLE IN THIS CASE, BUT IS LEFT FOR CONSISTENCY)
		Lbk4_3[] 	  = Line list (part of top edge)
		Lbk45[] 	  = Line list of internal 'edge'
		LS[], LE[], Li[]  = Aux Line lists during loop iteration 
		SB1[], SB3[]      = Lists with Surfaces forming the backing
		SB2[]		  = EMPTY list of Surfaces (central block not present)
			            RETURNED FOR CONSISTENCY
		step, sub1	  = Aux variables for loop iteration
		ext[]		  = Aux list for iterative extrusion
		pE_1[]		  = Aux Point list
		sf		  = AUx variable for loop iteration
		LL 		  = Aux variables for Line Loop definition
		S		  = Aux variables for Plane Surface definition
		lyr		  = Aux variables for loop iteration
		Li		  = Aux variables for loop iteration
*/

// INITIALISE VARIABLES AND LISTS
//TL3 = #Lbk1[]+1;
// NORMALLY TL3 SPECIFIED FROM PREVIOUS MACROS
// LINE ABOVE CAN BE UNCOMMENTED IN CASE IT NEEDS TO BE COMPUTED HERE

dzL[] = {};
dx1L[] = {};
For L In {0:#Lbk1[]-1}
	p[] = Boundary{ Line{Lbk1[L]}; };
	xyzS = Point{p[0]};
	xyzE = Point{p[1]};
	dzL[] = {dzL[], xyzE[2]-xyzS[2]};
	dx1L[] = {dx1L[], xyzE[0]-xyzS[0]};
	If (L == 0)
		p001 = p[0];
	EndIf
	If (L == #Lbk1[]-1)
		p003 = p[1];
	EndIf
EndFor
xyz001[] = Point{p001};
xyz003[] = Point{p003};

dx3L[] = {};
For L In {0:#Lbk2[]-1}
	p[] = Boundary{ Line{Lbk2[#Lbk2[]-(L+1)]}; };
	xyzS = Point{p[0]};
	xyzE = Point{p[1]};
	dx3L[] = {dx3L[], xyzS[0]-xyzE[0]};
	If (L == 0)
		p004 = p[1];
	EndIf
	If (L == #Lbk2[]-1)
		p006 = p[0];
	EndIf
EndFor
xyz004[] = Point{p004};
xyz006[] = Point{p006};

pS[] = {p001};
pEt[] = {};

Lbk12[] = {};
Lbk4_1[] = {};
Lbk4_2[] = {};	// << WILL REMAIN EMPTY WHEN RETURNED BUT IT IS STILL NECESSARY GLOBALLY
Lbk4_3[] = {};
Lbk45[] = {};

LS[] = {};
LE[] = {};
Li[] = {};

SB1[] = {};
SB3[] = {};
SB2[] = {};	// << WILL REMAIN EMPTY WHEN RETURNED BUT IT IS STILL NECESSARY GLOBALLY

// CONSTRUCTION OF TRIANGULAR BLOCK p001-p002-p003
For step In {1:TL3-1}
	p[] = Boundary{ Line{Lbk1[step-1]}; };
	pE_1[] = {p[1]};
	For sub1 In {1:step}
		ext[] = Extrude {0,0,dzL[step-1]} {Point{pS[{sub1-1}]};};
		pEt[] = {pEt[], ext[0]};
		Li[] = {Li[], ext[1]};
		
		If (sub1 == 1)
			Lbk12[] = {Lbk12[], ext[1]};
		Else
			L = newl;
			Line(L) = {pEt[{#pEt[]-2}], pEt[{#pEt[]-1}]};
			If (step == TL3-1)
				Lbk4_1[] = {Lbk4_1[],L};
			EndIf
			LE[] = {LE[], L};
		EndIf

		If (sub1 == step)
			L = newl;
			Line(L) = {pEt[{#pEt[]-1}], pE_1[0]};
			If (step == TL3-1)
				Lbk4_1[] = {Lbk4_1[], L};
			EndIf
			LE[] = {LE[], L};
		EndIf
	EndFor
	Transfinite Line {Li[], LE[]} = 2;
	For sf In {1:step-1}
		LL = newll;
		Line Loop(LL) = {LE[{sf-1}], -Li[{sf}], -LS[{sf-1}], Li[{sf-1}]};
		S = news;
		Plane Surface(S) = LL;
		SB1[] = {SB1[], S};
	EndFor
	LL = newll;
	Line Loop(LL) = {LE[{step-1}], -Lbk1[{step-1}], Li[{step-1}]};
	S = news; Plane Surface(S) = LL;
	SB1[] = {SB1[], S};

	pS[] = {pEt[], pE_1[]};
	pEt[] = {};
	
	LS[] = LE[];
	LE[] = {};
	Li[] = {};
EndFor
Lbk45[] = Lbk12[];


// CONSTRUCTION OF TRIANGULAR BLOCK p004-p005-p006
LS[] = Lbk45[];
Li[] = {};
LE[] = {};
For step In {1:TL3-1}
	pE[] = Boundary{ Line{Lbk2[{#Lbk2[]-step}]}; };
	For sub1 In {1:TL3-step}
		pS[] = Boundary{ Line{LS[sub1-1]}; };
		If (sub1 == 1)
			L = newl; Line(L) = {pS[1], pE[0]};
			Li[] = {Li[], L};
			If (sub1 == TL3-step)
				Lbk4_3[] = {Lbk4_3[], -L};
			EndIf
		Else
			ext[] = Extrude {dx3L[step-1],0,0} { Point{pS[1]}; };
			Li[] = {Li[], ext[1]};
			L = newl; Line(L) = {pE[0], ext[0]};
			LE[] = {LE[], L};
			pE[] = Boundary{ Line{-L}; };
			If (sub1 == TL3-step)
				Lbk4_3[] = {Lbk4_3[], -ext[1]};
			EndIf
		EndIf
	EndFor
	Transfinite Line {Li[], LE[]} = 2;

	LL = newll;
	Line Loop(LL) = {LS[0], Li[0], Lbk2[{#Lbk2[]-step}]};
	S = news;
	Plane Surface(S) = LL;
	SB3[] = {SB3[], S};
	For sf In {1:#LS[]-1}
		LL = newll;
		Line Loop(LL) = {LS[sf], Li[sf], -LE[{sf-1}], -Li[{sf-1}]};
		S = news;
		Plane Surface(S) = LL;
		SB3[] = {SB3[], S};
	EndFor

	LS[] = LE[];
	LE[] = {};
	Li[] = {};
EndFor

Transfinite Surface {SB1[]} Right; //Recombine Surface {SB1[]};
Transfinite Surface {SB3[]} Left; //Recombine Surface {SB3[]};
// UNCOMMENT Recombine TO GENERATE QUADS INSTEAD OF TRIANGLES

Return
