param($installPath, $toolsPath, $package, $project)
$serverProvider = $dte.GetObject("CustomWebServerProvider")
if ($serverProvider -eq $null)
{
    return; # Only supported on VS 2013
}
$servers = $serverProvider.GetCustomServers($project.Name)
if ($servers -eq $null)
{
    return; # Not a WAP project
}
$solutionDir = [System.IO.Path]::Combine($installPath, "..\..\")
$solutionDir = [System.IO.Path]::GetFullPath($solutionDir)
$relativeToolsDir = $toolsPath.SubString($solutionDir.Length)

$iisexpress = Join-Path (Get-ItemProperty 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\IISExpress\8.0' 'InstallPath').InstallPath 'iisexpress.exe'


$server = $servers.GetWebServer('IISExpressAppPoolExternalHost')
if ($server -ne $null)
{
    $servers.UpdateWebServer('IISExpressAppPoolExternalHost', $iisexpress, $server.CommandLine, $server.Url, $server.WorkingDirectory)
}
else
{
    try
    {
       $servers.AddWebServer('IISExpressAppPoolExternalHost', $iisexpress, '/AppPool:Clr4IntegratedAppPool', [System.Management.Automation.Language.NullString]::Value, '{solutiondir}')
	   #This adds a Custom Server with
		#Name: IISExpressAppPoolExternalHost
		#Location of EXE to Execute and pass parameters into: C:\Test\foo.exe
		#Command Line Arugement: /{URL}
		#URL: Not specified (due to the [System.Management.Automation.Language.NullString]::VALUE
		#And a Working Directory: {SolutionDir}
		#Use of the {URL} and {SolutionDir} means that this server will defer to Visual studio to set those values automatically
    }
    catch [System.OperationCanceledException]
    {
        # The user hit No when prompted about locking the VS version.
    }
}