# k-Wave-II: A MATLAB toolbox for the simulation of acoustic wave fields


!!! warning "Under Construction"
    K‑Wave ii is currently under active development and not public yet.  
    Documentation, APIs, and features may change without notice.  


[![License: LGPL v3](https://img.shields.io/badge/License-LGPL_v3-blue.svg)](LICENSE.md) [![codecov](https://codecov.io/gh/ucl-bug/k-wave-ii/graph/badge.svg?token=A8UMTDRF6T)](https://codecov.io/gh/ucl-bug/k-wave-ii) ![unit tests](https://github.com/ucl-bug/k-wave-ii/actions/workflows/tests.yml/badge.svg) ![code quality](https://github.com/ucl-bug/k-wave-ii/actions/workflows/
code_quality.yml/badge.svg) ![build docs](https://github.com/ucl-bug/k-wave-ii/actions/workflows/docs.yml/badge.svg) <!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-11-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

k\-Wave-II is an open\-source MATLAB toolbox used to solve partial differential equations, with a particular focus on wave problems in biomedical ultrasound. The unifying thread for the solvers is that spatial gradients are computed using a Fourier collocation spectral method. This has many advantages, including spectral convergence for smooth functions, and a known analytical form for the bandlimited interpolant, which is useful for implementing staircase free sources, for example.


k-Wave-II is a major re-write of the original [k-Wave](https://github.com/ucl-bug/k-wave) Toolbox, developed

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

We aim to release a new version of the toolbox every May and November, with patches issued in-between as needed. If you want to use the latest features between releases, you can clone the [github repo](https://github.com/ucl-bug/k-wave-ii/tree/main) and use the `develop` branch. If you choose to do that, please keep in mind that those features might not be complete yet, and therefore we would appreciate your feedback and your patience.

Every k-Wave-II release is tested with all releases of MATLAB after the minimum (see [Minimum requirements](#minimum-requirements)), until the latest one before the release was made.


## Getting started

### Minimum requirements

- k-Wave-II requires MATLAB 2022b or later.
- No MATLAB toolboxes are required to use k-Wave-II. However, running the unit tests requires the signal processing toolbox for the reference `sinc` function.
- If importing the k-Wave-II namespace (using `import kwave.toolbox.*`) it is recommended that k-Wave-I is NOT on the MATLAB path to avoid naming conflicts.

### Using k-Wave-II

For examples of how to use k-Wave-II, have a look at the  [tutorials](helpfilesweb/Tutorials/SUMMARY.md) and the [toolbox classes documentation](helpfilesweb/Toolbox_Functions/SUMMARY.md).

## Getting help

We are a very small team maintaining this toolbox, and we would like it to be community-driven and sustained as much as possible.

If you would like to report a bug or request a new feature, first check the [existing issues](https://github.com/ucl-bug/k-wave-ii/issues) in the github repo and contribute to the discussion if it is already reported. If it is not, please open a new issue, using the appropriate template. And then, please consider contributing to the fix or improvement (see the section on [contributing](#contributing)).



If you have a question or you need some help, please use the [discussions feature](https://github.com/ucl-bug/k-wave-ii/discussions) in the github repo. Hopefully someone from the community, either a maintainer, developer, or user will be able to assist you.

## Contributing

The user community is very welcome to contribute to the code and open pull requests for new features and bug fixes. New developers should read the developer docs first, starting with the [contributor guidelines](CONTRIBUTING.md).

We also welcome further involvement by people wishing to review developers' code contributions and help the community of developers grow. Please contact the maintainers if you are interested in becoming a code reviewer.

## Contributors
<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/bencox"><img src="https://avatars.githubusercontent.com/u/5031946?v=4?s=100" width="100px;" alt="Ben Cox"/><br /><sub><b>Ben Cox</b></sub></a><br /><a href="#custom-bencox" title=""></a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/btreeby"><img src="https://avatars.githubusercontent.com/u/4980942?v=4?s=100" width="100px;" alt="Bradley Treeby"/><br /><sub><b>Bradley Treeby</b></sub></a><br /><a href="#custom-btreeby" title=""></a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/MatthewJohnKing"><img src="https://avatars.githubusercontent.com/u/137497118?v=4?s=100" width="100px;" alt="MatthewJohnKing"/><br /><sub><b>MatthewJohnKing</b></sub></a><br /><a href="#custom-MatthewJohnKing" title=""></a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/ilectra"><img src="https://avatars.githubusercontent.com/u/22891967?v=4?s=100" width="100px;" alt="Ilektra Christidi"/><br /><sub><b>Ilektra Christidi</b></sub></a><br /><a href="#custom-ilectra" title=""></a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.davidstansby.com/"><img src="https://avatars.githubusercontent.com/u/6197628?v=4?s=100" width="100px;" alt="David Stansby"/><br /><sub><b>David Stansby</b></sub></a><br /><a href="#custom-dstansby" title=""></a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/astanziola"><img src="https://avatars.githubusercontent.com/u/3237202?v=4?s=100" width="100px;" alt="Antonio Stanziola"/><br /><sub><b>Antonio Stanziola</b></sub></a><br /><a href="#custom-astanziola" title=""></a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/arindamsaha1507"><img src="https://avatars.githubusercontent.com/u/25665512?v=4?s=100" width="100px;" alt="Arindam Saha"/><br /><sub><b>Arindam Saha</b></sub></a><br /><a href="#custom-arindamsaha1507" title=""></a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/stellaprins"><img src="https://avatars.githubusercontent.com/u/30465823?v=4?s=100" width="100px;" alt="Stella Prins"/><br /><sub><b>Stella Prins</b></sub></a><br /><a href="#custom-stellaprins" title=""></a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://profiles.ucl.ac.uk/61652"><img src="https://avatars.githubusercontent.com/u/36169767?v=4?s=100" width="100px;" alt="Devaraj Gopinathan"/><br /><sub><b>Devaraj Gopinathan</b></sub></a><br /><a href="#custom-Devaraj-G" title=""></a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://qiuip.github.io/"><img src="https://avatars.githubusercontent.com/u/7360775?v=4?s=100" width="100px;" alt="Mashy Green"/><br /><sub><b>Mashy Green</b></sub></a><br /><a href="#custom-qiUip" title=""></a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/nicolin"><img src="https://avatars.githubusercontent.com/u/6137757?v=4?s=100" width="100px;" alt="nicolin"/><br /><sub><b>nicolin</b></sub></a><br /><a href="#custom-nicolin" title=""></a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->
<!-- markdownlint-disable -->

The grid above is generated with [all-contributors](https://allcontributors.org/) using information from GitHub. If you’d like to request a change, contact us at http://www.k-wave.org/forum.