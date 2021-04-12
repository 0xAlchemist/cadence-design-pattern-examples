import DesignPatterns from 0x01cf0e2f2f715450

transaction() {
    prepare(signer: AuthAccount) {
        
        // create the new ActorResource
        let actorResource <- DesignPatterns.createActorResource()

        // save the resource to the signer's account storage
        signer.save(<- actorResource, to: DesignPatterns.actorResourceStoragePath)

        // link the AddCapability in public storage
        // so the Admin can borrow it
        //
        signer.link<&{DesignPatterns.AddCapability}>(
            DesignPatterns.addCapabilityPublicPath,
            target: DesignPatterns.actorResourceStoragePath
        )

        // link the UnlockedCapability in private storage
        signer.link<&{DesignPatterns.UnlockedCapability}>(
            DesignPatterns.unlockedCapabilityPrivatePath,
            target: DesignPatterns.actorResourceStoragePath
        )
    }
}