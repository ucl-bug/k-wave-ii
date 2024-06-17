%% TestFourierCollocation
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.TestGrid
%
% Unit tests for the FourierCollocation class.
%
%% Description
% Tests the gradient and divergence functions of the
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
        end

        % Test sinc function.
        function testSinc(testCase)
            import matlab.unittest.constraints.IsEqualTo

            x = linspace(-10, 10, 100);
            testCase.actualSolution = testCase.solver.sinc(pi * x);
            testCase.referenceSolution = sinc(x);
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
        % the maximum of the divergence is approximately 1. The gradient
        % can also be returned on a staggered grid.
        function [F, divF] = getPeriodicVectorFunction(obj, staggering)

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
