import DesignPatterns from "../contracts/DesignPatterns.cdc"

transaction() {
    prepare(signer: AuthAccount) {
        
        // create the new ActorResource
        let actorResource <- DesignPatterns.createActorResource()

        // save the resource to the signer's account storage
        signer.save(<- actorResource, to: DesignPatterns.actorResourceStoragePath)

        // link the UnlockedCapability in private storage
        signer.link<&{DesignPatterns.UnlockedCapability}>(
            DesignPatterns.unlockedCapabilityPrivatePath,
            target: DesignPatterns.actorResourceStoragePath
        )
    }
}