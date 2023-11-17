Get-ADOrganizationalUnit -Filter *|Find-AdmPwdExtendedRights -PipelineVariable OU |ForEach{
$_.ExtendedRightHolders|ForEach{
[pscustomobject]@{
OU=$Ou.ObjectDN
Object = $_
}
}
}
