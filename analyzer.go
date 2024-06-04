package custom_code_analysis_tools

import (
	"go/ast"
	"strings"

	"github.com/golangci/plugin-module-register/register"
	"golang.org/x/tools/go/analysis"
	"golang.org/x/tools/go/analysis/passes/inspect"
	"golang.org/x/tools/go/ast/inspector"
)

func init() {
	register.Plugin("mocklint", New)
}

func New(_ any) (register.LinterPlugin, error) {
	return &mockLintAnalyzer{}, nil
}

type mockLintAnalyzer struct{}

func (m *mockLintAnalyzer) BuildAnalyzers() ([]*analysis.Analyzer, error) {
	return []*analysis.Analyzer{
		{
			Name: "mocklint",
			Doc:  "finds mock.Anything in unit tests",
			Run:  run,
			Requires: []*analysis.Analyzer{
				inspect.Analyzer,
			},
		},
	}, nil
}

func (m *mockLintAnalyzer) GetLoadMode() string {
	return register.LoadModeSyntax
}

func run(pass *analysis.Pass) (interface{}, error) {
	insp := pass.ResultOf[inspect.Analyzer].(*inspector.Inspector)

	nodeFilter := []ast.Node{
		(*ast.CallExpr)(nil),
	}

	testFiles := make(map[string]bool)
	for _, f := range pass.Files {
		filename := pass.Fset.File(f.Pos()).Name()
		if strings.HasSuffix(filename, "_test.go") {
			testFiles[filename] = true
		}
	}

	insp.Preorder(nodeFilter, func(node ast.Node) {
		filename := pass.Fset.File(node.Pos()).Name()

		if !testFiles[filename] {
			return
		}

		callExpr, ok := node.(*ast.CallExpr)
		if !ok {
			return
		}

		for _, arg := range callExpr.Args {
			selectorExpr, ok := arg.(*ast.SelectorExpr)
			if !ok {
				continue
			}

			xIdent, ok := selectorExpr.X.(*ast.Ident)
			if ok && xIdent.Name == "mock" && selectorExpr.Sel.Name == "Anything" {
				pass.Reportf(selectorExpr.Pos(), "use of mock.Anything is disallowed in unit tests")
			}
		}
	})

	return nil, nil
}
