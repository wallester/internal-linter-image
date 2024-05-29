package analyzer

import (
	"go/ast"
	"strings"

	"golang.org/x/tools/go/analysis"
	"golang.org/x/tools/go/analysis/passes/inspect"
	"golang.org/x/tools/go/ast/inspector"
)

var Analyzer = &analysis.Analyzer{
	Name:     "mocklint",
	Doc:      "check for usage of mock.Anything in unit tests",
	Requires: []*analysis.Analyzer{inspect.Analyzer},
	Run:      run,
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
