package main

import (
	"github.com/wallester/custom-code-analysis-tools/analyzer"
	"golang.org/x/tools/go/analysis"
)

func New(_ any) ([]*analysis.Analyzer, error) {
	return []*analysis.Analyzer{analyzer.Analyzer}, nil
}
