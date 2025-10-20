%% TestThermalSource
% *Package:* kwave.tests.unit
% *Superclasses:* kwave.tests.unit.AbstractTestGridInput
%
% Unit tests for the ThermalSource class using the TestMedium class.
% Tests that the solver will still run with empty initial condition, and
% that the when given an initial condition it produces the correct size
% matrix

classdef TestThermalSource < kwave.tests.unit.AbstractTestGridInput

    properties
        inputClass = 'ThermalSource'
        inputProperties = {'initialTemperature'}
        inputPropertiesPadded = {'initialTemperaturePadded'}
        inputPropertiesScalar = {}
        inputPropertiesComplex = {}
        inputPropertiesVectorField = {}
    end

    methods(Test)
        function testSubrefs(testCase)

            % Initialize source object.
            grid = kwave.toolbox.Grid([64,64,], [0.5,0.5]);
            source = kwave.toolbox.ThermalSource(grid);
            medium = kwave.toolbox.ThermalMedium(grid);
            medium.thermalConductivity = 0.52;
            medium.specificHeat = 3540;
            medium.density = 1000;
            solver=kwave.toolbox.ThermalSolver(grid, medium, source, []);
            solver.run(Nt=0,dt=1);
            % Check slicing.
            testCase.verifyEqual(size(solver.temperature(1,:)), [1, 64]);

            source.initialTemperature = rand(source.gridSize);
            % Check slicing.
            testCase.verifyEqual(size(source.initialTemperature(1,:)), [1, 64]);
            
            

        end
    end

end
