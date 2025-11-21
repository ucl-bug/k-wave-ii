# k-Wave-II: A MATLAB toolbox for the simulation of acoustic wave fields

[![License: LGPL v3](https://img.shields.io/badge/License-LGPL_v3-blue.svg)](LICENSE.md) [![codecov](https://codecov.io/gh/ucl-bug/k-wave-ii/graph/badge.svg?token=A8UMTDRF6T)](https://codecov.io/gh/ucl-bug/k-wave-ii) ![unit tests](https://github.com/ucl-bug/k-wave-ii/actions/workflows/tests.yml/badge.svg) ![code quality](https://github.com/ucl-bug/k-wave-ii/actions/workflows/code_quality.yml/badge.svg) ![build docs](https://github.com/ucl-bug/k-wave-ii/actions/workflows/docs.yml/badge.svg)

k\-Wave-II is an open\-source MATLAB toolbox used to solve differential equations, with a particular focus on wave problems in acoustics. The unifying thread for the solvers is that spatial gradients are computed using a Fourier collocation spectral method. This has many advantages, including spectral convergence for smooth functions, and a known analytical form for the band\-limited interpolant, which is useful for implementing stair\-case free sources, for example.

k-Wave-II is a major re-write of the original [k-Wave](http://k-wave.org/) Toolbox, developed
with the following aims:

1. Re-engineering the code base to leverage object orientated programming
and differentiable functions for deep learning and coupled physics problems
2. Extending the algorithms to facilitate general boundary conditions on
arbitrary surfaces, and to increase performance for narrow-band simulations
3. Improving the development and release process to incorporate good
practice and advance long-term sustainability
4. Improving training, user engagement, and support.

## Releases

The current release is _XX.YY.ZZ (link to the Changelog/Release notes here)_.

We aim to release a new version of the toolbox every _MonthX_ and _MonthY_, with patches issued in-between as needed. If you want to use the latest features between releases, you can clone the [github repo](https://github.com/ucl-bug/k-wave-ii/tree/main) and use the `develop` branch. If you choose to do that, please keep in mind that those features might not be complete yet, and therefore we would appreciate your feedback and your patience.

Every k-wave-ii release is guaranteed to work with all releases of MATLAB after the minimum (see [Minimum requirements](#minimum-requirements)), until the latest one before the release was made.

## Getting started

### Minimum requirements

- k-Wave-II requires MATLAB 2022b or later.
- No MATLAB toolboxes are required to use k-Wave-II. However, running the unit tests requires the signal processing toolbox for the reference `sinc` function.
- If importing the k-Wave-II namespace (using `import kwave.toolbox.*`) it is recommended that k-Wave-I is NOT on the MATLAB path to avoid naming conflicts.

### Using k-Wave-II

For examples of how to use k-Wave-II, have a look at the  [tutorials](helpfilesweb/Tutorials/SUMMARY.md) and the [toolbox classes documentation](helpfilesweb/Toolbox_Functions/SUMMARY.md).

## Getting help

We are a very small team maintaining this toolbox, and we would like it to be community-driven and sustained as much as possible.

If you would like to report a bug or request a new feature, first check the [existing issues](https://github.com/ucl-bug/k-wave-ii/issues) in the github repo and contribute to the discussion if it is already reported. If it is not, please open a new issue, using the appropriate template. And then, why not contribute to the fix or improvement! Check the section on [contributing](#contributing).

_We endeavour to review and triage new issues every week._

If you have a question or you need some help, please use the [discussions feature](https://github.com/ucl-bug/k-wave-ii/discussions) in the github repo. Hopefully someone from the community, either a maintainer, developer, or user will be able to assist you.

## Contributing

You are also very welcome to contribute to the code and open pull requests for new features and bug fixes. New developers should read the developer docs first, starting with the [contributor guidelines](CONTRIBUTING.md).
