/************************************************************************
 *
 *  Macro Pier2DFromEdge
 *
 *  Automated generation of structured piers from an EDGE (regular quads)
 *
 ************************************************************************/
// MESH A PIER DEFINED IN THE (Y=0) PLANE AS A -Z EXTRUSION FROM AN  EDGE BELONGING TO A SKEWBACK BASE

Macro Pier2DFromEdge

/*
IN:		PL[]  = List of Lines forming the base of the skewback
		PH    = Pier height
		NLPr  = Number of layers in the Z direction when extruding PL[]

OUT: 		ext[] = Aux list for extrusion
		SP[]  = List of surfaces forming the pier
*/

// EXTRUDE IN -Z FROM THE BASE OF A SKEWBACK
ext[] = Extrude {0,0,-PH} { Line{PL[]}; Layers{NLPr}; Recombine;};
SP[] = ext[{1:#ext[]-1:4}];

Return
