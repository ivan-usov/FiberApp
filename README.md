# FiberApp
## Description
**FiberApp** is a software for tracking and analyzing biomacromolecules, polymers, filaments and fibrous objects.

The software operates on images from various microscope sources (atomic force or transmission electron microscopy, optical, fluorescence, confocal, etc.), acquiring the spatial coordinates of objects by a semi-automated tracking procedure based on _A* pathfinding algorithm_, followed by the application of *active contour models* and generating statistical, topological, and graphical output, derivable from these coordinates.

![main_window](https://user-images.githubusercontent.com/13196195/50549974-53497a80-0c67-11e9-8ca8-bb1af3e9c7b8.png)

There are 5 core panels for image, mask and fiber tracking parameters, as well as tracked data information and fiber view properties. One panel is for generating images with simulated fibrils and corresponding XYZ data, which serves the purpose of tracking quality and algorithm correctness validation. In the current version, there are 14 data processing tools, allowing determination of the basic single-object morphological parameters, distributions, collective orientation behavior, etc.

![scheme](https://user-images.githubusercontent.com/13196195/50549980-796f1a80-0c67-11e9-8939-0db8b5acd0c2.png)

The processing tools include:
* Height Profile
* Height Autocorrelation function (ACF)
* Height Discrete Fourier Transform (DFT)
* Height Distribution
* Length Distribution
* Orientation Distribution
* Curvature Distribution
* Kink Angle Distribution
* Bond Correlation Function (BCF)
* Mean-Squared End-to-end Distance (MSED)
* Mean-Squared Midpoint Displacement (MSMD)
* Scaling Exponent
* Excess Kurtosis
* 2D Order Parameter

![panels](https://user-images.githubusercontent.com/13196195/50549978-6eb48580-0c67-11e9-8b1e-ec04d5c25892.png)

Further information and examples of data processing can be found in the article:

Usov, I and Mezzenga, R. FiberApp: an Open-source Software for Tracking and Analyzing Polymers, Filaments, Biomacromolecules, and Fibrous Objects. *Macromolecules*, **49**, 1269-1280 (2015).

## Running the application
Execute `FiberApp.m` in matlab environment to open the software GUI.
