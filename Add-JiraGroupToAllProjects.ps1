<#
vim: syntax=ps1:ts=3
#>

<#
.SYNOPSIS
Adds Jira Group to All Projects on a Server

.DESCRIPTION
This Script will allow you to add a Group to all Projects on a Jira Server.

.NOTES
$Id:  $
$URL:  $

.EXAMPLE
Add-JiraGroupToProjects

.LINK
https://github.com/MajorManUMan/jira-ps
#>


# Library Import

# Functions

# Constants

# Variables


# Main Script Body

# Connect to Jira
#Set-JiraApiBase
#Set-JiraCredentials

#Check UserGroup

#Enumerate all Projects on the server.
$Projects = Get-JiraProjectList

foreach ($Project in $Projects) {
     Write-Host $Project.Name $Project.id
     $ProjectID = $Project.id
     $JsonProjectRole = Get-JiraProjectRole $ProjectID 10000
     Write-Host $JsonProjectRole.actor
    }
