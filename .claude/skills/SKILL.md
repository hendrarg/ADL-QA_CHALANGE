---
name: automation-robot-framework
description: >
  Skill untuk test automation menggunakan Robot Framework (Python).
  Gunakan skill ini ketika user bekerja di project Robot Framework — membuat test case,
  resource files (POM equivalent), keyword libraries, API test dengan RequestsLibrary,
  atau bertanya tentang best practices Robot Framework. Trigger pada: "robot framework",
  "buat robot test", "buat keyword", "resource file", "robot POM", "RequestsLibrary",
  "SeleniumLibrary", "Browser library", "robot API test", "buatkan test robot",
  "robot .robot", "pabot", "robot tags".
---

# Robot Framework Automation Skill

## Core Principles

1. **Resource file = POM** — locator dan keyword aksi di resource file, bukan di test
2. **Locator di Variables section** — semua selector di atas, tidak inline di keyword
3. **Stable selectors** — `data-testid` > `aria` > `id` > CSS > XPath
4. **Tidak pernah `Sleep`** — pakai `Wait Until` keywords bawaan library
5. **Login via API** — setup session lewat RequestsLibrary di Suite Setup
6. **Tags wajib** — setiap test punya tag: `smoke`, `regression`, `api`, `negative`, dll
7. **Variables file** — baseURL, credentials dari env variable atau variables.py

---

## Project Structure

```
project-root/
├── robot.yaml               # Entry point (pabot/robot config)
├── config/
│   └── variables.py         # Environment variables
├── resources/
│   ├── common.resource      # Import semua shared resources
│   ├── pages/               # Page Object (resource files)
│   │   ├── base_page.resource
│   │   ├── login_page.resource
│   │   └── dashboard_page.resource
│   ├── components/          # Reusable UI components
│   │   └── navbar.resource
│   └── api/                 # API keywords
│       ├── auth_api.resource
│       └── users_api.resource
├── tests/
│   ├── web/
│   │   └── login_tests.robot
│   └── api/
│       └── users_api_tests.robot
├── libraries/               # Custom Python keywords
│   └── CustomHelper.py
└── results/                 # Output (gitignore)
```

---

## robot.yaml

```yaml
command:
  - python
  - -m
  - pabot
  - --processes
  - "4"
  - --outputdir
  - results
  - --variablefile
  - config/variables.py
  - --variable
  - BASE_URL:%{BASE_URL:http://localhost:3000}
  - --variable
  - HEADLESS:%{HEADLESS:True}
  - tests/
```

---

## variables.py

```python
# config/variables.py
import os

BASE_URL      = os.environ.get('BASE_URL', 'http://localhost:3000')
API_URL       = os.environ.get('API_URL', 'http://localhost:3000/api')
TEST_EMAIL    = os.environ.get('TEST_EMAIL', '')
TEST_PASSWORD = os.environ.get('TEST_PASSWORD', '')
ADMIN_EMAIL   = os.environ.get('ADMIN_EMAIL', '')
ADMIN_PASSWORD= os.environ.get('ADMIN_PASSWORD', '')
HEADLESS      = os.environ.get('HEADLESS', 'True') == 'True'
BROWSER       = os.environ.get('BROWSER', 'chromium')
```

---

## Base Page Resource

```robotframework
# resources/pages/base_page.resource
*** Settings ***
Library    Browser

*** Keywords ***
Wait For Page Load
    Wait For Load State    networkidle

Navigate To
    [Arguments]    ${path}
    Go To          ${BASE_URL}${path}
    Wait For Page Load

Take Screenshot On Failure
    Take Screenshot    filename=failure-{index}

Element Should Be Visible
    [Arguments]    ${selector}
    Get Element States    ${selector}    validate    visible
```

---

## Login Page Resource (POM)

```robotframework
# resources/pages/login_page.resource
*** Settings ***
Resource    base_page.resource

*** Variables ***
# Semua locator di sini — tidak inline di keyword
${EMAIL_INPUT}      [data-testid="email-input"]
${PASSWORD_INPUT}   [data-testid="password-input"]
${SUBMIT_BUTTON}    [data-testid="login-submit"]
${ERROR_MESSAGE}    [data-testid="error-message"]

*** Keywords ***
Open Login Page
    Navigate To    /login

Fill Email
    [Arguments]    ${email}
    Fill Text    ${EMAIL_INPUT}    ${email}

Fill Password
    [Arguments]    ${password}
    Fill Secret    ${PASSWORD_INPUT}    ${password}

Submit Login Form
    Click    ${SUBMIT_BUTTON}

Login As User
    [Arguments]    ${email}    ${password}
    Fill Email       ${email}
    Fill Password    ${password}
    Submit Login Form

Error Message Should Contain
    [Arguments]    ${expected_text}
    Get Text    ${ERROR_MESSAGE}    ==    ${expected_text}

Login Page Should Be Visible
    Get Element States    ${SUBMIT_BUTTON}    validate    visible
```

---

## Web Test

```robotframework
# tests/web/login_tests.robot
*** Settings ***
Resource            ../../resources/pages/login_page.resource
Resource            ../../resources/pages/dashboard_page.resource
Suite Setup         Open Browser Session
Suite Teardown      Close Browser
Test Setup          Open Login Page
Test Teardown       Run Keyword If Test Failed    Take Screenshot On Failure

*** Test Cases ***
Should Redirect To Dashboard When Valid Credentials Provided
    [Tags]    smoke    auth    regression
    Login As User    ${TEST_EMAIL}    ${TEST_PASSWORD}
    Dashboard Page Should Be Visible
    Get Url    ==    ${BASE_URL}/dashboard

Should Show Error When Invalid Password Provided
    [Tags]    auth    negative
    Login As User    ${TEST_EMAIL}    wrong-password
    Error Message Should Contain    Invalid credentials

Should Show Validation When Email Field Empty
    [Tags]    auth    validation
    Submit Login Form
    Get Text    [data-testid="email-error"]    ==    Email is required

*** Keywords ***
Open Browser Session
    New Browser    ${BROWSER}    headless=${HEADLESS}
    New Context    baseURL=${BASE_URL}
    New Page       ${BASE_URL}
```

---

## Auth API Resource

```robotframework
# resources/api/auth_api.resource
*** Settings ***
Library    RequestsLibrary
Library    Collections

*** Keywords ***
Get Auth Token
    [Arguments]    ${email}=${TEST_EMAIL}    ${password}=${TEST_PASSWORD}
    Create Session    auth_session    ${API_URL}
    ${payload}=    Create Dictionary
    ...    email=${email}
    ...    password=${password}
    ${response}=    POST On Session    auth_session    /auth/login
    ...    json=${payload}
    Should Be Equal As Integers    ${response.status_code}    200
    ${token}=    Set Variable    ${response.json()}[token]
    RETURN    ${token}

Create Authenticated Session
    [Arguments]    ${token}
    ${headers}=    Create Dictionary
    ...    Content-Type=application/json
    ...    Authorization=Bearer ${token}
    Create Session    api    ${API_URL}    headers=${headers}
```

---

## Users API Resource

```robotframework
# resources/api/users_api.resource
*** Settings ***
Resource    auth_api.resource

*** Keywords ***
GET Users
    ${response}=    GET On Session    api    /users
    RETURN    ${response}

POST Create User
    [Arguments]    ${name}    ${email}    ${role}=viewer
    ${payload}=    Create Dictionary
    ...    name=${name}
    ...    email=${email}
    ...    role=${role}
    ${response}=    POST On Session    api    /users    json=${payload}
    RETURN    ${response}

GET User By Id
    [Arguments]    ${user_id}
    ${response}=    GET On Session    api    /users/${user_id}
    ...    expected_status=any
    RETURN    ${response}

DELETE User
    [Arguments]    ${user_id}
    ${response}=    DELETE On Session    api    /users/${user_id}
    RETURN    ${response}

Generate Unique Email
    ${timestamp}=    Get Time    epoch
    ${email}=    Set Variable    test-${timestamp}@example.com
    RETURN    ${email}
```

---

## API Test

```robotframework
# tests/api/users_api_tests.robot
*** Settings ***
Resource            ../../resources/api/users_api.resource
Suite Setup         Setup Authenticated Session
Suite Teardown      Delete Session    api

*** Variables ***
${CREATED_USER_ID}    ${EMPTY}

*** Test Cases ***
Should Return User List With Status 200
    [Tags]    api    users    smoke
    ${response}=    GET Users
    Should Be Equal As Integers    ${response.status_code}    200
    ${users}=    Set Variable    ${response.json()}[data]
    Should Not Be Empty    ${users}

Should Create User And Return 201
    [Tags]    api    users    regression
    ${email}=    Generate Unique Email
    ${response}=    POST Create User    name=Test User    email=${email}
    Should Be Equal As Integers    ${response.status_code}    201
    ${body}=    Set Variable    ${response.json()}
    Should Not Be Empty    ${body}[id]
    Set Suite Variable    ${CREATED_USER_ID}    ${body}[id]

Should Return 404 When User Not Found
    [Tags]    api    users    negative
    ${response}=    GET User By Id    99999
    Should Be Equal As Integers    ${response.status_code}    404

Should Return 401 When No Token Provided
    [Tags]    api    auth    negative
    Create Session    no_auth    ${API_URL}
    ${response}=    GET On Session    no_auth    /users
    ...    expected_status=any
    Should Be Equal As Integers    ${response.status_code}    401

*** Keywords ***
Setup Authenticated Session
    ${token}=    Get Auth Token
    Create Authenticated Session    ${token}
```

---

## Tags Strategy

```
smoke       — tes kritis, harus lulus sebelum deploy
regression  — full suite
sanity      — quick check setelah deploy ke env
api         — API tests only
web         — UI tests only
negative    — negative / error scenarios
skip        — skip sementara (tambahkan komentar kenapa)
```

```bash
# Run per tag
robot --include smoke tests/
robot --include api --exclude skip tests/
pabot --processes 4 --include regression tests/
```

---

## Common Patterns

### Kondisional Cleanup
```robotframework
Test Teardown    Run Keywords
...    Run Keyword If    '${CREATED_USER_ID}' != '${EMPTY}'
...        DELETE User    ${CREATED_USER_ID}
...    AND    Run Keyword If Test Failed    Take Screenshot On Failure
```

### Data-Driven Test
```robotframework
*** Test Cases ***
Login Validation
    [Tags]           validation
    [Template]       Login Should Fail With Message
    invalid@x.com    wrong     Invalid credentials
    ${EMPTY}         pass123   Email is required
    user@test.com    ${EMPTY}  Password is required

*** Keywords ***
Login Should Fail With Message
    [Arguments]    ${email}    ${password}    ${expected_error}
    Open Login Page
    Login As User    ${email}    ${password}
    Error Message Should Contain    ${expected_error}
```
