%%

clear
close all
import kwave.toolbox.*

acc=0.005;
dx=1e-4;
Nx=256;

x1=-1*(Nx/2*dx)/2;
x2=1*(Nx/2*dx)/2;
y1=-x1/2;
y2=-x2/2;


kgrid2D=Grid( [Nx, Nx],  dx , [20,20]);

medium2D=Medium(kgrid2D);
medium2D.materialIDGrid=1;
source = AcousticSource(kgrid2D);
setting=Settings;
setting.plotSimulation='on';
source.initialPressure = zeros(kgrid2D.gridSize);
source.initialPressure(kgrid2D.x.^2 + kgrid2D.y.^2 < 4*dx^2)=4;
Square1=BoundaryCondition(kgrid2D);
Square1.mask=zeros(kgrid2D.gridSize);
Square1.mask( abs(kgrid2D.x)>abs(x1)  )=1;
Square1.mask( abs(kgrid2D.y)>abs(x1)  )=1;
Square1.mask( abs(kgrid2D.y)>abs(x1)+2*dx  )=0;
Square1.mask( abs(kgrid2D.x)>abs(x1)+2*dx  )=0;
dt1=0.5e-7;
Nt1=150;

Square1.normalVector=zeros([Nx+40,Nx+40,1,2]);
Temp1=zeros([Nx+40,Nx+40]);
Temp1( (kgrid2D.x>=kgrid2D.y).*(kgrid2D.x>=-kgrid2D.y)==1 ) = 1 ;
Square1.normalVector(:,:,1,1)=Temp1;

Temp1=zeros([Nx+40,Nx+40]);
Temp1( (kgrid2D.x<kgrid2D.y).*(kgrid2D.x<-kgrid2D.y)==1 ) = -1 ;
Square1.normalVector(:,:,1,1)=Temp1;

Temp1=zeros([Nx+40,Nx+40]);
Temp1( (kgrid2D.x<kgrid2D.y).*(kgrid2D.x>=-kgrid2D.y)==1 ) = 1 ;
Square1.normalVector(:,:,1,2)=Temp1;

Temp1=zeros([Nx+40,Nx+40]);
Temp1( (kgrid2D.x>=kgrid2D.y).*(kgrid2D.x<-kgrid2D.y)==1 ) = -1 ;
Square1.normalVector(:,:,1,2)=Temp1;

solver=AcousticSolver(kgrid2D, medium2D, source, [],setting);
solver.setVelocityBoundaryCondition(Square1)
solver.run(Nt=Nt1,dt=dt1);

v1=sqrt(2)*abs(x1);
Square2=BoundaryCondition(kgrid2D);
Square2.mask=zeros(kgrid2D.gridSize);
Square2.mask( abs(kgrid2D.x - kgrid2D.y -v1) < 2*dx   )=1; 
Square2.mask( abs(kgrid2D.x + kgrid2D.y +v1) < 2*dx   )=1; 
Square2.mask( abs(kgrid2D.x - kgrid2D.y +v1) < 2*dx   )=1; 
Square2.mask( abs(kgrid2D.x + kgrid2D.y -v1) < 2*dx   )=1; 
Square2.mask(  kgrid2D.y< -v1  )=0;
Square2.mask(  kgrid2D.y> v1  )=0;
Square2.mask(  kgrid2D.x< -v1  )=0;
Square2.mask(  kgrid2D.x> v1  )=0;

Square2.normalVector=zeros([Nx+40,Nx+40,1,2]);
Temp1=zeros([Nx+40,Nx+40]);
Temp1((kgrid2D.x>=0))=1/sqrt(2);
Square2.normalVector( :,:,1 , 1 ) = Temp1 ;

Temp1=zeros([Nx+40,Nx+40]);
Temp1((kgrid2D.x<0))=-1/sqrt(2);
Square2.normalVector( :,:,1 , 1 ) = Temp1 ;

Temp1=zeros([Nx+40,Nx+40]);
Temp1((kgrid2D.y>=0))=1/sqrt(2);
Square2.normalVector( :,:,1 , 2 ) = Temp1 ;

Temp1=zeros([Nx+40,Nx+40]);
Temp1((kgrid2D.y<0))=-1/sqrt(2);
Square2.normalVector( :,:,1 , 2 ) = Temp1 ;

solver1R=AcousticSolver(kgrid2D, medium2D, source, [],setting);
solver1R.setVelocityBoundaryCondition(Square2)
solver1R.run(Nt=Nt1,dt=dt1);

solver2=AcousticSolver(kgrid2D, medium2D, source, [],setting);

% eachline is 2* x1 long, so requires 2*x1/dx points
A=[linspace(0,v1,2*abs(x1)/dx +2 ).' , linspace(-v1,0,2*abs(x1)/dx +2).'];
B=[linspace(0,v1,2*abs(x1)/dx +2).' , linspace(v1,0,2*abs(x1)/dx +2).'];
C=[linspace(-v1,0,2*abs(x1)/dx +2).' , linspace(0,v1,2*abs(x1)/dx +2).'];
D=[linspace(-v1,0,2*abs(x1)/dx +2).' , linspace(0,-v1,2*abs(x1)/dx +2).'];
Square3=[A(2:end-1,:); B(2:end-1,:); C(2:end-1,:); D(2:end-1,:) ];

Square3OG=OffGrid(kgrid2D,length(Square3(:,1)),Square3);

Square3BC=OffGridBoundaryCondition(kgrid2D,Square3OG,accuracy=acc);
Square3BC.mask=Square3BC.maskBuilder;
solver2.setPressureBoundaryCondition(Square3BC);
% solver2.run(Nt=Nt1,dt=dt1);

plot1=figure(1);
hold on
plot(linspace(-x1,x1,2),linspace(-x1,-x1,2),'k')
plot(linspace(-x1,x1,2),linspace(x1,x1,2),'k')
plot(linspace(x1,x1,2),linspace(x1,-x1,2),'k')
plot(linspace(-x1,-x1,2),linspace(x1,-x1,2),'k')
plot(A(:,1),A(:,2),'k--')
plot(B(:,1),B(:,2),'k--')
plot(C(:,1),C(:,2),'k--')
plot(D(:,1),D(:,2),'k--')
% plot(linspace(-sqrt(2)*1e-3,sqrt(2)*1e-3,2),linspace(-sqrt(2)*1e-3,sqrt(2)*1e-3,2),'m-.')
xlim([-v1,v1]);
ylim([-v1,v1]);


plot2=figure(2);
hold on
% plot(linspace(y1,y2,50),linspace(x1,x2,50),'k')
plot(A(:,1),A(:,2),'k')
plot(B(:,1),B(:,2),'k')
plot(C(:,1),C(:,2),'k')
plot(D(:,1),D(:,2),'k')
plot(linspace(-x1,x1,2),linspace(-x1,-x1,2),'k--')
plot(linspace(-x1,x1,2),linspace(x1,x1,2),'k--')
plot(linspace(x1,x1,2),linspace(x1,-x1,2),'k--')
plot(linspace(-x1,-x1,2),linspace(x1,-x1,2),'k--')
% plot(linspace(-2e-3,2e-3,2),linspace(0,0,2),'m-.')
xlim([-v1,v1])
ylim([-v1,v1])

% plot3=figure(3);
% hold on
% % plot(linspace(y1,y2,50),linspace(x1,x2,50),'k')
% plot(A(:,1),A(:,2),'k')
% plot(B(:,1),B(:,2),'k')
% plot(C(:,1),C(:,2),'k')
% plot(D(:,1),D(:,2),'k')
% plot(linspace(-x1,x1,2),linspace(-x1,-x1,2),'k--')
% plot(linspace(-x1,x1,2),linspace(x1,x1,2),'k--')
% plot(linspace(x1,x1,2),linspace(x1,-x1,2),'k--')
% plot(linspace(-x1,-x1,2),linspace(x1,-x1,2),'k--')
% % plot(linspace(-2e-3,2e-3,2),linspace(0,0,2),'m-.')
% 
% xlim([-v1,v1])
% ylim([-v1,v1])
% 
% exportgraphics('plot1','squareOnGrid.jpeg')
% exportgraphics('plot2','rotatedsquareOnGrid.jpeg')
% exportgraphics('plot3','rotatedsquareOffGrid.jpeg')