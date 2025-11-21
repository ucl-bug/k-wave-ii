# Contributor guidelines

## Development Workflow

The k\-Wave development workflow follows [git-flow](https://nvie.com/posts/a-successful-git-branching-model/), modernised for an open-source project to [use forks](https://docs.github.com/en/get-started/exploring-projects-on-github/contributing-to-a-project) instead of branches:

- The `main` branch is used only for releases. Any code development branches off and eventually merges back into the `develop` branch, via feature branches. For more details on this workflow, see the [maintainer guidelines](maintainerDocs.md)
- Start by [creating a fork](https://docs.github.com/en/get-started/exploring-projects-on-github/contributing-to-a-project#creating-your-own-copy-of-a-project) of the GitHub k-wave-ii repo. Make sure you copy all branches, not only the default. Now you have your own copy of the whole repo on GitHub.
  You can manage that fork as you please, but it is good practice to keep its `main`, `develop`, and feature branches in synch with the upstream k-wave-ii repo, and do your development on different branches.
- Clone the fork locally to work on your code changes
```
git clone https://github.com/YOUR-USER-NAME/k-wave-ii
```
- Any code development you would like to contribute to k-wave-ii, has to relate to an already reported issue in the upstream repo. For existing issues under active development, an appropriate feature branch would already exist. Those are descriptively named, starting with the issue number, e.g., `62-implement-pml-class`. If an appropriate feature branch does not exist, [open an issue](../#getting-help) in the upstream repo to request one. You will then need to re-synch your fork and `git pull` to get that branch locally.
- Create a branch off the feature branch you want to contribute to, and switch to it.
```
git checkout 62-implement-pml-class
git switch -c 62-implement-pml-class-getters
```

**Now that you are ready to code, please read the [developers intro](developerIntroduction.md) and [coding standard](codingStandard.md)!**

- Commit to that branch locally and regularly push your work to the same named branch on the fork.
- Label commit messages with the issue number, e.g., `commit -m "#62: Basic class structure"`
- If you need feedback or help but your branch is not ready to merge, open a draft pull request (PR) from your branch in your fork, to the feature branch in the upstream repo. Likewise, when you think the branch is ready for merging, open a (normal) PR, or convert your draft one to a normal PR, and request a code review.

For experienced git users, `git rebase` should be avoided if multiple people might be contributing to a branch (use `git merge` instead).

## Conditions for merging a PR

The pull request template will guide you through the requirements to get your changes approved and merged by the maintainers. For reference, those are

- If adding a new function or class, add appropriate tests. See the [developer docs](../developerIntroduction#testing-framework) for more details.
- All tests, existing or new, should pass. You should strive to run the tests locally before you open the PR, in order to catch errors early, but the Github Actions automation on the k-wave-ii repo will run them automatically as well when you open a PR.
- [Update the documentation](../developerIntroduction#writing-and-building-the-documentation) and make sure it builds and looks right.
- Add examples and/or tutorials if you added more substantial functionality.
- One approving code review by one of the maintainers.

The code review step is a crucial one, to guarantee the quality of code contributions from the community. It is an iterative process, and you will have to address the reviewer's comments and any concerns. Keep in mind that those comments are given in good faith and not as judgement on anyone's coding ability, and are meant to support our community of developers in creating the best software we can, for all of us to use. Seasoned developers would testify to how much they have learned and improved in their work by receiving reviews on their codes.

