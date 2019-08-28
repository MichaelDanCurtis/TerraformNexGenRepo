We may want to use a service principal other than the service connection’s, then we need to wire it up. (and eventually not at all) The four environment variables required for terraform (ARM_SUBSCRIPTION_ID, ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID) are documented : https://www.terraform.io/docs/providers/azurerm/auth/service_principal_client_secret.html#configuring-the-service-principal-in-terraform

Eventuially this part of the code has been automated but was backed out because of the efffort to get it to work

For our project terraform needs to have a shared state.  Therfore we use an storage account. I need to build a Tform to create the storage or maybe a Py script to do it but for now you need to set it up previosuly.

Please set these as env vars on the azure cli task, and use them in the script for terraform init, and terraform plan.
    export ARM_ACCESS_KEY=$(az storage account keys list -n ${ARM_STORAGE_ACCOUNT_NAME} --query="[0].value" -o tsv)

This has to be set using the az cli. This is required for the terraform azure remote state backend which we will define later. By leveraging the already authenticated cli (from the AzCli task) to set the env variable, we have one less environment variable/password for us to worry about passing around and needing set. This is also nice if the storage account keys get rotated every so often so it keep the build dry... frankly it's not terribly nessasary, but yanking it out causes more trouble than it was worth, and its needed for the Aplha 1 