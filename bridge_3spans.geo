/*********************************************************************
 *
 *  bridge example
 *
 *  Automatic generation of a sample FULL 3D macroscale 3-span bridge
 *  (including interface surfaces between continuum bulks)
 *
 *********************************************************************/
//SetFactory("OpenCASCADE");
SetFactory("Built-in");

Mesh.ElementOrder = 2;
Mesh.SecondOrderIncomplete = 1;

Mesh.CharacteristicLengthMin = 50;
Mesh.CharacteristicLengthMax = 1000;
//------------------------------------------------------------------------------
Include "Macro_Arch2DfromEdge.geo";
Include "Macro_Trapezium2DFromPoint.geo";
Include "Macro_Trapezium2DFromEdge.geo";
Include "Macro_Backing3.geo";
Include "Macro_Backing2.geo";
Include "Macro_Backing1.geo";
Include "Macro_BackfillUnstructured.geo";
Include "Macro_Pier2DFromEdge.geo";

Include "Macro_Bridge2D3Span.geo";
Include "Macro_Initialiser.geo";

Include "Macro_SurfaceVolumeRetrievalSkewback.geo";
Include "Macro_SurfaceVolumeRetrievalBacking.geo";
Include "Macro_Bridge3D3SpanSpandrels.geo";
Include "Macro_Bridge3D3SpanInnerBulk.geo";

Include "Macro_Bridge3D3Span.geo";
//------------------------------------------------------------------------------
// DEFINE GEOMETRIC INPUT [mm]
//------------------------------------------------------------------------------
// PIERS
PH    = 5000;	// Height
PWd   = 2000;	// Reference X-width (set PWd=0 if a triangular skewback is needed)

// ARCHES
CSp   = 12320;	// Clear span
ARs   = 2430;	// Rise
Th    = 680;	// Thickness

// SKEWBACK
Call Initialiser;

// BACKING
Hbk   = 2230;	// Height measured from skewback head

// BACKFILL
Hbf   = 1520;	// Height measured from backing head

// BALLAST LAYER (ATOP OF THE BACKFILL)
ELTh  = 450;	// Thickness

// LOADING
LdL[] = {3300, 1500, -1500, -3300};	// X coordinates of load resultants
WdL[] = {250, 250, 250, 250};		// load strip X-width values

// SPANDREL WALLS
WSp   = 450;	// Y-width
HPp   = 2000;	// Parapet height measured from top of backfill

// BULK BETWEEN SPANDRELS
WBf[] = {757.5, 800, 700, 800, 1515, 800, 700, 800, 757.5};	// List of Y-width bands
//------------------------------------------------------------------------------
// DEFINE DISCRETISATION INPUT
//------------------------------------------------------------------------------
TL1    = 3;	 // TL1 - 1 = Number of rings in an arch
TL2    = 3;	 // (2*TL1 + TL2) - 3 = Number of layers along the X-width of the pier
TL3    = 6;	 // TL3 - 1 = Number of layers along the arch segments contiguous to backing
		     // FOR THE TIME BEING, RESTRICTION: TL3 >= 3
TL4    = 6;	 // TL4 - 1 = Number of layers along the central arch segments
// TL5 is omitted by default (see NOTES on macro BackfillUnstructured)
TL5    = 3;

NLPr   = 15; // Number of layers along the pier height

NLSp   = 1;	 // Number of layers along the Y-width of the spandrel walls
NLPp   = 4;	 // Number of Z-layers in parapet starting from top of ballast

NLEL   = 1;	 // Number of elmt layers along the thickness of the ballast layer

NLBf[] = {1,1,1,1,2,1,1,1,1};	// Number of Y-layers per band
LdBf[] = {0,1,0,1,0,1,0,1,0};	// Indicator of load for each Y-width band (0=not loaded; 1=loaded)
//------------------------------------------------------------------------------
// EXECUTE MAIN GENERATION MACROS
//------------------------------------------------------------------------------
Call Bridge2D3Span;

Call Bridge3D3Span;
//------------------------------------------------------------------------------
