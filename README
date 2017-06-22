# JIRA PowerShell Toolkit
---

**Requires PowerShell 4.0**

This is pretty rough at the moment and offers the bare minimum to be able to
construct PowerShell scripts that can access JIRA in a convenient manner.

# Usage
## Importing the Powershell module
You can use the toolkit in an interactive manner by importing the module to your
current environment:

    cd .\jira
    Import-Module .\Jira.psm1

## Setting the API Base
Set your JIRA Api Base:

    Set-JiraApiBase

## Setting your Jira Credentials
Set your JIRA credentials but note that these are insecurely stored in the Windows
Environment in base64 encoded form:

    Set-JiraCredentials

    cmdlet Set-JiraCredentials at command pipeline position 1
    Supply values for the following parameters:
    username: first.last
    password:

## Examples
Now you can use the provided Get-JiraIssue function:

    Get-JiraIssue KEY-250



Or the Get-JiraSearchResult function to provide a quesry in JQL:

    Get-JiraSearchResult "id = KEY-250"
