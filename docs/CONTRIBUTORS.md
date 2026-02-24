# Contributors

This project is the result of a collaborative effort between researchers and developers at **University College London (UCL)** and the **Brno University of Technology**.

## Project Leads
* **Bradley E. Treeby** ([@ucl-bug](https://github.com/ucl-bug)) – Project Founder & Lead Architect
* **Benjamin T. Cox** – Project Founder & Lead Theoretical Developer
* **Jiří Jaroš** – Lead HPC & GPU Developer

## k-Wave II Core Development Team
* **Antonio Stanziola** ([@astanziola](https://github.com/astanziola)) – Python Integration & OO Framework
* **David Stansby** ([@dstansby](https://github.com/dstansby)) – Infrastructure & CI/CD
* **Devaraj Gopinathan** – Algorithms & Boundary Conditions

## High-Performance Computing (C++ / CUDA)
* **Filip Vaverka** ([@fvaverka](https://github.com/fvaverka)) – GPU Optimization
* **A. P. Rendell** – High-performance code architecture

## Component & Feature Contributors
The following researchers have authored specific models and extensions foundational to the k-Wave ecosystem:

* **Eleanor S. Martin** (UCL) – Experimental validation & source modeling
* **Elliot S. Wise** (UCL) – `kWaveArray` class & sensor/source distributions
* **Filip Kuklis** (UCL) – Axisymmetric modeling
* **Jakub Budisky** (Brno University of Technology) – Rapid acoustic field propagators
* **David Rohrbach** – Elastic wave modeling
* **Felix Lucka** (UCL/CWI) – Equivalent-source holography

## Institutional Support
The development of k-Wave and k-Wave II has been supported by:

* **UCL Department of Medical Physics and Biomedical Engineering**
* **Brno University of Technology**, Faculty of Information Technology
* **The Engineering and Physical Sciences Research Council (EPSRC)**

## Community Contributors
We are grateful to the following community members for their contributions to k-wave-ii:

1. Fix spelling mistakes ([#194](https://github.com/ucl-bug/k-wave-ii/pull/194)) by [@stellaprins](https://github.com/stellaprins)
2. Create top level docs table of contents ([#189](https://github.com/ucl-bug/k-wave-ii/pull/189)) by [@ilectra](https://github.com/ilectra)
3. 179: update docs that we use squash commits. ([#187](https://github.com/ucl-bug/k-wave-ii/pull/187)) by [@ilectra](https://github.com/ilectra)
4. Add vscode settings folder to gitignore ([#185](https://github.com/ucl-bug/k-wave-ii/pull/185)) by [@stellaprins](https://github.com/stellaprins)
5. Stop CI from running on draft PRs ([#186](https://github.com/ucl-bug/k-wave-ii/pull/186)) by [@stellaprins](https://github.com/stellaprins)
6. #132 Tidied up header text in sensor classes and tutorials ([#176](https://github.com/ucl-bug/k-wave-ii/pull/176)) by [@bencox](https://github.com/bencox)
7. #132 Acoustic sensor class and tests added from MKingEndBranch ([#175](https://github.com/ucl-bug/k-wave-ii/pull/175)) by [@bencox](https://github.com/bencox)
8. Cleanup develop for first release ([#173](https://github.com/ucl-bug/k-wave-ii/pull/173)) by [@ilectra](https://github.com/ilectra)
9. Fixing system git diff ([#117](https://github.com/ucl-bug/k-wave-ii/pull/117)) by [@qiUip](https://github.com/qiUip)
10. Add support for vector grid inputs ([#90](https://github.com/ucl-bug/k-wave-ii/pull/90)) by [@btreeby](https://github.com/btreeby)
11. added EM source class ([#108](https://github.com/ucl-bug/k-wave-ii/pull/108)) by [@bencox](https://github.com/bencox)
12. added EM medium class ([#107](https://github.com/ucl-bug/k-wave-ii/pull/107)) by [@bencox](https://github.com/bencox)
13. Add detailed developer documentation ([#168](https://github.com/ucl-bug/k-wave-ii/pull/168)) by [@ilectra](https://github.com/ilectra)
14. Create help files for helptoc section headings ([#169](https://github.com/ucl-bug/k-wave-ii/pull/169)) by [@ilectra](https://github.com/ilectra)
15. Add mkdocs documentation - local ([#157](https://github.com/ucl-bug/k-wave-ii/pull/157)) by [@ilectra](https://github.com/ilectra)
16. 49 markdown docs ([#152](https://github.com/ucl-bug/k-wave-ii/pull/152)) by [@ilectra](https://github.com/ilectra)
17. Medium class ([#141](https://github.com/ucl-bug/k-wave-ii/pull/141)) by [@MatthewJohnKing](https://github.com/MatthewJohnKing)
18. #139 initial conditions ([#143](https://github.com/ucl-bug/k-wave-ii/pull/143)) by [@MatthewJohnKing](https://github.com/MatthewJohnKing)
19. 118 add support for changing time steps to time domain solvers ([#137](https://github.com/ucl-bug/k-wave-ii/pull/137)) by [@MatthewJohnKing](https://github.com/MatthewJohnKing)
20. #138 Adding Medium Class for Labelled Materials ([#140](https://github.com/ucl-bug/k-wave-ii/pull/140)) by [@MatthewJohnKing](https://github.com/MatthewJohnKing)
21. 131 add absorption to acoustic solver ([#136](https://github.com/ucl-bug/k-wave-ii/pull/136)) by [@MatthewJohnKing](https://github.com/MatthewJohnKing)
22. #87: added curl function and unit test ([#130](https://github.com/ucl-bug/k-wave-ii/pull/130)) by [@bencox](https://github.com/bencox)
23. #114: Changed all length comparisonagaint 1 with isscalar ([#115](https://github.com/ucl-bug/k-wave-ii/pull/115)) by [@qiUip](https://github.com/qiUip)
24. Basic implementation of `AcousticSolver` class ([#92](https://github.com/ucl-bug/k-wave-ii/pull/92)) by [@btreeby](https://github.com/btreeby)
25. Fix bug in display of padded grid size ([#103](https://github.com/ucl-bug/k-wave-ii/pull/103)) by [@btreeby](https://github.com/btreeby)
26. Adds abstract `Solver` class ([#106](https://github.com/ucl-bug/k-wave-ii/pull/106)) by [@astanziola](https://github.com/astanziola)
27. Account for vector fields in grid testing framework ([#112](https://github.com/ucl-bug/k-wave-ii/pull/112)) by [@btreeby](https://github.com/btreeby)
28. Account for vector fields when padding ([#111](https://github.com/ucl-bug/k-wave-ii/pull/111)) by [@btreeby](https://github.com/btreeby)
29. Implement run method for time domain solvers ([#98](https://github.com/ucl-bug/k-wave-ii/pull/98)) by [@btreeby](https://github.com/btreeby)
30. Fix chained subrefs and subasgn for GridInput ([#95](https://github.com/ucl-bug/k-wave-ii/pull/95)) by [@astanziola](https://github.com/astanziola)
31. Implement split field PML ([#81](https://github.com/ucl-bug/k-wave-ii/pull/81)) by [@btreeby](https://github.com/btreeby)
32. Implement `Logger` class ([#83](https://github.com/ucl-bug/k-wave-ii/pull/83)) by [@btreeby](https://github.com/btreeby)
33. Remove `kWave` from class names ([#79](https://github.com/ucl-bug/k-wave-ii/pull/79)) by [@btreeby](https://github.com/btreeby)
34. Refactor input class to use virtual properties to remove boiler plate ([#78](https://github.com/ucl-bug/k-wave-ii/pull/78)) by [@btreeby](https://github.com/btreeby)
35. Adds Complex Sources ([#76](https://github.com/ucl-bug/k-wave-ii/pull/76)) by [@astanziola](https://github.com/astanziola)
36. Devolve checking real attribute from validateSize ([#77](https://github.com/ucl-bug/k-wave-ii/pull/77)) by [@btreeby](https://github.com/btreeby)
37. Document output arguments and other doc updates ([#68](https://github.com/ucl-bug/k-wave-ii/pull/68)) by [@btreeby](https://github.com/btreeby)
38. Add check for cyclomatic complexity ([#69](https://github.com/ucl-bug/k-wave-ii/pull/69)) by [@btreeby](https://github.com/btreeby)
39. Add developer docs ([#64](https://github.com/ucl-bug/k-wave-ii/pull/64)) by [@btreeby](https://github.com/btreeby)
40. Update TestCodeQuality to use codeIssues and check for dependencies ([#63](https://github.com/ucl-bug/k-wave-ii/pull/63)) by [@btreeby](https://github.com/btreeby)
41. Remove web call from GenerateDocumentation ([#66](https://github.com/ucl-bug/k-wave-ii/pull/66)) by [@btreeby](https://github.com/btreeby)
42. Refactor solver class ([#52](https://github.com/ucl-bug/k-wave-ii/pull/52)) by [@btreeby](https://github.com/btreeby)
43. Implement basic solver class ([#45](https://github.com/ucl-bug/k-wave-ii/pull/45)) by [@btreeby](https://github.com/btreeby)
44. Update legacy version of kWaveDiffusion ([#57](https://github.com/ucl-bug/k-wave-ii/pull/57)) by [@btreeby](https://github.com/btreeby)
45. Import k-Wave into +legacy namespace ([#26](https://github.com/ucl-bug/k-wave-ii/pull/26)) by [@btreeby](https://github.com/btreeby)
46. Add coding standard to developer docs ([#36](https://github.com/ucl-bug/k-wave-ii/pull/36)) by [@btreeby](https://github.com/btreeby)
47. Output human-readable HTML coverage report when running tests locally ([#34](https://github.com/ucl-bug/k-wave-ii/pull/34)) by [@dstansby](https://github.com/dstansby)
48. Clean docgen ([#41](https://github.com/ucl-bug/k-wave-ii/pull/41)) by [@dstansby](https://github.com/dstansby)
49. Remove `nameSpace` parameter in `GenerateDocumentation` ([#40](https://github.com/ucl-bug/k-wave-ii/pull/40)) by [@dstansby](https://github.com/dstansby)
50. Add doc build to CI ([#38](https://github.com/ucl-bug/k-wave-ii/pull/38)) by [@dstansby](https://github.com/dstansby)
51. Fix link generation in GenerateDocumentation ([#18](https://github.com/ucl-bug/k-wave-ii/pull/18)) by [@btreeby](https://github.com/btreeby)
52. Add MATLAB version check to runTests ([#23](https://github.com/ucl-bug/k-wave-ii/pull/23)) by [@btreeby](https://github.com/btreeby)
53. Create initial classes and repository structure ([#4](https://github.com/ucl-bug/k-wave-ii/pull/4)) by [@btreeby](https://github.com/btreeby)
54. Implement medium and source classes ([#19](https://github.com/ucl-bug/k-wave-ii/pull/19)) by [@btreeby](https://github.com/btreeby)
55. Use heading not filename when generating helptoc.xml ([#33](https://github.com/ucl-bug/k-wave-ii/pull/33)) by [@btreeby](https://github.com/btreeby)
56. Add code linting to test suite ([#22](https://github.com/ucl-bug/k-wave-ii/pull/22)) by [@dstansby](https://github.com/dstansby)
57. Use pull_request to trigger GitHub actions ([#20](https://github.com/ucl-bug/k-wave-ii/pull/20)) by [@dstansby](https://github.com/dstansby)
58. Fix pull request templates ([#16](https://github.com/ucl-bug/k-wave-ii/pull/16)) by [@dstansby](https://github.com/dstansby)
59. Add automatic testing on Windows ([#15](https://github.com/ucl-bug/k-wave-ii/pull/15)) by [@dstansby](https://github.com/dstansby)

---
*Generated automatically by the contribution-update script.*