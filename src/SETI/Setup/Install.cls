Class SETI.Setup.Install
{

ClassMethod Install()
{
    do ..SetHSLIBToWrite()
    do ..Mappings()
    do ..Compile()
    do ..AddManagmentPortal()
    do ..EditPath()
}

/// Give HSLIB read-permission, so we can write to the Health pages in
/// the managment portal.
ClassMethod SetHSLIBToWrite()
{
    try {
        zn "%SYS"
        Set db=##Class(SYS.Database).%OpenId("hslib")
        s db.ReadOnly = 0
        do db.%Save()
        zn "HSCUSTOM"
    } catch {
        zn "HSCUSTOM"
        w "SetHSLIBToWrite: Switching to %SYS failed"
    }
}

/// Add CSP, global mappings.
ClassMethod Mappings()
{
    try {
        zn "%SYS"
        s hscustom("Database") = "HSCUSTOM"

        // setup CSP webpage
        do ##class(Config.MapPackages).Create("HSRegistry", "SETI.CSP", .hscustom)
        
        // global map customsda
        do ##class(Config.MapGlobals).Create("HSANALYTICS", "customsda", .hscustom)

        zn "HSCUSTOM"
    } catch {
        zn "HSCUSTOM"
        write !, "Mappings: Switiching to %SYS failed"
    }
}

/// Compile necessary classes.
ClassMethod Compile()
{
    try {
        zn "HSREGISTRY"
        do $system.OBJ.Compile("SETI.CSP.SDAStudio")
        zn "HSCUSTOM"
    } catch {
        zn "HSCUSTOM"
        write !, "Compile: Switiching to HSREGISTRY failed"
    }
}

/// Insert into managment portal.
ClassMethod AddManagmentPortal()
{
    try {
        zn "HSREGISTRY"
        s portal = ##class(%Dictionary.ClassDefinition).%OpenId("HS.UI.Home")
        set key = 0

        // find the HSRegistry tab on HealthShare
        for {
            set key = key + 1
            set method = portal.Methods.GetAt(key)
            if (method.Name = "GetRegistryManagement") {
                quit
            }
        }

	    set implementation = portal.Methods.GetAt(key).Implementation
	    do implementation.Rewind()
	
	    if (implementation.ReadLine() = "   Do ..AddOption($$$Text(""SDA Studio""),$$$Text(""Customize SDA Data Model""),"""",""SETI.CSP.SDAStudio.cls"",,..Link(""portal/role_48.gif""),,.pData,.n2,pN1)")
            { quit }

	    // add the SDA Studio option
        set addSDAStudio = ##class(%Stream.TmpCharacter).%New()
        do addSDAStudio.WriteLine("   Do ..AddOption($$$Text(""SDA Studio""),$$$Text(""Customize SDA Data Model""),"""",""SETI.CSP.SDAStudio.cls"",,..Link(""portal/role_48.gif""),,.pData,.n2,pN1)")
        do addSDAStudio.CopyFrom(implementation)

        //make it the new implementation
        set portal.Methods.GetAt(key).Implementation = addSDAStudio 
        do portal.%Save()
        do $system.OBJ.Compile("HS.UI.Home")

        zn "HSCUSTOM"
    } catch {
        zn "HSCUSTOM"
        write !, "AddManagmentPortal: Switiching to HSREGISTRY failed"
    }
}

/// Change the path of seti to be the angular "build version".
ClassMethod EditPath()
{
    try {
        zn "%SYS"

        // get build version of OS
        set OS = $system.Version.GetBuildOS()
        if OS = "UNIX" {
            set ext = "dist/sda-studio/"
        }
        if OS = "Windows" {
            set ext = "dist\sda-studio\"
        }

        // get the seti project
        set dispatch = ##class(Security.Applications).%OpenId("/seti")

        // the build is in the dist folder
        set dispatch.Path = dispatch.Path _ ext
        do dispatch.%Save()
        zn "HSCUSTOM"

    } catch {
        zn "HSCUSTOM"
        write !, "EditPath: Switching to %SYS failed"
    }
}

}
