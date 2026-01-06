FUNCTION zhr_prt_fg001_09.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_LEAVE) TYPE  ZHR_PRT_S018
*"     VALUE(I_STATU) TYPE  ZHR_PRT_STATU DEFAULT 05
*"     VALUE(CR_PERNR) TYPE  PERSNO OPTIONAL
*"     VALUE(I_ADMIN) TYPE  FLAG OPTIONAL
*"  EXPORTING
*"     VALUE(ET_RETURN) TYPE  ZHR_PRT_TRETURN
*"----------------------------------------------------------------------

  DATA : ls_cds2   TYPE zhr_prt_ddl002,
         ls_t004   TYPE zhr_prt_t004, "Portal talepleri başlık
         lt_t004   TYPE TABLE OF zhr_prt_t004, "Portal talepleri başlık
         ls_t005   TYPE zhr_prt_t005, "İzin talepleri detayı
         lt_t005   TYPE TABLE OF zhr_prt_t005, "İzin talepleri detayı
         lt_t006   TYPE TABLE OF zhr_prt_t006, "İzin talepleri onaycıları
         lv_statu  TYPE zhr_prt_statu,
         ls_return TYPE bapireturn1,
         langu     LIKE sy-langu VALUE 'T',
         lv_admin  TYPE  flag.

  DATA : et_persons TYPE  zhr_prt_tt022.

  DEFINE statu_message.
    CLEAR : ls_return.
    PERFORM add_message TABLES et_return
                         USING '00001'
                               is_leave-pernr
                               'ZHR_PRT'
                               'E'
                               '020'
                               ls_return .
  END-OF-DEFINITION.

  SET LOCALE LANGUAGE  langu.

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

  SELECT SINGLE * FROM zhr_prt_ddl002 INTO ls_cds2
      WHERE tlpid     EQ is_leave-tlpid
        AND ap_statu  EQ '01'
    .

  SELECT * FROM zhr_prt_t004 INTO TABLE lt_t004
      WHERE tlpid EQ is_leave-tlpid.

  SELECT * FROM zhr_prt_t005 INTO TABLE lt_t005
      WHERE tlpid EQ is_leave-tlpid.

  SELECT * FROM zhr_prt_t006 INTO TABLE lt_t006
      WHERE tlpid EQ is_leave-tlpid
        AND ( statu EQ '01' OR statu EQ '00' ).  " Onay bekliyor .

  SORT lt_t006 ASCENDING BY tlpid seqnr .
*01	Onay Bekliyor
*02	Onaylandı
*03	Reddedildi
*04	Tamamlandı
*05	İptal edildi

  READ TABLE lt_t004 ASSIGNING FIELD-SYMBOL(<fs_4>) WITH KEY tlpid = is_leave-tlpid.
  READ TABLE lt_t005 ASSIGNING FIELD-SYMBOL(<fs_5>) WITH KEY tlpid = is_leave-tlpid.
  CASE <fs_4>-statu.
    WHEN '03' OR '05'.
      statu_message.
      EXIT.
    WHEN OTHERS.
      lv_admin = i_admin.
      " Zaman yöneticisi kendi taleplerini statü farketmeksizin iptal edebilsin.
      READ TABLE lt_t006 ASSIGNING FIELD-SYMBOL(<fs_6>)
              WITH KEY tlpid = is_leave-tlpid statu = '01' .
      IF i_admin NE 'X' AND cr_pernr EQ is_leave-pernr AND <fs_6>-seqnr NE 1 .
        CALL FUNCTION 'ZHR_PRT_FG001_20'
          EXPORTING
            i_pernr    = cr_pernr
            i_datum    = sy-datum
          IMPORTING
            et_persons = et_persons.
        READ TABLE et_persons INTO DATA(ls_persons) INDEX 1 .
        IF ls_persons-aptyp NE 'ZMNY'.
          statu_message.
          EXIT.
        ELSE.
          lv_admin = 'X'.
        ENDIF.

      ELSE.
        " Admin ekranından çağrılmamışsa ve tamamlandı statüyse hata ver
        IF i_admin NE 'X' AND <fs_4>-statu EQ '04'.
          statu_message.
          EXIT.
        ENDIF.
      ENDIF.


      READ TABLE lt_t006 ASSIGNING <fs_6>
              WITH KEY tlpid = is_leave-tlpid statu = '01'.
      IF sy-subrc NE 0 AND <fs_4>-statu EQ '04' AND i_statu EQ '05'.
        SELECT * FROM zhr_prt_t006 INTO TABLE lt_t006
            WHERE tlpid EQ is_leave-tlpid
              AND seqnr EQ ( SELECT MAX( seqnr ) FROM zhr_prt_t006
                              WHERE tlpid EQ is_leave-tlpid ).
        READ TABLE lt_t006 ASSIGNING <fs_6> WITH KEY tlpid = is_leave-tlpid  .
      ENDIF.
      lv_statu = <fs_6>-statu = i_statu.
      <fs_6>-ap_zdesc = is_leave-ap_zdesc .
*      lv_statu = <fs_4>-statu = i_statu.
      lv_statu = i_statu.
      IF <fs_4>-statu NE '04' .
        lv_statu = <fs_4>-statu = i_statu.
      ENDIF.
*      <fs_4>-unamechn = <fs_5>-unamechn = <fs_6>-unamechn = sy-uname  .
      <fs_4>-unamechn = <fs_5>-unamechn = <fs_6>-unamechn = cr_pernr  .
      <fs_4>-datumchn = <fs_5>-datumchn = <fs_6>-datumchn = sy-datum  .
      <fs_4>-uzeitchn = <fs_5>-uzeitchn = <fs_6>-uzeitchn = sy-uzeit  .

      CLEAR : ls_return.
      ls_return-message_v1 = is_leave-tlpid.
      ls_return-message_v2 = ls_cds2-awart_t.
      ls_return-message_v3 = 'İptal edilmiştir.'.
      PERFORM add_message TABLES et_return
                           USING '00001'
                                 is_leave-pernr
                                 'ZHR_PRT'
                                 'S'
                                 '014'
                                 ls_return .
      IF <fs_4>-statu EQ '04' AND lv_admin EQ 'X' . "Tamamlandı varsa sil
        <fs_4>-statu = i_statu.
        PERFORM operation_leave_data
                                  TABLES  et_return
                                   USING  lv_statu
                                          is_leave-tlpid
                                          is_leave-pernr
                                          'DEL'
                                          <fs_5>.
        READ TABLE et_return TRANSPORTING NO FIELDS WITH KEY type = 'E'.
        CHECK sy-subrc NE 0 .
      ENDIF.

      PERFORM leave_req_send_mail TABLES  lt_t004
                                          lt_t005
                                          lt_t006
                                          et_return
                                   USING  lv_statu
                                          is_leave-tlpid
                                          is_leave-pernr
                                          gv_sender.
      READ TABLE et_return TRANSPORTING NO FIELDS WITH KEY type = 'E'.
      CHECK sy-subrc NE 0 .
      MODIFY zhr_prt_t004 FROM TABLE lt_t004.
      MODIFY zhr_prt_t005 FROM TABLE lt_t005.
      MODIFY zhr_prt_t006 FROM TABLE lt_t006.

      COMMIT WORK AND WAIT .
      IF <fs_4>-statu EQ '04' .
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
      ENDIF.


  ENDCASE.

ENDFUNCTION.
