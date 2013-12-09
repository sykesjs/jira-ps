Function ConvertTo-SafeUri($uri) {
    Return [System.Uri]::EscapeDataString($uri)
}

Function Set-JiraApiBase {
    Param (
        [Parameter (Mandatory=$True)]
        [string] $jira_api_base
    )

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

Function Invoke-JiraRequest($method, $request) {
    If ($env:JIRA_API_BASE -eq $Null) {
        Write-Error "JIRA API Base has not been set, please run ``Set-JiraApiBase'"
    }
    If ($env:JIRA_CREDENTIALS -eq $Null) {
        Write-Error "No JIRA credentials have been set, please run ``Set-JiraCredentials'"
    }
    Write-Debug "Calling $method $env:JIRA_API_BASE$request with AUTH: Basic $env:JIRA_CREDENTIALS"
    Return Invoke-RestMethod -Uri "${env:JIRA_API_BASE}${request}" -Headers @{"AUTHORIZATION"="Basic $env:JIRA_CREDENTIALS"} -Method $method -ContentType "application/json"
}

# Begin Get Functions
Function Get-JiraIssue($issue) {
    Return Invoke-JiraRequest GET "issue/$(ConvertTo-SafeUri $issue)"
}

Function Get-JiraHistory($issue) {
    Return Invoke-JiraRequest GET "issue/$(ConvertTo-SafeUri $issue)?expand=changelog"
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
# End Get Functions

# Begin Start Functions
Function Start-JiraBackgroundReIndex {
    Return Invoke-JiraRequest POST "reindex"
}
# End Start Functions

Export-ModuleMember -Function Set-JiraApiBase,
                              Set-JiraCredentials,
                              ConvertTo-SafeUri,
                              Invoke-JiraRequest,
                              Get-JiraProjectList,
                              Get-JiraProject,
                              Get-JiraProjectRole,
                              Get-JiraIssue,
                              Get-JiraHistory,
                              Get-JiraSearchResult,
                              Start-JiraBackgroundReIndex