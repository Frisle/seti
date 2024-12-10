Class SETI.Setup.Ports
{

/// Get input from the user for getting the ports.
ClassMethod SetPorts()
{
    // 1. Prompt user for port numbers.
    // get ucr port
    do ##class(%RoutineMgr).GetWebServerPort(.port)
    set ^ucrPort = port
    /// because instance name is usually all caps, but for a website it needs to be all lower
    set instance = ##class(%SYS.System).GetInstanceName()
    set instance = $ZCONVERT(instance, "L")

    READ !, "Please enter your Clinical Viewer web port number:", !, viewer
    set ^viewerPort = viewer
    write !
    READ !, "Please enter your Clinical Viewer instance name:", !, viewer
    set ^viewerInstance = viewer

    // 2. Add port numbers to XData of the CSP for SDAStudio.
    set sdaStudio = ##class(%Dictionary.ClassDefinition).%OpenId("SETI.CSP.SDAStudio")
    set xdata = sdaStudio.XDatas.GetAt(1).Data

    set newStream = ##class(%Stream.TmpCharacter).%New()
    do newStream.WriteLine("<page xmlns=""http://www.intersystems.com/zen"">")
    do newStream.WriteLine("<html id=""titleBar"" OnDrawContent=""DrawTitle""/>")
    do newStream.WriteLine("<iframe width=""100%"" height=""100%"" src=""http://localhost:" _ ^ucrPort _ "/" _ instance _ "/seti/index.html"" frameBorder=""0"" id=""display""></iframe>")
    do newStream.WriteLine("</page>")
    // copy from the new stream
    do xdata.Clear()
    do xdata.CopyFrom(newStream)
    do sdaStudio.%Save()
    do $system.OBJ.Compile("SETI.CSP.SDAStudio")
}

}
