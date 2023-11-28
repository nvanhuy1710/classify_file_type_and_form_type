*** Settings ***
Library         DOP.RPA.ProcessArgument
Library         DOP.RPA.Asset
Library         DOP.RPA.Log
Library         OperatingSystem
Library         libraries/dop-custom-library.py

*** Variables ***
${INVOICE_FILE}=    ${None}
${EXTRACT_FORM_KEY}=    ${None}
${STATUS_EXTRACT_FORM_TYPE}=    ${False}

*** Tasks ***
Get ProcessArgument
    ${invoiceFilePathArg}=    Get In Arg    invoice_file_path
    Set Global Variable    ${INVOICE_FILE}    ${invoiceFilePathArg}[value]

*** Tasks ***
Detect File Type And Form Key
    FOR    ${counter}    IN RANGE    0    1
        ${isExcelFile}=    Check File Type    ${INVOICE_FILE}    xlsx
        ${isPdfFile}=    Check File Type    ${INVOICE_FILE}    pdf
        ${isPngFile}=    Check File Type    ${INVOICE_FILE}    png
        ${isJPEGFile}=    Check File Type    ${INVOICE_FILE}    JPEG
        ${isJpgFile}=    Check File Type    ${INVOICE_FILE}    jpg

        IF    ${isExcelFile} == ${True}
            ${isReadFormKeyDonBrock}=    Run Keyword And Ignore Error    Read File Excel Form Key Don Brock    ${INVOICE_FILE}
            Log To Console    message
            IF    "${isReadFormKeyDonBrock}[0]" == "PASS"
                Set Global Variable    ${EXTRACT_FORM_KEY}    form_key_don_brock
                Set Global Variable    ${STATUS_EXTRACT_FORM_TYPE}    ${True}
                Exit For Loop
            END
        END
    END

*** Tasks ***
Set Out ProcessArgument
    Set Out Arg    extract_form_key    ${EXTRACT_FORM_KEY}
    Set Out Arg    status_extract_form_type    ${STATUS_EXTRACT_FORM_TYPE}

*** Keywords ***
Check File Type
    [Arguments]    ${file_path}    ${expected_extension}
    ${actual_extension}    Evaluate    "${file_path}".split('.')[-1]
    IF    "${actual_extension}" == "${expected_extension}"
        Return From Keyword    ${True}
    ELSE
        Return From Keyword    ${False}
    END
