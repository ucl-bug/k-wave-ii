

xvals=linspace(-10,10,400);
xbgvals=linspace(-10,10,21);
yvals = @(x) sin(pi*x)./(pi*x);
plotSinc=figure();
plot(xvals,yvals(xvals),'b');
xticks(-10:1:10);
hold on
plot(linspace(-10,10,2),linspace(0,0,2),'k-');
plot(linspace(0,0,2),linspace(0,1,2),'b--');
plot(xbgvals,yvals(xbgvals),'bx');
plot(0,1,'bx')
exportgraphics(plotSinc,'sincplotOnGrid.jpeg')
plot([-4.4,-4.4],[0,yvals(-4.4)],'r--')
plot(-4.4,yvals(-4.4),'rx')
exportgraphics(plotSinc,'sincplotOnGridInterp.jpeg')
hold off
vec=[-8,-6.5, -0.35, 2.7];
for j1=1:4
plot(xvals,yvals(xvals),'b');
xticks(-10:1:10);
hold on
plot(linspace(-10,10,2),linspace(0,0,2),'k-');
plot(xbgvals,yvals(xbgvals),'bx');
plot(linspace(0,0,2),linspace(0,1,2),'b--');
plot(0,1,'bx')
plot(xvals,yvals(xvals-vec(j1)),'r');
plot(xbgvals,yvals(xbgvals-vec(j1)),'rx');
plot(linspace(vec(j1),vec(j1),2),linspace(0,1,2),'r--');
name=['sincplotOffGrid' num2str(j1) '.jpeg'];
hold off
exportgraphics(plotSinc,name)
end

clear
close all
import kwave.toolbox.*

acc=0.005;
dx=1e-4;
Nx=256;

kgrid1D=Grid( Nx,  dx , 0);

medium1D=Medium(kgrid1D);
medium1D.materialIDGrid=1;
source = AcousticSource(kgrid1D);
setting=Settings;
setting.plotSimulation="on";
source.initialPressure = zeros(kgrid1D.gridSize);
p0= @(x) exp(-(x/(10*dx)).^2);
source.initialPressure=p0(kgrid1D.x);
dt1=0.4e-7;
Nt1=150;
solver=AcousticSolver(kgrid1D, medium1D, source, [],setting);
solver.run(Nt=Nt1,dt=dt1);
figure(6);
plot(kgrid1D.x, (p0(kgrid1D.x+medium1D.soundSpeed*dt1*Nt1) + p0(kgrid1D.x-medium1D.soundSpeed*dt1*Nt1))/2 ,'r')
hold on
plot(kgrid1D.x,solver.pressure,'b--')

newplot=figure(7);
plot(kgrid1D.x, (p0(kgrid1D.x+medium1D.soundSpeed*dt1*Nt1) + p0(kgrid1D.x-medium1D.soundSpeed*dt1*Nt1))/2 ,'r')
hold on
plot(kgrid1D.x,solver.pressure,'b--')

p= p0(kgrid1D.x);
dp = derr(p,dx);
u= + dt1*dp/2;
c0=medium1D.soundSpeed;
for j1=1:Nt1
    dp = derr(p,dx);
    u = u - dt1*dp;
    du = derr(u,dx);
    p=p-dt1*(c0.^2)*du;
    % figure(5)
    % plot(p)
end

zoomed=figure(6);
hold on
plot(kgrid1D.x,p,'m--')
 xlim([0.0085,0.0095])

full=figure(7);
hold on
plot(kgrid1D.x,p,'m--')

exportgraphics(full,'withcorrectionfull.jpeg')
exportgraphics(zoomed,'withcorrectionzoom.jpeg')


function dF = derr(f,dx)
    dF=zeros(size(f));
    dF(2:end-1)=(f(1:end-2) - f(3:end))/(2*dx);
    dF(1)=(f(end) - f(2))/(2*dx);
    dF(end)=(f(end-1) - f(1))/(2*dx);
end
