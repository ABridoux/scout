Taken with all my gratitude and 💚 from [JamfKit](https://github.com/Ethenyl/JAMFKit)

# Contributing #

## Summary ##

- [Setup](#setup)
- [Architecture](architecture)
- [Branching Model](#branching-model)
  - [Master](#master)
  - [Develop](#develop)
  - [Patterns](#patterns)
- [Commits](#commits)
- [Unit testing](#unit-testing)
- [Linting](#linting)
- [Issue checklist](#issue-checklist)
- [Pull request checklist](#pull-request-checklist)

## Setup ##

To get started on contributing on Scout you'll need to clone the repository from `GitHub`.

Next step will be to verify that you're using **Xcode 11.5** or higher.

Once those two steps are completed, you'll be able to start contributing to Scout.

We recommend the usage of the following useful tools:
- [SwiftLint](https://github.com/realm/SwiftLint)

## Architecture

Before implementing a new feature, please take the time to read and understand the [Architecture](https://github.com/ABridoux/scout/wiki/%5B80%5D-Architecture) of the project. When doing so, feel free to ask questions at alexis1bridoux@gmail.com or open an issue if you think the architecture could be improved.

## Branching model ##

The current branching model of Scout is built upon [A successful Git branching model](http://nvie.com/posts/a-successful-git-branching-model) from [Vincent Driessen](http://nvie.com).

Every single change that targets the main branches (master, develop) can only be merged through a pull request, which we greatly encourage.

### Master ###

This very peculiar branch is used only for hosting the releases of Scout.

Apart from the code coming from the release branches, it is allowed to create pull request to merge hotfixes and documentation fixes.

To perform a new release, a branch (named like **release/release-x.x.x**) must be created from the **develop** branch. Once all the preparatory work is done, a pull request (named like **Release x.x.x**) must be created with **master** as the target.

Once everything is settled on the pull request (version bump, up-to-date documentation, hotfixes, etc.) it will be merged into **master**. Right after, a new tag (named like **x.x.x**) will be associated with the merge commit.

### Develop ###

This branch can be considered as the main working branch, every change toward the next release is staged here until the next release branch is created.

You're free to rebase on develop whenever you need to get the latest change in your branch.

### Patterns ###

All branches inside Scout needs to be named by following one of the pattern below:

- feature/{branch_name}
- bug/{branch_name}
- release/{branch_name}
- hotfix/{branch_name}

Pull requests coming from branches which are not matching any of those pattern will be declined.

## Commits ##

Before commiting anything to you branch, make sure to add relevant message and description to your commit.

If you need to some insights on how to actually do this, here's some very interesting readings:

- [How to Write a Git Commit Message](https://chris.beams.io/posts/git-commit)
- [What makes a good commit message?](https://hackernoon.com/what-makes-a-good-commit-message-995d23687ad)

## Unit testing ##

Rather than using TDD, you are encouraged to provide code that testes the API entry points, or critical parts. You can find some inspirations in this [article](https://www.swiftbysundell.com/articles/pragmatic-unit-testing-in-swift/).

Testing errors is heavily recommended to make sure the correct error is thrown when the program is misused.

## Linting ##

Currently, Scout uses `SwiftLint` before each push to enforce a general quality of the code.
## Issue checklist ##

- [ ] Issue tracker does not already contain the same (or a very similar) issue
- [ ] Title must be clear about what is the issue
## Pull request checklist ##

- [ ] Title must be clear about what will change
- [ ] Description must contain a comprehensive explanation of what changed and links toward related issues
- [ ] Unit tests must put in place
- [ ] New objects must be fully documented inline