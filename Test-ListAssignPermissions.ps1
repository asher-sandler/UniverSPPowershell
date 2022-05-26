function Set-PermissionsOnList()
{
    param(
        [Parameter(Mandatory=$true)][string]$url,
        [Parameter(Mandatory=$true)][System.Net.NetworkCredential]$credentials,
        [Parameter(Mandatory=$true)][string]$listName,
        [Parameter(Mandatory=$true)][string]$GroupName,
        [Parameter(Mandatory=$true)][string]$Roletype
    )
    begin{
        try
        {
            #get Client Object
            $context = New-Object Microsoft.SharePoint.Client.ClientContext($url)
            $context.Credentials = $credentials
            $web = $context.Web 
            $context.Load($web) 
            $context.ExecuteQuery()

            # get root web
            $RootWeb = $context.Site.RootWeb
            $context.Load($RootWeb) 
            $context.ExecuteQuery()

            # get list
            #$lists = $web.Lists
            #$context.Load($lists)
            #$context.ExecuteQuery()
            #$list = $lists | where {$_.Title -eq $listName}

            #Retrieve List
            $List = $context.Web.Lists.GetByTitle($listName)
            $context.Load($List)
            $context.ExecuteQuery()

            $list.BreakRoleInheritance($true, $false)
            $roleType = [Microsoft.SharePoint.Client.RoleType]$Roletype

            # get group/principal
            $groups = $web.SiteGroups
            $context.Load($groups)
            $context.ExecuteQuery()
            $group = $groups | where {$_.Title -eq $RootWeb.Title + " " + $GroupName}

            # get role definition
            $roleDefs = $web.RoleDefinitions
            $context.Load($roleDefs)
            $context.ExecuteQuery()
            $roleDef = $roleDefs | where {$_.RoleTypeKind -eq $Roletype}
        }
        catch
        {
            Write-Host "Error while getting context. Error -->> "  + $_.Exception.Message -ForegroundColor Red
        }
    }
    process{
        try
        {
            # Assign permissions
            $collRdb = new-object Microsoft.SharePoint.Client.RoleDefinitionBindingCollection($context)
            $collRdb.Add($roleDef)
            $collRoleAssign = $list.RoleAssignments
            $rollAssign = $collRoleAssign.Add($group, $collRdb)
            $context.ExecuteQuery()

            Write-Host "Permissions assigned successfully." -ForegroundColor Green
        }
        catch
        {
            Write-Host "Error while setting permissions. Error -->> "  + $_.Exception.Message -ForegroundColor Red
        }
    }
    end{
    $context.Dispose()
    }
}
$credentials = Get-Credential
$ListTitle = "Your List Name"
Set-PermissionsOnList "http://YourSite" $credentials $ListTitle "Students" "Read"
