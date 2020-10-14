# Generation of a macroscale multi-span bridge FE mesh

This repository contains a set of macros to generate a 3D Finite Element macroscale mesh of a 3-span arch bridge, via the free meshing tool [gmsh](https://gmsh.info). The main features of the macros and execution guidelines can be found in the sections below:

* [Introduction](https://github.com/AlfaBetaBeta/gmsh-3D-arch-bridge#introduction)
* further links..

## Introduction

The spatial FE mesh comprises solely quadratic incomplete (serendipitous) solid elements of the type:

* 20-noded hexahedron ([gmsh element type 17](https://gmsh.info/doc/texinfo/gmsh.html#MSH-file-format))
* 15-noded wedge ([gmsh element type 18](https://gmsh.info/doc/texinfo/gmsh.html#MSH-file-format))

Although other element types (e.g. 10-noded tetrahedron, [gmsh type 11](https://gmsh.info/doc/texinfo/gmsh.html#MSH-file-format)) could easily be accommodated with minor changes in some macros, it is convenient to work with the default types above for consistency with other potential functionalities (see caveats link).

An example mesh resulting from invoking the generative macros can be seen below, where colour encoding reflects materials with different self-weight. The coordinate system adopted throughout all macros is the orthonormal triplet XYZ and it is also shown for illustration.

<img src="https://github.com/AlfaBetaBeta/gmsh-3D-arch-bridge/blob/main/img/intro/3D-bridge-XYZ.png" width=100% height=100%>

The constituents considered here are the following:

* masonry (piers, skewbacks, arches, spandrels, parapets)
* backing
* backfill
* ballast

These are schematically shown below, roughly corresponding to the self-weight groups from above (whereby in this case `backing` and `masonry` were assigned the same self-weight and hence the identical colouring).

 <img src="https://github.com/AlfaBetaBeta/gmsh-3D-arch-bridge/blob/main/img/intro/3D-bridge-materials.png" width=100% height=100%>

Further details regarding the material groups and assignment of welf-weight can be found in ...

## Input parameters and execution guidelines



<img src="https://github.com/AlfaBetaBeta/gmsh-3D-arch-bridge/blob/main/img/input_and_exe/main-file-geometric-input.png" width=100% height=100%>