*** Settings ***
Library    SSHLibrary
Resource   api.resource

*** Variables ***
${NETDATA_PATH}
${NETDATA_FQDN}
${IMAGE_URL}        ghcr.io/nethserver/netdata:latest

*** Test Cases ***
Check if netdata is installed correctly
    ${output}  ${rc} =    Execute Command    add-module ${IMAGE_URL} 1
    ...    return_rc=True
    Should Be Equal As Integers    ${rc}  0
    &{output} =    Evaluate    ${output}
    Set Suite Variable    ${module_id}    ${output.module_id}

Check netdata path is configured
    ${ocfg} =   Run task    module/${module_id}/get-configuration    {}
    Set Suite Variable     ${NETDATA_PATH}    ${ocfg['path']}
    Set Suite Variable     ${NETDATA_FQDN}    ${ocfg['fqdn']}
    Should Not Be Empty    ${NETDATA_PATH}
    Should Not Be Empty    ${NETDATA_FQDN}

Check if netdata works as expected
    Wait Until Keyword Succeeds    20 times    3 seconds    Ping netdata

Check if netdata is removed correctly
    ${rc} =    Execute Command    remove-module --no-preserve ${module_id}
    ...    return_rc=True  return_stdout=False
    Should Be Equal As Integers    ${rc}  0

*** Keywords ***
Ping netdata
    ${out}  ${err}  ${rc} =    Execute Command    curl -k -f -H 'Host: ${NETDATA_FQDN}' https://127.0.0.1/${NETDATA_PATH}/
    ...    return_rc=True  return_stdout=True  return_stderr=True
    Should Be Equal As Integers    ${rc}  0
    Should Contain    ${out}    <title>Netdata
