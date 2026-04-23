*** Settings ***
Documentation     Variabel & inisialisasi HTTP session bersama.
Library           RequestsLibrary
Library           Collections
Library           OperatingSystem
Library           String

*** Variables ***
${API_BASE_URL}       http://localhost:8010
${ADMIN_EMAIL}        admin@example.com
${ADMIN_PASSWORD}     password123

*** Keywords ***
Initialize Invoice Api Session
    [Documentation]    Baca API_BASE_URL dari environment jika ada, lalu buat session alias invoice_api.
    ${u}=    Get Environment Variable    API_BASE_URL    ${API_BASE_URL}
    Set Global Variable    ${API_BASE_URL}    ${u}
    Create Session    invoice_api    ${API_BASE_URL}    disable_warnings=1
