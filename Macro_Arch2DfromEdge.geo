/**************************************************************************************
 *
 *  Macro Arch2DfromEdge
 *
 *  Automated generation of structured arches from an EDGE (regular quads by extrusion)
 *
 **************************************************************************************/
// MESH AN ARCH WITH REGULAR QUADS BY EXTRUSION (ROTATION)

// ARCH DEFINED IN THE XZ PLANE (Y=0), STARTING FROM A SKEWBACK EDGE L[]
// 3 ROTATIONAL EXTRUSIONS ARE EXECUTED:
//	(1) ARCH SEGMENT ADJACENT TO BACKING
//	(2) ARCH SEGMENT ADJACENT TO BACKFILL (CENTRAL)
//	(3) ARCH SEGMENT ADJACENT TO BACKING

// NOTES:  * IT IS ASSUMED THAT THE BACKING NEVER GETS PAST THE ARCH (EXTRADOS) CROWN
//	       * THE BACKING HEIGHT IS ASSUMED TO BE THE SAME AT BOTH ENDS OF THE ARCH

Macro Arch2DfromEdge

/*
IN:		L[]      = List of (transfinite) Lines connecting p001 and p003 
		Hbk      = Height of the backing, measured from the top of the skewback
		CSp      = Clear span
		ARs      = Arch rise
		R        = Radius of the arch (centre to intrados)
		Th       = Arch thickness
		TL3      = Number of points to make arch segments adjacent to backing transfinite
		TL4      = Number of points to make arch segment adjacent to backfill transfinite

OUT: 	A_x1     = X-shift of Point p003 wrt p001
		A_z      = Z-shift of Point p003 wrt p001
		p[]	     = Aux list
		p001	 = Starting Point of the first Line in L[]
		p003	 = Ending Point of the last Line in L[]
		xyz001[] = Coordinates of Point p001
		xyz003[] = Coordinates of Point p003
		phi	     = Angle (slope) of L[] (skewback side) wrt the horizontal
		signphi  = Aux function returning the sign of phi
		xyzC[]	 = Coordinates of the arch centre
		theta	 = Angle between the horizontal and the radius (centre-top of backing)
		ang1	 = Difference between theta and phi
		sign	 = Aux function returning the sign of theta
		ang2	 = Angle covered by the central arch segment (2nd extrusion)
		L0[]	 = List with end Lines after each extrusion 
		Lxtd[]	 = List with 3 Line sets {La1[],La2[],La3[]} forming the extrados
		ang[]	 = Aux angle list
		TL[]	 = Aux TL list
		lyr	     = aux iteration variable
		extL[]	 = Aux list for extrusion
		SA[]	 = List with Surfaces forming the arch
*/

// PROCESS GEOMETRIC DATA

p[] = Boundary{ Line{L[0]}; };
p001 = p[0];
p[] = Boundary{ Line{L[#L[]-1]}; };
p003 = p[1];

xyz001[] = Point{p001}; xyz003[] = Point{p003};
A_x1 = xyz003[0] - xyz001[0]; 
A_z = xyz003[2] - xyz001[2];
//Th = Sqrt(A_z^2 + A_x1^2); << GIVEN FROM Initialiser Macro

phi = Atan(A_z/A_x1);
signphi = Fmod(phi, Pi)/Fabs(Fmod(phi, Pi));

//R = (CSp^2/4 + ARs^2)/(2*ARs); << GIVEN FROM Initialiser Macro

xyzC[] = {xyz003[0]-signphi*R*Cos(phi), 0, xyz003[2]-signphi*R*Sin(phi)};

theta = Asin((Fabs(A_z)+Fabs(R*Sin(phi))+Hbk)/(R+Th))*signphi;
If (xyz003[2]-xyzC[2]+Fabs(A_z)+Hbk > R+Th)
	Printf("WARNING: Excessive backing height (beyond extrados crown)");
	Printf("         Adjust ARs or Hbk in the main .geo file calling the macros");
	Abort;
EndIf

ang1 = theta - phi;
sign = Fmod(theta, Pi)/Fabs(Fmod(theta, Pi));
ang2 = sign*Pi-2*theta; 

// EXTRUDE BY ROTATION AND REGULARISE WITH TRANSFINITE ALGORITHM

SA[] = {};
L0[] = L[];
Lxtd[] = {};
ang[] = {ang1, ang2, ang1};
TL[] = {TL3, TL4, TL3};
For seg In {1:3}
	ang = ang[seg-1]/(TL[seg-1]-1);
	For lyr In {1:TL[seg-1]-1}
		extL[] = Extrude {{0,1,0}, {xyzC[0],xyzC[1],xyzC[2]}, -ang} { Line{L0[]}; };
		Lxtd[] = {Lxtd[], -extL[3]};
		Transfinite Line {extL[3]} = 2;
		Transfinite Line {extL[{0:#extL[]-1:4}]} = 2;
		Transfinite Line {extL[{2:#extL[]-1:4}]} = 2;
		SA[] = {SA[], extL[{1:#extL[]-1:4}]};
		Transfinite Surface{extL[{1:#extL[]-1:4}]};
		Recombine Surface{extL[{1:#extL[]-1:4}]};
		L0[] = extL[{0:#extL[]-1:4}];
	EndFor
EndFor
La1[] = Lxtd[{0:TL3-2}];
La2[] = Lxtd[{TL3-1:TL3+TL4-3}];
La3[] = Lxtd[{TL3+TL4-2:TL3+TL4+TL3-4}];

Return
