*** Settings ***
Documentation     Feature: Unbilled summary
...               Scenario: Total PENDING dari /invoices cocok dengan /invoices/unbilled/summary
Resource          ../resources/invoice_api_bdd.resource
Suite Setup       Given Invoice Api Session Is Ready

*** Test Cases ***
Scenario Unbilled Summary Matches Calculated Pending Totals
    [Tags]    bdd    bag3    api
    Given I Am Logged In As Admin
    ${invoices}=    When I Get Invoices List
    ${summary}=    When I Get Unbilled Summary As Object
    Then Unbilled Summary Matches Pending From List    ${invoices}    ${summary}
