FUNCTION zhr_prt_fg001_03.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_PERNR) TYPE  PERSNO OPTIONAL
*"  EXPORTING
*"     VALUE(ET_KVKK) TYPE  ZHR_PRT_TT010
*"     VALUE(ET_RETURN) TYPE  ZHR_PRT_TRETURN
*"----------------------------------------------------------------------

  DATA : ls_kvkk             TYPE zhr_prt_s010,
         ls_return           TYPE  bapireturn1,
         bds_instance        TYPE REF TO cl_bds_document_set,
         logical_system      TYPE sbdst_logical_system,
         classname           TYPE sbdst_classname,
         classtype           TYPE sbdst_classtype,
         client              TYPE sbdst_client,
         object_key          TYPE sbdst_object_key,
         check_state         TYPE bapibds01-x,
         connections         TYPE sbdst_connections,
         extended_components TYPE sbdst_components2,
         components          TYPE sbdst_components,
         content             TYPE sbdst_content,
         signature           TYPE sbdst_signature,
         lv_lgsystm          TYPE logsys,
         lv_input_len        TYPE i,
         ls_kvkk2            TYPE zhr_prt_tkvkk.

  DATA : BEGIN OF gv,
           classname  TYPE  sbdst_classname VALUE 'ZHR_PRT_KVKK',
           classtype  TYPE  sbdst_classtype VALUE 'OT',
           object_key TYPE  sbdst_object_key,
         END OF   gv.

*    MODIFY zhr_prt_tkvkk FROM ls_kvkk.
  DATA langu LIKE sy-langu VALUE 'T'.
  SET LOCALE LANGUAGE  langu.


  SELECT SINGLE * FROM zhr_prt_t002 INTO CORRESPONDING FIELDS OF ls_kvkk
        WHERE versi EQ ( SELECT MAX( versi ) FROM zhr_prt_t002 ).
  IF sy-subrc EQ 0 .
    CLEAR ls_kvkk2 .
    SELECT SINGLE * FROM zhr_prt_tkvkk INTO ls_kvkk2
          WHERE pernr EQ i_pernr
            AND time  EQ ( SELECT MAX( time ) FROM zhr_prt_tkvkk
                              WHERE pernr EQ i_pernr
                                AND versi EQ ls_kvkk-versi )
            AND versi EQ ls_kvkk-versi .

    CHECK ls_kvkk2-appfl IS INITIAL .
    CREATE OBJECT bds_instance.
    gv-object_key = ls_kvkk-tdname.

    CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
      IMPORTING
        own_logical_system             = lv_lgsystm
      EXCEPTIONS
        own_logical_system_not_defined = 1
        OTHERS                         = 2.
    IF sy-subrc <> 0.
      CLEAR lv_lgsystm .
    ENDIF.

    CALL METHOD bds_instance->get_with_table
      EXPORTING
        logical_system  = lv_lgsystm
        classname       = gv-classname
        classtype       = gv-classtype
        client          = sy-mandt
        object_key      = gv-object_key
      CHANGING
        content         = content
        signature       = signature
        components      = components
      EXCEPTIONS
        error_kpro      = 1
        internal_error  = 2
        nothing_found   = 3
        no_content      = 4
        parameter_error = 5
        not_authorized  = 6
        not_allowed     = 7
        OTHERS          = 8.
    CHECK sy-subrc EQ 0 .

    LOOP AT content INTO DATA(ls_content).
      CONCATENATE ls_kvkk-zxstring ls_content-line INTO ls_kvkk-zxstring IN BYTE MODE.
    ENDLOOP.
    READ TABLE components INTO DATA(ls_components) INDEX 1 .
    lv_input_len  = ls_components-comp_size .
*
    CALL FUNCTION 'SSFC_BASE64_ENCODE'
      EXPORTING
        bindata                  = ls_kvkk-zxstring
      IMPORTING
        b64data                  = ls_kvkk-zbase64
      EXCEPTIONS
        ssf_krn_error            = 1
        ssf_krn_noop             = 2
        ssf_krn_nomemory         = 3
        ssf_krn_opinv            = 4
        ssf_krn_input_data_error = 5
        ssf_krn_invalid_par      = 6
        ssf_krn_invalid_parlen   = 7
        OTHERS                   = 8.
    ls_kvkk-comp_id   = ls_components-comp_id.
    ls_kvkk-mimetype  = ls_components-mimetype.
    ls_kvkk-comp_size = ls_components-comp_size.
    APPEND ls_kvkk TO et_kvkk.
  ELSE.
    PERFORM add_message TABLES et_return
                         USING ''
                               ''
                               'ZHR_PRT'
                               'E'
                               '001'
                               ls_return .
  ENDIF.

ENDFUNCTION.
