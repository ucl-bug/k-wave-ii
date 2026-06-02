# k-Wave-II: A MATLAB toolbox for the simulation of acoustic wave fields

!!! WARNING "Under Construction"
    k‑Wave-II is currently under active development. Documentation, APIs, and features may change without notice.

[![License: LGPL v3](https://img.shields.io/badge/License-LGPL_v3-blue.svg)](LICENSE.md) [![codecov](https://codecov.io/gh/ucl-bug/k-wave-ii/graph/badge.svg?token=A8UMTDRF6T)](https://codecov.io/gh/ucl-bug/k-wave-ii) ![unit tests](https://github.com/ucl-bug/k-wave-ii/actions/workflows/tests.yml/badge.svg) ![code quality](https://github.com/ucl-bug/k-wave-ii/actions/workflows/code_quality.yml/badge.svg) ![build docs](https://github.com/ucl-bug/k-wave-ii/actions/workflows/docs.yml/badge.svg)<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-14-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

k\-Wave-II is an open\-source MATLAB toolbox used to solve partial differential equations, with a particular focus on wave problems in biomedical ultrasound. The unifying thread for the solvers is that spatial gradients are computed using a Fourier collocation spectral method. This has many advantages, including spectral convergence for smooth functions and a known analytical form for the bandlimited interpolant, which is useful for implementing staircase-free sources, for example.

k-Wave-II is a major re-write of the original [k-Wave](https://github.com/ucl-bug/k-wave) Toolbox, developed with the aim of making k-Wave sustainable in the long term. The specific objectives are to re-engineer the code base leveraging object orientated programming, to improve the development and release process to incorporate best practice, and to facilitate greater engagement of the user and contributor communities in its development.

## Getting started

### Installation

- From the [k-Wave-II GitHub page](https://github.com/ucl-bug/k-wave-ii), find the green Code button and either [clone the repo](https://docs.github.com/en/repositories/creating-and-managing-repositories/cloning-a-repository) or download a zip file of the current version of the codebase.
- Open Matlab.
- Add the location of the k-wave files to the Matlab path, eg. using `addpath(<path-to-kwave>)` on the Matlab command line, or the Set Path button on the Home tab.
- Generate the help files, if required, from the Matlab command line. This can take several minutes to run but only needs to be done once as the help files documentation will then be stored.
```
>> kwave.devtools.GenerateDocumentation
``` 
- Import the kwave namespace. This avoids having to prepend all function calls with `kwave.toolbox`, eg. `kgrid = Grid(Nx,dx)` rather than `kgrid = kwave.toolbox.Grid(Nx,dx)`. (If you do this, ensure k-Wave-I is not on the Matlab path to avoid naming conflicts.)
```
>> import kwave.toolbox.*
```
- For examples of how to use k-Wave-II, and templates to build upon, see the tutorials in `kwave/tutorials`. 


### Minimum requirements

- k-Wave-II requires MATLAB R2023b or later.
- No MATLAB toolboxes are required to use k-Wave-II. However, running the unit tests requires the signal processing toolbox for the reference `sinc` function.

## Releases

k-Wave-II is currently in a pre-release state. We aim, in due course, to release a new version of the toolbox every six months, with patches issued in-between as needed. To use the latest features between releases, you can clone the [github repo](https://github.com/ucl-bug/k-wave-ii/tree/develop) and use the `develop` branch. Please bear in mind that features on the `develop` branch may not be complete yet, and, in that context, we appreciate your feedback, contributions, and patience.

Every k-Wave-II release is tested with all releases of MATLAB after the minimum (see [Minimum requirements](#minimum-requirements)), until the latest one before the release was made.

## Getting help

We are a very small team maintaining this toolbox, and we would like it to be community-driven and therefore sustainable.

If you would like to report a bug or request a new feature, first check the [existing issues](https://github.com/ucl-bug/k-wave-ii/issues) in the github repo and contribute to the discussion if it is already reported. If it is not, please open a new issue, using the appropriate template. Also please consider contributing to the fix or improvement (see the section on [contributing](#contributing)).

If you have a question or you need some help, please use the [discussions feature](https://github.com/ucl-bug/k-wave-ii/discussions) in the github repo. Hopefully someone from the community will be able to assist you.

## Contributing

Users are encouraged to contribute to the code and open pull requests for new features and bug fixes. New developers should read the developer docs first, starting with the [contributor guidelines](CONTRIBUTING.md). Anyone who submits code that is accepted into the toolbox will automatically be added to the list of contributors below.

We also encourage involvement by those able to review developers' code contributions. Please contact the maintainers if you are interested in becoming a code reviewer.

## Development lead
k‑Wave‑II builds on long‑standing collaborations and the contributions of many researchers to k-Wave-I, including foundational work by Bradley Treeby, Ben Cox, and Jiri Jaros. Its ongoing development is guided and maintained by [the UCL Biomedical Ultrasound Group](http://bug.medphys.ucl.ac.uk/).

## Contributors
<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/btreeby"><img src="https://avatars.githubusercontent.com/u/4980942?v=4?s=80" width="80px;" alt="Bradley Treeby"/><br /><sub><b>Bradley Treeby</b></sub></a><br /><a href="#custom-btreeby" title=""></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/bencox"><img src="https://avatars.githubusercontent.com/u/5031946?v=4?s=80" width="80px;" alt="Ben Cox"/><br /><sub><b>Ben Cox</b></sub></a><br /><a href="#custom-bencox" title=""></a></td>
      <td align="center" valign="top" width="16.66%"><a href="http://www.fit.vutbr.cz/~jarosjir/"><img src="https://avatars.githubusercontent.com/u/4980903?v=4?s=80" width="80px;" alt="Jiri Jaros"/><br /><sub><b>Jiri Jaros</b></sub></a><br /><a href="#custom-jarosjir" title=""></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/ellymartin"><img src="https://avatars.githubusercontent.com/u/62395290?v=4?s=80" width="80px;" alt="ellymartin"/><br /><sub><b>ellymartin</b></sub></a><br /><a href="#custom-ellymartin" title=""></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/MatthewJohnKing"><img src="https://avatars.githubusercontent.com/u/137497118?v=4?s=80" width="80px;" alt="MatthewJohnKing"/><br /><sub><b>MatthewJohnKing</b></sub></a><br /><a href="#custom-MatthewJohnKing" title=""></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/astanziola"><img src="https://avatars.githubusercontent.com/u/3237202?v=4?s=80" width="80px;" alt="Antonio Stanziola"/><br /><sub><b>Antonio Stanziola</b></sub></a><br /><a href="#custom-astanziola" title=""></a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/ellwise"><img src="https://avatars.githubusercontent.com/u/45689261?v=4?s=80" width="80px;" alt="ellwise"/><br /><sub><b>ellwise</b></sub></a><br /><a href="#custom-ellwise" title=""></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://profiles.ucl.ac.uk/61652"><img src="https://avatars.githubusercontent.com/u/36169767?v=4?s=80" width="80px;" alt="Devaraj Gopinathan"/><br /><sub><b>Devaraj Gopinathan</b></sub></a><br /><a href="#custom-Devaraj-G" title=""></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/ilectra"><img src="https://avatars.githubusercontent.com/u/22891967?v=4?s=80" width="80px;" alt="Ilektra Christidi"/><br /><sub><b>Ilektra Christidi</b></sub></a><br /><a href="#custom-ilectra" title=""></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://www.davidstansby.com/"><img src="https://avatars.githubusercontent.com/u/6197628?v=4?s=80" width="80px;" alt="David Stansby"/><br /><sub><b>David Stansby</b></sub></a><br /><a href="#custom-dstansby" title=""></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/stellaprins"><img src="https://avatars.githubusercontent.com/u/30465823?v=4?s=80" width="80px;" alt="Stella Prins"/><br /><sub><b>Stella Prins</b></sub></a><br /><a href="#custom-stellaprins" title=""></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/arindamsaha1507"><img src="https://avatars.githubusercontent.com/u/25665512?v=4?s=80" width="80px;" alt="Arindam Saha"/><br /><sub><b>Arindam Saha</b></sub></a><br /><a href="#custom-arindamsaha1507" title=""></a></td>
    </tr>
    <tr>
      <td align="center" valign="top" width="16.66%"><a href="https://qiuip.github.io/"><img src="https://avatars.githubusercontent.com/u/7360775?v=4?s=80" width="80px;" alt="Mashy Green"/><br /><sub><b>Mashy Green</b></sub></a><br /><a href="#custom-qiUip" title=""></a></td>
      <td align="center" valign="top" width="16.66%"><a href="https://github.com/nicolin"><img src="https://avatars.githubusercontent.com/u/6137757?v=4?s=80" width="80px;" alt="nicolin"/><br /><sub><b>nicolin</b></sub></a><br /><a href="#custom-nicolin" title=""></a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->
<!-- markdownlint-disable -->

The grid above is generated with [all-contributors](https://allcontributors.org/) using information from GitHub. If you’d like to request a change contact [the maintainers](mailto:b.cox@ucl.ac.uk).
