# k-Wave-II: A MATLAB toolbox for the simulation of acoustic wave fields

[![License: LGPL v3](https://img.shields.io/badge/License-LGPL_v3-blue.svg)](LICENSE.txt)

## Overview

### Project goals

k-Wave-II is a major re-write of the original k-Wave Toolbox, developed
with the following aims:

1. Re-engineering the code base to leverage object orientated programming
and differentiable functions for deep learning and coupled physics problems
2. Extending the algorithms to facilitate general boundary conditions on
arbitrary surfaces, and to increase performance for narrow-band simulations
3. Improving the development and release process to incorporate good
practice and advance long-term sustainability
4. Improving training, user engagement, and support.

### Guiding principles

- Code is accurate
   - Avoids narrow scope assumptions
   - Well tested
   - Implements input validation and error handling
- Code is easy to use
   - Well thought out interfaces
   - Well chosen defaults
   - User examples
   - Documentation
   - Stable API
   - Feedback, warnings
- Code is sustainable
- Code is fast

## Getting started

### Minimum requirements

- k-Wave-II requires MATLAB 2022b or later.
- If importing the k-Wave-II namespace (using `import kwave.toolbox.*`) it is recommended that k-Wave-I is NOT on the MATLAB path to avoid naming conflicts.

### Building the documentation

- All documentation (including developer documentation) is written in `.m` files and automatically compiled to `.html` viewable in the MATLAB help browser.
- The documentation can be compiled by calling `kwave.utilities.GenerateDocumentation` in the root folder.
- After compiling, the documentation can be viewed by opening the MATLAB help browser and selecting **k-Wave II** from the list of supplemental software.

### Running the tests

- Tests are written using the MATLAB unit testing framework. To run the tests locally, call:
   - `kwave.tests.runTests(TestType=kwave.tests.TestType.unit)`
   - `kwave.tests.runTests(TestType=kwave.tests.TestType.linting)`
- Running the unit tests requires the signal processing toolbox for the reference `sinc` function.
