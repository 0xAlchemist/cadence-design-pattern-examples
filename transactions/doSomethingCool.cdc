import DesignPatterns from 0x01cf0e2f2f715450

transaction() {
    prepare(signer: AuthAccount) {

        // borrow a reference to the UnlockedCapability
        // methods on the ActorResource stored in the
        // signer's account
        //
        let actorResource = signer.getCapability
            <&{DesignPatterns.UnlockedCapability}>
            (DesignPatterns.unlockedCapabilityPrivatePath)
            .borrow() ?? panic("could not borrow a reference to the UnlockedCapability interface")

        // log the result of the doSomethingCool method
        //
        // - this will panic and revert the transaciton
        // if the SpecialCapability has not been added
        // 
        log(actorResource.doSomethingCool())
    }
}