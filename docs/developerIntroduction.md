# Developer Introduction

Introduction to k\-Wave II for developers.

## Overview

k\-Wave II is an open\-source MATLAB toolbox used to solve differential equations, with a particular focus on wave problems in acoustics. The unifying thread for the solvers is that spatial gradients are computed using a Fourier collocation spectral method. This has many advantages, including spectral convergence for smooth functions, and a known analytical form for the band\-limited interpolant, which is useful for implementing stair\-case free sources, for example.


The main components of the toolbox are written using an object\-orientated programming design approach, primarily using `handle` classes. Sets of functionality (such as medium inputs for a particular solver) are grouped into classes. Base classes are used for common functionality that needs to be re\-used multiple times. This adheres to the don't repeat yourself (DRY) software development principle. Some additional helper functions with limited scope are written as standalone functions.


The software is written with the following four guiding principles, in decreasing order of importance:

1.  **The code is accurate.** The solvers should avoid narrow scope assumptions which are not always applicable. The code should also implement appropriate input validation and error handling, and be covered by appropriate tests (see [Testing Framework](#testing-framework)   (testingFramework.md) for further details).
2. **The code is easy to use.** Careful thought should be given to the class interfaces and default values, and the user\-facing API should be as stable as possible over time. All code should be well documented, and the documentation should include user examples and tutorials. Code should also provide sufficient feedback and warnings to guide users.
3. **The code is sustainable.** The development, testing, and release workflows should be sufficiently automated that it is straightforward to implement new features and bug fixes. All code should follow the  [Coding Standard](codingStandard.md).
4. **The code is fast.** Code should be profiled regularly, and where possible, refactored to improve computational efficiency.

## Repository Structure

The code is grouped into [package folders](https://uk.mathworks.com/help/matlab/matlab_oop/scoping-classes-with-packages.html) (namespaces). The basic folder structure is as follows:

```
   ├── .github
   │   ├── ISSUE_TEMPLATE         (GitHub issue templates)
   │   ├── PULL_REQUEST_TEMPLATE  (GitHub pull request template)
   │   └── workflows       (GitHub actions)
   ├── +kwave
   │   ├── +devtools       (Developer tools)
   |   ├── +docfiles       (Documentation files)
   │   │   └── +general    (Additional Documentation Pages)
   │   ├── +legacy         (Copy of k-Wave I)
   │   ├── +tests          (Tests)
   │   │   ├── +legacy     (Regression tests against k-Wave I)
   │   │   ├── +linting    (Linting tests)
   │   │   └── +unit       (Unit tests)
   │   ├── +toolbox        (Main classes and functions)
   │   ├── +tutorials      (Examples and tutorials)
   │   └── +utilities      (Other tools)
   └── docs                (Contributor guidelines and other static docs)
       ├── helpfiles       (Created and populated at html documentation generation time)
       └── helpfilesweb    (Created and populated at md documentation generation time)
```

## Writing And Building The Documentation

Part of the success of k\-Wave can be attributed to the good documentation, both of the individual functions and classes, and the examples. All code should be documented as outlined in the [Coding Standard](codingStandard.md). It can often be easiest to start with the [documentation template](helpfilesweb/classDocsExample.md).

When adding a new class or function, examples should be added. If the code usage is relatively straightforward, examples can be included directly in the help documentation for that class or function. For more complex classes (e.g., the solver classes), longer tutorials or examples should be provided.

1.  **Tutorials:** These are worked examples stored as `.m` files in the  `kwave.tutorials` name space. For tutorials, each block of code should be surrounded by a discussion guiding the user through the example. The discussion should be written using  [publishing markup](https://uk.mathworks.com/help/matlab/matlab_prog/marking-up-matlab-comments-for-publishing.html). Similar to k\-Wave I, concepts introduced in other tutorials do not need to be re\-introduced. Try and focus on a relatively small number of new concepts in each tutorial. The tutorial code should generally run fast on basic hardware (< 1 min).
2. **Examples:** These are illustrative examples stored as `.m` files in the  `kwave.examples` name space. Examples have a wider scope than tutorials, and may demonstrate a real\-world simulation using realistic grid sizes for example (so do not necessarily need to run fast). Examples should contain a comprehensive description of what the example does in the description of the file, but does not need to have long step\-by\-step.

### Building The Documentation

_MATLAB R2023b or later is required to build the documentation._

General and developer documentation that is static and does not have to be automatically generated from the code, should be written in markdown (`.md`) files inside the `/docs` folder. The in-code documentation is written in the `.m` files and can be automatically compiled by calling `kwave.devtools.GenerateDocumentation` in the root folder. This utility compiles the documentation into two formats:

- `.html`, using [`publish`](https://uk.mathworks.com/help/matlab/ref/publish.html). After compiling, the `html` documentation can be found in `docs/helpfiles` and can be viewed by opening the MATLAB help browser and selecting **k-Wave II** from the list of supplemental software.
- `.md`, using [`export`](https://uk.mathworks.com/help/matlab/ref/export.html). After compiling, the `md` documentation can be found in `docs/helpfilesweb` and can be further processed with `mkdocs` to produce a standalone webpage in `readthedocs` style.

To generate the standalone website with `mkdocs` after the `.md` files have been generated, you need to have a few packages in your python environment, so run `pip install -r requirements.txt` first. Then the website can be served locally with
```
mkdocs serve --livereload
```
and viewed in a browser in `http://127.0.0.1:8000/` for debugging purposes (watch the output of the above command for this address).

## Logging And Errors

Logging messages help users understand code settings and status, and help developers debug code. In k\-Wave\-II, all logging messages (including warnings and errors) should be printed using the `kwave.toolbox.Logger` class. This provides a consistent interface, allow adjusting the verbosity of the output messages, and allows piping the logging messages to an external file.

## Toolboxes And External Code

The core functionality of k\-Wave\-II should not depend on any MATLAB toolboxes. This is to minimise the requirements for non\-academic users who must purchase a MATLAB license to use k\-Wave. Tests can (and do) depend on additional toolboxes, as this dependency is fulfilled by the GitHub runners (both private and public).


If considering using other external code or libraries (e.g., from the file exchange), this should be flagged first on the issue or pull request. This way, a discussion can be had about the cost of introducing the dependency, and any potential licensing issues.

## Testing Framework

k\-Wave uses the [class\-based unit testing framework](https://uk.mathworks.com/help/matlab/class-based-unit-tests.html). There are several test levels (defined in `kwave.tests.TestType`), each of which lives in its own namespace:

-  **`+unit`:** Unit tests validate individual components of a function or class in isolation. 
-  **`+linting`:** Linting checks assess code for stylistic and syntactical correctness. 
-  **`+legacy`:** Legacy tests are regression tests against k\-Wave I to ensure existing functionality remains unaffected by changes. 

Each top level class or function should have at least one corresponding unit test. Unit tests should have 100% line coverage. Tests should inheret from one of the following:

-  `kwave.tests.unit.AbstractTestGridInput` for testing classes that derive from `kwave.toolbox.GridInput`. 
-  `kwave.tests.unit.AbstractTestGrid` for tests that need to iterate over different sized grids. 
-  `matlab.unittest.TestCase` for general tests. 
-  `matlab.perftest.TestCase` for performance tests. 

The filenames for all tests should start with `Test`. Unit tests should be named `TestClassName` or `TestFunctionName`. Other tests should be given sensible descriptive names.


The linting tests check for code complexity using [cylomatic complexity](https://uk.mathworks.com/help/matlab/matlab_prog/measure-code-complexity-using-cyclomatic-complexity.html), which is a measure of the decision structure complexity of the code. The complexity of all files changed in a pull request is automatically added to pull requests as part of the code checks action. While a particular number isn't enforced, both developers and reviewers should consider whether a re\-factoring is appropriate if the cylomatic complexity is above 10.

