Install the dependencies using pip.

    ```
    cd azure-python-examples
    pip install -r requirements.txt
    ```

    Retrieve the application ID (a.k.a. client ID),
    authentication key (a.k.a. client secret),
    tenant ID and subscription ID from the Azure portal for use
    in the next step.
    [This document](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-create-service-principal-portal#get-application-id-and-authentication-key)
    describes where to find them (besides the subscription ID,
    which is in the "Overview" section of the "Subscriptions" blade.)

Fill in and export these environment variables into your current shell.

    ```
    export AZURE_TENANT={your tenant id}
    export AZURE_CLIENT_ID={your client id}
    export AZURE_SECRET={your client secret}
    export AZURE_SUBSCRIPTION_ID={your subscription id}
    ```

