package main

import (
	"github.com/bjartek/go-with-the-flow/gwtf"
)

func main() {
	// Create a new go-with-the-flow instance
	// - create the Actor account
	//
	g := gwtf.
		NewGoWithTheFlowEmulator().
		CreateAccount("actor")

	// create the Actor Resource
	// - sign as the Actor
	g.
		TransactionFromFile("createActorResource").
		SignProposeAndPayAs("actor").
		Run()

	// running doSomethingCool as the Actor
	// would fail here, as the ActorResource
	// hasn't received the capability yet
	//
	// g.
	// 	TransactionFromFile("doSomethingCool").
	// 	SignProposeAndPayAs("actor").
	// 	Run()

	// add capability to capability receiver with admin resource
	// - pass in the Actor's account argument (Address)
	// - sign as the Deployer
	//
	g.
		TransactionFromFile("addCapability").
		AccountArgument("actor").
		SignProposeAndPayAs("deployer").
		Run()

	// successfully run the doSomethingCool method
	// - sign as the Actor
	//
	g.
		TransactionFromFile("doSomethingCool").
		SignProposeAndPayAs("actor").
		Run()
}