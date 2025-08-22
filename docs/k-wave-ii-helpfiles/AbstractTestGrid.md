---
DC.date: '2025-08-19'
DC.source: 'AbstractTestGrid.m'
generator: 'MATLAB 25.1'
title: AbstractTestGrid
---

::: {.content}
AbstractTestGrid
================

**Package:** kwave.tests.unit **Superclasses:** matlab.unittest.TestCase

Super class for tests requiring a Grid object of different sizes.

Contents
--------

<div>

-   [Description](#1)
-   [Examples](#2)
-   [See Also](#3)

</div>

Description {#1}
-----------

Abstract test class for tests that require a `kwave.toolbox.Grid` object
with different sizes and dimensions. Each test method should define
`testClass.actualSolution` and `testClass.referenceSolution`.
Comparisons should be made using `testCase.verifyThat` as shown in the
example below. `kwave.toolbox.Grid` objects are defined on both the
unpadded (`kgrid`) and padded domains (`kgridPadded`). The test class
also sets up a failure diagnostic that plots the differences in the
actual and reference solution.

Examples {#2}
--------

Example of a derived test class that uses the parametrised Grid object.
This automatically loops over different 1D, 2D, and 3D
`kwave.toolbox.Grid` objects assigned to `kgrid`.

      classdef TestMyClass < kwave.tests.unit.AbstractTestGrid
          methods(Test, ParameterCombination="sequential")
              function testSomething(testCase)

                  import matlab.unittest.constraints.IsEqualTo
                  import kwave.toolbox.*

                  % Assign actual and reference solutions.
                  testCase.actualSolution = testCase.kgrid.xVec;
                  testCase.referenceSolution = testCase.kgrid.yVec;

                  % Compare with tolerance.
                  testCase.verifyThat(testCase.actualSolution, IsEqualTo(testCase.referenceSolution, "Within", testCase.tol));

              end
          end
      end

See Also {#3}
--------

<div>

-   `AbstractTestGridInput`

</div>

\
[Published with MATLAB®
R2025a](https://www.mathworks.com/products/matlab/)\
:::
