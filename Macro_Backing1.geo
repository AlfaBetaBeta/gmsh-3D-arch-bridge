/***********************************************************************************************************************
 *
 *  Macro Backing1
 *
 *  Automated generation of the backing contour from 1 EDGE (1 side only) (regular quads and distorted triangular elmts)
 *
 ***********************************************************************************************************************/
// MESH A BACKING CONTOUR WITH REGULAR QUADS AND TRIANGULAR ELMTS (WHEREBY NO VERTEX IS A RADIAL ORIGIN)

// BACKING DEFINED IN THE XZ PLANE (Y=0), STARTING FROM A CIRCULAR ARCH EDGE AND WITHOUT SKEWBACK HORIZONTAL EDGE OR THE SYMMETRIC CIRCULAR EDGE

// NOTES:	* THE 1 EDGE MUST EXIST, I.E. THE INPUT LIST MUST BE NON-EMPTY
//		* CASES WITH 2 OR 3 EDGES ARE TREATED ON SEPARATE MACROS
//		* TL3 IS NORMALLY INHERITED FROM PREVIOUS MACROS
//		* IT IS ASSUMED THAT THE BACKFILL IS BUILT FROM THE EDGE OF
//		  AN INCOMING ARCH, AS THIS WILL NORMALLY BE THE CASE IN MORE
//		  GLOBAL MACROS BUILDING THE ENTIRE BRIDGE. IF THE ARCH IS
//		  SALIENT, ADJUSTMENTS MUST BE MADE TO Lbk2[]

Macro Backing1

/*
IN:		Lbk2[] 		  = List of (transfinite) Lines in edge incoming arch - backing
		TL3    		  = Number of Points on transfinite curved edge Lbk2[]
	
OUT:		dzL[]	          = Aux list with Z intervals between p001 and p003
		dx3L[]	          = Aux list with X intervals between p004 and p006
		p004, xyz004[]    = Corner Point and its coordinates
		p006, xyz006[]    = Corner Point and its coordinates
		L	          = Aux variable for Line definition
		p[]	          = Aux Point list
		xyzS[], xyzE[]    = Aux Point coordinates list
		pS[], pEt[], pE[] = Aux Point lists
		Lbk1[]		  = Line list (edge opposite to circular arch)
		Lbk4_3[] 	  = Line list (top edge)
		LS[], LE[], Li[]  = Aux Line lists during loop iteration 
		SB3[] 	          = List with Surfaces forming the backing
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
//TL3 = #Lbk2[]+1;
// NORMALLY TL3 SPECIFIED FROM PREVIOUS MACROS
// LINE ABOVE CAN BE UNCOMMENTED IN CASE IT NEEDS TO BE COMPUTED HERE

dzL[] = {};
dx3L[] = {};
For L In {0:#Lbk2[]-1}
	p[] = Boundary{ Line{Lbk2[#Lbk2[]-(L+1)]}; };
	xyzS = Point{p[0]};
	xyzE = Point{p[1]};
	dzL[] = {dzL[], xyzS[2]-xyzE[2]};
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

Lbk1[] = {};
Lbk4_3[] = {};

LS[] = {};
LE[] = {};
Li[] = {};

SB3[] = {};


// CONSTRUCTION OF TRIANGULAR BLOCK p004-p005-p006
p[] = p004;
For step In {1:TL3-1}
	ext[] = Extrude {0,0,dzL[step-1]} { Point{p[0]}; };
	LS[] = {LS[], ext[1]};
	p[] = ext[0];
	Lbk1[] = {Lbk1[], ext[1]};
EndFor
Transfinite Line {LS[]} = 2;

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

Transfinite Surface {SB3[]}; //Recombine Surface {SB3[]};
// UNCOMMENT Recombine TO GENERATE QUADS INSTEAD OF TRIANGLES

Return
