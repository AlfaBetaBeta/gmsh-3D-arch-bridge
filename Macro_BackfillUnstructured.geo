/************************************************************************************************************************
 *
 *  Macro BackfillUnstructured
 *
 *  Automated generation of the backfill layer resting on N arches and (N+1) backing contours, accounting for load strips
 *  (solely triangular elmts, unstructured)
 *
 ************************************************************************************************************************/
// MESH BACKFILL AREA WITHOUT TRANSFINITE ALGORITHM, WITHOUT RECOMBINING

// BACKFILL DEFINED IN THE XZ PLANE (Y=0), WITH BOTTOM EDGES FORMED BY ARCHES AND SKEWBACK Line LISTS STEMMING FROM PREVIOUSLY EXECUTED MACROS

// NOTES:	* LdL[] AND WdL[] LISTS MUST HAVE THE SAME LENGTH
//		* A ZERO WIDTH IN WdL[] DOES NOT CAUSE ERROR BY EXTRUSION BUT
//		  SHOULD BE AVOIDED AS THE ALLOCATION OF POINTS IN THE LINES
//		  BETWEEN LOAD STRIPS ASSUMES ALL WIDTHS TO BE FINITE
//		* TL2, TL3 AND TL4 WILL NORMALLY BE INHERITED FROM PREVIOUSLY
//		  EXECUTED MACROS
//		* IT IS ASSUMED THAT THERE IS ALWAYS A NONZERO DISTANCE BETWEEN
//		  p003/p004 AND THE FIRST/LAST LOAD STRIP, I.E. THE FIRST AND
//		  LAST LINES STORED IN Lbf[] ARE NOT LOAD STRIPS!
//		* ALSO, THE DISTANCE BETWEEN LOAD STRIPS HAS TO BE FINITE, I.E.
//		  THERE ARE (#Lbf[]-1) LINES CONNECTING THE (#Lbf[]) LOAD STRIPS

/* WARNING:

   BY DEFAULT, THIS MACRO LEAVES THE SURFACE Sbf UNSTRUCTURED. ONLY THE
   BOTTOM EDGES STORED IN Lbkarc[] ARE TRANSFINITE, AS THEY RESULT FROM
   PREVIOUSLY EXECUTED MACROS, AS WELL AS THE LINES REPRESENTING LOAD
   STRIPS. OTHERWISE ALL OTHER LINES REMAIN FREE AND ARE DISCRETISED
   ACCORDING TO THE MESHING PARAMETERS SPECIFIED IN THE CALLING MAIN FILE.
   IN THIS DEFAULT CASE, TL5 MAY BE OMITTED!
   TO CHANGE THIS, UNCOMMENT LINES APPLYING TRANSFINITE ALGORITHM (96,132,133)
   AND BLOCK (106-128). Sbf WILL THEN BECOME TRANSFINITE, BUT IN THE CURRENT
   MACRO VERSION THIS CAN ONLY BE SUSTAINED FOR A LOW TO MODERATE NUMBER
   OF LOADS.
*/

Macro BackfillUnstructured

/*
IN:		Lbkarc[]      = List of top edge Lines of backing and arches
		Hbf	        = Height of the backfill layer measured from the backing
		LdL[]	      = List of X coordinates of the load centres
			            (from p003 along negative X direction)
		WdL[]	      = List of widths for the spreading of each load
		TL5	        = Number of Points to make side Lines LbfE and LbfW transfinite
			          (See important note above)
		TL2	        = Number of Points along top edge of backing (rectangle)
		TL3	        = Number of Points along top edge of backing (triangle(s))
		TL4	        = Number of Points along top edge of arch (between backings)

OUT:		p[]	          = Aux Point list
		p001 ... p004 = Corner Points
		xyz001[]      = Coordinates of Point p001
		xyz003[]      = Coordinates of Point p003
		ext[]         = Aux list for extrusions
		LbfE          = Side Line connecting p002 to p003
		LbfW          = Side Line connecting p001 to p004
		Lbf[]         = List with Lines of top edge
		pS, pE        = Aux Point IDs
		sub           = Looping variable
		L             = Aux LineID
		LL            = Aux Line Loop ID
		Sbf           = Surface of backfill (single Surface, not a list!)
*/

// LOCATE AND ASSIGN EDGE Points OF Lbkarc[] 
p[] = Boundary{ Line{Lbkarc[0]}; };
p001 = p[0];
xyz001[] = Point{p001};
p[] = Boundary{ Line{Lbkarc[{#Lbkarc[]-1}]}; };
p002 = p[1];

// VERTICAL LINE STARTING FROM p002
ext[] = Extrude {0,0,Hbf} { Point{p002}; };
p003 = ext[0];
LbfE = ext[1];
xyz003[] = Point{p003};

// LOOP TO GENERATE LINES ON TOP EDGE OF BACKFILL
Lbf[] = {};
pS = p003;
For sub In {1:#LdL[]}
	pE = newp;
	Point(pE) = {LdL[sub-1]+WdL[sub-1]/2, xyz003[1], xyz003[2]};
	L = newl;
	Line(L) = {pS, pE};
	Lbf[] = {Lbf[], L};
	pS = pE;
	pE = newp;
	Point(pE) = {LdL[sub-1]-WdL[sub-1]/2, xyz003[1], xyz003[2]};
	L = newl;
	Line(L) = {pS, pE};
	Lbf[] = {Lbf[], L};
	//Transfinite Line {L} = 2; // << SEE WARNING ABOVE
	pS = pE;
EndFor
ext[] = Extrude {0,0,Hbf} { Point{p001}; };
p004 = ext[0];
LbfW = ext[1];
L = newl;
Line(L) = {pE, p004};
Lbf[] = {Lbf[], L};

/***********************************************************************
// REGULARISE SIDE LINES
Transfinite Line {LbfE, LbfW} = TL5;
Printf("NOTE: I shouldnt pop up if the block were really commented out");
// REGULARISE TOP LINES THAT ARE NOT LOAD STRIPS
TLaux = #Lbkarc[]+1;
xref = Fabs(xyz003[0] - xyz001[0]);
xS = xyz003[0];
sTL = 0;
For lin In {0:#Lbf[]-2:2}
	xlin = Fabs(xS-LdL[lin/2]);
	TLlin = (Floor(xlin/xref*TLaux)>2) ? Floor(xlin/xref*TLaux) : 2; 
	Transfinite Line {Lbf[lin]} = TLlin;
	sTL = sTL + TLlin;
	If (sTL > TLaux-2)
		Printf("WARNING: Excessive number of loads to make Sbf transfinite");
		Printf("         Increase TL2/TL3/TL4 in the main calling .geo file and retry");
		Abort;
	EndIf
	xS = LdL[lin/2];
EndFor
Transfinite Line {Lbf[#Lbf[]-1]} = ((TLaux-sTL) > 2) ? TLaux-sTL : 2;
************************************************************************/

LL = newll; Line Loop(LL) = {Lbf[], -LbfW, Lbkarc[], LbfE};
Sbf = news; Plane Surface(Sbf) = LL;
//Transfinite Surface{Sbf} = {p001, p002, p003, p004}; // << SEE WARNING ABOVE
//Recombine Surface{Sbf}; // << SEE WARNING ABOVE

Return
