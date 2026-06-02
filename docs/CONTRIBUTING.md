# Contributor guidelines

We welcome contributions from users with all levels of experience. 

Our aim with k-Wave-II is to keep the barriers to contributing as low as possible while maintaining a tidy and functioning codebase. If something in this guide feels like overkill for your contribution, please feel free to proceed in the simplest way that works and ask for help if needed; the maintainers are happy to guide you. For larger or more complex contributions, following the workflow described here will be important.

If you would like to contribute but are new to it, these are some good ways to get started:

- Improve documentation (clarifications, typos, missing explanations)
- Add or refine examples and tutorials
- Suggest small usability improvements
- Improve error messages or warnings
- Help answer or triage issues

If you are unsure whether something is a suitable contribution, please open an issue or a draft pull request. We are happy to discuss ideas and help you get started.

Before beginning work on a substantial contribution, please read these Contributor Guidelines and:

* [developerIntroduction.md](developerIntroduction.md)
* [codingStandard.md](codingStandard.md)

## Development Workflow

The k-Wave-II development workflow follows a git-flow style organisation (`main`/`develop`/`feature` branches), adapted for open-source development using forks. The `main` branch is reserved for releases. Code development typically takes place via feature branches that are eventually merged back into the `develop` branch. For more details, see the [maintainer guidelines](maintainerDocs.md)

### Getting started as a contributor

For most contributions, the simplest workflow is:

* [Fork the repository](https://docs.github.com/en/get-started/exploring-projects-on-github/contributing-to-a-project#creating-your-own-copy-of-a-project). Copy all branches if possible. Now you have your own copy of the whole repo on GitHub.
* Clone your fork to your local machine, so you can work locally on code changes:

```
git clone <your-fork-url>
```
* Create a new branch from `develop`, choosing a descriptive name, ideally starting with the number of the issue you are working on.

```
git checkout develop
git switch -c <issue-number-short-descriptive-name>
```
* Make the changes and open a pull request to the upstream repository.

### Issues and feature branches 

- For anything beyond a trivial fix, please link your work to an existing issue. If there is no suitable issue, please [open an issue](../#getting-help) in the upstream repo.
- For larger or coordinated features, maintainers will organise work using shared feature branches. Please check to see if the relevant feature branch already exists for your issue:
```
git branch -r
```
- Where a relevant feature branch exists, create a branch off the feature branch you want to contribute to, and switch to it, e.g.
```
git checkout 62-implement-a-new-feature
git switch -c 75-implement-a-new-feature-my-part
```
or to work on a parent issue directly, please use a branch name that identifies you:
e.g.
```
git switch -c 62-implement-a-new-feature-<your-username>
```

### Development good practice

- Commit to your branch locally and regularly push your work to the same named branch on the fork.
- Label commit messages with the issue number, e.g.,
```
git commit -m "#62: Basic class structure"`
```
- If you need feedback or help but your branch is not ready to merge, open a draft pull request (PR).
- When your branch is ready for merging, open a (normal) PR, or convert your draft one to one, and request a code review.
- Please avoid rebasing branches that are shared with other contributors. For shared work we recommend using `git merge` instead to avoid disrupting others.

### Setting up a Development Environment

For small contributions (e.g., documentation updates, minor fixes), you may not need a full development environment. For more substantial development work, we recommend the following setup:

#### 1. Create and activate an environment

Use an environment manager to create and activate an environment. For example, with [conda](https://docs.conda.io/projects/conda/en/latest/index.html):

```bash
conda create -n kwave
conda activate kwave
```

#### 2. Install dependencies

Install packages defined in `requirements.txt`, which contain tools used for documentation and development:
```
pip install -r requirements.txt
```

k-Wave-II uses [pre-commit](https://pre-commit.com/) to run automated checks (formatting, spelling, line endings, etc.) on every `git commit` to keep the codebase consistent. If you want to skip the pre-commit checks when you commit a change, you can use 
```
git commit --no-verify
```
However, the same tests will be run automatically during Continuous Integration (CI) when you push your changes to GitHub, and they will fail if any fixes are required. For this reason, we recommend fixing any issues identified by pre-commit locally before committing and pushing to the repository.

To run pre-commit manually on the files that have changed use:

```bash
pre-commit run
```
or to run it on all files, use
```
pre-commit run -a
```
### Conditions for merging a PR

Only the k-Wave-II maintainers can merge PRs into any of the branches of the upstream repo. The pull request template will guide you through the requirements to get your changes approved and merged by the maintainers. For reference, those are

- For new features (functions or classes), please add appropriate tests. See the [developer docs](developerIntroduction.md) for more details.
- All tests should pass. Running tests locally is encouraged but not required as CI will run them automatically when you open a pull request.
- [Update the documentation](developerIntroduction.md#writing-and-building-the-documentation) and make sure it builds and looks right.
- Add examples and/or tutorials for substantial new functionality.
- One approving code review from a maintainer is required.

The code review step is crucial in order to guarantee the quality of code contributions from the community. It is an iterative process, and you will have to address the reviewer's comments and any concerns. Please remember that these comments are intended to improve the software, and should not be taken as a judgement on coding ability.

## AI and LLM Use

AI tools can be valuable for learning, exploring ideas, and accelerating work. We welcome their thoughtful use. To ensure contributions remain meaningful and contributors continue to grow, we ask that you:

* Understand what you submit. Be able to explain and defend any contribution you make. If you cannot, it is not ready to submit.
* Stay in the driver's seat. Use AI to support your learning and work, not to replace the effort and critical thinking that make you a better developer.
* Engage meaningfully. Low-effort, AI-generated submissions (issues, PRs, or proposals) without genuine personal engagement will not be accepted.

Maintainers may ask contributors to explain their work. This is part of our commitment to learning and quality — it is not a test of whether you used AI but whether you understand what you contributed.


## Legal and Licensing
To protect the interests of the k-Wave-II community and ensure the long-term sustainability of the project, we require all contributors to adhere to our [licensing terms](LICENSE.md).

### Contributor Agreement
By contributing to k-Wave-II, you agree that we may redistribute your work under the project's current open-source license. You represent that you are legally entitled to grant this permission and that your contribution does not infringe on the intellectual property rights of others.

For more information on why this is necessary and how ownership works in open source, please refer to the following resources from OSS Watch:

* [Open source development - An introduction to ownership and licensing issues](http://oss-watch.ac.uk/resources/iprguide)
* [Contributor Licence Agreements (CLAs)](http://oss-watch.ac.uk/resources/cla)
