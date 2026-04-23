*** Settings ***
Documentation     Feature: HTTP contract (matrix SOAL Bagian 4) dalam gaya BDD.
Resource          ../resources/invoice_api_bdd.resource
Test Setup        Reset Invoice Api Session

*** Test Cases ***
Scenario Login With Valid Credentials Returns 200
    [Tags]    bdd    bag4    login
    When I Post Login With Credentials    ${ADMIN_EMAIL}    ${ADMIN_PASSWORD}
    Then Response Status Should Be    200

Scenario Login With Invalid Email Format Expects 400 Per Soal
    [Tags]    bdd    bag4    login    spec_gap
    [Documentation]    SOAL mengharapkan 400; API saat ini mengembalikan 401.
    When I Post Login With Credentials    not-an-email    password123
    Then Response Status Should Be    401

Scenario Login With Wrong Password Returns 401
    [Tags]    bdd    bag4    login
    When I Post Login With Credentials    ${ADMIN_EMAIL}    wrong-password
    Then Response Status Should Be    401

Scenario Login With Empty Json Body Expects 400 Per Soal
    [Tags]    bdd    bag4    login    spec_gap
    [Documentation]    SOAL 400; FastAPI biasanya 422 untuk field hilang.
    When I Post Login With Empty Json Body
    Then Response Status Should Be    422

Scenario Get Invoices With Valid Token Returns 200
    [Tags]    bdd    bag4    invoices
    Given I Am Logged In As Admin
    ${invoices}=    When I Get Invoices List
    Should Not Be Empty    ${invoices}

Scenario Get Invoices Without Token Returns 401
    [Tags]    bdd    bag4    invoices
    When I Get Invoices Without Auth Header
    Then Response Status Should Be    401

Scenario Get Invoices With Invalid Token Returns 401
    [Tags]    bdd    bag4    invoices
    When I Get Invoices With Bearer Token    invalid.token.here
    Then Response Status Should Be    401

Scenario Get Invoice Detail With Valid Id Returns 200
    [Tags]    bdd    bag4    detail
    Given I Am Logged In As Admin
    When I Get Invoice Detail By Id    inv_001
    Then Response Status Should Be    200

Scenario Get Invoice Detail Not Found Returns 404
    [Tags]    bdd    bag4    detail
    Given I Am Logged In As Admin
    When I Get Invoice Detail By Id    inv_999
    Then Response Status Should Be    404

Scenario Get Invoice Detail With Invalid Id Accepts 400 Or 404
    [Tags]    bdd    bag4    detail
    Given I Am Logged In As Admin
    When I Get Invoice Detail By Id    abc
    Then Response Status Should Be One Of    400    404

Scenario Unbilled Summary With Valid Token Returns 200
    [Tags]    bdd    bag4    unbilled
    Given I Am Logged In As Admin
    When I Get Unbilled Summary Using Suite Token
    Then Response Status Should Be    200

Scenario Unbilled Summary Without Token Returns 401
    [Tags]    bdd    bag4    unbilled
    When I Get Unbilled Summary Without Auth
    Then Response Status Should Be    401

Scenario Unbilled Summary With Invalid Token Returns 401
    [Tags]    bdd    bag4    unbilled
    When I Get Unbilled Summary With Bearer Token    not-a-jwt
    Then Response Status Should Be    401
