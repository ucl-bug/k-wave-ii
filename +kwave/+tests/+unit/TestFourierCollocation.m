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
        function testGradientSymTensor(testCase)
            import matlab.unittest.constraints.IsEqualTo

            % No staggering.
            [f, testCase.referenceSolution] = testCase.getPeriodicGradTensorFunction;
            testCase.actualSolution = testCase.solver.gradientSymTensor(f);
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

            % Forward staggering.
            [f, testCase.referenceSolution] = testCase.getPeriodicGradTensorFunction("forward");
            testCase.actualSolution = testCase.solver.gradientSymTensor(f, Staggering="forward");
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

            % Backward staggering.
            [f, testCase.referenceSolution] = testCase.getPeriodicGradTensorFunction("backward");
            testCase.actualSolution = testCase.solver.gradientSymTensor(f, Staggering="backward");
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

            % Scalar kappa.
            testCase.solver.kappa = 2;
            [f, testCase.referenceSolution] = testCase.getPeriodicGradTensorFunction;
            testCase.referenceSolution = testCase.referenceSolution .* testCase.solver.kappa;
            testCase.actualSolution = testCase.solver.gradientSymTensor(f);
            testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

            % Test incorrect size gives exception.
            f = rand(2, 2, 2, 7);
            testCase.verifyError(@() testCase.solver.gradientSymTensor(f), 'FourierCollocation:incorrectSize');
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


        % Define a periodic tensor function and its analytic gradient on
        % the grid specified by obj.kgridPadded, returning the gradients
        % in each axis. The function is normalized so the maximum of the
        % gradient in each axis is approximately 1.  The gradient tensor
        % can also be returned on a staggered grid.
        function [F, gradF] = getPeriodicGradTensorFunction(obj, staggering)

            arguments
                obj
                staggering(1,:) char {mustBeMember(staggering, {'none', 'forward', 'backward'})} = 'none'
            end

            switch staggering
                case 'none'
                    xxSgx = obj.kgridPadded.xVec;
                    xySgy = obj.kgridPadded.yVec;
                    xzSgz = obj.kgridPadded.zVec;
                    yxSgx = obj.kgridPadded.xVec;
                    yySgy = obj.kgridPadded.yVec;
                    yzSgz = obj.kgridPadded.zVec;
                    zxSgx = obj.kgridPadded.xVec;
                    zySgy = obj.kgridPadded.yVec;
                    zzSgz = obj.kgridPadded.zVec;
                case 'forward'
                    xxSgx = obj.kgridPadded.xVec + obj.kgridPadded.dx/2;
                    xySgy = obj.kgridPadded.yVec - obj.kgridPadded.dy/2;
                    xzSgz = obj.kgridPadded.zVec - obj.kgridPadded.dz/2;
                    yxSgx = obj.kgridPadded.xVec - obj.kgridPadded.dx/2;
                    yySgy = obj.kgridPadded.yVec + obj.kgridPadded.dy/2;
                    yzSgz = obj.kgridPadded.zVec - obj.kgridPadded.dz/2;
                    zxSgx = obj.kgridPadded.xVec - obj.kgridPadded.dx/2;
                    zySgy = obj.kgridPadded.yVec - obj.kgridPadded.dy/2;
                    zzSgz = obj.kgridPadded.zVec + obj.kgridPadded.dz/2;

                case 'backward'
                    xxSgx = obj.kgridPadded.xVec - obj.kgridPadded.dx/2;
                    xySgy = obj.kgridPadded.yVec + obj.kgridPadded.dy/2;
                    xzSgz = obj.kgridPadded.zVec + obj.kgridPadded.dz/2;
                    yxSgx = obj.kgridPadded.xVec + obj.kgridPadded.dx/2;
                    yySgy = obj.kgridPadded.yVec - obj.kgridPadded.dy/2;
                    yzSgz = obj.kgridPadded.zVec + obj.kgridPadded.dz/2;
                    zxSgx = obj.kgridPadded.xVec + obj.kgridPadded.dx/2;
                    zySgy = obj.kgridPadded.yVec + obj.kgridPadded.dy/2;
                    zzSgz = obj.kgridPadded.zVec - obj.kgridPadded.dz/2;
            end

            switch obj.kgridPadded.dimensions
                case 1
                    kx = (2*pi ./ obj.kgridPadded.xSize);
                    F = sin(kx .* obj.kgridPadded.xVec) ./ kx;
                    gradF = cos(kx .* xxSgx);

                case 2
                    kx = (2*pi ./ obj.kgridPadded.xSize);
                    ky = (2*pi ./ obj.kgridPadded.ySize);

                    [X, Y] = ndgrid(obj.kgridPadded.xVec, obj.kgridPadded.yVec);
                    [xxsgx, xysgy] = ndgrid(xxSgx, xySgy);
                    [yxsgx, yysgy] = ndgrid(yxSgx, yySgy);

                    Fxx = sin(kx .* X) .* sin(ky .* Y) ./ kx;
                    Fyy = sin(ky .* Y) .* sin(kx .* X) ./ ky;
                    Fxy = sin(kx .* X) .* sin(ky .* Y) ./ (kx .* ky);

                    gradFxx_x = cos(kx .* xxsgx) .* sin(ky .* Y);
                    gradFxy_x = sin(ky .* Y)   .* cos(kx .* yxsgx) .* (1 ./ ky);
                    gradFxy_y = sin(kx .* X)   .* cos(ky .* xysgy) .* (1 ./ kx);
                    gradFyy_y = cos(ky .* yysgy) .* sin(kx .* X);

                    F = cat(4, Fxx, Fyy, Fxy);
                    gradF = cat(5, cat(4, gradFxx_x, gradFxy_x), cat(4, gradFxy_y, gradFyy_y));

                case 3
                    kx = (2*pi ./ obj.kgridPadded.xSize);
                    ky = (2*pi ./ obj.kgridPadded.ySize);
                    kz = (2*pi ./ obj.kgridPadded.zSize);

                    [X, Y, Z] = ndgrid(obj.kgridPadded.xVec, obj.kgridPadded.yVec, obj.kgridPadded.zVec);
                    [xxsgx, xysgy, xzsgz] = ndgrid(xxSgx, xySgy, xzSgz);
                    [yxsgx, yysgy, yzsgz] = ndgrid(yxSgx, yySgy, yzSgz);
                    [zxsgx, zysgy, zzsgz] = ndgrid(zxSgx, zySgy, zzSgz);

                    Fxx = sin(kx .* X) .* sin(ky .* Y) .* sin(kz .* Z) ./ kx;
                    Fyy = sin(ky .* Y) .* sin(kx .* X) .* sin(kz .* Z) ./ ky;
                    Fzz = sin(kz .* Z) .* sin(kx .* X) .* sin(ky .* Y) ./ kz;
                    Fxy = sin(kx .* X) .* sin(ky .* Y) .* sin(kz .* Z) ./ (kx .* ky);
                    Fxz = sin(ky .* Y) .* sin(kx .* X) .* sin(kz .* Z) ./ (kx .* kz);
                    Fyz = sin(kz .* Z) .* sin(kx .* X) .* sin(ky .* Y) ./ (ky .* kz);

                    gradFxx_x = cos(kx .* xxsgx) .* sin(ky .* Y) .* sin(kz .* Z);
                    gradFxy_y = sin(kx .* X) .* cos(ky .* xysgy) .* sin(kz .* Z) .* (1 ./ kx);
                    gradFxz_z = sin(kx .* X) .* sin(ky .* Y) .* cos(kz .* xzsgz) .* (1 ./ kx);

                    gradFyx_x = sin(ky .* Y) .* cos(kx .* yxsgx) .* sin(kz .* Z) .* (1 ./ ky);
                    gradFyy_y = cos(ky .* yysgy) .* sin(kx .* X) .* sin(kz .* Z);
                    gradFyz_z = sin(ky .* Y) .* sin(kx .* X) .* cos(kz .* yzsgz) .* (1 ./ ky);

                    gradFzx_x = sin(kz .* Z) .* cos(kx .* zxsgx) .* sin(ky .* Y) .* (1 ./ kz);
                    gradFzy_y = sin(kz .* Z) .* sin(kx .* X) .* cos(ky .* zysgy) .* (1 ./ kz);
                    gradFzz_z = cos(kz .* zzsgz) .* sin(kx .* X) .* sin(ky .* Y);

                    F = cat(4, Fxx, Fyy, Fzz, Fxy, Fxz, Fyz);
                    gradF = cat(5, cat(4, gradFxx_x, gradFyx_x, gradFzx_x), cat(4, gradFxy_y, gradFyy_y, gradFzy_y), cat(4, gradFxz_z, gradFyz_z, gradFzz_z));
            end
        end

    end

end
