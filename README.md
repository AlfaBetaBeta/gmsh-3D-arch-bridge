# Generation of a macroscale multi-span bridge FE mesh

This repository contains a set of macros to generate a 3D Finite Element macroscale mesh of a 3-span arch bridge, via the free meshing tool [gmsh](https://gmsh.info). The main features of the macros and their execution guidelines can be found in the sections below:

* [Introduction](https://github.com/AlfaBetaBeta/gmsh-3D-arch-bridge#introduction)
* Etc
* Etc

## Introduction

The spatial FE mesh comprises solely quadratic incomplete (serendipitous) solid elements of the type:

* 20-noded hexahedron ([gmsh element type 17](https://gmsh.info/doc/texinfo/gmsh.html#MSH-file-format))
* 15-noded wedge ([gmsh element type 18](https://gmsh.info/doc/texinfo/gmsh.html#MSH-file-format))

Although other element types (e.g. 10-noded tetrahedron, [gmsh type 11](https://gmsh.info/doc/texinfo/gmsh.html#MSH-file-format)) could easily be accommodated with minor changes in some macros, it is convenient to work with the default types above for consistency with other potential functionalities (see caveats link).

An example mesh resulting from invoking the generative macros can be seen below, where colour encoding reflects materials with different self-weight. The coordinate system adopted throughout all macros is the orthonormal triplet XYZ and it is also shown for reference.

<img src="https://github.com/AlfaBetaBeta/gmsh-3D-arch-bridge/blob/main/img/intro/3D-bridge-XYZ.png" width=100% height=100%>

The constituents considered here are the following:

* masonry (piers, skewbacks, arches, spandrels, parapets)
* backing
* backfill
* ballast

These are schematically shown below, roughly corresponding to the self-weight groups from above (whereby in this case `backing` and `masonry` were assigned the same self-weight and hence the identical colouring).

 <img src="https://github.com/AlfaBetaBeta/gmsh-3D-arch-bridge/blob/main/img/intro/3D-bridge-materials.png" width=100% height=100%>

Further details regarding the material groups and assignment of welf-weight can be found in ...

## Input parameters

All the `.geo` files containing macros are named as the macro they embed, prepended by `Macro_`. The main `.geo` file actually calling the macros is the one meant to be edited by the user, in this case `bridge_3pans.geo`, though the naming of this file is arbitrary. (Exception for physical groups?). There are **two main groups of input parameters** in the main `.geo` file: **geometry** and **meshing** parameters.

### Geometry

An example of geometric input from within `bridge_3pans.geo` is shown below:

<img src="https://github.com/AlfaBetaBeta/gmsh-3D-arch-bridge/blob/main/img/input_and_exe/main-file-geo-input.png" width=75% height=75%>

Though most of the bridge dimensions are intuitive, these are shown on a sample mesh below for ease of interpretation.

<img src="https://github.com/AlfaBetaBeta/gmsh-3D-arch-bridge/blob/main/img/input_and_exe/geo-bridge-dimensions.png" width=100% height=100%>

The lists defining the position and distribution of the loading areas (`LdL[]`, `WdL[]` and `WBf[]`) require further consideration. The loads are assumed to be applied over the ballast layer, in a distribution of concentrated areas/patches representing a reference vehicle (e.g. axle loads if the framework is railway traffic). To fully define the geometry around these patches, the following criteria need to be followed when defining those lists:

* `LdL[]` contains the X coordinates of each patch strip centreline, **sorted in descending order** (i.e. starting with the patch strip of greatest X and then continuing in direction -X; `{3000, 1000, -1000}` would be a valid example, whereas `{3000, -1000, 1000}` would raise an error).
* `WdL[]` contains the width values (in X direction) of each patch strip, in the order corresponding to `LdL[]`. Every width value must be strictly positive, but otherwise the values in the list may be unequal.
* `WBf[]` contains the width values (in Y direction) of each band (patch or inter-patch gap), sorted following +Y. Every width value must be strictly positive, but otherwise the values in the list may be unequal.

The image below further illustrates these points, for the specific lists defined in the example `bridge_3pans.geo`:

 <img src="https://github.com/AlfaBetaBeta/gmsh-3D-arch-bridge/blob/main/img/input_and_exe/geo-loading-patches.png" width=100% height=100%>

### Meshing

The sample meshing input from within `bridge_3pans.geo` is also shown below:

<img src="https://github.com/AlfaBetaBeta/gmsh-3D-arch-bridge/blob/main/img/input_and_exe/main-file-mesh-input.png" width=90% height=90%>

Most of the meshing parameters are sufficiently intuitive or can be inferred with ease by playing around with their values. Similarly to the case of the geometric parameters, the following lists deal with the loading areas:

* `NLBf[]` defines the discretisation along Y with regards to the bands defined in `WBf[]`, i.e. `NLBf[i]` determines the number of layers in which band `i` (of Y-width `WBf[i]`) must be discretised.
* `LdBf[]` is also in correspondence with `WBf[]` and `NLBf[]`, and it specifies which band actually contains loading patches (value `1`) and which band contains inter-patch gaps (value `0`). The truthy value `1` can be replaced by any nonzero value, though it is recommended to use `1` to reflect more intuitively the binary purpose of this list.

As can be seen from the images above, the mesh in the spandrels' region adjacent to the backfill is unstructured by default, which leaves parameter `TL5` unused and it can therefore be omitted in such cases. If a structured mesh with hexahedrons is required in that region, then a few lines in `Macro_BackfillUnstructured.geo` need to be uncommented (as is indicated in that file). An example of this fully structured meshing is shown below as a longitudinal section at Y = *constant*, where the ballast layer has been omitted for simplicity and the meaning of `TL5` has been indicated explicitly.

<img src="https://github.com/AlfaBetaBeta/gmsh-3D-arch-bridge/blob/main/img/input_and_exe/2D-strip-structured.png" width=100% height=100%>

