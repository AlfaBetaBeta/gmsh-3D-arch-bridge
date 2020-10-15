/*******************************************************************************************************************************
 *
 *  Macro SurfaceVolumeRetrievalBacking
 *
 *  Automatic retrieval of Surfaces and Volumes from the extruded (in +Y) backings for the purpose of defining Physical entities
 *
 *******************************************************************************************************************************/
// RETRIEVAL OF ALL SURFACES AT Y=extr.width FROM THE EXTRUDED BACKINGS, AS WELL AS THE GENERATED VOLUMES AND THE SURFACES AT THE BACKING 'ABUTMENTS'

// NOTES: * THIS MACRO FEEDS ORIGINALLY FROM MACRO Bridge3D3Span, HENCE ALL LIMITATIONS AND SPECIFICITIES NOTED THERE APPLY HERE AS WELL

Macro SurfaceVolumeRetrievalBacking

/*
IN:		*args from previous macros

INOUT:		V_BK[]     = List of ALL Volumes forming the backings in the current extrusion
		S_abtbk[]  = List of Surfaces at the backing 'abutments' along the current extrusion

OUT:		S_Yext[]   = List of all Surfaces at Y>0 (with Y = width of extrusion)
		             (Reset and updated here with the backings contribution)
		aux3	   = Number of elements in 1 layer of each triangular part of
			     the backing
		aux2bk	   = Number of elements in 1 layer of the central (rectangular)
			     part of the backing should it be present

		+ other aux variables
*/
//------------------------------------------------------------------------------
// INITIALISE AUX LISTS
S_Yext[] = {}; // RESET AND UPDATED EVERY TIME THIS MACRO IS CALLED!

If (L_x2 == 0)
	aux2bk = 0;
Else
	aux2bk = (TL3-1)*(TL2-1);
EndIf

aux3 = (TL3/2)*(TL3-1);
add[] = {5};
For (1:aux3-2)
	add[] = {add[], 6}; 	
EndFor
For j In {2:TL3-1}
	add[{ (j/2*(j-1))-1 }] = 5;	
EndFor
add2[] = {0};
addsum = 0;
For j In {1:aux3-1}
	addsum = addsum + add[j-1];
	add2[] = {add2[], addsum};
EndFor
//------------------------------------------------------------------------------
// SIMULTANEOUS UPDATE OF S_Yext[] AND V_SK[]:
//------------------------------------------------------------------------------
// 1st EDGE BACKING
suma = 0;
sumv = 1;
For step In {TL3-1:1:-1}
	S_Yext[] = {S_Yext[], extBK[suma]};
	V_BK[] = {V_BK[], extBK[sumv]};
	suma = suma+5; 
	sumv = sumv+5;

	For (1:step-1)
		S_Yext[] = {S_Yext[], extBK[suma]};
		V_BK[] = {V_BK[], extBK[sumv]};
		suma = suma+6;
		sumv = sumv+6;
	EndFor
EndFor
//------------------------------------------------------------------------------
// 1st FULL BACKING (1/3)
For j In {0:aux3-1}
	S_Yext[] = {S_Yext[], extBK[suma+add2[j]]};
	V_BK[] = {V_BK[], extBK[sumv+add2[j]]};
EndFor

// 1st FULL BACKING TRANSITION TO (2/3) OR (3/3)
suma = suma+add2[aux3-1]+5;
sumv = sumv+add2[aux3-1]+5;

// 1st FULL BACKING (2/3) IF PRESENT
If (L_x2 != 0)
	For (1:aux2bk)
		S_Yext[] = {S_Yext[], extBK[suma]};
		V_BK[] = {V_BK[], extBK[sumv]};
		suma = suma+6;
		sumv = sumv+6;
	EndFor
EndIf

// 1st FULL BACKING (3/3)
For step In {TL3-1:1:-1}
	S_Yext[] = {S_Yext[], extBK[suma]};
	V_BK[] = {V_BK[], extBK[sumv]};
	suma = suma+5;
	sumv = sumv+5;

	For (1:step-1)
		S_Yext[] = {S_Yext[], extBK[suma]};
		V_BK[] = {V_BK[], extBK[sumv]};
		suma = suma+6;
		sumv = sumv+6;
	EndFor
EndFor
//------------------------------------------------------------------------------
// 2nd FULL BACKING (1/3)
For j In {0:aux3-1}
	S_Yext[] = {S_Yext[], extBK[suma+add2[j]]};
	V_BK[] = {V_BK[], extBK[sumv+add2[j]]};
EndFor

// 2nd FULL BACKING TRANSITION TO (2/3) OR (3/3)
suma = suma+add2[aux3-1]+5;
sumv = sumv+add2[aux3-1]+5;

// 2nd FULL BACKING (2/3) IF PRESENT
If (L_x2 != 0)
	For (1:aux2bk)
		S_Yext[] = {S_Yext[], extBK[suma]};
		V_BK[] = {V_BK[], extBK[sumv]};
		suma = suma+6;
		sumv = sumv+6;
	EndFor
EndIf

// 2nd FULL BACKING (3/3)
For step In {TL3-1:1:-1}
	S_Yext[] = {S_Yext[], extBK[suma]};
	V_BK[] = {V_BK[], extBK[sumv]};
	suma = suma+5;
	sumv = sumv+5;

	For (1:step-1)
		S_Yext[] = {S_Yext[], extBK[suma]};
		V_BK[] = {V_BK[], extBK[sumv]};
		suma = suma+6;
		sumv = sumv+6;
	EndFor
EndFor
//------------------------------------------------------------------------------
// TRANSITION TO 2nd EDGE BACKING
auxsuma = suma; // << FOR LATER USE WITH S_abtbk[]

// 2nd EDGE BACKING
For step In {TL3-1:1:-1}
	S_Yext[] = {S_Yext[], extBK[suma]};
	V_BK[] = {V_BK[], extBK[sumv]};
	suma = suma+5;
	sumv = sumv+5;

	For (1:step-1)
		S_Yext[] = {S_Yext[], extBK[suma]};
		V_BK[] = {V_BK[], extBK[sumv]};
		suma = suma+6;
		sumv = sumv+6;
	EndFor
EndFor
//------------------------------------------------------------------------------
// UPDATE OF S_abtbk[]:
//------------------------------------------------------------------------------
// 'ABUTMENT' OF 1st ARCH
suma = 2;
S_abtbk[] = {S_abtbk[], extBK[suma]};
suma = suma+5;
For (1:TL3-2)
	S_abtbk[] = {S_abtbk[], extBK[suma]};
	suma = suma+6;
EndFor

// 'ABUTMENT' OF 3rd ARCH
suma = auxsuma+2;
S_abtbk[] = {S_abtbk[], extBK[suma]};
suma = suma+5;
For (1:TL3-2)
	S_abtbk[] = {S_abtbk[], extBK[suma]};
	suma = suma+6;
EndFor
//------------------------------------------------------------------------------

Return
