%% Developer Introduction
%
% Introduction to k-Wave II for developers.
%
%% Overview
% k-Wave II is an open-source MATLAB toolbox used to solve differential
% equations, with a particular focus on wave problems in acoustics. The
% unifying thread for the solvers is that spatial gradients are computed
% using a Fourier collocation spectral method. This has many advantages,
% including spectral convergence for smooth functions, and a known
% analytical form for the band-limited interpolant, which is useful for
% implementing stair-case free sources, for example.
% 
% The main components of the toolbox are written using an object-orientated
% programming design approach, primarily using |handle| classes. Sets of
% functionality (such as medium inputs for a particular solver) are grouped
% into classes. Base classes are used for common functionality that needs
% to be re-used multiple times. This adheres to the don't repeat yourself
% (DRY) software development principle. Some additional helper functions
% with limited scope are written as standalone functions.
%
% The software is written with the following four guiding principles, in
% decreasing order of importance:
%
% # *The code is accurate.* The solvers should avoid narrow scope
% assumptions which are not always applicable. The code should also
% implement appropriate input validation and error handling, and be covered
% by appropriate tests (see <testingFramework.html Testing Framework> for
% further details).
% # *The code is easy to use.* Careful thought should be given to the class
% interfaces and default values, and the user-facing API should be as
% stable as possible over time. All code should be well documented, and the
% documentation should include user examples and tutorials. Code should
% also provide sufficient feedback and warnings to guide users.
% # *The code is sustainable.* The development, testing, and release
% workflows should be sufficiently automated that it is straightforward to
% implement new features and bug fixes. All code should follow the
% <codingStandard.html Coding Standard>.
% # *The code is fast.* Code should be profiled regularly, and where
% possible, refactored to improve computational efficiency.
%
%% Repository Structure
% The code is grouped into
% <https://uk.mathworks.com/help/matlab/matlab_oop/scoping-classes-with-packages.html
% package folders> (namespaces). The basic folder structure is as follows:
%
%     ├── .github
%     │   ├── ISSUE_TEMPLATE  (GitHub issue templates)
%     │   └── workflows       (GitHub actions)
%     ├── +kwave
%     │   ├── +docfiles       (Documentation files)
%     │   │   ├── +developer  (Developer Documentation)
%     │   │   └── +general    (Additional Documentation Pages)
%     │   ├── +legacy         (Copy of k-Wave I)
%     │   ├── +tests          (Tests)
%     │   │   ├── +legacy     (Regression tests against k-Wave I)
%     │   │   ├── +linting    (Linting tests)
%     │   │   └── +unit       (Unit tests)
%     │   ├── +toolbox        (Main classes and functions)
%     │   ├── +tutorials      (Examples and tutorials)
%     │   └── +utilities      (Developer tools)
%     └── helpfiles           (Compiled documentation)
%
%% Development Workflow
% The k-Wave development workflow broadly follows
% <http://scottchacon.com/2011/08/31/github-flow.html GitHub flow>: 
%
% # Anything in the main branch is deployable.
% # To work on something new, create a descriptively named branch off of
% main, starting with the issue number, e.g., |62-implement-pml-class|.
% # Commit to that branch locally and regularly push your work to the same
% named branch on the server.
% # Label commit messages with the issue number, e.g., |commit -m "#62:
% Basic class structure"|
% # When you need feedback or help, or you think the branch is ready for
% merging, open a pull request.
% # After someone else has reviewed and signed off on the feature, you can
% merge it into main.
%
% For git ninjas, |git rebase| should be avoided if multiple people might
% be contributing to a branch (use |git merge| instead). If merging to main
% locally, to maintain the history of the feature branches, |git merge
% --no-ff| (the default if merging via GitHub).
%
%% Writing And Compiling Documentation
% Part of the success of k-Wave can be attributed to the good
% documentation, both of the individual functions and classes, and the
% examples. All code should be documented as outlined in the
% <codingStandard.html Coding Standard>. It can often be easiest to start
% with the <matlab:edit('kwave.docfiles.general.classDocsExample')
% documentation template>.
%
% When adding a new class or function, examples should be added. If the
% code usage is relatively straightforward, examples can be included
% directly in the help documentation for that class or function. For more
% complex classes (e.g., the solver classes), longer tutorials or examples
% should be provided.
%
% # *Tutorials:* These are worked examples stored as |.m| files in the
% |kwave.tutorials| name space. For tutorials, each block of code should be
% surrounded by a discussion guiding the user through the example. The
% discussion should be written using
% <https://uk.mathworks.com/help/matlab/matlab_prog/marking-up-matlab-comments-for-publishing.html
% publishing markup>. Similar to k-Wave I, concepts introduced in other
% tutorials do not need to be re-introduced. Try and
% focus on a relatively small number of new concepts in each tutorial. The
% tutorial code should generally run fast on basic hardware (< 1 min).
% # *Examples:* These are illustrative examples stored as |.m| files in the
% |kwave.examples| name space. Examples have a wider scope than tutorials,
% and may demonstrate a real-world simulation using realistic grid sizes
% for example (so do not necessarily need to run fast). Examples should
% contain a comprehensive description of what the example does in the
% description of the file, but does not need to have long step-by-step.
%
% The documentation can be automatically compiled by calling
% |kwave.utilities.GenerateDocumentation|. This parses the individual |.m|
% files into |.html| files using <matlab:doc('publish') |publish|>.
% Additional documentation files that are not automatically added to the
% table of contents should be stored in |+kwave/+docfiles/+general|.
%
%% Toolboxes And External Code
% The core functionality of k-Wave-II should not depend on any MATLAB
% toolboxes. This is to minimise the requirements for non-academic users
% who must purchase a MATLAB license to use k-Wave. Tests can (and do)
% depend on additional toolboxes, as this dependency is fulfilled by the
% GitHub runners (both private and public). 
%
% If considering using other external code or libraries (e.g., from the
% file exchange), this should be flagged first on the issue or pull
% request. This way, a discussion can be had about the cost of introducing
% the dependency, and any potential licensing issues.
%
%% Testing Framework
% k-Wave uses the
% <https://uk.mathworks.com/help/matlab/class-based-unit-tests.html
% class-based unit testing framework>. There are several test levels
% (defined in |kwave.tests.TestType|), each of which lives in its own
% namespace:
%
% * *|+unit|:* Unit tests validate individual components of a function or
% class in isolation.
% * *|+linting|:* Linting checks assess code for stylistic and syntactical
% correctness.
% * *|+legacy|:* Legacy tests are regression tests against k-Wave I to ensure
% existing functionality remains unaffected by changes. 
% 
% Each top level class or function should have at least one corresponding
% unit test. Unit tests should have 100% line coverage. Tests should
% inheret from one of the following:
%
% * |kwave.tests.unit.TestInput| for testing classes that derive from
% |kwave.toolbox.kWaveInput|. 
% * |kwave.tests.unit.TestGrid| for tests that need to iterate over
% different sized grids.
% * |matlab.unittest.TestCase| for general tests.
% * |matlab.perftest.TestCase| for performance tests.
%
% The filenames for all tests should start with |Test|. Unit tests should
% be named |TestClassName| or |TestFunctionName|. Other tests should be
% given sensible descriptive names.
%
% The linting tests check for code complexity using
% <https://uk.mathworks.com/help/matlab/matlab_prog/measure-code-complexity-using-cyclomatic-complexity.html
% cylomatic complexity>, which is a measure of the decision structure
% complexity of the code. The complexity of all files changed in a pull
% request is automatically added to pull requests as part of the code
% checks action. While a particular number isn't enforced, both developers
% and reviewers should consider whether a re-factoring is appropriate if
% the cylomatic complexity is above 10.
