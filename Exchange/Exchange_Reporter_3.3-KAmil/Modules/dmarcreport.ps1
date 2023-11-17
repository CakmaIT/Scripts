$DMARCUseExchangeDefaultDomain = $True

#You can specify your Domains here, if you don't wan't to use Exchange Default Accepted Domain (set $DMARCUseExchangeDefaultDomain = $false)
$CustomDMARCDomains = @(
    'microsoft.com'
    'google.de'
	)

#--------------------------------------------------------------

$DMARCsettingshash = $inifile["DMARC"]
$DMARCsettings = convert-hashtoobject $DMARCsettingshash	

$MailboxName = ($DMARCsettings | Where-Object {$_.Setting -eq "RUA-Address"}).Value
$username = ($DMARCsettings | Where-Object {$_.Setting -eq "Username"}).Value
$password = ($DMARCsettings | Where-Object {$_.Setting -eq "Password"}).Value
$domain = ($DMARCsettings | Where-Object {$_.Setting -eq "Domain"}).Value
$folder = ($DMARCsettings | Where-Object {$_.Setting -eq "ArchiveFolder"}).Value

$dmarcreport = Generate-ReportHeader "dmarcreport.png" "$l_dmarc_header"

$cells=@("$l_dmarc_domain","$l_dmarc_entryfordomain")
$dmarcreport += Generate-HTMLTable "$l_dmarc_header2" $cells

if ($DMARCUseExchangeDefaultDomain -eq $True)
{
	$dmarcdomainnames = (Get-AcceptedDomain | where {$_.Default -eq "True"}).Domainname.Domain
}
else 
{
	$dmarcdomainnames = $Customdmarcdomains
}

foreach ($dmarcdomainname in $dmarcdomainnames)
	{
		$dmarcdnsname = "_dmarc." + "$dmarcdomainname"
		$dnsentry = Resolve-DnsName $dmarcdnsname -server 8.8.8.8 -Type TXT -ea 0
		$dnsdmarcentry = $dnsentry.strings
		
		$cells=@("$dmarcdnsname","$dnsdmarcentry")
		$dmarcreport += New-HTMLTableLine $cells
	}
$dmarcreport += End-HTMLTable

#Get DMARC Reports mailbox

Add-Type -Path "C:\Program Files\Microsoft\Exchange\Web Services\2.2\Microsoft.Exchange.WebServices.dll"

$ExchangeVersion = [Microsoft.Exchange.WebServices.Data.ExchangeVersion]::Exchange2010_SP2
$service = New-Object Microsoft.Exchange.WebServices.Data.ExchangeService($ExchangeVersion)


$creds = New-Object System.Net.NetworkCredential("$username","$password","$domain")
$service.Credentials = $creds  

#CAS URL Option 1 Autodiscover
$service.AutodiscoverUrl($MailboxName,{$true})

#CAS URL Option 2 Hardcoded  
#$uri=[system.URI] "https://outlook.frankysweb.local/ews/Exchange.asmx"
#$service.Url = $uri  

$Sfha = new-object Microsoft.Exchange.WebServices.Data.SearchFilter+IsEqualTo([Microsoft.Exchange.WebServices.Data.EmailMessageSchema]::HasAttachments, $true)
$folderid= new-object Microsoft.Exchange.WebServices.Data.FolderId([Microsoft.Exchange.WebServices.Data.WellKnownFolderName]::Inbox,"$MailboxName")   
$Inbox = [Microsoft.Exchange.WebServices.Data.Folder]::Bind($service,$folderid)  

$ivItemView = New-Object Microsoft.Exchange.WebServices.Data.ItemView(1000)
$downloadDirectory = "$installpath\Temp"

$findItemsResults = $Inbox.FindItems($Sfha,$ivItemView)
foreach($miMailItems in $findItemsResults.Items){
	$miMailItems.Load()
	foreach($attach in $miMailItems.Attachments){
		if ($attach.name -match "zip")
			{
				$attach.Load()
				$fiFile = new-object System.IO.FileStream(($downloadDirectory + "\" + $attach.Name.ToString()), [System.IO.FileMode]::Create)
				$fiFile.Write($attach.Content, 0, $attach.Content.Length)
				$fiFile.Close()
			}
	}
}
  
$fvFolderView =  New-Object Microsoft.Exchange.WebServices.Data.FolderView(1000)  
$fvFolderView.Traversal = [Microsoft.Exchange.WebServices.Data.FolderTraversal]::Shallow;
$SfSearchFilter = new-object Microsoft.Exchange.WebServices.Data.SearchFilter+IsEqualTo([Microsoft.Exchange.WebServices.Data.FolderSchema]::DisplayName,"$folder")
$findFolderResults = $Inbox.FindFolders($SfSearchFilter,$fvFolderView)  
    
$ivItemView =  New-Object Microsoft.Exchange.WebServices.Data.ItemView(1000)  
$fiItems = $null    
do{    
    $fiItems = $Inbox.FindItems($Sfha,$ivItemView)   
        foreach($Item in $fiItems.Items){      
 
            $move = $Item.Move($findFolderResults.Folders[0].Id)  
        }    
        $ivItemView.Offset += $fiItems.Items.Count    
    }while($fiItems.MoreAvailable -eq $true)  

#Extract ZIP Files

Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip-File
{
    param([string]$zipfile, [string]$outpath)
	try 
		{
			[System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
		}
	catch
		{
		}
}

$zipfiles =  Get-ChildItem "$Installpath\Temp\*.zip" -Recurse | Where {-NOT $_.PSIsContainer} | foreach {$_.fullname}
foreach ($zipfile in $zipfiles)
	{
		$unzip = Unzip-File $zipfile "$Installpath\Temp"
	}

#Getting DMARC Entrys vom XML Files
	
$dmarcobject = @()
$xmlfiles =  Get-ChildItem "$Installpath\Temp\*.xml" -Recurse | Where {-NOT $_.PSIsContainer} | foreach {$_.fullname}
foreach ($xmlfile in $xmlfiles)
	{
		$xmldata = [xml](Get-Content $xmlfile)
		
		$dmarcmail = $xmldata.feedback.report_metadata.email
		$dmarcorgname = $xmldata.feedback.report_metadata.org_name
		$dmarcentrys = $xmldata.feedback.record
		
		foreach ($dmarcentry in $dmarcentrys)
			{
				
				$dmarcdom = $dmarcentry.identifiers.header_from

				$dmarcrows = $dmarcentry.row
				foreach ($dmarcrow in $dmarcrows)
				{
					$dmarcip = $dmarcrow.source_ip
					$dmarcipcount = $dmarcrow.count
					
					[array]$dmarcobject  += new-object PSObject -property @{Organisation=$dmarcorgname;OrgMail=$dmarcmail;Domain=$dmarcdom;IP=$dmarcip;Count=$dmarcipcount}
	
				}
			}
	}

$cells=@("$l_dmarc_orgname","$l_dmarc_orgmailaddr","$l_dmarc_domain","$l_dmarc_ip","$l_dmarc_count")
$dmarcreport += Generate-HTMLTable "$l_dmarc_header3" $cells

if ($dmarcobject)
{
	foreach ($dmarcentry in $dmarcobject)
		{
			$orgname = $dmarcentry.organisation
			$orgmail = $dmarcentry.orgmail
			$count = $dmarcentry.count
			$ip = $dmarcentry.ip
			$domain = $dmarcentry.domain
			$ip
		
			$cells=@("$orgname","$orgmail","$domain","$ip","$count")
			$dmarcreport += New-HTMLTableLine $cells
		}
}
else
	{
		$cells=@("$l_dmarc_noentry")
		$dmarcreport += New-HTMLTableLine $cells
	}


$dmarcreport += End-HTMLTable

$dmarcreport | set-content "$tmpdir\dmarcreport.html"
$dmarcreport | add-content "$tmpdir\report.html"