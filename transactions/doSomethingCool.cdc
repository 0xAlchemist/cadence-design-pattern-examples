import DesignPatterns from 0x01cf0e2f2f715450

transaction() {
    prepare(signer: AuthAccount) {

        let actorResource = signer.getCapability
            <&{DesignPatterns.UnlockedCapability}>
            (DesignPatterns.unlockedCapabilityPrivatePath)
            .borrow() ?? panic("could not borrow a reference to the UnlockedCapability interface")

        log(actorResource.doSomethingCool())
    }
}