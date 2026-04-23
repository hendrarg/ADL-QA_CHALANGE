*** Settings ***
Documentation     Feature: Invoice list vs detail
...               Scenario: Setiap baris GET /invoices harus konsisten dengan GET /invoices/{id}
Resource          ../resources/invoice_api_bdd.resource
Suite Setup       Given Invoice Api Session Is Ready

*** Test Cases ***
Scenario Each Invoice In List Matches Its Detail Endpoint
    [Tags]    bdd    bag2    api
    Given I Am Logged In As Admin
    ${invoices}=    When I Get Invoices List
    Then Every List Invoice Matches Its Detail    ${invoices}
