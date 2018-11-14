function Get-JiraIssue {
    [CmdletBinding()]
    param (
        # JQL query
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]
        $filter,

        # User with access to JIRA
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [pscredential]
        $credential
    )

    $jiraRestApiUrl = "https://jira.q.com/rest/api/latest/"
    $resource = "search?jql="
    $include = "&fields=key"
    $getIssueRequest = $jiraRestApiUrl + $resource + $filter + $include

    $headers = Get-HttpBasicHeader -credential $credential
    $res = Invoke-RestMethod -Uri $getIssueRequest -Headers $headers

    $res.issues.key | Write-Output
}

