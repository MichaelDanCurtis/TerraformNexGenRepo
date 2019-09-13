# createSubscription
#
# This script expects that the following environment vars are set:
#
# AZURE_TENANT: your Azure Active Directory tenant id or domain
# AZURE_CLIENT_ID: your Azure Active Directory Application Client ID
# AZURE_SECRET: your Azure Active Directory Application Secret
# AZURE_SUBSCRIPTION_ID: your Azure Subscription Id

import os
import traceback
from azure.common.credentials import ServicePrincipalCredentials
from msrestazure.azure_exceptions import CloudError
from msrestazure.azure_configuration import AzureConfiguration
from msrest.service_client import ServiceClient
from msrest.polling import LROPoller
from msrestazure.polling.arm_polling import ARMPolling
from msrest.pipeline import ClientRawResponse
import uuid

SUBSCRIPTION_ID = os.environ['AZURE_SUBSCRIPTION_ID']
ENROLLMENT_ACCOUNT_NAME = "myEnrollmentAccount"

BODY = {
  "offerType": "MS-AZR-0017P",
  "displayName": "Test Ea Azure Sub",
  "owners": [
    {
      "objectId": "??"
    },
    {
      "objectId": "??"
    }
  ],
  "additionalParameters": {
    "customData": {
      "key1": "value1",
      "key2": True
    }
  }
}

API_VERSION = '2018-03-01-preview'

def get_credentials():
    credentials = ServicePrincipalCredentials(
        client_id=os.environ['AZURE_CLIENT_ID'],
        secret=os.environ['AZURE_SECRET'],
        tenant=os.environ['AZURE_TENANT']
    )
    return credentials


def wait_poller(service_client, operation_config, response):
    def get_long_running_output(response):
        return response
    poller = LROPoller(service_client,
                        ClientRawResponse(None, response),
                        get_long_running_output,
                        ARMPolling(30, **operation_config))
    try:
        poller.wait(timeout=600)
        response = poller.result()
    except Exception as exc:
        raise
    return response


def run_example():
    credentials = get_credentials()

    config = AzureConfiguration('https://management.azure.com')
    service_client = ServiceClient(credentials, config)

    query_parameters = {}
    query_parameters['api-version'] = API_VERSION

    header_parameters = {}
    header_parameters['Content-Type'] = 'application/json; charset=utf-8'
    header_parameters['x-ms-client-request-id'] = str(uuid.uuid1())

    operation_config = {}
    request = service_client.post("/providers/Microsoft.Billing/enrollmentAccounts/" + ENROLLMENT_ACCOUNT_NAME + "/providers/Microsoft.Subscription/createSubscription", query_parameters)
    response = service_client.send(request, header_parameters, BODY, **operation_config)

    if response.status_code == 202:
        response = wait_poller(service_client, operation_config, response)
    print(response.text)


if __name__ == "__main__":
    run_example()
