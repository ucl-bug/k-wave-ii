# Contributor guidelines

## Development Workflow

The k\-Wave development workflow broadly follows [GitHub flow](http://scottchacon.com/2011/08/31/github-flow):

1.  Anything in the main branch is deployable.
2. To work on something new, create a descriptively named branch off of main, starting with the issue number, e.g., `62-implement-pml-class`.
3. Commit to that branch locally and regularly push your work to the same named branch on the server.
4. Label commit messages with the issue number, e.g., `commit -m "#62: Basic class structure"`
5. When you need feedback or help, or you think the branch is ready for merging, open a pull request.
6. After someone else has reviewed and signed off on the feature, you can merge it into main.

For experienced git users, `git rebase` should be avoided if multiple people might be contributing to a branch (use `git merge` instead). If merging to main locally, to maintain the history of the feature branches, `git merge --no-ff` (the default if merging via GitHub).

### Running the tests

- Tests are written using the MATLAB unit testing framework. To run the tests locally, call:
   - `kwave.tests.runTests(TestType=kwave.tests.TestType.unit)`
   - `kwave.tests.runTests(TestType=kwave.tests.TestType.linting)`
