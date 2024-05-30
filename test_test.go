package main

import (
	"testing"

	"github.com/stretchr/testify/mock"
)

func TestSomething(_ *testing.T) {
	m := &mock.Mock{}
	m.On("Method", mock.Anything).Return(nil)
}
