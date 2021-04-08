package main

import (
	"github.com/bjartek/go-with-the-flow/gwtf"
)

func main() {
	g := gwtf.
		NewGoWithTheFlowEmulator().
		CreateAccount("actor")

	// create the Actor Resource
	g.
		TransactionFromFile("createActorResource").
		SignProposeAndPayAs("actor").
		Run()

	// fail running doSomethingCool as the actor
	// g.
	// 	TransactionFromFile("doSomethingCool").
	// 	SignProposeAndPayAs("actor").
	// 	Run()

	// add capability to capability receiver with admin resource
	g.
		TransactionFromFile("addCapability").
		AccountArgument("actor").
		SignProposeAndPayAs("deployer").
		Run()

	// successfully run the doSomethingCool method
	g.
		TransactionFromFile("doSomethingCool").
		SignProposeAndPayAs("actor").
		Run()
}