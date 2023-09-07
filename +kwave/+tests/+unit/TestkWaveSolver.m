%% TestkWaveSolver
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.TestGrid
%
% Unit tests for the kWaveSolver class.
%
%% Description
% Tests the gradient and divergence functions of the kWaveSolver against
% simple analytical functions that are periodic on the test grid. All
% dimensions and grid staggering options are tested.
%
% Note, as kWaveSolver is an abstract class, we must use one of the
% concrete implementations to test it. Here, we use kWaveThermalSolver
% setup with dummy medium and source properties (which aren't used in the
% tests).

classdef TestkWaveSolver < kwave.tests.unit.TestGrid

    % Add solver to class properties so we can pass it to each testCase.
    properties
        solver kwave.toolbox.kWaveThermalSolver
    end

    % Setup solver for each test.
    methods(TestMethodSetup, ParameterCombination="sequential")
        function createSolver(testCase)
            import kwave.toolbox.*

            medium = kWaveThermalMedium(testCase.kgrid);
            medium.thermalConductivity = 0.52;
            medium.specificHeat = 3540;
            medium.density = 1000;
            
            source = kWaveThermalSource(testCase.kgrid);

            testCase.solver = kWaveThermalSolver(testCase.kgrid, medium, source, []);
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
            [f, testCase.referenceSolution] = testCase.getPeriodicVectorFunction;
            testCase.actualSolution = testCase.solver.divergence(f);
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

            % Forward staggering.
            [f, testCase.referenceSolution] = testCase.getPeriodicVectorFunction("forward");
            testCase.actualSolution = testCase.solver.divergence(f, Staggering="forward");
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

            % Backward staggering.
            [f, testCase.referenceSolution] = testCase.getPeriodicVectorFunction("backward");
            testCase.actualSolution = testCase.solver.divergence(f, Staggering="backward");
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

            % Scalar kappa.
            testCase.solver.kappa = 2;
            [f, testCase.referenceSolution] = testCase.getPeriodicVectorFunction;
            testCase.referenceSolution = testCase.referenceSolution .* testCase.solver.kappa;
            testCase.actualSolution = testCase.solver.divergence(f);
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

            % Test incorrect size gives exception.
            f = rand(2, 2, 2, 4);
            testCase.verifyError(@() testCase.solver.divergence(f), 'kWaveSolver:incorrectSize');

        end

        % Test sinc function.
        function testSinc(testCase)
            import matlab.unittest.constraints.IsEqualTo

            x = linspace(-10, 10, 100);
            testCase.actualSolution = testCase.solver.sinc(pi * x);
            testCase.referenceSolution = sinc(x);
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));
        end

        % Define medium and source inputs on a different grid, and test for
        % input errors.
        function testInputErrors(testCase)
            import kwave.toolbox.*

            kgrid = kWaveGrid(10, 2e-3);

            medium = kWaveThermalMedium(kgrid);
            medium.thermalConductivity = 0.52;
            medium.specificHeat = 3540;
            medium.density = 1000;
            
            source = kWaveThermalSource(kgrid);

            testCase.verifyError(@() ...
                kWaveThermalSolver(testCase.kgrid, medium, testCase.solver.source, []), ...
                'kWaveSolver:gridMismatch');

                testCase.verifyError(@() ...
                kWaveThermalSolver(testCase.kgrid, testCase.solver.medium, source, []), ...
                'kWaveSolver:gridMismatch');

        end

    end

    % Test utilities.
    methods

        % Define a periodic scalar function and its analytic gradient on
        % the grid specified by obj.kgrid. The function is normalised so
        % the maximum of the gradient is approximately 1. The gradient can
        % also be returned on a staggered grid.
        function [F, gradF] = getPeriodicScalarFunction(obj, staggering)

            arguments
                obj
                staggering(1,:) char {mustBeMember(staggering, {'none', 'forward', 'backward'})} = 'none'
            end

            switch staggering
                case 'none'
                     xSg = obj.kgrid.xVec;
                     ySg = obj.kgrid.yVec;
                     zSg = obj.kgrid.zVec;
                case 'forward'
                     xSg = obj.kgrid.xVec + obj.kgrid.dx/2;
                     ySg = obj.kgrid.yVec + obj.kgrid.dy/2;
                     zSg = obj.kgrid.zVec + obj.kgrid.dz/2;
                case 'backward'
                     xSg = obj.kgrid.xVec - obj.kgrid.dx/2;
                     ySg = obj.kgrid.yVec - obj.kgrid.dy/2;
                     zSg = obj.kgrid.zVec - obj.kgrid.dz/2;
            end

            switch obj.kgrid.dimensions
                case 1
                    kx = (2*pi ./ obj.kgrid.xSize);
                    F = sin(kx .* obj.kgrid.xVec) ./ kx;
                    gradF = cos(kx .* xSg);
                case 2
                    kx = (2*pi ./ obj.kgrid.xSize);
                    ky = (2*pi ./ obj.kgrid.ySize);

                    [X, Y] = ndgrid(obj.kgrid.xVec, obj.kgrid.yVec);
                    [Xsg, Ysg] = ndgrid(xSg, ySg);
                    
                    F = sin(kx .* X) .* sin(ky .* Y) ./ kx;
                    
                    gradF = zeros([size(F), 1, 2]);
                    gradF(:, :, :, 1) = cos(kx .* Xsg) .* sin(ky .* Y);
                    gradF(:, :, :, 2) = sin(kx .* X)   .* cos(ky .* Ysg) .* (ky ./ kx);
                case 3
                    kx = (2*pi ./ obj.kgrid.xSize);
                    ky = (2*pi ./ obj.kgrid.ySize);
                    kz = (2*pi ./ obj.kgrid.zSize);
                    
                    [X, Y, Z] = ndgrid(obj.kgrid.xVec, obj.kgrid.yVec, obj.kgrid.zVec);
                    [Xsg, Ysg, Zsg] = ndgrid(xSg, ySg, zSg);
                    
                    F = sin(kx .* X) .* sin(ky .* Y) .* sin(kz .* Z) ./ kx;
                    
                    gradF = zeros([size(F), 3]);
                    gradF(:, :, :, 1) = cos(kx .* Xsg) .* sin(ky .* Y)   .* sin(kz .* Z);
                    gradF(:, :, :, 2) = sin(kx .* X)   .* cos(ky .* Ysg) .* sin(kz .* Z)   .* (ky ./ kx);
                    gradF(:, :, :, 3) = sin(kx .* X)   .* sin(ky .* Y)   .* cos(kz .* Zsg) .* (kz ./ kx);
            end
        end

        % Define a periodic vector function and its analytic divergence on
        % the grid specified by obj.kgrid. The function is normalized so
        % the maximum of the divergence is approximately 1. The gradient
        % can also be returned on a staggered grid.
        function [F, divF] = getPeriodicVectorFunction(obj, staggering)

            arguments
                obj
                staggering(1,:) char {mustBeMember(staggering, {'none', 'forward', 'backward'})} = 'none'
            end

            switch staggering
                case 'none'
                     xSg = obj.kgrid.xVec;
                     ySg = obj.kgrid.yVec;
                     zSg = obj.kgrid.zVec;
                case 'forward'
                     xSg = obj.kgrid.xVec + obj.kgrid.dx/2;
                     ySg = obj.kgrid.yVec + obj.kgrid.dy/2;
                     zSg = obj.kgrid.zVec + obj.kgrid.dz/2;
                case 'backward'
                     xSg = obj.kgrid.xVec - obj.kgrid.dx/2;
                     ySg = obj.kgrid.yVec - obj.kgrid.dy/2;
                     zSg = obj.kgrid.zVec - obj.kgrid.dz/2;
            end

            switch obj.kgrid.dimensions
                case 1
                    kx = (2*pi ./ obj.kgrid.xSize);
                    F = sin(kx .* obj.kgrid.xVec) ./ kx;
                    divF = cos(kx .* xSg);
                case 2
                    kx = (2*pi ./ obj.kgrid.xSize);
                    ky = (2*pi ./ obj.kgrid.ySize);
                    
                    [X, Y] = ndgrid(obj.kgrid.xVec, obj.kgrid.yVec);
                    [Xsg, Ysg] = ndgrid(xSg, ySg);
                    
                    Fx = sin(kx .* X) ./ kx;
                    Fy = sin(ky .* Y) ./ ky;
                    
                    F = cat(4, Fx, Fy);
                    
                    divF = cos(kx .* Xsg) + cos(ky .* Ysg);
                case 3
                    kx = (2*pi ./ obj.kgrid.xSize);
                    ky = (2*pi ./ obj.kgrid.ySize);
                    kz = (2*pi ./ obj.kgrid.zSize);
                    
                    [X, Y, Z] = ndgrid(obj.kgrid.xVec, obj.kgrid.yVec, obj.kgrid.zVec);
                    [Xsg, Ysg, Zsg] = ndgrid(xSg, ySg, zSg);
                    
                    Fx = sin(kx .* X) ./ kx;
                    Fy = sin(ky .* Y) ./ ky;
                    Fz = sin(kz .* Z) ./ kz;
                    
                    F = cat(4, Fx, Fy, Fz);
                    
                    divF = cos(kx .* Xsg) + cos(ky .* Ysg) + cos(kz .* Zsg);
            end
        end

    end

end
