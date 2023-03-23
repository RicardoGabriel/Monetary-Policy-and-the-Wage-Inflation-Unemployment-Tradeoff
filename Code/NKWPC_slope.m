%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%    NKWPC Slope                                                        %
%                                                                       %
%    Author: Ricardo Duque Gabriel                                      %
%                                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%definitions
% phi is the slope of the NKWPC
% phi = -(varphi*(1-theta)*(1-beta*theta))/((1-beta*rho)*theta*(1+eps*varphi)) [Eq. 10]

% varphi - elasticity of the marginal disutility of work, support [0,+oo)
% beta - discount rate, support (0,1) - close to 1
% theta - probability of a wage adjustment, calvo parameter, support (0,1)
% rho - natural wage markup gap persistence, support (0,1)
% eps - wage elasticity of demand (substitution) for the services of each 
% labor type in the model, support (0,1) ?? 
% flexible wage markup = eps / (eps -1) in support (-oo,+oo)

%parameters
theta = 0.75;
varphi = 5;
beta = 0.99;
eps = 2.15;
rho = 0.5;

figure
subplot(2,2,1)      
fplot(@(theta) (-(varphi*(1-theta)*(1-beta*theta))/((1-beta*rho)*theta*(1+eps*varphi))),[0.05 0.95],'k')          
title('\theta')
subplot(2,2,2)       
fplot(@(varphi) (-(varphi*(1-theta)*(1-beta*theta))/((1-beta*rho)*theta*(1+eps*varphi))),[0.01 20],'k')        
title('\phi')
subplot(2,2,3)      
fplot(@(beta) (-(varphi*(1-theta)*(1-beta*theta))/((1-beta*rho)*theta*(1+eps*varphi))),[0 1],'k')          
title('\beta')
subplot(2,2,4)       
fplot(@(eps) (-(varphi*(1-theta)*(1-beta*theta))/((1-beta*rho)*theta*(1+eps*varphi))),[0.01 10],'k')
title('\epsilon')
fig = gcf;
fig.PaperPositionMode = 'auto'
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
%saveas(gcf,'NKWPCslope.pdf')
print(fig,'NKWPCslope','-dpdf')