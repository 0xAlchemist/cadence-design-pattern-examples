// A Cadence Design Pattern demonstration


pub contract DesignPatterns {

    // Named Paths
    pub let adminResourceStoragePath: StoragePath

    pub let actorResourceStoragePath: StoragePath
    
    pub let specialCapabilityPrivatePath: PrivatePath
    
    pub let unlockedCapabilityPrivatePath: PrivatePath
    
    pub let addCapabilityPublicPath: PublicPath

    // Resource Interfaces
    pub resource interface SpecialCapability {
        // just used to enable the ActorResource
    }

    pub resource interface AddCapability {
        pub fun addCapability(cap: Capability<&{SpecialCapability}>)
    }

    pub resource interface UnlockedCapability {
        pub fun doSomethingCool(): String
    }

    // Admin Resource - Init Singleton
    pub resource AdminResource: SpecialCapability, AddCapability {

        // receiveCapability method
        pub fun addCapability(cap: Capability<&{SpecialCapability}>) {
            pre {
                // we make sure the correct capability exists before executing the method
                cap.borrow() != nil: "could not borrow a reference to the special capability"
            }
        }
    }

    // Actor Resource - Capability Receiver
    pub resource ActorResource: AddCapability, UnlockedCapability {

        // this field is initialized with a nil value, but stores the capability
        // once the resource has received it from the owner of the AdminResource
        //
        access(contract) var capability: Capability<&{SpecialCapability}>?
        
        // this is the receiveCapability method that the admin resource calls
        // to add the special capability to the ActorResource
        //
        pub fun addCapability(cap: Capability<&{SpecialCapability}>) {
            pre {
                // we make sure the correct capability exists before executing the method
                cap.borrow() != nil: "could not borrow a reference to the special capability"
            }

            // set the special capability
            self.capability = cap
        }

        // the actor can only call this method once the special capability
        // has been received
        //
        pub fun doSomethingCool(): String {
            pre {
                self.capability != nil: "I don't have the special capability :("
            }

            return "I have the special capability!!!"
        }

        init() {

            // set the initial field value to nil
            self.capability = nil
        }

    }

    pub fun createActorResource(): @ActorResource {
        return <- create ActorResource()
    }

    // TODO: does this work with `flow project deploy` now?
    init(admin: AuthAccount) {

        // Named Paths
        self.adminResourceStoragePath = /storage/AdminResource

        self.actorResourceStoragePath = /storage/ActorResource

        self.specialCapabilityPrivatePath = /private/SpecialCapability

        self.unlockedCapabilityPrivatePath = /private/UnlockedCapability

        self.addCapabilityPublicPath = /public/AddCapability

        // Init Singleton

        // create and save an AdminResource to the deployer's account
        // - this is the only time this resource can be created
        admin.save(<- create AdminResource(), to: self.adminResourceStoragePath)

        // store a link to the SpecialCapability interface in the owner's
        // private account storage
        //
        // - this restricts the capability so the AdminResource owner is the
        // only one that can borrow a reference to it
        //
        admin.link<&{SpecialCapability}>(
            self.specialCapabilityPrivatePath,
            target: self.adminResourceStoragePath
        )
    }
}