import DesignPatterns from "../contracts/DesignPatterns"

transaction() {
    prepare(signer: AuthAccount) {

        let actorResource = signer.getCapability
            <&{DesignPatterns.UnlockedCapability}>
            (DesignPatterns.unlockedCapabilityPrivatePath)
            .borrow() ?? panic("could not borrow a reference to the UnlockedCapability interface")

        actorResource.doSomethingCool()
    }
}