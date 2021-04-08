package main

import (
	"github.com/bjartek/go-with-the-flow/gwtf"
)

func main() {
	gwtf.
		NewGoWithTheFlowEmulator().
		CreateAccount("deployer")
}