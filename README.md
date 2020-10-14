# Generation of a macroscale 3-span bridge FE mesh

This repository contains a set of macros to generate a 3D Finite Element mesh of a 3-span arch bridge, via the free meshing tool [gmsh](https://gmsh.info). The main features of the macros and the main execution guidelines can be found in the sections below:

* Link to intro
* further links..

## Introduction

The spatial FE mesh comprises solely quadratic incomplete (serendipitous) solid elements of the type:

* 20-noded hexahedron (gmsh element type 17)
* 15-noded wedge (gmsh element type 18)

Although other element types (e.g. 10-noded tetrahedron, gmsh type 11) could be easily accommodated with minor changes in some macros, it is convenient to work with the default types for consistency with other potential functionalities (see caveats link).

