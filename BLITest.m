%% BLI testing
%
% Set up a functional wave
%
clear
close all
import kwave.toolbox.*
for m=6:12
    for eo=0:1
        % generate increasing size grid, both with even and odd numbers of
        % grid points
        kgrid1D = Grid(2^m + eo, 1e-3,0);
        medium=AcousticMedium(kgrid1D);
        medium.soundSpeed=1500;
        medium.density = 1000;
        source = AcousticSource(kgrid1D);
        settings = Settings;
        settings.plotSimulation = 'off';

        % Initial function can be changed here
        % p = @(x)  exp( -(x.^2) ./ (10 * kgrid1D.dx).^2 );
        p = @(x)  cos( pi * x/max(abs(x))/2);

        source.initialPressure = p(kgrid1D.x);
        
        % A number of steps up to 500 such that the result should be
        % bandlimited and the FFT will be accurate.
        steps2=floor(1000*rand(1,1));
        dt=1e-7;
        solver = AcousticSolver(kgrid1D, medium, source,[],settings);
        solver.run(Nt=steps2,dt=dt);
        leng=length(solver.kgridPadded.xVec);
        
        % random amount of shift on each grid set-up
        shift=rand(1,1)*kgrid1D.dx;
        xshift=reshape(ifftshift( exp( 1i.*solver.kgridPadded.kxVec * solver.kgridPadded.dx/2)), [], 1, 1);

        %Fourier Transformed shift 
        fstg = zeros([leng, 1]);
        f_k = fftn(solver.pressurePadded);
        fstg(:, 1) = ifftn(xshift .* f_k, 'symmetric');

        %Analytic solution shift 
        % Won't be a good comparison if the periodic domain has been used.
        actualShift=  (p(kgrid1D.xVec + shift + medium.soundSpeed*steps2*dt) + p(kgrid1D.xVec + shift - medium.soundSpeed*steps2*dt) )/2;
        
        %Set up for the BLI
        xrel=(solver.kgridPadded.x)/kgrid1D.dx;
        shiftedxrel=(solver.kgridPadded.x+shift)/kgrid1D.dx;

        %Computation of BLI's for each off-grid and grid value
        if floor(leng/2)==leng/2
            BLIs=BandLimEven(xrel,shiftedxrel,leng);
        else
            BLIs=BandLimOdd(xrel,shiftedxrel,leng);
        end

        % BLI off-grid shift values
        BLIShift=sum(real(BLIs).*solver.pressurePadded,2);

        figure(2*m+eo)
        newplot=tiledlayout(2,3);
        nexttile(1)
        plot((actualShift))
        title("Pressure: analytic")
        nexttile(2)
        plot((abs(actualShift-fstg)))
        title("Analytic to FT error")
        nexttile(3)
        plot((abs(actualShift-BLIShift)))
        title("Analytic to BLI error")
        nexttile(4)
        plot((abs(fstg-BLIShift)))
        title("FT to BLI error")
        nexttile(5)
        plot((abs(BLIShift-fstg)/0.5))
        title("FT to BLI error normalised by expected maximum")
        nexttile(6)
        plot(log10(abs(1-BLIShift./fstg)))
        title("log10 locally relative FT BLI error")
        title(newplot, {"Time = ", num2str(steps2*dt), ". gridpoints = ", num2str(2^m+eo)})
       
        % Increased grid courseness = steaper derivatives.

        % Error between Fourier Transform for bell curve consistantly 0.04
        % when normalised by wave peak.

        % Cosine error is significanly smaller, best to observe error
        % between the BLI and FT.

        % Errors observed in areas away 0 derivative including wave peak.
        

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


