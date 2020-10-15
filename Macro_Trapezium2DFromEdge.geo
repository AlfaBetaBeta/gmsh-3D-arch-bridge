/***************************************************************************************************
 *
 *  Macro Trapezium2DFromEdge
 *
 *  Automated generation of structured trapezia from an EDGE (regular quads and triangular elements)
 *
 ***************************************************************************************************/
// MESH A TRAPEZIUM WITH REGULAR QUADS AND TRIANGULAR ELMTS (WITH JUST 1/2 ELMT(S) ATTACHED TO EACH TRAPEZIUM VERTEX,
// I.E. NO VERTEX IS A RADIAL ORIGIN)

// TRAPEZIUM DEFINED IN THE XZ PLANE (Y=0), STARTING FROM THE EDGE L3[]
// Point p001 STARTING POINT OF THE FIRST LINE IN L3[]
// Point p002 SHIFTED FROM p001 BY (0,           0, L_z)
// Point p003 SHIFTED FROM p001 BY (L_x1,        0, L_z)
// Point p004 SHIFTED FROM p001 BY (L_x2,        0, 0)
// Point p005 SHIFTED FROM p001 BY (L_x2,        0, L_z)
// Point p006 SHIFTED FROM p001 BY (L_x2 + L_x3, 0, L_z)

Macro Trapezium2DFromEdge

/*
IN:		L3[]  	 = List of (transfinite) Lines connecting p001 and p003 
		L_x2  	 = X-shift of Points p004 & p005 wrt p001 (may be zero)
		L_x3  	 = X-shift of Point p006 wrt p004 & p005 (may be zero)
		TL2   	 = Number of points to make central horizontal edges transfinite
			   (TL2 may be omitted if L_x2 is set to zero)
		TL1   	 = Number of points to make side edges transfinite
			   (coincides with #L3[] but can be retrieved globally)

OUT: 		L_x1     = X-shift of Point p003 wrt p001
		L_z      = Z-shift of (p002,p003,p005,p006) wrt p001
		
		p001	 = Starting Point of the first Line in L3[]
		p003	 = Ending Point of the last Line in L3[]
		p[]	 = Aux list
		xyz001[] = Coordinates of Point p001
		xyz003[] = Coordinates of Point p003
		dx1	 = Width of vertical layers along L_x1
		dx2	 = Width of vertical layers along L_x2
		dx3	 = Width of vertical layers along L_x3
		dz	 = Height of horizontal layers
		pS[]	 = Aux list 
		pEt[]	 = Aux list
		pE_1[]   = Aux list
		L1[]	 = List with Points forming edge p004-p006
		L2_1[]	 = List with Points forming edge p002-p003
		L2_2[]	 = List with Points forming edge p002-p005
		L2_3[]	 = List with Points forming edge p005-p006
		L1_R[]	 = List with Points along internal line p001-p002
		L3_L[]	 = List with Points along internal line p004-p005
		LS[]	 = Aux list 
		LE[]	 = Aux list 
		Li[] 	 = Aux list
		S1[]	 = List with all surfaces embedded in triangle p001-p002-p003
		S2[]	 = List with all surfaces embedded in rectangle p001-p002-p005-p004
		S3[]	 = List with all surfaces embedded in triangle p004-p005-p006
		step	 = Index variable moving along layers in Z-direction
		sub1	 = Index variable moving along layers in X-direction
		ext[]	 = Aux list for extrusion
		L	 = Aux variable for Line definition
		sf	 = Aux variable, surface counter
		LL	 = Aux variable for Line Loop definition
		S	 = Aux variable for Plane Surface definition
*/

// INITIALISE VARIABLES AND LISTS
p[] = Boundary{ Line{L3[0]}; };
p001 = p[0];
p[] = Boundary{ Line{L3[#L3[]-1]}; };
p003 = p[1];
xyz001[] = Point{p001}; xyz003[] = Point{p003};
L_x1 = xyz003[0] - xyz001[0];
L_z = xyz003[2] - xyz001[2];

// TL1 = #L3[]+1; << REDUNDANT BUT CAN BE UNCOMMENTED IF NECESSARY FOR CHECKING

dx1 = L_x1/(TL1-1);
If (L_x2 != 0)
	dx2 = L_x2/(TL2-1);
Else
	dx2 = 0;
EndIf
dx3 = L_x3/(TL1-1);
dz = L_z/(TL1-1);

pS[] = {p001};
pEt[] = {};

L1[] = {};
L1_R[] = {};
L2_1[] = {};
L2_2[] = {};
L2_3[] = {};
L3_L[] = {};
L4[] = {};

LS[] = {};
LE[] = {};
Li[] = {};

S1[] = {};
S2[] = {};
S3[] = {};

// CONSTRUCTION OF TRIANGULAR BLOCK p001-p002-p003
For step In {1:TL1-1}
	p[] = Boundary{ Line{L3[step-1]}; };
	pE_1[] = {p[1]};
	For sub1 In {1:step}
		ext[] = Extrude {0,0,dz} {Point{pS[{sub1-1}]};};
		pEt[] = {pEt[], ext[0]};
		Li[] = {Li[], ext[1]};
		
		If (sub1 == 1)
			L1_R[] = {L1_R[], ext[1]};
		Else
			L = newl;
			Line(L) = {pEt[{#pEt[]-2}], pEt[{#pEt[]-1}]};
			If (step == TL1-1)
				L2_1[] = {L2_1[],L};
			EndIf
			LE[] = {LE[], L};
		EndIf

		If (sub1 == step)
			L = newl;
			Line(L) = {pEt[{#pEt[]-1}], pE_1[0]};
			If (step == TL1-1)
				L2_1[] = {L2_1[], L};
			EndIf
			LE[] = {LE[], L};
		EndIf
	EndFor
	For sf In {1:step-1}
		LL = newll;
		Line Loop(LL) = {LE[{sf-1}], -Li[{sf}], -LS[{sf-1}], Li[{sf-1}]};
		S = news;
		Plane Surface(S) = LL;
		S1[] = {S1[], S};
	EndFor
	LL = newll;
	Line Loop(LL) = {LE[{step-1}], -L3[{step-1}], Li[{step-1}]};
	S = news; Plane Surface(S) = LL;
	S1[] = {S1[], S};

	pS[] = {pEt[], pE_1[]};
	pEt[] = {};
	
	LS[] = LE[];
	LE[] = {};
	Li[] = {};
EndFor


// CONSTRUCTION OF CENTRAL RECTANGULAR BLOCK p001-p002-p005-p004
LS[] = L1_R[];
If (dx2 != 0)
	LS[] = L1_R[];
	For lyr In {1:TL2-1}
		ext[] = Extrude {dx2,0,0} { Line{LS[]}; };
		L4[] = {L4[], ext[3]};
		L2_2[] = {L2_2[], ext[#ext[]-2]};
		S2[] = {S2[], ext[{1:#ext[]-1:4}]};
		LS[] = ext[{0:#ext[]-1:4}];
	EndFor
	L3_L[] = LS[];
EndIf


// CONSTRUCTION OF TRIANGULAR BLOCK p004-p005-p006

If (dx3 != 0)
	For step In {1:TL1-2}
		ext[] = Extrude {dx3,0,0} { Line{LS[{1:#LS[]-1}]}; };
		pS[] = Boundary{ Line{LS[0]}; };
		pE[] = Boundary{ Line{ext[3]}; };
		L = newl;
		Line(L) = {pS[0], pE[0]};
		L1[] = {L1[], L};
		L2_3[] = {L2_3[], ext[{#ext[]-2}]};
		LE[] = ext[{0:#ext[]-1:4}];

		LL = newll;
		Line Loop(LL) = {LS[{0}], -ext[{3}], -L1[{#L1[]-1}]};
		S = news;
		Plane Surface(S) = LL;
		S3[] = {S3[], S};
		S3[] = {S3[], ext[{1:#ext[]-1:4}]};
	
		LS[] = LE[];
		LE[] = {};
	EndFor
	pS[] = Boundary{ Line{LS[0]}; };
	ext[] = Extrude {dx3,0,0} { Point{pS[1]}; };
	L2_3[] = {L2_3[], ext[1]};

	L = newl;
	Line(L) = {pS[0], ext[0]};
	L1[] = {L1[], L};

	LL = newll;
	Line Loop(LL) = {LS[0], ext[1], -L};
	S = news;
	Plane Surface(S) = LL;
	S3[] = {S3[], S};
EndIf
If (dx3==0 && dx2==0)
	L1[] = L1_R[];
EndIf
If (dx3==0 && dx2!=0)
	L1[] = L3_L[];
EndIf

Transfinite Line "*" = 2;
Transfinite Surface{S1[]}; Recombine Surface{S1[]};
If (dx2 != 0)
	Transfinite Surface{S2[]}; Recombine Surface{S2[]};
EndIf
If (dx3 != 0)
	Transfinite Surface{S3[]}; Recombine Surface{S3[]};
EndIf

Return
