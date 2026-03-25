%% TestAcousticSensor
% *Package:* kwave.tests.unit
% *Superclasses:* matlab.unittest.TestCase
%
% Unit tests for the AcousticSensor class.
%
%% Description
% Tests shape allocation and basic property behavior for AcousticSensor.
% The tests avoid relying on the full solver.

classdef TestAcousticSensor < matlab.unittest.TestCase

    properties
        grid   % kwave.toolbox.Grid
        sensor % kwave.toolbox.AcousticSensor
    end

    methods (TestMethodSetup)
        function createGridAndSensor(testCase)
            
            % 2D grid; small for quick tests.
            testCase.grid = kwave.toolbox.Grid([8, 7], [1, 1]);

            % Underlying Sensor constructor typically accepts the grid.
            testCase.sensor = kwave.toolbox.AcousticSensor(testCase.grid);
            
            % Define a sparse mask with a known number of points.
            mask = false(testCase.grid.gridSize);
            mask(1,1) = true;
            mask(3,5) = true;
            mask(8,7) = true;
            testCase.sensor.mask = mask; % totalSensorPoints should be nnz(mask)
            % Leave timeSteps at default (1) unless a test changes it.
        end
    end

    methods (Test)
        
        function defaults_are_as_documented(testCase)
            s = testCase.sensor;
            testCase.verifyEqual(s.pressureSensor, 'on');   % default
            testCase.verifyEqual(s.velocitySensor, 'off');  % default
            testCase.verifyEqual(s.densitySensor,  'off');  % default
            testCase.verifyEqual(s.timeSteps, 1);           % default
        end

        function validators_reject_invalid_members(testCase)
            s = testCase.sensor;
            testCase.verifyError(@() setVelocity(s, 'bad'),      'MATLAB:validators:mustBeMember');
            testCase.verifyError(@() setPressure(s, 'maybe'),    'MATLAB:validators:mustBeMember');
            testCase.verifyError(@() setDensity(s, 'maybe'),     'MATLAB:validators:mustBeMember');
            function setVelocity(obj,val), obj.velocitySensor = val; end
            function setPressure(obj,val), obj.pressureSensor = val; end
            function setDensity(obj,val),  obj.densitySensor  = val; end
        end

        function initialise_Nt0_pressure_only(testCase)
            s = testCase.sensor;
            s.pressureSensor = 'on';
            s.densitySensor  = 'off';
            s.velocitySensor = 'off';
            s = s.initialiseSensorData(0);
            nPts = s.totalSensorPoints;
            testCase.verifySize(s.pressure, [nPts, 1]);
            testCase.verifyEqual(s.times, 0);
        end

        function initialise_Nt0_density_only_allocates_density(testCase)
            % This test expects density to allocate at Nt == 0 when densitySensor='on'.
            s = testCase.sensor;
            s.pressureSensor = 'off';
            s.densitySensor  = 'on';
            s.velocitySensor = 'off';
            s = s.initialiseSensorData(0);
            nPts = s.totalSensorPoints;
            testCase.verifySize(s.density, [nPts, 1]);   % Expected behavior
            testCase.verifyTrue(isempty(s.pressure));    % Should not allocate pressure here
            testCase.verifyEqual(s.times, 0);
        end

        function initialise_Nt0_velocity_on_shape(testCase)
            % Expect velocity to allocate [nPts, D, 1] so it matches the
            % recordSensorData slicing convention velocity(:,:,n)
            s = testCase.sensor;
            s.pressureSensor = 'off';
            s.densitySensor  = 'off';
            s.velocitySensor = 'on';
            s = s.initialiseSensorData(0);
            nPts = s.totalSensorPoints;
            D    = s.kgrid.dimensions;
            testCase.verifySize(s.velocity, [nPts, D, 1]); % Expected
            testCase.verifyEqual(s.times, 0);
        end

        function initialise_positiveNt_allocates_all_and_times(testCase)
            s = testCase.sensor;
            s.pressureSensor  = 'on';
            s.densitySensor   = 'on';
            s.velocitySensor  = 'on';
            s.timeStepSpacing = 2;
            Nt = 9;                      % arbitrary
            nCols = floor(Nt/s.timeStepSpacing) + 1;     % 5
            s = s.initialiseSensorData(Nt);
            nPts = s.totalSensorPoints;
            D    = s.kgrid.dimensions;
            testCase.verifySize(s.pressure, [nPts, nCols]);
            testCase.verifySize(s.density,  [nPts, nCols]);
            testCase.verifySize(s.velocity, [nPts, D, nCols]);
            testCase.verifySize(s.times,    [1,   nCols]);
        end

        function initialise_extend_buffers_on_subsequent_calls(testCase)
            % First call allocates; second call should extend by floor(Nt/timeSteps).
            s = testCase.sensor;
            s.pressureSensor  = 'on';
            s.timeStepSpacing = 2;
            s = s.initialiseSensorData(4);  % nCols = 3
            s = s.initialiseSensorData(4);  % extend by floor(4/2)=2 -> total 5
            nCols = 5;
            nPts  = s.totalSensorPoints;
            testCase.verifySize(s.pressure, [nPts, nCols]);
            testCase.verifySize(s.times,    [1,   nCols]);
        end

        % function record_velocity_on_grid_branch_respected(testCase)
        %     % Demonstrate how to test 'ongrid' recording using a spy that bypasses
        %     % ProcessSensorData. This is a template; enable when ready.
        %     %
        %     % NOTE: The attached class compares 'onGrid' (camel case) in recordSensorData,
        %     % while the validator allows 'ongrid' (lowercase). This test expects lowercase
        %     % to be honored; if the class isn't case-normalizing, it may fail and surface
        %     % the inconsistency.
        %     testCase.assumeTrue(true); % set to false if you want to skip for now
        % 
        %     s = testCase.sensor;
        %     s.pressureSensor = 'off';
        %     s.velocitySensor = 'ongrid';   % per validator
        %     s = s.initialiseSensorData(3);
        % 
        %     spy = kwave.tests.unit.support.AcousticSensorSpy(s); % see helper class below
        % 
        %     fake = kwave.tests.unit.support.FakeSolver(testCase.grid);
        %     fake.timePoint = 1.23;
        % 
        %     spy = spy.recordSensorData(fake, 1);
        %     testCase.verifySize(spy.velocity, [spy.totalSensorPoints, spy.kgrid.dimensions, size(spy.velocity,3)]);
        %     testCase.verifyEqual(spy.times(1), fake.timePoint);
        % end
    end
end
