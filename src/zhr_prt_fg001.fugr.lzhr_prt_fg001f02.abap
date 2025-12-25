*----------------------------------------------------------------------*
***INCLUDE LZHR_PRT_FG001F02.
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Form portal_logon
*&---------------------------------------------------------------------*
  FORM portal_logon  USING    pv_user
                              pv_password
                              pv_url
                     CHANGING cv_token
                              cv_error
                              cv_message.

    DATA : BEGIN OF ls_data ,
             token       TYPE string,
             personnelno TYPE string,
             fullname    TYPE string,
             email       TYPE string,
             expiresat   TYPE string,
           END OF ls_data,
           BEGIN OF ls_rest ,
             success   TYPE string,
             message   TYPE string,
             data      LIKE ls_data,
             errors    TYPE TABLE OF string,
             timestamp TYPE string,
           END OF ls_rest,
           lv_user   TYPE string,
           lv_pswd   TYPE string,
           lt_return TYPE TABLE OF bapiret2.

    initial_services.

    TRY.
        CALL METHOD cl_http_client=>create_by_url
          EXPORTING
            url                = pv_url "wl_url
          IMPORTING
            client             = w_http_client
          EXCEPTIONS
            argument_not_found = 1
            plugin_not_active  = 2
            internal_error     = 3
            OTHERS             = 4.

        set_header_field  :'~request_method'  'POST' ,
                           '~server_protocol' 'HTTP/1.1' ,
                           'Content-Type'     'application/json' ,
                           'Accept'           'Encoding: gzip,deflate' ,
                           'Host'             'ikportaltest.icdas.com.tr'.
        lv_user = '"personnelNo": "' && pv_user     && '",'.
        lv_pswd = '"password": "'    && pv_password && '"' .

        new_cdata: '{',
                      lv_user,
                      lv_pswd,
                   '}'.
        set_cdata.
        send.
        receive_data.
        get_status.
        get_cdata.


        /ui2/cl_json=>deserialize(
          EXPORTING
            json             = w_result
          CHANGING
            data             = ls_rest
        ).

        IF ls_rest-success EQ 'X'.
          cv_token = ls_rest-data-token.
        ELSE.
          READ TABLE ls_rest-errors INTO DATA(ls_error) INDEX 1 .
          cv_error = 'E'.
          cv_message = ls_error.
        ENDIF.

        w_http_client->close( ).

      CATCH cx_root INTO DATA(lx_exception).
        DATA(error) =  lx_exception->get_text( ).
        cv_error = CONV #( error ) .
    ENDTRY.

  ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_oper
*&---------------------------------------------------------------------*
  FORM user_oper  USING    pv_token
                           pv_url
                           ps_pers STRUCTURE zhr_prt_ddl001
                           pv_oper
                  CHANGING cv_error
                           cv_message.

    DATA : lv_rols TYPE text1000 .

    DATA : BEGIN OF ls_errors ,
             personnelno      TYPE string,
             errormessage     TYPE string,
             validationerrors TYPE TABLE OF string,
           END OF ls_errors,
           BEGIN OF ls_data ,
             processedusers    TYPE string,
             id                TYPE string,
             personnelno       TYPE string,
             email             TYPE string,
             applicationuserid TYPE string,
             iscreated         TYPE string,
             errors            LIKE TABLE OF ls_errors,
           END OF ls_data,
           BEGIN OF ls_rest ,
             success   TYPE string,
             message   TYPE string,
             data      LIKE ls_data,
             errors    TYPE TABLE OF string,
             timestamp TYPE string,
           END OF ls_rest,
           lv_aut TYPE string.
    DATA : et_persons TYPE  zhr_prt_tt022 .
    DATA : lt_rolls TYPE TABLE OF  zhr_prt_t008 .
    CALL FUNCTION 'ZHR_PRT_FG001_20'
      EXPORTING
        i_pernr    = ps_pers-pernr
        i_datum    = sy-datum
      IMPORTING
        et_persons = et_persons.
    IF et_persons[] IS NOT INITIAL .
      SELECT * FROM zhr_prt_t008 INTO TABLE lt_rolls
        FOR ALL ENTRIES IN  et_persons
          WHERE aptyp EQ et_persons-aptyp
            AND head  EQ et_persons-head.
      LOOP AT lt_rolls INTO DATA(ls_rolls) .
        IF sy-tabix EQ 1 .
          pv_oper = ls_rolls-zzrol.
        ELSE .
          CONCATENATE pv_oper ls_rolls-zzrol INTO pv_oper SEPARATED BY ','.
        ENDIF.
      ENDLOOP.
    ENDIF.



    CONCATENATE 'Bearer' pv_token INTO lv_aut SEPARATED BY space ..

    CLEAR : w_result        ,
            emptybuffer     ,
            cdata           ,
            http_status_code,
            status_text      .

    TRY.
        CALL METHOD cl_http_client=>create_by_url
          EXPORTING
            url                = pv_url
          IMPORTING
            client             = w_http_client
          EXCEPTIONS
            argument_not_found = 1
            plugin_not_active  = 2
            internal_error     = 3
            OTHERS             = 4.

        set_header_field  :'~request_method'  'POST' ,
                           '~server_protocol' 'HTTP/1.1' ,
                           'Content-Type'     'application/json' ,
                           'Accept'           'Encoding: gzip,deflate' ,
                           'Host'             'ikportaltest.icdas.com.tr'.
        CONCATENATE
          '{'
            '"users" : ['
               '{'
                  '"personnelNo" : "' ps_pers-pernr '",'
                  '"firstName" : "'   ps_pers-vorna '",'
                  '"lastName" : "'    ps_pers-nachn '",'
                  '"email" : "'       ps_pers-zemail '",'
                  '"phoneNumber" : "' ps_pers-cell   '",'
                  '"isCreatePortalUser" : ' pv_oper '",'
                  '"roleNames" : ' lv_rols
               '}'
            ']'
         '}' INTO  cdata.

        set_header_field : 'Authorization'  lv_aut,
                           'Content-Type' 'application/json'.
        set_cdata.
        send.
        receive_data.
        get_status.
        get_cdata.

        /ui2/cl_json=>deserialize(
          EXPORTING
            json             = w_result
          CHANGING
            data             = ls_rest  ).
        IF ls_rest-success IS INITIAL .

          READ TABLE ls_rest-data-errors INTO DATA(ls_error) INDEX 1 .
          IF sy-subrc NE 0.
            cv_error = 'E'.
            cv_message = ls_rest-message.
          ELSE.
            IF ls_error-errormessage IS NOT INITIAL .
              cv_message = ls_error-errormessage..
            ELSE.
              LOOP AT ls_rest-errors INTO DATA(ls_er).
                CONCATENATE ls_er cv_message INTO cv_message.
              ENDLOOP.
            ENDIF.
            cv_error = 'E'.
          ENDIF.
        ELSE.
*          cv_message = 'Başarılı'.

          READ TABLE ls_rest-data-errors INTO ls_error INDEX 1 .
          IF sy-subrc EQ 0 .
            cv_error = 'E'.
            cv_message = ls_error-errormessage.
          ELSE.
            cv_message = ls_rest-message.
          ENDIF.

        ENDIF.
        w_http_client->close( ).

      CATCH cx_root INTO DATA(lx_exception).
        DATA(error) =  lx_exception->get_text( ).
        cv_error = CONV #( error ) .
    ENDTRY.

  ENDFORM.
