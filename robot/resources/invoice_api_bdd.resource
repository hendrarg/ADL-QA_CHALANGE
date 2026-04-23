*** Settings ***
Documentation     Keywords bergaya BDD (Given / When / Then) untuk Invoice API.
Resource          common.resource
Library           ../libraries/InvoiceRobotLibrary.py

*** Keywords ***
# --- Session / auth ---
Invoice Api Session Is Ready
    Initialize Invoice Api Session

I Am Logged In As Admin
    [Documentation]    Given valid credentials -> token disimpan di suite scope.
    ${body}=    Create Dictionary    email=${ADMIN_EMAIL}    password=${ADMIN_PASSWORD}
    ${hdr}=    Create Dictionary    Content-Type=application/json
    ${r}=    POST On Session    invoice_api    /users/login    json=${body}    headers=${hdr}    expected_status=any
    Should Be Equal As Integers    ${r.status_code}    200    Login gagal: ${r.text}
    ${data}=    Set Variable    ${r.json()}
    ${token}=    Get From Dictionary    ${data}    token
    Set Suite Variable    ${AUTH_TOKEN}    ${token}

Reset Invoice Api Session
    [Documentation]    Hapus session agar skenario matrix independen.
    Delete All Sessions
    Initialize Invoice Api Session

# --- When (aksi) ---
I Get Invoices List
    [Documentation]    Mengembalikan list Python hasil JSON GET /invoices (retry jika 500 acak).
    ${items}=    Wait Until Keyword Succeeds    8x    250ms    Fetch Invoices List Successful
    RETURN    ${items}

Fetch Invoices List Successful
    ${hdr}=    Create Dictionary    Authorization=Bearer ${AUTH_TOKEN}
    ${r}=    GET On Session    invoice_api    /invoices    headers=${hdr}    expected_status=any
    Should Be Equal As Integers    ${r.status_code}    200    ${r.text}
    ${items}=    Set Variable    ${r.json()}
    RETURN    ${items}
I Get Invoice Detail As Object
    [Arguments]    ${invoice_id}
    ${obj}=    Wait Until Keyword Succeeds    8x    250ms    Fetch Invoice Detail Successful    ${invoice_id}
    RETURN    ${obj}

Fetch Invoice Detail Successful
    [Arguments]    ${invoice_id}
    ${hdr}=    Create Dictionary    Authorization=Bearer ${AUTH_TOKEN}
    ${r}=    GET On Session    invoice_api    /invoices/${invoice_id}    headers=${hdr}    expected_status=any
    Should Be Equal As Integers    ${r.status_code}    200    ${r.text}
    ${obj}=    Set Variable    ${r.json()}
    RETURN    ${obj}

I Get Unbilled Summary As Object
    ${obj}=    Wait Until Keyword Succeeds    8x    250ms    Fetch Unbilled Summary Successful
    RETURN    ${obj}

Fetch Unbilled Summary Successful
    ${hdr}=    Create Dictionary    Authorization=Bearer ${AUTH_TOKEN}
    ${r}=    GET On Session    invoice_api    /invoices/unbilled/summary    headers=${hdr}    expected_status=any
    Should Be Equal As Integers    ${r.status_code}    200    ${r.text}
    ${obj}=    Set Variable    ${r.json()}
    RETURN    ${obj}

I Post Login With Credentials
    [Arguments]    ${email}    ${password}
    ${body}=    Create Dictionary    email=${email}    password=${password}
    ${hdr}=    Create Dictionary    Content-Type=application/json
    ${r}=    POST On Session    invoice_api    /users/login    json=${body}    headers=${hdr}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${r}

I Post Login With Empty Json Body
    ${hdr}=    Create Dictionary    Content-Type=application/json
    ${body}=    Create Dictionary
    ${r}=    POST On Session    invoice_api    /users/login    json=${body}    headers=${hdr}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${r}

I Get Invoices Without Auth Header
    ${r}=    GET On Session    invoice_api    /invoices    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${r}

I Get Invoices With Bearer Token
    [Arguments]    ${token_value}
    ${hdr}=    Create Dictionary    Authorization=Bearer ${token_value}
    ${r}=    GET On Session    invoice_api    /invoices    headers=${hdr}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${r}

I Get Invoice Detail By Id
    [Arguments]    ${invoice_id}
    ${hdr}=    Create Dictionary    Authorization=Bearer ${AUTH_TOKEN}
    Wait Until Keyword Succeeds    8x    250ms    Store Detail Response Skipping Server 500    ${invoice_id}    ${hdr}

Store Detail Response Skipping Server 500
    [Arguments]    ${invoice_id}    ${hdr}
    ${r}=    GET On Session    invoice_api    /invoices/${invoice_id}    headers=${hdr}    expected_status=any
    Should Not Be Equal As Integers    ${r.status_code}    500
    Set Test Variable    ${LAST_RESPONSE}    ${r}

I Get Unbilled Summary Without Auth
    ${r}=    GET On Session    invoice_api    /invoices/unbilled/summary    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${r}

I Get Unbilled Summary With Bearer Token
    [Arguments]    ${token_value}
    ${hdr}=    Create Dictionary    Authorization=Bearer ${token_value}
    ${r}=    GET On Session    invoice_api    /invoices/unbilled/summary    headers=${hdr}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${r}

I Get Unbilled Summary Using Suite Token
    [Documentation]    GET summary dengan Bearer ${AUTH_TOKEN} (tanpa assert; untuk matrix).
    ${hdr}=    Create Dictionary    Authorization=Bearer ${AUTH_TOKEN}
    ${r}=    GET On Session    invoice_api    /invoices/unbilled/summary    headers=${hdr}    expected_status=any
    Set Test Variable    ${LAST_RESPONSE}    ${r}

# --- Then (assert) ---
Response Status Should Be
    [Arguments]    ${expected}
    Should Be Equal As Integers    ${LAST_RESPONSE.status_code}    ${expected}
    ...    msg=expected status ${expected} got ${LAST_RESPONSE.status_code}: ${LAST_RESPONSE.text}

Response Status Should Be One Of
    [Arguments]    ${c1}    ${c2}
    ${actual}=    Convert To Integer    ${LAST_RESPONSE.status_code}
    ${v1}=    Convert To Integer    ${c1}
    ${v2}=    Convert To Integer    ${c2}
    ${match}=    Evaluate    ${actual} == ${v1} or ${actual} == ${v2}
    Should Be True    ${match}
    ...    msg=expected one of ${v1}|${v2} got ${actual}: ${LAST_RESPONSE.text}

Every List Invoice Matches Its Detail
    [Arguments]    ${invoices}
    FOR    ${inv}    IN    @{invoices}
        ${iid}=    Get From Dictionary    ${inv}    id
        ${detail}=    When I Get Invoice Detail As Object    ${iid}
        Compare Invoice List Item To Detail    ${inv}    ${detail}
    END

Unbilled Summary Matches Pending From List
    [Arguments]    ${invoices}    ${summary}
    Unbilled Summary Should Match Pending Calculation    ${invoices}    ${summary}
