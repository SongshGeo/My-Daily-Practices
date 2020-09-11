%% Function to compute the GENEPY index and its components
% for details see 
% Sciarra C., Chiarotti G., Ridolfi L. & Laio F. 
% "Reconciling contrasting views on economic complexity" (2020).
%
% The GENEPY index (GENerealized Economic comPlexitY index)
% constitutes of the first two eigenvectors of the proximity matrix P. 
% For countries, the proximity matrix P is Ncc = Wcp*Wcp', while
% for products, the matrix is Gpp = Wcp'*Wcp, with Wcp = M_cp./k_c*k_p'.
% The matrix M is the incidence matrix of the binary countries-product bipartite
% network, k_c the degree of countries and k_p'=sum(M_cp/k_c).
% The function allows to choose the group for which to perform the computation, 
% either countries or products and returns the values of the first two
% eigenvectors of the proximity matrix and the resulting GENEPY index.
% -------------------------------------------------------------------------
% by Carla Sciarra - 
% V 1.0 - June 2020
% -------------------------------------------------------------------------

function [E1,E2,GENEPY]=genepy_index(M,group)
% M = double, incidence matrix of the bipartite network
% group = str, choose between 'countries' or 'products'

%% Construct transformation matrix Wcp=M_cp./k_c*k_p'
%node degree k_c
kc=sum(M,2); 
% Random walk matrix
RW=M./kc; 
% compute k_p'
kp_1=sum(RW,1);
% compute denominator of the fraction
den=kc*kp_1;
% compute transformation matrix Wcp
W=M./den;    

% compute proximity matrix P
if strcmp(group,'countries')
    P=W*W'; % P equals Ncc = Wcp*Wcp'
elseif strcmp(group,'products')
    P=W'*W; % P equals Gpp = Wcp'*Wcp
end
% set diagonal to zero 将对角线设置为 0
P(eye(size(P))~=0)=0;  % 返回与 P 同样大小的单位矩阵
% compute eigenvectors and eigenvalues of the matrix P
evalues=eig(P);      %eigenvalues 返回一个列向量，其中包含方阵 A 的特征值。
[evectors,~]=eig(P); %eigenvectors
% sort absolute eigenvalues in descending order
[~,order_eig]=sort(evalues,'descend','ComparisonMethod','abs');
% re-order eigenvalues and eigenvectors accordingly
evalues=evalues(order_eig);
evectors=evectors(:,order_eig);
clear order_eig

% Eigenvectors are define up to multiplication by constant values.
% The Perron-Frobenius Th ensures the eigenvector corresponding to the
% largest eigenvalues to be positive. Computation can include this constant
% as a minus sign. Take the absolute value of the first eigenvector.
E1=abs(evectors(:,1));  % first eigenvector  (X1 for countries, Y1 for products)
E2=evectors(:,2);       % second eigenvector (X2 for countries, Y2 for products)

%% Compute GENEPY index using unique contribution
% use linear algebra to compact GENEPY formula
E=[E1 E2];                      % matrix of first two eigenvectors E1 and E2
lambda=[evalues(1) evalues(2)]; % vector of first two eigenvalues
GENEPY=(((E(:,:).^2))*lambda(:)).^2+2.*((E(:,:).^2))*(lambda(:).^2);


