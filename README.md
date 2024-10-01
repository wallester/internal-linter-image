# Internal linter image

## Overview

`custom-gcl` is a custom version of `golangci-lint` that includes custom linters.
## Build new Golang image
1. Change versions in this repo code (Dockerfile, go.mod)
2. Create PR and merge changes to master
3. AWS Codebuild will automatically detect changes, build new image and upload to `271332529381.dkr.ecr.eu-west-1.amazonaws.com/golang-with-dependencies:latest`
4. Monorepo services will automatically catch new version during its next build

## Creating the Analyzer

### Develope the main logic

1. Create a Go file with the linter logic. For example, `analyzer.go`:
```go
package custom-code-analysis-tools

import (
    "golang.org/x/tools/go/analysis"
)

var ExampleAnalyzer = &analysis.Analyzer{
        Name: "example",
        Doc:  "this is an example analyzer",
        Run:  run,
}

func run(pass *analysis.Pass) (interface{}, error) {
    for _, file := range pass.Files {
        // Implement your analysis logic here
        pass.Reportf(file.Pos(), "example warning")
    }
    return nil, nil
}

func New(conf any) ([]*analysis.Analyzer, error) {
    return []*analysis.Analyzer{ExampleAnalyzer}, nil
}
```
2. Ensure your project utilizes a go.mod file for managing dependencies.

### Generate the custom golagnci-lint binary

1. Define your building configuration into `.custom-gcl.yml`.
```yaml
version: v1.57.0
plugins:
  # a plugin from a Go proxy
  - module: 'github.com/golangci/plugin1'
    import: 'github.com/golangci/plugin1/foo'
    version: v1.0.0

  # a plugin from local source
  - module: 'github.com/golangci/plugin2'
    path: /my/local/path/plugin2
```
2. From the root directory of your plugin project, run the command `golangci-lint custom` (or `golangci-lint custom -v` to have logs):

```bash
golangci-lint custom -v
```

### Configuring Your Project for custom `golangci-lint`

To configure `golangci-lint` to use your custom linters, perform the following steps:

1. **Add or update the `.golangci.yml` file** in the root directory of the project you want to lint:

```yaml
linters-settings:
  custom:
    your_linter_name:
      type: "module"
      description: This is an example usage of a plugin linter.
      settings:
        message: hello
linters:
  disable-all: true
  enable:
      - your_linter_name
```