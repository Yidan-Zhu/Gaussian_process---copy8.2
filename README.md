# Gaussian_process---copy8.2

visit: https://yidan-zhu.github.io/Gaussian_process---copy8.2/

Move the fixed point(s) around by dragging and dropping.

========================================

- A Simple Explanation:

1x and 1y Jacobian(slope) corresponds to a surface 1 in 3D space. 2x and 2y Jacobian corresponds to a surface 2 in 3D space. 

Each of the surface is recovered by Gaussian process, knowing the same set of fixed points(z=0) and two different sets of x and y slopes. 

The dynamics is showing an evolution of (x,y)' = (f1(x,y), f2(x,y)). Where the z values of surface 1 and surface 2 are the velocity at each point (x,y).

The streamline with a small dt time interval displays the path of each moving state(x,y).


<img src="https://github.com/Yidan-Zhu/Gaussian_process---copy8.2/blob/main/pic.png?raw=true" width=600 height=350>

code in file: Gaussian Process Non-linear Dynamics System
