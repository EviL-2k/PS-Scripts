# Unresolvable SID Check 
# If SID's from different domains are used this might produce some false positives.

#clear previous logs
if (Test-Path C:\logs\siderror.txt) {Remove-Item -Path C:\logs\siderror.txt -Verbose}

#check domain name and set it to the sysvol folder
$domainname = (gcim -classname Win32_ComputerSystem).domain

#sysvol location check
if (Test-path C:\Windows\SYSVOL\sysvol\$domainname\Policies) 
    {$pol_path = "C:\Windows\SYSVOL\sysvol\$domainname\Policies"}
else
    {$pol_path = "C:\Windows\SYSVOL_DFSR\sysvol\$domainname\Policies"}

Set-Location $pol_path

#grab all policy GUID
$policy_list = gci $pol_path | where name -like "{*" | select -ExpandProperty name

#parse all GptTmpl files in all policies across domain for Administrator memberships
foreach ($policy in $policy_list) 
    {
        if (test-path "$policy\Machine\microsoft\windows nt\SecEdit\GptTmpl.inf")
            {
                # S-1-5-32-544__Members is the group with admin privleges
                $sidlist = (((get-content "$policy\Machine\microsoft\windows nt\SecEdit\GptTmpl.inf" | select-string "S-1-5-32-544__Members" | Select-Object -First 1 ) -replace "(.*=.)|(NT Service\\)|([aA-zZ]+[0-9]-)|(([aA-zZ]*-[aA-zZ]).*,)|([Aa-zZ]{2,30})|(\*)","")) -replace "(S-1-5-32-544__ =)|(\$)|(,\d{1,2})","" -split ","
                    foreach ($sid in $sidlist) 
                        {
                            if ($sid){
                                try {
                                        $check = Get-ADObject -filter "objectSid -eq '$sid'"
                                        if ($check -eq $null) 
                                            {
                                                $pol = $policy -replace "(\()|(\))"
                                                $polname = (get-gpo -Guid $pol).DisplayName
                                                Write-Output "unresolvable sid found in $polname !!!    Sid = $sid"
                                                $polname | Out-File "C:\logs\siderror.txt" -Append
                                                
                                            } 
                                    }
                                catch 
                                    {
                                                $pol = $policy -replace "(\()|(\))"
                                                $polname = (get-gpo -Guid $pol).DisplayName
                                                Write-Output "error in policy $polname"
                                                $sid
                                    }
                                    }
                        }

            }
        
    }

Write-Host "Final list: " -ForegroundColor Green
Get-Content c:\logs\siderror.txt | sort | Select-Object -Unique
