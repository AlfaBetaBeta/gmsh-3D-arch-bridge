/******************************************************************************************************************************
 *
 *  Macro SurfaceVolumeRetrievalSkewback
 *
 *  Automatic retrieval of Surfaces & Volumes from the extruded (in +Y) skewbacks for the purpose of defining Physical entities
 *
 ******************************************************************************************************************************/
// RETRIEVAL OF ALL SURFACES AT Y=extr.width FROM THE EXTRUDED SKEWBACKS, AS WELL AS THE GENERATED VOLUMES

// NOTES:	* THIS MACRO FEEDS ORIGINALLY FROM MACRO Bridge3D3Span, HENCE
//	    	  ALL LIMITATIONS AND SPECIFICITIES NOTED THERE APPLY HERE AS WELL

Macro SurfaceVolumeRetrievalSkewback

/*
IN:		*args from previous macros

INOUT:		S_Yext[]   = List of all Surfaces at Y>0 (with Y = width of extrusion)
		    	     (updated here with the skewbacks contribution)
		V_SK[]     = List of ALL Volumes forming the skewbacks in the current extrusion
		V_SK20[]   = List of WEDGE Volumes forming the skewbacks in the current extrusion
		V_SK15[]   = List of HEXAHEDRAL Volumes forming the skewbacks in the current extrusion
		aux1	   = Number of elements in 1 layer of each triangular part of the skewback
		aux2sk	   = Number of elements in 1 layer of the central (rectangular)
		     	     part of the skewback should it be present

		+ other aux variables
*/
//------------------------------------------------------------------------------
// INITIALISE AUX LISTS
If (L_x2 == 0)
	aux2sk = 0;
Else
	aux2sk = (TL1-1)*(TL2-1);
EndIf

aux1 = (TL1/2)*(TL1-1);
add[] = {5};
For (1:aux1-2)
	add[] = {add[], 6}; 	
EndFor
For j In {2:TL1-1}
	add[{ (j/2*(j-1))-1 }] = 5;	
EndFor
add2[] = {0};
addsum = 0;
For j In {1:aux1-1}
	addsum = addsum + add[j-1];
	add2[] = {add2[], addsum};
EndFor
//------------------------------------------------------------------------------
// SIMULTANEOUS UPDATE OF S_Yext[] AND V_SK[], SPLITTING INTO V_SK15[] AND V_SK20[]
//------------------------------------------------------------------------------
// 1st SKEWBACK (1/3)
suma = 0;
sumv = 1;
For j In {0:aux1-1}
	S_Yext[] = {S_Yext[], extSK[suma+add2[j]]};
	V_SK[] = {V_SK[], extSK[sumv+add2[j]]};
EndFor

// SPLIT V_SK[] INTO WEDGES AND HEXAHEDRONS
For j In {0:aux1-2}
	If (add[j] == 5)
		V_SK15[] = {V_SK15[], extSK[sumv+add2[j]]};
	ElseIf (add[j] == 6)
		V_SK20[] = {V_SK20[], extSK[sumv+add2[j]]};
	EndIf
EndFor
V_SK15[] = {V_SK15[], extSK[sumv+add2[aux1-1]]};
//------------------------------------------------------------------------------
// 1st SKEWBACK (2/3) IF PRESENT
suma = suma+add2[aux1-1]+5;
sumv = sumv+add2[aux1-1]+5;
If (L_x2 != 0)
	For (1:aux2sk)
		S_Yext[] = {S_Yext[], extSK[suma]};
		V_SK[] = {V_SK[], extSK[sumv]};
		V_SK20[] = {V_SK20[], extSK[sumv]};
		suma = suma+6;
		sumv = sumv+6;
	EndFor
EndIf
//------------------------------------------------------------------------------
// 1st SKEWBACK (3/3)
For step In {TL1-1:1:-1}
	S_Yext[] = {S_Yext[], extSK[suma]};
	suma = suma+5;

	V_SK[] = {V_SK[], extSK[sumv]};
	V_SK15[] = {V_SK15[], extSK[sumv]};
	sumv = sumv+5;

	For (1:step-1)
		S_Yext[] = {S_Yext[], extSK[suma]};
		suma = suma+6;

		V_SK[] = {V_SK[], extSK[sumv]};
		V_SK20[] = {V_SK20[], extSK[sumv]};
		sumv = sumv+6;
	EndFor
EndFor
//------------------------------------------------------------------------------
// 2nd SKEWBACK (1/3)
For j In {0:aux1-1}
	S_Yext[] = {S_Yext[], extSK[suma+add2[j]]};
	V_SK[] = {V_SK[], extSK[sumv+add2[j]]};
EndFor

// SPLIT V_SK[] INTO WEDGES AND HEXAHEDRONS
For j In {0:aux1-2}
	If (add[j] == 5)
		V_SK15[] = {V_SK15[], extSK[sumv+add2[j]]};
	ElseIf (add[j] == 6)
		V_SK20[] = {V_SK20[], extSK[sumv+add2[j]]};
	EndIf
EndFor
V_SK15[] = {V_SK15[], extSK[sumv+add2[aux1-1]]};
//------------------------------------------------------------------------------
// 2nd SKEWBACK (2/3) IF PRESENT
suma = suma+add2[aux1-1]+5;
sumv = sumv+add2[aux1-1]+5;
If (L_x2 != 0)
	For (1:aux2sk)
		S_Yext[] = {S_Yext[], extSK[suma]};
		V_SK[] = {V_SK[], extSK[sumv]};
		V_SK20[] = {V_SK20[], extSK[sumv]};
		suma = suma+6;
		sumv = sumv+6;
	EndFor
EndIf
//------------------------------------------------------------------------------
// 2nd SKEWBACK (3/3)
For step In {TL1-1:1:-1}
	S_Yext[] = {S_Yext[], extSK[suma]};
	suma = suma+5;

	V_SK[] = {V_SK[], extSK[sumv]};
	V_SK15[] = {V_SK15[], extSK[sumv]};
	sumv = sumv+5;

	For (1:step-1)
		S_Yext[] = {S_Yext[], extSK[suma]};
		suma = suma+6;

		V_SK[] = {V_SK[], extSK[sumv]};
		V_SK20[] = {V_SK20[], extSK[sumv]};
		sumv = sumv+6;
	EndFor
EndFor
//------------------------------------------------------------------------------


Return
