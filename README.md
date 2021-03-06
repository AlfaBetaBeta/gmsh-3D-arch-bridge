# Generation of a macroscale multi-span bridge FE mesh

This repository contains a set of macros to generate a 3D Finite Element macroscale mesh of a 3-span arch bridge, via the free meshing tool [gmsh](https://gmsh.info). The main features of the macros, as well as their input parameters and execution guidelines can be found in the sections below:

* [Introduction](https://github.com/AlfaBetaBeta/gmsh-3D-arch-bridge#introduction)
* [Input parameters](https://github.com/AlfaBetaBeta/gmsh-3D-arch-bridge#input-parameters):
    * [Geometry](https://github.com/AlfaBetaBeta/gmsh-3D-arch-bridge#geometry)
    * [Meshing](https://github.com/AlfaBetaBeta/gmsh-3D-arch-bridge#meshing)
    * [Macros](https://github.com/AlfaBetaBeta/gmsh-3D-arch-bridge#macros)
* [Execution guidelines](https://github.com/AlfaBetaBeta/gmsh-3D-arch-bridge#execution-guidelines)
* [Caveats and limitations](https://github.com/AlfaBetaBeta/gmsh-3D-arch-bridge#caveats-and-limitations)

## Introduction

The spatial FE mesh comprises solely quadratic incomplete (serendipitous) solid elements of the type:

* 20-noded hexahedron ([gmsh element type 17](https://gmsh.info/doc/texinfo/gmsh.html#MSH-file-format))
* 15-noded wedge ([gmsh element type 18](https://gmsh.info/doc/texinfo/gmsh.html#MSH-file-format))

Although other element types (e.g. 10-noded tetrahedron, [gmsh type 11](https://gmsh.info/doc/texinfo/gmsh.html#MSH-file-format)) could easily be accommodated with minor changes in some macros, it is convenient to work with the default types above for consistency with other potential functionalities (see the [caveats](https://github.com/AlfaBetaBeta/gmsh-3D-arch-bridge#caveats-and-limitations)).

An example mesh resulting from invoking the generative macros can be seen below, where colour encoding reflects materials with different self-weight (i.e. assigned to different Physical Volumes). The coordinate system adopted throughout all macros is the orthonormal triplet XYZ and it is also shown for reference.

<img src="https://github.com/AlfaBetaBeta/gmsh-3D-arch-bridge/blob/main/img/intro/3D-bridge-XYZ.png" width=100% height=100%>

The constituents considered here are the following:

* masonry (piers, skewbacks, arches, spandrels, parapets)
* backing
* backfill
* ballast

These are schematically shown below, roughly corresponding to the self-weight groups from above (whereby in this case `backing` and `masonry` were assigned the same self-weight and hence the identical colouring).

 <img src="https://github.com/AlfaBetaBeta/gmsh-3D-arch-bridge/blob/main/img/intro/3D-bridge-materials.png" width=100% height=100%>

Further details regarding the material groups and assignment of welf-weight can be found in the [section about editable macros](https://github.com/AlfaBetaBeta/gmsh-3D-arch-bridge#macros).

## Input parameters

All the `.geo` files containing macros are named as the macro they embed, prepended by `Macro_`. The main `.geo` file actually calling the macros is the one meant to be edited by the user, in this case `bridge_3pans.geo`, though the naming of this file is arbitrary (in certain cases, some macros may need to be edited by the user as well, this is explained in [this section](https://github.com/AlfaBetaBeta/gmsh-3D-arch-bridge#macros)). There are **two main groups of input parameters** in the main `.geo` file: **geometry** and **meshing** parameters.

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

### Macros

In principle, the `Macro_*.geo` files can be left as is to start invoking them (although the user can hack them at their convenience if they are familiar with gmsh syntax). There are, however, two macros that the user might find useful to edit depending on their needs. Future revisions will centralise everything in the main `.geo` file, but for now the editable macros are explained hereafter.

As can be seen from all images above, the mesh in the spandrels' region adjacent to the backfill is unstructured by default, which leaves parameter `TL5` unused and it can therefore be omitted in such cases. If a structured mesh with hexahedrons is required in that region, then a few lines in `Macro_BackfillUnstructured.geo` need to be uncommented (as is indicated in that file). An example of this fully structured meshing is shown below as a longitudinal section at Y = *constant*, where the ballast layer has been omitted for simplicity and the meaning of `TL5` has been indicated explicitly.

<img src="https://github.com/AlfaBetaBeta/gmsh-3D-arch-bridge/blob/main/img/input_and_exe/2D-strip-structured.png" width=100% height=100%>

The definition of Physical Entities (Surfaces/Volumes) is entirely done in `Macro_Bridge3D3Span.geo`, in the block shown below:

<img src="https://github.com/AlfaBetaBeta/gmsh-3D-arch-bridge/blob/main/img/input_and_exe/physical-entities.png" width=90% height=90%>

The meaning of each Surface/Volume list is explained in the heading of that file. The strings labelling each Physical Entity are in general strongly FE engine dependent and in this case they encode information (material group, self-weight, bounday conditions, ect) by complying with certain syntax rules. If the user needs a different syntax for the labels, these strings can be changed without restrictions. Any Physical Entity can even be omitted altogether if the user does not need it or has their own tool to transform the resulting `.msh` file into a suitable input file for the FE engine. In any case, the Physical Entities or their labels are not needed for the macros to work properly.

## Execution guidelines

Once all necessary [input parameters](https://github.com/AlfaBetaBeta/gmsh-3D-arch-bridge#input-parameters) have been specified by the user, the execution of the macros from the main `.geo` file can be done via GUI or CLI. For the example included here, these options would be:

* GUI:
    * Open `bridge_3spans.geo` from gmsh and then press `0` to read the file.
    * To execute the 3D meshing after reading the script, press `3`.
    * The resulting `.msh` file can be saved locally and might be necessary as input for further generative/analysis tools.

* CLI:
```
$ gmsh -3 bridge_3spans.geo
```
or
```
$ gmsh -3 -part 6 bridge_3spans.geo
```
should it be necessary to partition the mesh (say in 6 in this case).

## Caveats and limitations

* Reading the main `.geo` file as indicated above can take some time depending on the machine and the meshing parameters. If the main aim is for the user to experiment with the input parameters to graphically check their influence, it might be convenient to comment out `Call Bridge3D3Span` in the main `.geo` file. This just generates a 2D strip in the XZ plane, and it does so very quickly. While this does not allow inspecting the effect of parameters in the Y direction, it is a quick hack useful for the majority of input parameters.

* The Physical Surfaces `g_*2*` and `s2in` in `Macro_Bridge3D3Span.geo` are meant to be transformed into crack or interface planes, that is the sole reason why these Physical Entities are created. If this is indeed of interest, please refer to [this repository's plugin](https://github.com/AlfaBetaBeta/gmsh-crack-generator#gmsh-plugin-for-crack-generation-in-3d-fe-meshes) to see how to transform these surfaces into cracks (only the `.msh` file resulting from executing the macros here would be necessary). Resorting to the crack plugin in its current form, however, precludes the use of 10-noded tetrahedrons, hence the recommendation not to change the default element types in the macros. If inserting crack/interface planes is not necessary, then the aforementioned Physical Surfaces can be dispensed with, and the macros can be hacked to generate tetrahedrons without further consequence.

* The macros in this repository should work even with the newest version of gmsh, but bear in mind that the [crack plugin](https://github.com/AlfaBetaBeta/gmsh-crack-generator#gmsh-plugin-for-crack-generation-in-3d-fe-meshes) does not. Please refer to the [caveats on that repository](https://github.com/AlfaBetaBeta/gmsh-crack-generator#caveats-and-shortcomings) to adjust the format of the `.msh` file if the pipeline includes the crack plugin.

* The choice of 3 spans for the bridge is somewhat arbitrary and is related to legacy issues at the time of developing the macros originally. Future revisions will aim at adding an additional input parameter in the main `.geo` file representing the number of spans to generate.