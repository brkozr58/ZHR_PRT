FUNCTION zhr_prt_fg001_08.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SRCID) TYPE  ZHR_PRT_SRCID DEFAULT '00001'
*"     VALUE(IS_LEAVE) TYPE  ZHR_PRT_S016
*"     VALUE(CR_PERNR) TYPE  PERSNO OPTIONAL
*"  EXPORTING
*"     VALUE(EV_TLPID) TYPE  ZHR_PRT_TLPID
*"     VALUE(ET_RETURN) TYPE  ZHR_PRT_TRETURN
*"----------------------------------------------------------------------

  DATA : lt_t004      TYPE TABLE OF zhr_prt_t004, "Portal talepleri başlık
         lt_t005      TYPE TABLE OF zhr_prt_t005, "İzin talepleri detayı
         lt_t006      TYPE TABLE OF zhr_prt_t006, "İzin talepleri onaycıları
         lv_atext     TYPE t554t-atext,
*         lv_tlpid     TYPE zhr_prt_tlpid,
         ls_t010      TYPE zhr_prt_t010,
         lr_pernr     TYPE RANGE OF persno WITH HEADER LINE,
         ls_return    TYPE bapireturn1,
         ls_leave     TYPE  zhr_prt_s016,
         lv_msgno     TYPE bapireturn1-number,
         lv_subrc     TYPE sy-subrc,
         lt_approvers TYPE zhr_prt_tt014.

  DATA langu LIKE sy-langu VALUE 'T'.
  SET LOCALE LANGUAGE  langu.


  IF is_leave-pernr IS NOT INITIAL .
    APPEND VALUE #( sign = 'I' option = 'EQ' low = is_leave-pernr )
          TO lr_pernr.
  ELSE.
    lv_msgno = '006'.
  ENDIF.

  IF lv_msgno IS NOT INITIAL .
    PERFORM add_message TABLES et_return
                         USING i_srcid
                               is_leave-pernr
                               'ZHR_PRT'
                               'E'
                               lv_msgno
                               ls_return .
    EXIT.
  ENDIF.

  "<<--------Check Leave------>>
  MOVE-CORRESPONDING is_leave TO ls_leave.

  CALL FUNCTION 'ZHR_PRT_CHECK_LEAVE'
    EXPORTING
      i_srcid   = i_srcid
*     i_tlpid   = lv_tlpid
    IMPORTING
      et_return = et_return
    CHANGING
      cs_leave  = ls_leave.

  READ TABLE et_return TRANSPORTING NO FIELDS WITH KEY type = 'E'.
  CHECK sy-subrc NE 0 .
  "<<--------END CODE------>>

  IF ( sy-datum - ls_leave-begda ) GT 3 .
    CLEAR ls_return.
    PERFORM add_message TABLES et_return
                         USING i_srcid
                               ls_leave-pernr
                               'ZHR_PRT'
                               'E'
                               '018'
                               ls_return .
    EXIT.
  ENDIF.

  "<<--------Approvers------>>
  CALL FUNCTION 'ZHR_PRT_FG001_07'
    EXPORTING
      i_srcid      = i_srcid
      i_pernr      = ls_leave-pernr
      i_datum      = sy-datum
    IMPORTING
      et_approvers = lt_approvers
      et_return    = et_return.
  "<<--------END CODE------>>

  READ TABLE et_return TRANSPORTING NO FIELDS WITH KEY type = 'E'.
  CHECK sy-subrc NE 0 .
  SELECT SINGLE * FROM zhr_prt_t010 INTO ls_t010
    WHERE srcid EQ i_srcid.

  PERFORM create_tlpid TABLES et_return
                        USING i_srcid
                     CHANGING ev_tlpid
                              lv_subrc.
  CASE lv_subrc.
    WHEN 0.

      SELECT SINGLE awart_t~atext
              FROM t554t  AS awart_t
        INNER JOIN t001p  AS t1
              ON    t1~moabw EQ awart_t~moabw
        INNER JOIN pa0001 AS t2
              ON    t2~werks EQ t1~werks
                AND t2~btrtl EQ t1~btrtl
        INTO lv_atext
        WHERE awart_t~awart EQ ls_leave-awart
          AND awart_t~sprsl EQ sy-langu
          AND t2~pernr      EQ ls_leave-pernr
          AND t2~endda      GE sy-datum.
      .

      DATA : lcr_pernr TYPE persno.

      IF cr_pernr IS NOT INITIAL .
        lcr_pernr = cr_pernr.
      ELSE.
        lcr_pernr = ls_leave-pernr.
      ENDIF.

      APPEND VALUE #(
                      srcid     = i_srcid
                      tlpid     = ev_tlpid
                      statu     = '01'
                      unamecre  = lcr_pernr
                      datumcre  = sy-datum
                      uzeitcre  = sy-uzeit
                      )
            TO lt_t004.

      APPEND VALUE #(
                      tlpid     = ev_tlpid
                      pernr     = ls_leave-pernr
                      awart     = ls_leave-awart
                      begda     = ls_leave-begda
                      endda     = ls_leave-endda
                      beguz     = ls_leave-beguz
                      enduz     = ls_leave-enduz
                      retdt     = ls_leave-retdt
                      kaltg     = ls_leave-kaltg
                      stdaz     = ls_leave-stdaz
                      abwtg     = ls_leave-abwtg
                      abrtg     = ls_leave-abrtg
                      abrst     = ls_leave-abrst
                      zdesc     = ls_leave-zdesc
                      unamecre  = lcr_pernr
                      datumcre  = sy-datum
                      uzeitcre  = sy-uzeit
                      )
            TO lt_t005.

      lt_t006 = VALUE #( FOR ls IN lt_approvers
                          (
                            tlpid     = ev_tlpid
                            seqnr     = ls-seqnr
                            plans     = ls-plans
                            orgsvy    = ls-orgsvy
                            aptyp     = ls-aptyp
                            statu     = '00'
                            unamecre  = lcr_pernr
                            datumcre  = sy-datum
                            uzeitcre  = sy-uzeit
                           )
                       ).
      SORT lt_t006 ASCENDING BY seqnr .
      READ TABLE lt_t006 ASSIGNING FIELD-SYMBOL(<fs>) INDEX 1 .
      <fs>-statu = '01'.


      MODIFY zhr_prt_t004 FROM TABLE lt_t004.
      MODIFY zhr_prt_t005 FROM TABLE lt_t005.
      MODIFY zhr_prt_t006 FROM TABLE lt_t006.
      COMMIT WORK AND WAIT .
      PERFORM leave_req_send_mail TABLES  lt_t004
                                          lt_t005
                                          lt_t006
                                          et_return
                                   USING  <fs>-statu
                                          ev_tlpid
                                          ls_leave-pernr
                                          gv_sender.
      COMMIT WORK AND WAIT .

      ls_return-message_v1 = ev_tlpid.
      ls_return-message_v2 = lv_atext.
      PERFORM add_message TABLES et_return
                           USING i_srcid
                                 ls_leave-pernr
                                 'ZHR_PRT'
                                 'S'
                                 '012'
                                 ls_return .

    WHEN OTHERS.

      CASE lv_subrc .
        WHEN 1."interval_not_found
          ls_return-message_v1 = 'Talep id bulunamadı.'.
        WHEN 2."number_range_not_intern
          ls_return-message_v1 = 'Talep id numara aralığı bulunamadı.'.
        WHEN OTHERS .
          ls_return-message_v1 = 'Hata oluştu.'.
      ENDCASE.
      ls_return-message_v2 = 'Sistem yöneticinize başvurunuz!'.
      PERFORM add_message TABLES et_return
                           USING i_srcid
                                 ls_leave-pernr
                                 'ZHR_PRT'
                                 'E'
                                 '000'
                                 ls_return .
  ENDCASE.

ENDFUNCTION.
