Function ConvertTo-SafeUri($uri) {
    Return [System.Uri]::EscapeDataString($uri)
}

Function Set-JiraApiBase {
    Param (
        [Parameter (Mandatory=$True)]
        [string] $jira_api_base
    )
        
        # This will take the format http://jira.domain.com/rest/api/2/
        $env:JIRA_API_BASE = $jira_api_base
        Write-Host "Jira Api Base Set:"
        Write-Host $env:JIRA_API_BASE
}

Function Set-JiraCredentials {
    Param(
        [Parameter(Mandatory=$True, Position=1)]
        [string]$username,

        [Parameter(Mandatory=$True, Position=2)]
        [System.Security.SecureString]$password
    )

    $env:JIRA_CREDENTIALS = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("${username}:$([System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)))"))
}

Function Invoke-JiraRequest($method, $request, $body) {
    If ($env:JIRA_API_BASE -eq $Null) {
        Write-Error "JIRA API Base has not been set, please run ``Set-JiraApiBase'"
    }
    If ($env:JIRA_CREDENTIALS -eq $Null) {
        Write-Error "No JIRA credentials have been set, please run ``Set-JiraCredentials'"
    }
    Write-Debug "Calling $method $env:JIRA_API_BASE$request with AUTH: Basic $env:JIRA_CREDENTIALS"
    If ($body -eq $Null) {

        Return Invoke-RestMethod -Uri "${env:JIRA_API_BASE}${request}" -Headers @{"AUTHORIZATION"="Basic $env:JIRA_CREDENTIALS"} -Method $method -ContentType "application/json"
    }
    else {
        Return Invoke-RestMethod -Uri "${env:JIRA_API_BASE}${request}" -Headers @{"AUTHORIZATION"="Basic $env:JIRA_CREDENTIALS"} -Method $method -Body $body -ContentType "application/json"
    }
}

# Begin Remove Functions
Function Remove-JiraIssueLink($linkID) {
     Return Invoke-JiraRequest DELETE "issueLink/$(ConvertTo-SafeUri $linkID)"
    }

Function Remove-JiraProject($project) {
     Return Invoke-JiraRequest DELETE "project/$(ConvertTo-SafeUri $project)"
    }


Function Remove-JiraGroupFromRole ($project, $role, $group) {
     Return Invoke-JiraRequest DELETE "project/$(ConvertTo-SafeUri $project)/role/$(ConvertTo-SafeUri $role)?group=$(ConvertTo-SafeUri $group)"
    }
# End Remove Functions


# Begin Get Functions
Function Get-JiraGroup($group) {
    Return Invoke-JiraRequest GET "group?groupname=$(ConvertTo-SafeUri $group)&expand"
}

Function Get-JiraHistory($issue) {
    Return Invoke-JiraRequest GET "issue/$(ConvertTo-SafeUri $issue)?expand=changelog"
}

Function Get-JiraIssue($issue) {
    Return Invoke-JiraRequest GET "issue/$(ConvertTo-SafeUri $issue)"
}

Function Get-JiraIssueAttachment($attachmenturl, $attachmentfilename) {
    Return Invoke-WebRequest -Headers @{"AUTHORIZATION"="Basic $env:JIRA_CREDENTIALS"} $attachmenturl -OutFile $attachmentfilename
}
Function Get-JiraIssueLink($issue, $linkeid) {
    Return Invoke-JiraRequest GET "issue/$(ConvertTo-SafeUri $issue)/issueLink/$(ConvertTo-SafeUri $linkedid)"
}

Function Get-JiraSearchResult($query) {
    Return Invoke-JiraRequest GET "search?jql=$(ConvertTo-SafeUri $query)"
}

Function Get-JiraProjectList {
    # Returns All Projects on a Jira Server
    Return Invoke-JiraRequest GET "project"
}

Function Get-JiraProject($project) {
    # Returns a Particular Project
    Return Invoke-JiraRequest GET "project/$(ConvertTo-SafeUri $project)"
}

Function Get-JiraProjectRole($project, $role) {
    # Returns Users and Groups in a Role in a Jira Project (10000 - Users; 10002 - Administrators; 10001 - Developers)
    Return Invoke-JiraRequest GET "project/$(ConvertTo-SafeUri $project)/role/$(ConvertTo-SafeUri $role)"
}

Function Get-JiraProjectNotificationScheme ($strproject) {
    Return Invoke-JiraRequest GET "project/$(ConvertTo-SafeUri $strproject)/notificationscheme"
}

Function Get-JiraProjectPermissionScheme ($strproject) {
    Return Invoke-JiraRequest GET "project/$(ConvertTo-SafeUri $strproject)/permissionscheme"
}
# End Get Functions

# Begin Start Functions
Function Start-JiraBackgroundReIndex {
    Return Invoke-JiraRequest POST "reindex"
}
# End Start Functions

# Begin Add Functions
Function Add-JiraGrouptoProject($project, $role, $json) {
    # $json should be valid json like: 
    # { "user" : ["admin"] }  
    # or
    # { "group" : ["jira-developers"] }
    Return Invoke-JiraRequest POST "project/$(ConvertTo-SafeUri $project)/role/$(ConvertTo-SafeUri $role)" $json
}

Function Add-JiraAttachment($issue, $file) {
    # This function is much more complex than most, rather than use Invoke-JiraRequest, just using Invoke-RestMethod natively
    # Adding header to prevent XSXF error
    $hashRequestHeader = @{"AUTHORIZATION"="Basic $env:JIRA_CREDENTIALS"; "X-Atlassian-Token"="no-check"}
    $strFieldName = "file"
    $strContentType = "application/octet-stream"

    # Build Multipart Form Content payload
    $FileStream = [System.IO.FileStream]::new($file, [System.IO.FileMode]::Open)
    $FileHeader = [System.Net.Http.Headers.ContentDispositionHeaderValue]::new('form-data')
    $FileHeader.Name = $strFieldName
    $FileHeader.FileName = Split-Path -leaf $file
    $FileContent = [System.Net.Http.StreamContent]::new($FileStream)
    $FileContent.Headers.ContentDisposition = $FileHeader
    $FileContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse($strContentType)

    $MultipartContent = [System.Net.Http.MultipartFormDataContent]::new()
    $MultipartContent.Add($FileContent)

    Return Invoke-RestMethod -Uri "${env:JIRA_API_BASE}issue/$(ConvertTo-SafeUri $issue)/attachments" -Method POST -Headers $hashRequestHeader -Body $MultipartContent
}
# End Add Functions

# Begin Update Functions
Function Update-ProjectPermissionScheme ($strProjectKey,$jsonProject) {
    # $objProject should be a properly formated json e.g.
    # { "permissionScheme": 10500 }
    Return Invoke-JiraRequest PUT "project/$(ConvertTo-SafeUri $strProjectKey)" $jsonProject
}
# End Update Functions

Export-ModuleMember -Function Set-JiraApiBase,
                              Set-JiraCredentials,
                              ConvertTo-SafeUri,
                              Remove-JiraIssueLink,
                              Remove-JiraProject,
                              Remove-JiraGroupFromRole,
                              Invoke-JiraRequest,
                              Add-JiraGrouptoProject,
                              Add-JiraAttachment,
                              Get-JiraGroup,
                              Get-JiraProjectList,
                              Get-JiraProject,
                              Get-JiraProjectRole,
                              Get-JiraProjectNotificationScheme,
                              Get-JiraProjectPermissionScheme,
                              Get-JiraIssue,
                              Get-JiraIssueAttachment,
                              Get-JiraIssueLink,
                              Get-JiraHistory,
                              Get-JiraSearchResult,
                              Start-JiraBackgroundReIndex,
                              Update-ProjectPermissionScheme
