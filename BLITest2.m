%% BLI testing 2
clear
close all
import kwave.toolbox.*
for m=6:12
    for eo=0:1
        kgrid2D = Grid([2^m + eo,2^m+eo], 1e-3,0);
        medium=AcousticMedium(kgrid2D);
        medium.soundSpeed=1500;
        medium.density = 1000;
        source = AcousticSource(kgrid2D);
        settings = Settings;
        settings.plotSimulation = 'off';
        source.initialPressure = exp( -(kgrid2D.x.^2+ kgrid2D.y.^2) ./ (10 * kgrid2D.dx).^2 );

        distribution = @(x,y) exp( -(x.^2+ y.^2) ./ (10 * kgrid2D.dx).^2 );

        solver = AcousticSolver(kgrid2D, medium, source,[],settings);
        steps2=0; %floor(500*rand(1,1));
        solver.run(Nt=steps2,dt=1e-7);
        leng=length(solver.kgridPadded.xVec);
     
        distribution(0.1,0.2);

        shift1=rand(1,1)*kgrid2D.dx;
        shift2=rand(1,1)*kgrid2D.dy;
         numberofPoints=max(floor(25*rand(1,1)),8);
        minigridx=linspace(-2,2,numberofPoints)*kgrid2D.dx+(1-2*rand(1,numberofPoints))*shift1;
        minigridy=linspace(-1,1,numberofPoints)*kgrid2D.dy+(1-2*rand(1,numberofPoints))*shift2;
%        minigridx=[-1,-1,-1,0,0,0,1,1,1]*kgrid2D.dx+[-2*shift1,-shift1,-shift1/2,-shift1/2,0,shift1/2,shift1/2,shift1,2*shift1];
%        minigridy=[-1,0,1,0,1,-1,1,-1,0]*kgrid2D.dy+[-2*shift2,-shift2,-shift2/2,-shift2/2,0,shift2/2,shift2/2,shift2,2*shift2];

        xrel=(reshape(solver.kgridPadded.x,[],1))/kgrid2D.dx;
        yrel=(reshape(solver.kgridPadded.y,[],1))/kgrid2D.dy;
        shiftedxrel=(minigridx/kgrid2D.dx).';
        shiftedyrel=(minigridy/kgrid2D.dy).';

        values=distribution(minigridx,minigridy);
        tic
        if eo==0
            BLIs1=BandLimEven(shiftedxrel,xrel,leng).*BandLimEven(shiftedyrel,yrel,leng);
            BLIMat=BandLimEven(shiftedxrel,shiftedxrel,leng).*BandLimEven(shiftedyrel,shiftedyrel,leng);
            BLIs2=BandLimEven(xrel,shiftedxrel,leng).*BandLimEven(yrel,shiftedyrel,leng);
        else
            BLIs1=BandLimOdd(shiftedxrel,xrel,leng).*BandLimOdd(shiftedyrel,yrel,leng);
            BLIMat=BandLimOdd(shiftedxrel,shiftedxrel,leng).*BandLimOdd(shiftedyrel,shiftedyrel,leng);
            BLIs2=BandLimOdd(xrel,shiftedxrel,leng).*BandLimOdd(yrel,shiftedyrel,leng);
        end
        % ScaledValues=BLIMat\values.';
        ScaledValues=values.';
        gridValues=sum(BLIs1.*(ScaledValues.'),2);

        offgridValues=sum(real(BLIs2).*gridValues.',2);
        toc
        err=offgridValues.'-values;

        figure(m+eo)
        tiledlayout(1,3)
        nexttile(1)
        plot(abs(offgridValues.'-values))
        title("err")
        nexttile(2)
        plot(values)
        title("Pressure")
        nexttile(3)
        plot(abs(1-values./offgridValues.'))
        title("Normalised error")
        drawnow


    end
end
%%

function BandLimPointCoEven=BandLimEven(x1,x2,n)
% ACCURACY = 0.025 to Fourier if no 'should be 0' terms

x1=x1.';
v=pi*(x1-x2);
BandLimPointCoEven = sin(v) ./ ( n * tan (v / n) );
BandLimPointCoEven(isnan(BandLimPointCoEven ))=1;
BandLimPointCoEven = BandLimPointCoEven - sin(pi*(x1)).*sin(pi*(x2))/n  ...
    + 1i* sin(pi*(x1)).*cos(pi*(x2))/n;

% Version adjusts "should be 0 terms"
% Both versions behave the same currently, though case without better when
% pressure is in small region

% x1=x1.';
% v=pi*(x1-x2);
% BandLimPointCoEven = sin(v).*cos(v/n) ./ sin (v / n) ;
% BandLimPointCoEven= BandLimPointCoEven/n;
% BandLimPointCoEven(isnan(BandLimPointCoEven ))=1;
end

function BandLimPointCoOdd=BandLimOdd(x1,x2,n)
x1=x1.';
v=pi*(x1-x2);
BandLimPointCoOdd = sin(v) ./ ( n * sin (v/( n )) );
BandLimPointCoOdd(isnan(BandLimPointCoOdd))=1;
end


