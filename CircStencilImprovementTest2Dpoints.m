%%

clear
close all
import kwave.toolbox.*

radius=0.045;
acc=[0.1,0.05,0.025,0.01,0.005,0.0025,0.001];
mVal=[5,8,14,33,65,129,320];

circ.radius=radius;
circ.centre=[0,0];

dxval=[1e-2,5e-3,1e-3,5e-4,1e-4];

figure(1)
tiledlayout(3,5)
figure(2)
tiledlayout(3,5)

figure(3)
tiledlayout(3,5)
figure(4)
tiledlayout(3,5)


for j2=4:4 %7

    dx=dxval(j2);

    PointCount=floor(linspace(1,1.175,15)*(2*radius*pi/dx));
    PointCount2=ceil(linspace(1,1.175,15)*(2*radius*pi/dx));

    % dx=1e-3;



    kgrid2D=Grid([ 2*(radius/dx)+3, 2*(radius/dx)+3 ],  dx , [20,20]);

    medium2D=Medium(kgrid2D);
    medium2D.materialIDGrid=1;
    source = AcousticSource(kgrid2D);
    setting=Settings;
    setting.plotSimulation='on';
    source.initialPressure = exp( -((kgrid2D.x).^2+kgrid2D.y.^2+kgrid2D.z.^2) ./ (10 * kgrid2D.dx).^2 );

    Circle=BoundaryCondition(kgrid2D);
    Circle.mask=zeros(kgrid2D.gridSize);
    Circle.mask( kgrid2D.x.^2 + kgrid2D.y.^2 < (circ.radius +1*kgrid2D.dx/2)^2  )=1;
    Circle.mask( kgrid2D.x.^2 + kgrid2D.y.^2 < (circ.radius -1*kgrid2D.dx/2 )^2  )=0;

    Circle.normalVector=zeros([2*(radius/dx)+3+40,2*(radius/dx)+3+40,1,2]);
    Circle.normalVector(21:end-20,21:end-20,:,1)=kgrid2D.x ./ sqrt( kgrid2D.x.^2 + kgrid2D.y.^2 );
    Circle.normalVector(21:end-20,21:end-20,:,2)=kgrid2D.y ./ sqrt( kgrid2D.x.^2 + kgrid2D.y.^2 );
    Circle.normalVector(isnan(Circle.normalVector))=0;
    dt1=1e-7;
    Nt1=double((4*radius/medium2D.soundSpeed)/dt1);
    % wave at centre travels to the wall, and back, through the centre and reflects again to centre (4* radius) at the soundspeed
    % in d/V seconds, or (d/V)/dt time steps

    solver=AcousticSolver(kgrid2D, medium2D, source, [],setting);
    solver.setPressureBoundaryCondition(Circle)
    % solver.setVelocityBoundaryCondition(Circle)
    solver.run(Nt=Nt1,dt=dt1);


    for j1=4:4
        for j3=1:15
            pointcount=PointCount(j3);
            kgrid2DOG=Grid([ 2*(radius/dx + mVal(j1))+3, 2*(radius/dx + mVal(j1))+3 ],  dx , [20,20]);
            CircleOG=OffGrid(kgrid2DOG,pointcount,'circle',circ);

            medium2DOG=Medium(kgrid2DOG);
            medium2DOG.materialIDGrid=1;
            sourceOG = AcousticSource(kgrid2DOG);
            sourceOG.initialPressure = exp( -((kgrid2DOG.x).^2+kgrid2DOG.y.^2+kgrid2DOG.z.^2) ./ (10 * kgrid2DOG.dx).^2 );

            solverOG=AcousticSolver(kgrid2DOG, medium2DOG, sourceOG, [],setting);
            CircleBC=OffGridBoundaryCondition(kgrid2DOG,CircleOG,accuracy=acc(j1));
            % CircleBC=OffGridBoundaryCondition(kgrid2DOG,CircleOG,accuracy=acc(j1),staggering="forward");
            CircleBC.mask=CircleBC.maskBuilder;
            solverOG.setPressureBoundaryCondition(CircleBC)
            % solverOG.setVelocityBoundaryCondition(CircleBC)
            solverOG.run(Nt=Nt1,dt=dt1)

            pointcount2=PointCount2(j3);
            kgrid2DOG=Grid([ 2*(radius/dx + mVal(j1))+3, 2*(radius/dx + mVal(j1))+3 ],  dx , [20,20]);
            CircleOG2=OffGrid(kgrid2DOG,pointcount2,'circle',circ);

            medium2DOG=Medium(kgrid2DOG);
            medium2DOG.materialIDGrid=1;
            sourceOG = AcousticSource(kgrid2DOG);
            sourceOG.initialPressure = exp( -((kgrid2DOG.x).^2+kgrid2DOG.y.^2+kgrid2DOG.z.^2) ./ (10 * kgrid2DOG.dx).^2 );

            solverOG2=AcousticSolver(kgrid2DOG, medium2DOG, sourceOG, [],setting);
            CircleBC2=OffGridBoundaryCondition(kgrid2DOG,CircleOG2,accuracy=acc(j1));
            % CircleBC=OffGridBoundaryCondition(kgrid2DOG,CircleOG,accuracy=acc(j1),staggering="forward");
            CircleBC2.mask=CircleBC2.maskBuilder;
            solverOG2.setPressureBoundaryCondition(CircleBC2)
            % solverOG.setVelocityBoundaryCondition(CircleBC)
            solverOG2.run(Nt=Nt1,dt=dt1)

            figure(1)

            nexttile(j3)
            imagesc(solverOG.kgrid.xVec,solverOG.kgrid.yVec,log10(abs(1-solverOG.source.initialPressure./-solverOG.pressure)),[-3,1])
            colorbar
            hold on
            plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
            colorbar
            xlim([-circ.radius,circ.radius])
            ylim([-circ.radius,circ.radius])
            title([{'error off-grid' } {'boundary points = ' num2str(pointcount)}])


            drawnow

            figure(2)

            nexttile(j3)
            imagesc(solverOG.kgrid.xVec,solverOG.kgrid.yVec,abs((solverOG.source.initialPressure+solverOG.pressure)),[0,0.4])
            colorbar
            hold on
            plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
            colorbar
            xlim([-circ.radius,circ.radius])
            ylim([-circ.radius,circ.radius])
            title([{'error off-grid' } {'boundary points = ' num2str(pointcount)}])

            figure(3)

            nexttile(j3)
            imagesc(solverOG.kgrid.xVec,solverOG.kgrid.yVec,log10(abs(1-solverOG2.source.initialPressure./-solverOG.pressure)),[-3,1])
            colorbar
            hold on
            plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
            colorbar
            xlim([-circ.radius,circ.radius])
            ylim([-circ.radius,circ.radius])
            title([{'error off-grid' } {'boundary points = ' num2str(pointcount2)}])
            drawnow

            figure(4)

            nexttile(j3)
            imagesc(solverOG.kgrid.xVec,solverOG.kgrid.yVec,abs((solverOG2.source.initialPressure+solverOG.pressure)),[0,0.4])
            colorbar
            hold on
            plot(CircleOG.kgridLocations(:,2),CircleOG.kgridLocations(:,1),'w')
            colorbar
            xlim([-circ.radius,circ.radius])
            ylim([-circ.radius,circ.radius])
            title([{'error off-grid' } {'boundary points = ' num2str(pointcount2)}])
            drawnow
        end
    end

end
