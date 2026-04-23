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
    ${pending_total}=    Set Variable    ${0.0}
    FOR    ${inv}    IN    @{invoices}
        ${status}=    Get From Dictionary    ${inv}    status
        IF    '${status}' == 'PENDING'
            ${raw}=    Get From Dictionary    ${inv}    totalAmount    default=${0}
            IF    $raw is None
                ${amt}=    Set Variable    ${0.0}
            ELSE
                ${amt}=    Convert To Number    ${raw}
            END
            ${pending_total}=    Evaluate    ${pending_total} + ${amt}
        END
    END
    ${expected_after_tax}=    Evaluate    ${pending_total} * 1.1
    Should Be Equal As Numbers    ${summary}[totalUnbilled]    ${pending_total}    precision=6
    Should Be Equal As Numbers    ${summary}[unbilledAfterTax]    ${expected_after_tax}    precision=6
    Should Be Equal As Numbers    ${summary}[taxRate]    0.1    precision=6
