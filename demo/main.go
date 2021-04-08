package main

import (
	"github.com/bjartek/go-with-the-flow/gwtf"
)

func main() {
	g := gwtf.
		NewGoWithTheFlowEmulator().
		CreateAccountWithContracts("deployer")

	var ignoreFields = map[string][]string{
		"flow.AccountCodeUpdated": {"codeHash"},
		"flow.AccountKeyAdded":    {"publicKey"},
	}

	// create the Actor Resource
	g.
		TransactionFromFile("createActorResource").
		SignProposeAndPayAs("actor").
		RunPrintEvents(ignoreFields)

	// fail running doSomethingCool as the actor

	// add capability to capability receiver with admin resource

	// successfully run the doSomethingCool method
}