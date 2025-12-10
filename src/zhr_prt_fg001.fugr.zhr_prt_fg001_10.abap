FUNCTION zhr_prt_fg001_10.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IT_LEAVE) TYPE  ZHR_PRT_TT018
*"     VALUE(I_STATU) TYPE  ZHR_PRT_STATU
*"     VALUE(CR_PERNR) TYPE  PERSNO OPTIONAL
*"  EXPORTING
*"     VALUE(ET_RETURN) TYPE  ZHR_PRT_TRETURN
*"----------------------------------------------------------------------

  DATA : ls_cds2   TYPE zhr_prt_ddl002,
         lt_t004   TYPE TABLE OF zhr_prt_t004, "Portal talepleri başlık
         lt_t005   TYPE TABLE OF zhr_prt_t005, "İzin talepleri detayı
         lt_t006   TYPE TABLE OF zhr_prt_t006, "İzin talepleri onaycıları
         lv_statu  TYPE zhr_prt_statu,
         ls_return TYPE bapireturn1,
         langu     LIKE sy-langu VALUE 'T'.

  SET LOCALE LANGUAGE  langu.

  LOOP AT it_leave INTO DATA(is_leave).

    REFRESH : lt_t004, lt_t005, lt_t006.

    IF is_leave-tlpid IS INITIAL .
      CLEAR : ls_return.
      PERFORM add_message TABLES et_return
                           USING '00001'
                                 is_leave-pernr
                                 'ZHR_PRT'
                                 'E'
                                 '010'
                                 ls_return .
      EXIT.
    ENDIF.

    IF is_leave-tlpid EQ '9999999999' .
      CLEAR : ls_return.
      PERFORM add_message TABLES et_return
                           USING '00001'
                                 is_leave-pernr
                                 'ZHR_PRT'
                                 'E'
                                 '031'
                                 ls_return .
      EXIT.
    ENDIF.

    CASE i_statu.
      WHEN '02' OR '03' .
      WHEN OTHERS.
        CLEAR : ls_return.
        PERFORM add_message TABLES et_return
                             USING '00001'
                                   is_leave-pernr
                                   'ZHR_PRT'
                                   'E'
                                   '013'
                                   ls_return .
        EXIT.
    ENDCASE.

    SELECT SINGLE * FROM zhr_prt_ddl002 INTO ls_cds2
        WHERE tlpid     EQ is_leave-tlpid
          AND ap_statu  EQ '01'.

    SELECT * FROM zhr_prt_t004 INTO TABLE lt_t004
        WHERE tlpid EQ is_leave-tlpid.

    SELECT * FROM zhr_prt_t005 INTO TABLE lt_t005
        WHERE tlpid EQ is_leave-tlpid.

    SELECT * FROM zhr_prt_t006 INTO TABLE lt_t006
        WHERE tlpid EQ is_leave-tlpid
          AND ( statu EQ '01' OR statu EQ '00' ).  " Onay bekliyor .
    SORT lt_t006 ASCENDING BY tlpid seqnr .

    IF lt_t006[] IS INITIAL .
      CLEAR : ls_return.
      PERFORM add_message TABLES et_return
                           USING '00001'
                                 is_leave-pernr
                                 'ZHR_PRT'
                                 'E'
                                 '015'
                                 ls_return .
      EXIT.
    ENDIF.

    READ TABLE lt_t005 ASSIGNING FIELD-SYMBOL(<fs_5>)
            WITH KEY tlpid = is_leave-tlpid.
    READ TABLE lt_t004 ASSIGNING FIELD-SYMBOL(<fs_4>)
            WITH KEY tlpid = is_leave-tlpid.

    IF <fs_4>-statu NE '01'.
      CLEAR : ls_return.
      PERFORM add_message TABLES et_return
                           USING '00001'
                                 is_leave-pernr
                                 'ZHR_PRT'
                                 'E'
                                 '026'
                                 ls_return .
      EXIT.
    ENDIF.

    READ TABLE et_return TRANSPORTING NO FIELDS WITH KEY type = 'E'
                                                         pernr = is_leave-pernr.
    CHECK sy-subrc NE 0 .

    READ TABLE lt_t006 ASSIGNING FIELD-SYMBOL(<fs_6>)
            WITH KEY tlpid = is_leave-tlpid statu = '01'.
    lv_statu = <fs_6>-statu = i_statu.
    <fs_6>-ap_zdesc = is_leave-ap_zdesc .
*  <fs_6>-unamechn = sy-uname .
    <fs_6>-unamechn = cr_pernr .
    <fs_6>-datumchn = sy-datum .
    <fs_6>-uzeitchn = sy-uzeit .
    IF sy-subrc EQ 0 .

      CLEAR : ls_return.
      ls_return-message_v1 = is_leave-tlpid.
      ls_return-message_v2 = ls_cds2-awart_t.

      CASE i_statu.
        WHEN '02'. " Onaylandı
          " Sonraki onaycıyı geç
          DATA(lv_seqnr) = <fs_6>-seqnr + 1 .
          READ TABLE lt_t006 ASSIGNING <fs_6>
                  WITH KEY tlpid = is_leave-tlpid seqnr = lv_seqnr.
          IF sy-subrc EQ 0 .
            lv_statu = <fs_6>-statu = '01'. "01  Onay Bekliyor
          ELSE.
            " Sırada onaycı kalmamışsa talebi tamamla
            READ TABLE lt_t004 ASSIGNING <fs_4>
                    WITH KEY tlpid = is_leave-tlpid.
            lv_statu = <fs_4>-statu = '04'. "  04  Tamamlandı
            <fs_4>-unamechn = <fs_5>-unamechn = cr_pernr .
            <fs_4>-datumchn = <fs_5>-datumchn = sy-datum .
            <fs_4>-uzeitchn = <fs_5>-uzeitchn = sy-uzeit .
          ENDIF.
          ls_return-message_v3 = 'onaylanmıştır.'.

        WHEN '03'. " Reddedildi
          READ TABLE lt_t004 ASSIGNING <fs_4>
                  WITH KEY tlpid = is_leave-tlpid.
          lv_statu = <fs_4>-statu = i_statu. "  03  Reddedildi
          <fs_4>-unamechn = cr_pernr .
          <fs_4>-datumchn = sy-datum .
          <fs_4>-uzeitchn = sy-uzeit .

          ls_return-message_v3 = 'reddedilmiştir.'.
      ENDCASE.

      PERFORM add_message TABLES et_return
                           USING '00001'
                                 is_leave-pernr
                                 'ZHR_PRT'
                                 'S'
                                 '014'
                                 ls_return .

      READ TABLE et_return TRANSPORTING NO FIELDS WITH KEY type = 'E'
                                                         pernr = is_leave-pernr.
      CHECK sy-subrc NE 0 .
      IF lv_statu EQ '04'. "  04  Tamamlandı.
        PERFORM operation_leave_data
                                  TABLES  et_return
                                   USING  lv_statu
                                          is_leave-tlpid
                                          is_leave-pernr
                                          'INS'.
      ENDIF.

      READ TABLE et_return TRANSPORTING NO FIELDS WITH KEY type = 'E'
                                                         pernr = is_leave-pernr.
      CHECK sy-subrc NE 0 .
      PERFORM leave_req_send_mail TABLES  lt_t004
                                          lt_t005
                                          lt_t006
                                          et_return
                                   USING  lv_statu
                                          is_leave-tlpid
                                          is_leave-pernr
                                          gv_sender.
      READ TABLE et_return TRANSPORTING NO FIELDS WITH KEY type = 'E'
                                                         pernr = is_leave-pernr.
      CHECK sy-subrc NE 0 .

      MODIFY zhr_prt_t004 FROM TABLE lt_t004.
      MODIFY zhr_prt_t005 FROM TABLE lt_t005.
      MODIFY zhr_prt_t006 FROM TABLE lt_t006.

      COMMIT WORK AND WAIT .
      IF lv_statu EQ '04' .
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
      ENDIF.

    ELSE.
      CLEAR : ls_return.
      PERFORM add_message TABLES et_return
                           USING '00001'
                                 is_leave-pernr
                                 'ZHR_PRT'
                                 'E'
                                 '027'
                                 ls_return .
    ENDIF.

  ENDLOOP.

ENDFUNCTION.
