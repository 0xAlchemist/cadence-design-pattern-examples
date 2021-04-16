import DesignPatterns from 0x01cf0e2f2f715450

pub fun main(adminAddress: Address) {

    // get the admin public account object
    let adminAccount = getAccount(adminAddress)

    // borrow a reference to the AdminPublic capability
    let adminPublic = adminAccount.getCapability
        <&{DesignPatterns.AdminPublic}>
        (DesignPatterns.adminPublicPath)
        .borrow() ?? panic("could not borrow a reference to the AdminPublic capability")

    // generate a new ReportStruct
    let report = adminPublic.generateReport()

    // convert the integer values to strings
    let totalActors = report.actors.toString()
    let enabledActors = report.enabled.toString()

    // log the output from the report
    log("Enabled Actors: ".concat(enabledActors).concat("/").concat(totalActors))

}