% 1D Reflection.
%
% For boundarys point located at -Y and Y
% in 1D.
% After 2Y/co =t time a compactly supported source between the boundaries
% should have returned to its initial condition.
%
% Errors are, maximum amplitude
% Error across domain
% dispersion

clear
close all
import kwave.toolbox.*

% Initial Grid Size
dx=1e-3;
figure(2)
tiledlayout(6,7)
for m=7:12
    for eo=0:0
        Nx=2^m+eo;
        kgrid1D = Grid(Nx, dx,0);
        

        % ss=1500;
        dt=0.934e-7;
        Nt=500*2^(m-7) -100 + floor(200*rand(1,1));
        BoundarypmLoc=Nt*dt*1500/(2); % Y Wall locations from centre

        medium1D=Medium(kgrid1D);
        medium1D.materialIDGrid=1;

        source = AcousticSource(kgrid1D);
        source.initialPressure = zeros(Nx,1);
        source.initialPressure( floor(Nx/2)-2^(m-3)-1:floor(Nx/2)+2^(m-3)+3 ) = (1- (cos( 2*pi*( 0:2^(m-2)+4)/(2^(m-2)+5))))/2;
        % 
        if m==12
        nexttile(1)
        plot(kgrid1D.xVec,-source.initialPressure);
        drawnow
        end

        
        setting=Settings;
        setting.plotSimulation='off';

        for BPoints=1:2:5
            solver=AcousticSolver(kgrid1D, medium1D, source, [],setting);
            v1=BoundarypmLoc;
            v2=BoundarypmLoc+(BPoints-1)*rand(1,1)*dx;
            vec=[linspace(-v2,-v1,BPoints) , linspace(v1,v2,BPoints)];
            OG=OffGrid(kgrid1D,2*BPoints,vec);

            BC=OffGridBoundaryCondition(kgrid1D,OG,accuracy=0.0025);
            BC.mask=BC.maskBuilder;
            solver.setPressureBoundaryCondition(BC);
            
            solver.run(Nt=Nt,dt=dt)
            nexttile(7*(m-7)+(2*(BPoints+1)/2)+1)
            plot(kgrid1D.xVec,abs(solver.pressure+source.initialPressure))
            drawnow
            nexttile(7*(m-7)+(2*(BPoints+1)/2-1)+1)
            plot(kgrid1D.xVec,(solver.pressure))
            hold on
            plot(kgrid1D.xVec,(-source.initialPressure),'r--')
            drawnow
            
        end
    
    end
end

%         v1= -(ceil(Nx/4)+1/3)*dx;
%          % v2= -(ceil(Nx/4)+1+1/3)*dx;
%         v2= -(ceil(Nx/4)+1/2+1/3)*dx;
%         % v2= -(ceil(Nx/4)+1/num+1/3)*dx;
%         % v2= -(ceil(Nx/4)+1+(num-1)/5+1/3)*dx;
%         % OG=OffGrid(kgrid1D,num+1,[v2:dx/(num):v1]);
%         OG=OffGrid(kgrid1D,2,[v2,v1]);
% 
%         source = AcousticSource(kgrid1D);
%         setting=Settings;
%         setting.plotSimulation=decision;
%         sensor=AcousticSensor(kgrid1D);
%         sensor.mask=zeros(Nx,1);
%         sensor.mask(ceil(Nx/4)+1:floor(3*Nx/4))=1;
%         source.initialPressure = zeros(Nx,1);
%         source.initialPressure(ceil(3*Nx/4):Nx) = -(cos( 2*pi*(((ceil(3*Nx/4):Nx)-ceil(6*Nx/8))/(Nx-ceil(3*Nx/4))))-1);
%         solver=AcousticSolver(kgrid1D, medium1D, source, sensor,setting);
% 
% 
%         BC1=OffGridBoundaryCondition(kgrid1D,OG,accuracy=0.005);
%         BC1.mask=BC1.maskBuilder;
%         solver.setPressureBoundaryCondition(BC1)
% 
%     end
% end
