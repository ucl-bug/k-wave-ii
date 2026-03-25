%% TestFourierCollocation
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.TestGrid
%
% Unit tests for the FourierCollocation class.
%
%% Description
% Tests the gradient, divergence and curl functions of the
% |kwave.toolbox.FourierCollocation| class against simple analytical
% functions that are periodic on the test grid. All dimensions and grid
% staggering options are tested.

classdef TestFourierCollocation < kwave.tests.unit.AbstractTestGrid

    % Add solver to class properties so we can pass it to each testCase.
    properties
        solver kwave.toolbox.FourierCollocation
    end

    % Setup solver for each test.
    methods(TestMethodSetup, ParameterCombination="sequential")
        function createSolver(testCase)
            testCase.solver = kwave.toolbox.FourierCollocation(testCase.kgrid);
        end
    end

    % Parameterized tests.
    methods(Test, ParameterCombination="sequential")

        % Test the gradient function.
        function testGradient(testCase)
            import matlab.unittest.constraints.IsEqualTo

            % No staggering.
            [f, testCase.referenceSolution] = testCase.getPeriodicScalarFunction;
            testCase.actualSolution = testCase.solver.gradient(f);
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

            % Forward staggering.
            [f, testCase.referenceSolution] = testCase.getPeriodicScalarFunction("forward");
            testCase.actualSolution = testCase.solver.gradient(f, Staggering="forward");
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

            % Backward staggering.
            [f, testCase.referenceSolution] = testCase.getPeriodicScalarFunction("backward");
            testCase.actualSolution = testCase.solver.gradient(f, Staggering="backward");
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

            % Scalar kappa.
            testCase.solver.kappa = 2;
            [f, testCase.referenceSolution] = testCase.getPeriodicScalarFunction;
            testCase.referenceSolution = testCase.referenceSolution .* testCase.solver.kappa;
            testCase.actualSolution = testCase.solver.gradient(f);
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

        end

        % Test the divergence function.
        function testDivergence(testCase)
            import matlab.unittest.constraints.IsEqualTo

            % No staggering.
            [f, testCase.referenceSolution] = testCase.getPeriodicVectorFunctionDivergence;
            testCase.actualSolution = testCase.solver.divergence(f);
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

            % Forward staggering.
            [f, testCase.referenceSolution] = testCase.getPeriodicVectorFunctionDivergence("forward");
            testCase.actualSolution = testCase.solver.divergence(f, Staggering="forward");
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

            % Backward staggering.
            [f, testCase.referenceSolution] = testCase.getPeriodicVectorFunctionDivergence("backward");
            testCase.actualSolution = testCase.solver.divergence(f, Staggering="backward");
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

            % Scalar kappa.
            testCase.solver.kappa = 2;
            [f, testCase.referenceSolution] = testCase.getPeriodicVectorFunctionDivergence;
            testCase.referenceSolution = testCase.referenceSolution .* testCase.solver.kappa;
            testCase.actualSolution = testCase.solver.divergence(f);
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

            % Test incorrect size gives exception.
            f = rand(2, 2, 2, 4);
            testCase.verifyError(@() testCase.solver.divergence(f), 'FourierCollocation:incorrectSize');

        end

        % Test the gradient of a vector function.
        function testGradientVector(testCase)
            import matlab.unittest.constraints.IsEqualTo

            % No staggering.
            [f, testCase.referenceSolution] = testCase.getPeriodicTensorFunction;
            testCase.actualSolution = testCase.solver.gradientVector(f);
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

            % Forward staggering.
            [f, testCase.referenceSolution] = testCase.getPeriodicTensorFunction("forward");
            testCase.actualSolution = testCase.solver.gradientVector(f, Staggering="forward");
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

            % Backward staggering.
            [f, testCase.referenceSolution] = testCase.getPeriodicTensorFunction("backward");
            testCase.actualSolution = testCase.solver.gradientVector(f, Staggering="backward");
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

            % Scalar kappa.
            testCase.solver.kappa = 2;
            [f, testCase.referenceSolution] = testCase.getPeriodicTensorFunction;
            testCase.referenceSolution = testCase.referenceSolution .* testCase.solver.kappa;
            testCase.actualSolution = testCase.solver.gradientVector(f);
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

            % Test incorrect size gives exception.
            f = rand(2, 2, 2, 4);
            testCase.verifyError(@() testCase.solver.gradientVector(f), 'FourierCollocation:incorrectSize');

        end

        % Test the curl function.
        function testCurl(testCase)
            import matlab.unittest.constraints.IsEqualTo

            switch testCase.kgridPadded.dimensions
                case 1            

                    % Test to check incorrect number of dimensions gives exception
                    f = rand(testCase.kgridPadded.Nx,1);
                    testCase.verifyError(@() testCase.solver.curl(f), 'FourierCollocation:not3DVectorField');

                case 2

                    % Test to check incorrect number of dimensions gives exception
                    f = rand(testCase.kgridPadded.Nx,testCase.kgridPadded.Ny);
                    testCase.verifyError(@() testCase.solver.curl(f), 'FourierCollocation:not3DVectorField');

                case 3
        
                    % No staggering.
                    [f, testCase.referenceSolution] = testCase.getPeriodicVectorFunctionCurl;
                    testCase.actualSolution = testCase.solver.curl(f);
                    testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

                    % Forward staggering.
                    [f, testCase.referenceSolution] = testCase.getPeriodicVectorFunctionCurl("forward");
                    testCase.actualSolution = testCase.solver.curl(f, Staggering="forward");
                    testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));
        
                    % Backward staggering.
                    [f, testCase.referenceSolution] = testCase.getPeriodicVectorFunctionCurl("backward");
                    testCase.actualSolution = testCase.solver.curl(f, Staggering="backward");
                    testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));
        
                    % Scalar kappa.
                    testCase.solver.kappa = 2;
                    [f, testCase.referenceSolution] = testCase.getPeriodicVectorFunctionCurl;
                    testCase.referenceSolution = testCase.referenceSolution .* testCase.solver.kappa;
                    testCase.actualSolution = testCase.solver.curl(f);
                    testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

            end

            % Test incorrect size gives exception.
            f = rand(2, 2, 2, 4);
            testCase.verifyError(@() testCase.solver.curl(f), 'FourierCollocation:not3DVectorField');

        end


        % Test div(curl(.)) is zero.
        function testDivCurl(testCase)
            import matlab.unittest.constraints.IsEqualTo

            % For this test, the tolerance was changed to 1e-5, instead of
            % the default 1e-6, because round-off error accumulates quickly
            % when taking Fourier derivatives. The error is large because 
            % ddxNoShift etc are defined in the FourierCollocation class
            % as single precision.
            temporaryTolerance = matlab.unittest.constraints.AbsoluteTolerance(single(1e-5));
            
            if testCase.kgridPadded.dimensions == 3

                    % No staggering.
                    [f, ~] = testCase.getPeriodicVectorFunctionCurl;
                    testCase.referenceSolution = zeros(testCase.kgridPadded.gridSize);
                    testCase.actualSolution = testCase.solver.divergence(testCase.solver.curl(f));
                    testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", temporaryTolerance));
        
                    % Forward staggering.
                    [f, ~] = testCase.getPeriodicVectorFunctionCurl("forward");
                    testCase.referenceSolution = zeros(testCase.kgridPadded.gridSize);
                    testCase.actualSolution = testCase.solver.divergence(testCase.solver.curl(f, Staggering="forward"), Staggering="forward");
                    testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", temporaryTolerance));

                    % Backward staggering.
                    [f, ~] = testCase.getPeriodicVectorFunctionCurl("backward");
                    testCase.referenceSolution = zeros(testCase.kgridPadded.gridSize);
                    testCase.actualSolution = testCase.solver.divergence(testCase.solver.curl(f, Staggering="backward"), Staggering="backward");
                    testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", temporaryTolerance));
                    
            end

        end


%        Test curl(grad(.)) is zero.
        function testCurlGrad(testCase)
            import matlab.unittest.constraints.IsEqualTo

            % For this test, the tolerance was changed to 1e-3, instead of
            % the default 1e-6, because round-off error accumulates quickly
            % when taking Fourier derivatives. The error is large because 
            % ddxNoShift etc are defined in the FourierCollocation class
            % as single precision.
            temporaryTolerance = matlab.unittest.constraints.AbsoluteTolerance(single(1e-3));
            
            if testCase.kgridPadded.dimensions == 3

                    % No staggering.
                    [f, ~] = testCase.getPeriodicScalarFunction;
                    testCase.referenceSolution = zeros([testCase.kgridPadded.gridSize, 3]);
                    testCase.actualSolution = testCase.solver.curl(testCase.solver.gradient(f));
                    testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", temporaryTolerance));

                    % Forward staggering.
                    [f, ~] = testCase.getPeriodicScalarFunction("forward");
                    testCase.referenceSolution = zeros([testCase.kgridPadded.gridSize, 3]);
                    testCase.actualSolution = testCase.solver.curl(testCase.solver.gradient(f, Staggering="forward"), Staggering="forward");
                    testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", temporaryTolerance));

                    % Backward staggering.
                    [f, ~] = testCase.getPeriodicScalarFunction("backward");
                    testCase.referenceSolution = zeros([testCase.kgridPadded.gridSize, 3]);
                    testCase.actualSolution = testCase.solver.curl(testCase.solver.gradient(f, Staggering="backward"), Staggering="backward");
                    testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", temporaryTolerance));

            end

        end


        % Test sinc function.
        function testSinc(testCase)
            import matlab.unittest.constraints.IsEqualTo

            x = linspace(-10, 10, 100);
            testCase.actualSolution = testCase.solver.sinc(pi * x);
            testCase.referenceSolution = sinc(x);
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));
        end


        function testLaplacian(testCase)
             import matlab.unittest.constraints.IsEqualTo
            % No staggering.
            [f, testCase.referenceSolution] = testCase.getPeriodicVectorFunctionLap;
            testCase.actualSolution = -testCase.solver.fracLaplacian(f,1);
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

            % Forward staggering.
            [f, testCase.referenceSolution] = testCase.getPeriodicVectorFunctionLap("forward");
            testCase.actualSolution = -testCase.solver.fracLaplacian(f,1, Staggering="forward");
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

            % Backward staggering.
            [f, testCase.referenceSolution] = testCase.getPeriodicVectorFunctionLap("backward");
            testCase.actualSolution = -testCase.solver.fracLaplacian(f,1, Staggering="backward");
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));
            
        end

        function testStagger(testCase)
            import matlab.unittest.constraints.IsEqualTo
             % Forward staggering.
            [f, testCase.referenceSolution] = testCase.getPeriodicVectorFunctionStg("forward");
            testCase.actualSolution = testCase.solver.stagger(f,Staggering="forward");
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

            % Backward staggering.
            [f, testCase.referenceSolution] = testCase.getPeriodicVectorFunctionStg("backward");
            testCase.actualSolution = testCase.solver.stagger(f,Staggering="backward");
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

            % Forward staggering.
            [f, testCase.referenceSolution] = testCase.getLinearVectorFunctionStg("forward");
            testCase.actualSolution = testCase.solver.stagger(f,Staggering="forward",Type="linInterpolate");
            switch length(testCase.referenceSolution(1,1,1,:)) % Linear Interpolation requires points either side, so edges are null
                case 1
                    testCase.referenceSolution=testCase.referenceSolution(2:end-1);
                    testCase.actualSolution=testCase.actualSolution(2:end-1);
                case 2
                    testCase.referenceSolution=testCase.referenceSolution(2:end-1,2:end-1,:,:);
                    testCase.actualSolution=testCase.actualSolution(2:end-1,2:end-1,:,:);
                case 3
                    testCase.referenceSolution=testCase.referenceSolution(2:end-1,2:end-1,2:end-1,:);
                    testCase.actualSolution=testCase.actualSolution(2:end-1,2:end-1,2:end-1,:);
            end
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

            % Backward staggering.
            [f, testCase.referenceSolution] = testCase.getLinearVectorFunctionStg("backward");
            testCase.actualSolution = testCase.solver.stagger(f,Staggering="backward",Type="linInterpolate");
            switch length(testCase.referenceSolution(1,1,1,:)) % Linear Interpolation requires points either side, so edges are null
                case 1
                    testCase.referenceSolution=testCase.referenceSolution(2:end-1);
                    testCase.actualSolution=testCase.actualSolution(2:end-1);
                case 2
                    testCase.referenceSolution=testCase.referenceSolution(2:end-1,2:end-1,:,:);
                    testCase.actualSolution=testCase.actualSolution(2:end-1,2:end-1,:,:);
                case 3
                    testCase.referenceSolution=testCase.referenceSolution(2:end-1,2:end-1,2:end-1,:);
                    testCase.actualSolution=testCase.actualSolution(2:end-1,2:end-1,2:end-1,:);
            end
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));
            
        end
        
    end

    % Test utilities.
    methods

        % Define a periodic scalar function and its analytic gradient on
        % the grid specified by obj.kgridPadded. The function is normalised
        % so the maximum of the gradient is approximately 1. The gradient
        % can also be returned on a staggered grid.
        function [F, gradF] = getPeriodicScalarFunction(obj, staggering)

            arguments
                obj
                staggering(1,:) char {mustBeMember(staggering, {'none', 'forward', 'backward'})} = 'none'
            end

            switch staggering
                case 'none'
                    xSg = obj.kgridPadded.xVec;
                    ySg = obj.kgridPadded.yVec;
                    zSg = obj.kgridPadded.zVec;
                case 'forward'
                    xSg = obj.kgridPadded.xVec + obj.kgridPadded.dx/2;
                    ySg = obj.kgridPadded.yVec + obj.kgridPadded.dy/2;
                    zSg = obj.kgridPadded.zVec + obj.kgridPadded.dz/2;
                case 'backward'
                    xSg = obj.kgridPadded.xVec - obj.kgridPadded.dx/2;
                    ySg = obj.kgridPadded.yVec - obj.kgridPadded.dy/2;
                    zSg = obj.kgridPadded.zVec - obj.kgridPadded.dz/2;
            end

            switch obj.kgridPadded.dimensions
                case 1
                    kx = (2*pi ./ obj.kgridPadded.xSize);
                    F = sin(kx .* obj.kgridPadded.xVec) ./ kx;
                    gradF = cos(kx .* xSg);
                case 2
                    kx = (2*pi ./ obj.kgridPadded.xSize);
                    ky = (2*pi ./ obj.kgridPadded.ySize);

                    [X, Y] = ndgrid(obj.kgridPadded.xVec, obj.kgridPadded.yVec);
                    [Xsg, Ysg] = ndgrid(xSg, ySg);

                    F = sin(kx .* X) .* sin(ky .* Y) ./ kx;

                    gradF = zeros([size(F), 1, 2]);
                    gradF(:, :, :, 1) = cos(kx .* Xsg) .* sin(ky .* Y);
                    gradF(:, :, :, 2) = sin(kx .* X)   .* cos(ky .* Ysg) .* (ky ./ kx);
                case 3
                    kx = (2*pi ./ obj.kgridPadded.xSize);
                    ky = (2*pi ./ obj.kgridPadded.ySize);
                    kz = (2*pi ./ obj.kgridPadded.zSize);

                    [X, Y, Z] = ndgrid(obj.kgridPadded.xVec, obj.kgridPadded.yVec, obj.kgridPadded.zVec);
                    [Xsg, Ysg, Zsg] = ndgrid(xSg, ySg, zSg);

                    F = sin(kx .* X) .* sin(ky .* Y) .* sin(kz .* Z) ./ kx;

                    gradF = zeros([size(F), 3]);
                    gradF(:, :, :, 1) = cos(kx .* Xsg) .* sin(ky .* Y)   .* sin(kz .* Z);
                    gradF(:, :, :, 2) = sin(kx .* X)   .* cos(ky .* Ysg) .* sin(kz .* Z)   .* (ky ./ kx);
                    gradF(:, :, :, 3) = sin(kx .* X)   .* sin(ky .* Y)   .* cos(kz .* Zsg) .* (kz ./ kx);
            end
        end

        % Define a periodic vector function and its analytic divergence on
        % the grid specified by obj.kgridPadded. The function is normalized so
        % the maximum of the divergence is approximately 1. The divergence
        % can also be returned on a staggered grid.
        function [F, divF] = getPeriodicVectorFunctionDivergence(obj, staggering)

            arguments
                obj
                staggering(1,:) char {mustBeMember(staggering, {'none', 'forward', 'backward'})} = 'none'
            end

            switch staggering
                case 'none'
                    xSg = obj.kgridPadded.xVec;
                    ySg = obj.kgridPadded.yVec;
                    zSg = obj.kgridPadded.zVec;
                case 'forward'
                    xSg = obj.kgridPadded.xVec + obj.kgridPadded.dx/2;
                    ySg = obj.kgridPadded.yVec + obj.kgridPadded.dy/2;
                    zSg = obj.kgridPadded.zVec + obj.kgridPadded.dz/2;
                case 'backward'
                    xSg = obj.kgridPadded.xVec - obj.kgridPadded.dx/2;
                    ySg = obj.kgridPadded.yVec - obj.kgridPadded.dy/2;
                    zSg = obj.kgridPadded.zVec - obj.kgridPadded.dz/2;
            end

            switch obj.kgridPadded.dimensions
                case 1
                    kx = (2*pi ./ obj.kgridPadded.xSize);
                    F = sin(kx .* obj.kgridPadded.xVec) ./ kx;
                    divF = cos(kx .* xSg);
                case 2
                    kx = (2*pi ./ obj.kgridPadded.xSize);
                    ky = (2*pi ./ obj.kgridPadded.ySize);

                    [X, Y] = ndgrid(obj.kgridPadded.xVec, obj.kgridPadded.yVec);
                    [Xsg, Ysg] = ndgrid(xSg, ySg);

                    Fx = sin(kx .* X) ./ kx;
                    Fy = sin(ky .* Y) ./ ky;

                    F = cat(4, Fx, Fy);

                    divF = cos(kx .* Xsg) + cos(ky .* Ysg);
                case 3
                    kx = (2*pi ./ obj.kgridPadded.xSize);
                    ky = (2*pi ./ obj.kgridPadded.ySize);
                    kz = (2*pi ./ obj.kgridPadded.zSize);

                    [X, Y, Z] = ndgrid(obj.kgridPadded.xVec, obj.kgridPadded.yVec, obj.kgridPadded.zVec);
                    [Xsg, Ysg, Zsg] = ndgrid(xSg, ySg, zSg);

                    Fx = sin(kx .* X) ./ kx;
                    Fy = sin(ky .* Y) ./ ky;
                    Fz = sin(kz .* Z) ./ kz;

                    F = cat(4, Fx, Fy, Fz);

                    divF = cos(kx .* Xsg) + cos(ky .* Ysg) + cos(kz .* Zsg);
            end
        end
        
        % Define a periodic scalar function and its analytic laplacian on
        % the grid specified by obj.kgridPadded. The function is normalised
        % so the maximum of the gradient is approximately 1. The Laplacian
        % can also be returned on a staggered grid.
         function [F, LapF] = getPeriodicVectorFunctionLap(obj, staggering)
         
         arguments
                obj
                staggering(1,:) char {mustBeMember(staggering, {'none', 'forward', 'backward'})} = 'none'
            end
            switch staggering
                case 'none'
                     xSg = obj.kgridPadded.xVec;
                     ySg = obj.kgridPadded.yVec;
                     zSg = obj.kgridPadded.zVec;
                case 'forward'
                     xSg = obj.kgridPadded.xVec + obj.kgridPadded.dx/2;
                     ySg = obj.kgridPadded.yVec + obj.kgridPadded.dy/2;
                     zSg = obj.kgridPadded.zVec + obj.kgridPadded.dz/2;
                case 'backward'
                     xSg = obj.kgridPadded.xVec - obj.kgridPadded.dx/2;
                     ySg = obj.kgridPadded.yVec - obj.kgridPadded.dy/2;
                     zSg = obj.kgridPadded.zVec - obj.kgridPadded.dz/2;
            end
            
            switch obj.kgridPadded.dimensions
                case 1
                    kx = (2*pi ./ obj.kgridPadded.xSize);
                    F = sin(kx .* obj.kgridPadded.xVec) ./ (kx.^2);
                    LapF = -sin(kx .* xSg);
                case 2
                    kx = (2*pi ./ obj.kgridPadded.xSize);
                    ky = (2*pi ./ obj.kgridPadded.ySize);
                    [X, Y] = ndgrid(obj.kgridPadded.xVec, obj.kgridPadded.yVec);
                    [Xsg, Ysg] = ndgrid(xSg, ySg);
                    Fx = sin(kx .* X) ./ (kx);
                    Fy = sin(ky .* Y) ./ (ky);
                    F = Fx.*Fy; 
                    Fx = sin(kx .* Xsg) ./ (kx);
                    Fy = sin(ky .* Ysg) ./ (ky);
                    LapF = -(kx^2+ky.^2).*Fx.*Fy;
                case 3
                    kx = (2*pi ./ obj.kgridPadded.xSize);
                    ky = (2*pi ./ obj.kgridPadded.ySize);
                    kz = (2*pi ./ obj.kgridPadded.zSize);
                    [X, Y, Z] = ndgrid(obj.kgridPadded.xVec, obj.kgridPadded.yVec, obj.kgridPadded.zVec);
                    [Xsg, Ysg, Zsg] = ndgrid(xSg, ySg, zSg);
                    Fx = sin(kx .* X) ./ (kx);
                    Fy = sin(ky .* Y) ./ (ky);
                    Fz = sin(kz .* Z) ./ (kz);
                    F = Fx.*Fy.*Fz;
                    Fx = sin(kx .* Xsg) ./ (kx);
                    Fy = sin(ky .* Ysg) ./ (ky);
                    Fz = sin(kz .* Zsg) ./ (kz);
                    LapF = -(kx^2+ky.^2+kz.^2).*Fx.*Fy.*Fz;
            end
         end
         
        % Define a periodic scalar function on the grid specified by obj.kgridPadded. 
        % The function is normalised and staggered, suitable for returning stagger
        % by Fourier Methods.
         function [F,FStg]= getPeriodicVectorFunctionStg(obj, staggering)
             arguments
                obj
                staggering(1,:) char {mustBeMember(staggering, {'forward', 'backward'})} = 'forward'
            end

            switch staggering
                case 'forward'
                     xSg = obj.kgridPadded.xVec + obj.kgridPadded.dx/2;
                     ySg = obj.kgridPadded.yVec + obj.kgridPadded.dy/2;
                     zSg = obj.kgridPadded.zVec + obj.kgridPadded.dz/2;
                case 'backward'
                     xSg = obj.kgridPadded.xVec - obj.kgridPadded.dx/2;
                     ySg = obj.kgridPadded.yVec - obj.kgridPadded.dy/2;
                     zSg = obj.kgridPadded.zVec - obj.kgridPadded.dz/2;
            end
            switch obj.kgridPadded.dimensions
                case 1
                    kx = (2*pi ./ obj.kgridPadded.xSize);
                    F = sin(kx .* obj.kgridPadded.xVec);
                    FStg = sin(kx.* xSg);
                case 2
                    kx = (2*pi ./ obj.kgridPadded.xSize);
                    ky = (2*pi ./ obj.kgridPadded.ySize);
                    [X, Y] = ndgrid(obj.kgridPadded.xVec, obj.kgridPadded.yVec);
                    [Xsg, Ysg] = ndgrid(xSg, ySg);
                    Fx= sin(kx .* X);
                    Fy= sin(ky .* Y);
                    FSgx= sin(kx .* Xsg);
                    FSgy= sin(ky .* Ysg);
                    F= (Fx+Fy)/2;
                    FStg(:,:,1,1)=(FSgx+Fy)/2;
                    FStg(:,:,1,2)=(Fx+FSgy)/2;
                case 3
                    kx = (2*pi ./ obj.kgridPadded.xSize);
                    ky = (2*pi ./ obj.kgridPadded.ySize);
                    kz = (2*pi ./ obj.kgridPadded.zSize);
                    [X, Y, Z] = ndgrid(obj.kgridPadded.xVec, obj.kgridPadded.yVec, obj.kgridPadded.zVec);
                    [Xsg, Ysg, Zsg] = ndgrid(xSg, ySg, zSg);
                    Fx= sin(kx .* X);
                    Fy= sin(ky .* Y);
                    Fz= sin(kz .* Z);
                    FSgx= sin(kx .* Xsg);
                    FSgy= sin(ky .* Ysg);
                    FSgz= sin(kz .* Zsg);
                    F=(Fx+Fy+Fz)/3;
                    FStg(:,:,:,1)=(FSgx+Fy+Fz)/3;
                    FStg(:,:,:,2)=(Fx+FSgy+Fz)/3;
                    FStg(:,:,:,3)=(Fx+Fy+FSgz)/3;
            end
         end

        % Define a linear scalar function on the grid specified by obj.kgridPadded. 
        % The function is exact for linear interpolation to perform grid staggering.
         function [F,FStg]= getLinearVectorFunctionStg(obj, staggering)
             arguments
                obj
                staggering(1,:) char {mustBeMember(staggering, {'forward', 'backward'})} = 'forward'
            end

            switch staggering
                case 'forward'
                     xSg = obj.kgridPadded.xVec + obj.kgridPadded.dx/2;
                     ySg = obj.kgridPadded.yVec + obj.kgridPadded.dy/2;
                     zSg = obj.kgridPadded.zVec + obj.kgridPadded.dz/2;
                case 'backward'
                     xSg = obj.kgridPadded.xVec - obj.kgridPadded.dx/2;
                     ySg = obj.kgridPadded.yVec - obj.kgridPadded.dy/2;
                     zSg = obj.kgridPadded.zVec - obj.kgridPadded.dz/2;
            end

            switch obj.kgridPadded.dimensions
                case 1
                    kx = max(obj.kgridPadded.xVec);
                    F = 1+obj.kgridPadded.xVec/kx;
                    FStg = 1+xSg/kx;
                case 2
                    kx = max(obj.kgridPadded.xVec);
                    ky = max(obj.kgridPadded.yVec);
                    [X, Y] = ndgrid(obj.kgridPadded.xVec, obj.kgridPadded.yVec);
                    [Xsg, Ysg] = ndgrid(xSg, ySg);
                    Fx= 1+X/kx;
                    Fy= 2-Y/ky;
                    FSgx= 1+Xsg/kx;
                    FSgy= 2-Ysg/ky;
                    F= (Fx+Fy)/2;
                    FStg(:,:,1,1)=(FSgx+Fy)/2;
                    FStg(:,:,1,2)=(Fx+FSgy)/2;
                case 3
                    kx = max(obj.kgridPadded.xVec);
                    ky = max(obj.kgridPadded.yVec);
                    kz = max(obj.kgridPadded.zVec);
                    [X, Y, Z] = ndgrid(obj.kgridPadded.xVec, obj.kgridPadded.yVec, obj.kgridPadded.zVec);
                    [Xsg, Ysg, Zsg] = ndgrid(xSg, ySg, zSg);
                    Fx= 1+X/kx;
                    Fy= 2-Y/ky;
                    Fz= 2*Z/kz;
                    FSgx= 1+Xsg/kx;
                    FSgy= 2-Ysg/ky;
                    FSgz= 2*Zsg/kz;
                    F=(Fx+Fy+Fz)/3;
                    FStg(:,:,:,1)=(FSgx+Fy+Fz)/3;
                    FStg(:,:,:,2)=(Fx+FSgy+Fz)/3;
                    FStg(:,:,:,3)=(Fx+Fy+FSgz)/3;
            end
     end
     
        % Define a periodic vector function and its analytic curl on
        % the grid specified by obj.kgridPadded. The function is normalized so
        % the maximum of the curl is approximately 1. The curl
        % can also be returned on a staggered grid.
        function [F, curlF] = getPeriodicVectorFunctionCurl(obj, staggering)
          arguments
                obj
                staggering(1,:) char {mustBeMember(staggering, {'none', 'forward', 'backward'})} = 'none'
            end

            switch staggering
                case 'none'
                     xSg = obj.kgridPadded.xVec;
                     ySg = obj.kgridPadded.yVec;
                     zSg = obj.kgridPadded.zVec;
                case 'forward'
                     xSg = obj.kgridPadded.xVec + obj.kgridPadded.dx/2;
                     ySg = obj.kgridPadded.yVec + obj.kgridPadded.dy/2;
                     zSg = obj.kgridPadded.zVec + obj.kgridPadded.dz/2;
                case 'backward'
                     xSg = obj.kgridPadded.xVec - obj.kgridPadded.dx/2;
                     ySg = obj.kgridPadded.yVec - obj.kgridPadded.dy/2;
                     zSg = obj.kgridPadded.zVec - obj.kgridPadded.dz/2;
            end
            
            % Only need the 3D case here as curl is only defined for the 3D case
            % Choose wavenumbers to make function periodic on padded grid
            kx = (2*pi ./ obj.kgridPadded.xSize);
            ky = (2*pi ./ obj.kgridPadded.ySize);
            kz = (2*pi ./ obj.kgridPadded.zSize);
            
            [X, Y, Z] = ndgrid(obj.kgridPadded.xVec, obj.kgridPadded.yVec, obj.kgridPadded.zVec);
            [Xsg, Ysg, Zsg] = ndgrid(xSg, ySg, zSg);

            % Define a periodic vector function (on a staggered Yee cell)
            F(:,:,:,1) = ( sin(ky .* Y)/ky ) .* ( sin(kz .* Z)/kz ); 
            F(:,:,:,2) = ( sin(kx .* X)/kx ) .* ( sin(kz .* Z)/kz ); 
            F(:,:,:,3) = ( sin(kx .* X)/kx ) .* ( sin(ky .* Y)/ky ); 

            % Calculate the components of the analytical curl of F
            dFxdy =   cos(ky .* Ysg)      .* ( sin(kz .* Z  )/kz );
            dFxdz = ( sin(ky .* Y  )/ky ) .*   cos(kz .* Zsg);
            dFydx =   cos(kx .* Xsg)      .* ( sin(kz .* Z  )/kz );
            dFydz = ( sin(kx .* X  )/kx ) .*   cos(kz .* Zsg);
            dFzdx =   cos(kx .* Xsg)      .* ( sin(ky .* Y  )/ky );
            dFzdy = ( sin(kx .* X  )/kx ) .*   cos(ky .* Ysg);

            % Construct the analytical curl of F
            curlF(:,:,:,1) = dFzdy - dFydz;
            curlF(:,:,:,2) = dFxdz - dFzdx;      
            curlF(:,:,:,3) = dFydx - dFxdy;

        end


        % Define a periodic vector function and its analytic gradient on
        % the grid specified by obj.kgridPadded, returning the gradients 
        % in each axis as a tensor field. The function is normalized so 
        % the maximum of the gradient in each axis is approximately 1. 
        % The tensor field can also be returned on a staggered grid.
        function [F, gradF] = getPeriodicTensorFunction(obj, staggering)

            arguments
                obj
                staggering(1,:) char {mustBeMember(staggering, {'none', 'forward', 'backward'})} = 'none'
            end

            switch staggering
                case 'none'
                    xxSg = obj.kgridPadded.xVec;
                    xySg = obj.kgridPadded.yVec;
                    xzSg = obj.kgridPadded.zVec;
                    yxSg = obj.kgridPadded.xVec;
                    yySg = obj.kgridPadded.yVec;
                    yzSg = obj.kgridPadded.zVec;
                    zxSg = obj.kgridPadded.xVec;
                    zySg = obj.kgridPadded.yVec;
                    zzSg = obj.kgridPadded.zVec;
                case 'forward'
                    xxSg = obj.kgridPadded.xVec + obj.kgridPadded.dx/2;
                    xySg = obj.kgridPadded.yVec - obj.kgridPadded.dy/2;
                    xzSg = obj.kgridPadded.zVec - obj.kgridPadded.dz/2;
                    yxSg = obj.kgridPadded.xVec - obj.kgridPadded.dx/2;
                    yySg = obj.kgridPadded.yVec + obj.kgridPadded.dy/2;
                    yzSg = obj.kgridPadded.zVec - obj.kgridPadded.dz/2;
                    zxSg = obj.kgridPadded.xVec - obj.kgridPadded.dx/2;
                    zySg = obj.kgridPadded.yVec - obj.kgridPadded.dy/2;
                    zzSg = obj.kgridPadded.zVec + obj.kgridPadded.dz/2;

                case 'backward'
                    xxSg = obj.kgridPadded.xVec - obj.kgridPadded.dx/2;
                    xySg = obj.kgridPadded.yVec + obj.kgridPadded.dy/2;
                    xzSg = obj.kgridPadded.zVec + obj.kgridPadded.dz/2;
                    yxSg = obj.kgridPadded.xVec + obj.kgridPadded.dx/2;
                    yySg = obj.kgridPadded.yVec - obj.kgridPadded.dy/2;
                    yzSg = obj.kgridPadded.zVec + obj.kgridPadded.dz/2;
                    zxSg = obj.kgridPadded.xVec + obj.kgridPadded.dx/2;
                    zySg = obj.kgridPadded.yVec + obj.kgridPadded.dy/2;
                    zzSg = obj.kgridPadded.zVec - obj.kgridPadded.dz/2;
            end

            switch obj.kgridPadded.dimensions
                case 1
                    kx = (2*pi ./ obj.kgridPadded.xSize);
                    F = sin(kx .* obj.kgridPadded.xVec) ./ kx;
                    gradF = cos(kx .* xxSg);
                case 2
                    kx = (2*pi ./ obj.kgridPadded.xSize);
                    ky = (2*pi ./ obj.kgridPadded.ySize);

                    [X, Y] = ndgrid(obj.kgridPadded.xVec, obj.kgridPadded.yVec);
                    [xxsg, xysg] = ndgrid(xxSg, xySg);
                    [yxsg, yysg] = ndgrid(yxSg, yySg);

                    Fx = sin(kx .* X) .* sin(ky .* Y) ./ kx;
                    Fy = sin(ky .* Y) .* sin(kx .* X) ./ ky;

                    gradFx_x = cos(kx .* xxsg) .* sin(ky .* Y);
                    gradFx_y = sin(kx .* X)   .* cos(ky .* xysg) .* (ky ./ kx);
                    gradFy_x = sin(ky .* Y)   .* cos(kx .* yxsg) .* (kx ./ ky);
                    gradFy_y = cos(ky .* yysg) .* sin(kx .* X);

                    F = cat(4, Fx, Fy);
                    gradF = cat(5, cat(4, gradFx_x, gradFy_x), cat(4, gradFx_y, gradFy_y));

                case 3
                    kx = (2*pi ./ obj.kgridPadded.xSize);
                    ky = (2*pi ./ obj.kgridPadded.ySize);
                    kz = (2*pi ./ obj.kgridPadded.zSize);

                    [X, Y, Z] = ndgrid(obj.kgridPadded.xVec, obj.kgridPadded.yVec, obj.kgridPadded.zVec);
                    [xxsg, xysg, xzsg] = ndgrid(xxSg, xySg, xzSg);
                    [yxsg, yysg, yzsg] = ndgrid(yxSg, yySg, yzSg);
                    [zxsg, zysg, zzsg] = ndgrid(zxSg, zySg, zzSg);

                    Fx = sin(kx .* X) .* sin(ky .* Y) .* sin(kz .* Z) ./ kx;
                    Fy = sin(ky .* Y) .* sin(kx .* X) .* sin(kz .* Z) ./ ky;
                    Fz = sin(kz .* Z) .* sin(kx .* X) .* sin(ky .* Y) ./ kz;

                    gradFx_x = cos(kx .* xxsg) .* sin(ky .* Y) .* sin(kz .* Z);
                    gradFx_y = sin(kx .* X) .* cos(ky .* xysg) .* sin(kz .* Z) .* (ky ./ kx);
                    gradFx_z = sin(kx .* X) .* sin(ky .* Y) .* cos(kz .* xzsg) .* (kz ./ kx);

                    gradFy_x = sin(ky .* Y) .* cos(kx .* yxsg) .* sin(kz .* Z) .* (kx ./ ky);
                    gradFy_y = cos(ky .* yysg) .* sin(kx .* X) .* sin(kz .* Z);
                    gradFy_z = sin(ky .* Y) .* sin(kx .* X) .* cos(kz .* yzsg) .* (kz ./ ky);

                    gradFz_x = sin(kz .* Z) .* cos(kx .* zxsg) .* sin(ky .* Y) .* (kx ./ kz);
                    gradFz_y = sin(kz .* Z) .* sin(kx .* X) .* cos(ky .* zysg) .* (ky ./ kz);
                    gradFz_z = cos(kz .* zzsg) .* sin(kx .* X) .* sin(ky .* Y);

                    F = cat(4, Fx, Fy, Fz);
                    gradF = cat(5, cat(4, gradFx_x, gradFy_x, gradFz_x), cat(4, gradFx_y, gradFy_y, gradFz_y), cat(4, gradFx_z, gradFy_z, gradFz_z));
            end
        end

    end

end
