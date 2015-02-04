<#
.SYNOPSIS
Adds Jira Group to All Projects on a Server

.DESCRIPTION
This Script will allow you to add a Group to all Projects on a Jira Server.

.NOTES
Id:  vml-jsykes
URL:  https://github.com/vml-jsykes/jira-ps

.EXAMPLE
Add-JiraGroupToAllProjects

.LINK
https://github.com/vml-jsykes/jira-ps
#>


# Library Import
Import-Module .\Jira.psm1

# Functions
Function Get-UsertoAdd {
    $GroupName = Read-Host "What is the name of the Group you wish to add to all projects?"
    Return $Json = "{ ""group"" : [""$GroupName""] }"
}

# Variables
$DevelopersRole = 10001
$UsersRole = 10000


# Main Script Body

# Connect to Jira
#Set-JiraApiBase
#Set-JiraCredentials

$GrouptoAdd = Get-UsertoAdd


#Enumerate all Projects on the server.
$Projects = Get-JiraProjectList

foreach ($Project in $Projects) {
     $ProjectID = $Project.id
     $ProjectKey = $Project.key
     $ProjectName = $Project.name
     Write-Host
     Write-Host "Name: $ProjectName ID: $ProjectID Key: $ProjectKey"
     #Add group to Users
     $Result = Add-JiraGrouptoProject $ProjectKey $UsersRole $GrouptoAdd
     Write-Host $Result
    }