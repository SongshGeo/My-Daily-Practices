READ ME FIRST

---------------------------------------------------------------------------------------------

The files in this repository concern with the GENeralized Economic comPlexitY (GENEPY)
index defined in "Reconciling contrasting views on economic complexity" (2020) by 
Sciarra C., Chiarotti G., Ridolfi L. & Laio F. 

The MATLAB code solves the function to compute the GENEPY index.
The GENEPY index (GENerealized Economic comPlexitY index) constitutes of the first two
eigenvectors of the proximity matrix P. For countries, the proximity matrix P is 
Ncc = Wcp*Wcp', while for products, the matrix is Gpp = Wcp'*Wcp, with Wcp = M_cp./k_c*k_p'.
The matrix M is the incidence matrix of the binary countries-product bipartite network, 
kc the degree of countries and kp'=sum(Mcp/kc). 
The function allows to choose the group for which to perform the computation, either 
countries or products and returns the values of the first two eigenvectors of the 
proximity matrix and the resulting GENEPY index.

The excel file contains the results of the GENEPY index for countries shown in the main
article during the period 1995 - 2017.

For further requests contact: carla.sciarra@polito.it

---------------------------------------------------------------------------------------------

June 2020