# Code Quality

## Development

The following make targets can be used to analyse your code/run tests:

- `make analyse`: run a static code analysis ([GrumPHP](../docker/templates/magento/grumphp.yaml.dist)) on the entire codebase (files must be known to git).
- `make pre-commit`: run a static code analysis ([GrumPHP](../docker/templates/magento/grumphp.yaml.dist)) on staged files.
- `make tests`: run phpunit.

**These targets must not report any error**!
Don't commit your code if these commands report errors.

If GrumPHP is correctly installed, your code will be automatically validated when you create a new commit.

## CI

### Code Analysis

A code analysis is automatically run on GitLab when a commit is pushed on a branch.
You can customize how these tests are run by modifying the contents of the file ".gitlab-ci.yml" at the root of the Magento directory.

By default, it runs the following tools:

- GrumPHP
- SmileAnalyser

We encourage you to add more tests to the CI (e.g. unit tests and functional tests).

**Don't merge a MR if the tests failed on the CI.**

### Troubleshooting

If the CI fails, make sure that the variable "COMPOSER_AUTH" is defined in the settings of the git repository, and that it contains all required access keys.
