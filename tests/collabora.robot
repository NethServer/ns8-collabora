*** Settings ***
Library    SSHLibrary
Resource    api.resource

*** Keywords ***
Retry test
    [Arguments]    ${keyword}
    Wait Until Keyword Succeeds    60 seconds    1 second    ${keyword}

Backend URL is reachable
    ${rc} =    Execute Command    curl -f ${backend_url}
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0


*** Test Cases ***
Check if collabora is installed correctly
    ${output}  ${rc} =    Execute Command    add-module ${IMAGE_URL} 1
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}  0
    &{output} =    Evaluate    ${output}
    Set Suite Variable    ${module_id}    ${output.module_id}

Check if collabora can be configured
    ${rc} =    Execute Command    api-cli run module/${module_id}/configure-module --data '{"host": "collabora.nethserver.org","http2https": true,"lets_encrypt": true,"admin_password": "password"}'
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

Retrieve collabora backend URL
    # Assuming the test is running on a single node cluster
    ${response} =    Run task     module/traefik1/get-route    {"instance":"${module_id}"}
    Set Suite Variable    ${backend_url}    ${response['url']}

Check if collabora works as expected
    Retry test    Backend URL is reachable

Check if collabora is removed correctly
    ${rc} =    Execute Command    remove-module --no-preserve ${module_id}
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0