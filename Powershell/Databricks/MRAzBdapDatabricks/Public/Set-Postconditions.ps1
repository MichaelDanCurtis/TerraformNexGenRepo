<#
.SYNOPSIS
Create a databricks  cluster with post deployment steps

.DESCRIPTION
Create a databricks  cluster with post deployment steps

.PARAMETER Config

Deploy an AKS cluster with a given configuration




#>
<#
This could be trigger for few post deployment steps as below :

creating clusters for Shared and ETL work spaces

creating cluster secret scope

Creating Workspace AD groups  ?? using SQL wrapper ??
Syncing the users to workspace with AD ( ad group )

Creating cluster policies

#>
function Set-Postconditions {

}