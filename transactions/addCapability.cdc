import DesignPatterns from 0x01cf0e2f2f715450

transaction(actor: Address) {
    prepare(signer: AuthAccount) {

        // get the public account object for the actor
        let actorAccount = getAccount(actor)

        // get the public capability from the actor's public storage
        let actorResource = actorAccount.getCapability
            <&{DesignPatterns.AddCapability}>
            (DesignPatterns.addCapabilityPublicPath)
            .borrow() ?? panic("could not borrow reference to AddCapability")

        // get the private capability from the Authorized owner of the AdminResource
        // - this will be the signer of this transaction
        //
        let specialCapability = signer.getCapability
            <&{DesignPatterns.SpecialCapability}>
            (DesignPatterns.specialCapabilityPrivatePath)

        // if the special capability is valid...
        if specialCapability.check() {
            // ...add it to the ActorResource
            actorResource.addCapability(cap: specialCapability)
        } else {
            // ...let the people know we failed
            panic("special capability is invalid!")
        }
    }
}