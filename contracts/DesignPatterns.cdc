// A Cadence Design Pattern demonstration
// - https://docs.onflow.org/cadence/design-patterns
//
// - Named Value Fields
// - Capability Receiver
// - Init Singleton
// - Script Accessible Report
//

pub contract DesignPatterns {

    // Total amount of Actor resources created
    // - we will use this value in our ReportStruct
    access(contract) var totalActors: UInt64

    // Total amount of Actor resources that have
    // received the SpecialCapability
    access(contract) var enabledActors: UInt64

    // Named Value Fields
    // - https://docs.onflow.org/cadence/design-patterns/#named-value-field
    
    // Resource Storage Paths
    pub let adminResourceStoragePath: StoragePath
    pub let actorResourceStoragePath: StoragePath
    
    // Private Capability Paths
    pub let specialCapabilityPrivatePath: PrivatePath
    pub let unlockedCapabilityPrivatePath: PrivatePath
    
    // Public Capability Paths
    pub let addCapabilityPublicPath: PublicPath
    pub let adminPublicPath: PublicPath

    // Script Accessible Report
    // - https://docs.onflow.org/cadence/design-patterns/#script-accessible-report
    //
    // This allows us to create a safe and transaction free way
    // for users to fetch data from the smart contract or it's resources
    //
    pub struct ReportStruct {

        pub let actors: UInt64
        pub let enabled: UInt64

        init(actors: UInt64, enabled: UInt64) {
            self.actors = actors
            self.enabled = enabled
        }
    }

    // The SpecialCapability interface is
    // passed into the ActorResource by the Admin
    // to activate the locked functionality for that
    // ActorResource
    //
    // For this simple example, there are no methods
    // or fields included in this interface
    //
    pub resource interface SpecialCapability {
        // just used to enable the ActorResource
    }

    // The AdminPublic interface is used
    // to provide a capability for anyone
    // to generate a script accessible report 
    // from the AdminResource.
    // 
    pub resource interface AdminPublic {
        pub fun generateReport(): ReportStruct
    }

    // The AddCapability interface is the public 
    // capability the Admin borrows in order to pass in the 
    // required SpecialCapability and activate the locked 
    // functionality for it's ActorResource
    //
    pub resource interface AddCapability {
        pub fun addCapability(cap: Capability<&{SpecialCapability}>)
    }

    // The UnlockedCapability interface is a private capability
    // that the owner of the ActorResource can borrow to call the
    // unlocked functionality
    //
    // For this example, the doSomethingCool method will fail
    // unless the SpecialCapability has been passed into the
    // ActorResource by the owner of the AdminResource
    //
    pub resource interface UnlockedCapability {
        pub fun doSomethingCool(): String
    }

    // Admin Resource - Init Singleton
    pub resource AdminResource: SpecialCapability, AdminPublic {
        // Returns a report struct with the values from the
        // smart contract. You wouldn't be able to access
        // these values without this method as they are
        // restricted to the smart contract using 
        // 'access(contract)'
        //
        pub fun generateReport(): ReportStruct {
            return ReportStruct(actors: DesignPatterns.totalActors, enabled: DesignPatterns.enabledActors)
        }
    }

    // Actor Resource - Capability Receiver
    // - https://docs.onflow.org/cadence/design-patterns/#capability-receiver
    //
    pub resource ActorResource: AddCapability, UnlockedCapability {

        // this field is initialized with a nil value, but stores the SpecialCapability
        // once the resource has received it from the owner of the AdminResource
        //
        access(contract) var capability: Capability<&{SpecialCapability}>?
        
        // this is the addCapability method that the AdminResource owner calls
        // to add the SpecialCapability to the ActorResource
        //
        pub fun addCapability(cap: Capability<&{SpecialCapability}>) {
            pre {
                // we make sure the SpecialCapability is 
                // valid before executing the method
                cap.borrow() != nil: "could not borrow a reference to the SpecialCapability"
                self.capability == nil: "resource already has the SpecialCapability"
            }

            // update the enabledActors field for the smart contract
            DesignPatterns.enabledActors = DesignPatterns.enabledActors + 1 as UInt64

            // add the SpecialCapability
            self.capability = cap
        }

        // the actor can only call this method once 
        // the special capability has been received
        //
        pub fun doSomethingCool(): String {
            pre {
                // the transaction will instantly revert if 
                // the capability has not been added
                //
                self.capability != nil: "I don't have the special capability :("
            }

            // we return this result if the SpecialCapability
            // has been added
            //
            return "I have the special capability!!"
        }

        init() {

            // set the initial field value to nil
            self.capability = nil
        }

    }

    // Creates an ActorResource and returns it to the caller
    //
    // The new ActorResource will require the SpecialCapability
    // before any UnlockedCapability methods can be called
    //
    pub fun createActorResource(): @ActorResource {
        
        // increment the Actor count
        DesignPatterns.totalActors = DesignPatterns.totalActors + 1 as UInt64

        // return the new Actor resource to the caller
        return <- create ActorResource()
    }

    init() {

        // Set initial Actor count to zero
        self.totalActors = 0 as UInt64

        // Set initial ennabledActors count to zero
        self.enabledActors = 0 as UInt64

        // Resource Storage Paths
        self.adminResourceStoragePath = /storage/AdminResource
        self.actorResourceStoragePath = /storage/ActorResource

        // Private Capability Paths
        self.specialCapabilityPrivatePath = /private/SpecialCapability
        self.unlockedCapabilityPrivatePath = /private/UnlockedCapability

        // Public Capability Paths
        self.addCapabilityPublicPath = /public/AddCapability
        self.adminPublicPath = /public/AdminPublicCapability

        // Init Singleton Pattern
        // - https://docs.onflow.org/cadence/design-patterns/#init-singleton
        //
        // *NOTE* The flow-cli tookling does not support init arguments for
        // smart contracts yet, so we're using 'self.account' in place of
        // the 'init(admin: AuthAccount)' method in the docs.

        // create and save an AdminResource to the deployer's account
        // - this is the only time this resource can be created
        self.account.save(<- create AdminResource(), to: DesignPatterns.adminResourceStoragePath)

        // store a link to the SpecialCapability interface in the owner's
        // private account storage
        //
        // - this restricts the capability so the AdminResource owner is the
        // only one that can borrow a reference to it
        //
        self.account.link<&{SpecialCapability}>(
            DesignPatterns.specialCapabilityPrivatePath,
            target: DesignPatterns.adminResourceStoragePath
        )

        // store a link to the AdminPublic interface in the owner's
        // public account storage
        //
        // - this provides the capability that anyone can borrow a reference
        // to and use to generate a script-accessible report
        //
        self.account.link<&{AdminPublic}>(
            DesignPatterns.adminPublicPath,
            target: DesignPatterns.adminResourceStoragePath
        )
    }
}