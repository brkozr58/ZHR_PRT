FUNCTION zhr_prt_user_operation.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_OPER) TYPE  CHAR10 DEFAULT 'true'
*"     VALUE(IS_PERS) TYPE  ZHR_PRT_DDL001
*"  EXPORTING
*"     VALUE(ERROR) TYPE  STRING
*"     VALUE(MESSAGE) TYPE  STRING
*"  CHANGING
*"     VALUE(CV_TOKEN) TYPE  STRING OPTIONAL
*"----------------------------------------------------------------------
  DATA : lv_error TYPE string .
  DATA : lv_message TYPE string .
  DATA : lv_url TYPE text150.

*  initial_services.

  IF sy-sysid NE 'IHP'.
    lv_url = 'https://ikportaltest.icdas.com.tr/api/v1/auth/login'.
  ELSE.
    lv_url = 'https://ikportal.icdas.com.tr/api/v1/auth/login'.
  ENDIF.
  CLEAR lv_error.
  IF cv_token IS INITIAL .
    PERFORM portal_logon USING '0' 'Icdas2025*'
                               lv_url
                      CHANGING cv_token
                               lv_error
                               lv_message.
  ENDIF.

  error = lv_error.
  message = lv_message.
  CHECK lv_error IS INITIAL .
  IF sy-sysid NE 'IHP'.
    lv_url = 'https://ikportaltest.icdas.com.tr/api/v1/users/transfer-from-sap'.
  ELSE.
    lv_url = 'https://ikportal.icdas.com.tr/api/v1/users/transfer-from-sap'.
  ENDIF.
  PERFORM user_oper USING cv_token
                          lv_url
                          is_pers
                          i_oper
                 CHANGING lv_error
                           lv_message.

  error = lv_error.
  message = lv_message.

ENDFUNCTION.
