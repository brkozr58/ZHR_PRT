FUNCTION zhr_prt_check_leave.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SRCID) TYPE  ZHR_PRT_SRCID DEFAULT '0001'
*"     VALUE(I_TLPID) TYPE  ZHR_PRT_TLPID OPTIONAL
*"  EXPORTING
*"     VALUE(ET_RETURN) TYPE  ZHR_PRT_TRETURN
*"  CHANGING
*"     VALUE(CS_LEAVE) TYPE  ZHR_PRT_S016
*"----------------------------------------------------------------------


  DATA : hrsif          LIKE p2001-hrsif,
         vtken          LIKE p2001-vtken,
         alldf          LIKE p2001-alldf,
         holiday_filled VALUE '0',
         pbo_nobreaks   TYPE hrtim_att_breaks,
         subrc          LIKE sy-subrc,
         times_per_day  TYPE TABLE OF ptm_times_per_day,
         errors         LIKE hrerror   OCCURS 0 WITH HEADER LINE,
         errortexts     LIKE t100-text OCCURS 0,
         lt_t007        TYPE TABLE OF zhr_prt_t007,
         lr_pernr       TYPE RANGE OF persno WITH HEADER LINE,
         lr_statu       TYPE RANGE OF zhr_prt_statu WITH HEADER LINE,
         lr_tlpid       TYPE RANGE OF zhr_prt_tlpid,
         ls_return      TYPE bapireturn1,
         lv_msgno       TYPE bapireturn1-number.

  DATA langu LIKE sy-langu VALUE 'T'.
  SET LOCALE LANGUAGE  langu.

***    01	Onay Bekliyor
***    02	Onaylandı
***    03  Reddedildi
***    04  Tamamlandı
***    05  İptal edildi
***    00

  CALL FUNCTION 'HR_REFRESH_ERROR_LIST'.


  APPEND VALUE #( sign = 'I' option = 'EQ' low = '00' ) TO lr_statu.
  APPEND VALUE #( sign = 'I' option = 'EQ' low = '01' ) TO lr_statu.
  APPEND VALUE #( sign = 'I' option = 'EQ' low = '02' ) TO lr_statu.
  APPEND VALUE #( sign = 'I' option = 'EQ' low = '04' ) TO lr_statu.

  IF cs_leave-pernr IS NOT INITIAL .
    APPEND VALUE #( sign = 'I' option = 'EQ' low = cs_leave-pernr )
          TO lr_pernr.
  ELSE.
    lv_msgno = '006'.
  ENDIF.

  IF i_tlpid IS NOT INITIAL .
*    lv_msgno = '010'.
*  ELSE.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = i_tlpid ) TO lr_tlpid.
  ENDIF.

  IF lv_msgno IS NOT INITIAL .
    PERFORM add_message TABLES et_return
                         USING i_srcid
                               cs_leave-pernr
                               'ZHR_PRT'
                               'E'
                               lv_msgno
                               ls_return .
    EXIT.
  ENDIF.


  READ TABLE et_return TRANSPORTING NO FIELDS WITH KEY type = 'E'.
  CHECK sy-subrc NE 0 .

  SELECT * FROM zhr_prt_t007 INTO TABLE lt_t007 .

  "<<--------Portal izinlerini kontrol et ------>>

*  " Portal +2001 izin verileri
  DATA : et_list  TYPE TABLE OF zhr_prt_s017_2,
         lr_awart TYPE RANGE OF awart.

  PERFORM get_leave_list TABLES et_list lr_pernr lr_awart
                          USING i_srcid
                                cs_leave-begda
                                cs_leave-endda .
  DELETE et_list WHERE statu EQ '03' OR statu EQ '05'.
  IF i_tlpid IS NOT INITIAL .
    DELETE et_list WHERE tlpid EQ i_tlpid.
  ENDIF.
  IF et_list[] IS NOT INITIAL  .
    WRITE cs_leave-begda TO ls_return-message_v1 DD/MM/YYYY.
    WRITE cs_leave-endda TO ls_return-message_v2 DD/MM/YYYY.
    PERFORM add_message TABLES et_return
                         USING i_srcid
                               cs_leave-pernr
                               'ZHR_PRT'
                               'E'
                               '011'
                               ls_return .
  ENDIF.

  READ TABLE et_return TRANSPORTING NO FIELDS WITH KEY type = 'E'.
  CHECK sy-subrc NE 0 .
  hr_read_infotype : cs_leave-pernr '0000' p0000,
                     cs_leave-pernr '0001' p0001,
                     cs_leave-pernr '0002' p0002,
                     cs_leave-pernr '0007' p0007,
                     cs_leave-pernr '2001' p2001 ,
                     cs_leave-pernr '2002' p2002 ,
                     cs_leave-pernr '2003' p2003 .
  DATA : beguz TYPE beguz,
         enduz TYPE enduz.
  IF cs_leave-beguz IS NOT INITIAL . beguz = cs_leave-beguz. ENDIF.
  IF cs_leave-enduz IS NOT INITIAL . enduz = cs_leave-enduz. ENDIF.
  PERFORM count_abs_att_times
              TABLES
                   p0000
                   p0001
                   p0002
                   p0007
                   p2001
                   p2002
                   p2003
                   times_per_day
                   holiday[]
              USING
                   cs_leave-pernr
                   cs_leave-awart
                   cs_leave-begda
                   cs_leave-endda
                   beguz          " cs_leave-beguz
                   enduz          " cs_leave-enduz
                   cs_leave-kaltg
                   cs_leave-stdaz
                   cs_leave-abwtg
                   cs_leave-abrtg
                   cs_leave-abrst
                   hrsif
                   alldf
                   vtken
                   holiday_filled
                   pbo_nobreaks
                   subrc.
  IF subrc NE 0 .
    IF beguz IS NOT INITIAL .cs_leave-beguz = beguz. ENDIF.
    IF enduz IS NOT INITIAL .cs_leave-enduz = enduz. ENDIF.

    CALL FUNCTION 'HR_GET_ERROR_LIST'
      TABLES
        error      = errors
        errortexts = errortexts
      EXCEPTIONS
        no_errors  = 1
        OTHERS     = 2.

    LOOP AT errors WHERE msgty = 'E'
                   OR    msgty = 'A'.
      ls_return-type       = errors-msgty .
      ls_return-id         = errors-arbgb .
      ls_return-number     = errors-msgno .
      ls_return-message_v1 = errors-msgv1 .
      ls_return-message_v2 = errors-msgv2 .
      ls_return-message_v3 = errors-msgv3 .
      ls_return-message_v4 = errors-msgv4 .

      PERFORM add_message TABLES et_return
                           USING i_srcid
                                 cs_leave-pernr
                                 'ZHR_PRT'
                                 'E'
                                 lv_msgno
                                 ls_return .
    ENDLOOP.
  ENDIF.

  IF i_tlpid IS INITIAL .
    PERFORM check_qouta TABLES et_return
                         USING cs_leave.
  ENDIF.


  "<<--------MAX gün kontrolü ------>>
  "ilgili yılda max kotasını bul
  DATA : lv_begda TYPE begda,
         lv_endda TYPE endda,
         lv_kaltg TYPE p2001-kaltg,
         lv_abrtg TYPE p2001-abrtg,
         lv_abwtg TYPE p2001-abwtg.
  IF lt_t007[] IS NOT INITIAL .
    lv_begda = cs_leave-begda(4) && '0101'.
    lv_endda = cs_leave-begda(4) && '1231'.
    REFRESH : et_list.

    PERFORM get_leave_list TABLES et_list lr_pernr lr_awart
                            USING i_srcid
                                  lv_begda
                                  lv_endda.
    DELETE et_list WHERE statu EQ '03' OR statu EQ '05'.

    IF cs_leave-awart NE '0204'.
      lv_kaltg = cs_leave-kaltg.
      LOOP AT lt_t007 INTO DATA(ls_t007) WHERE awart EQ cs_leave-awart  .
        LOOP AT et_list INTO DATA(ls_temp) WHERE not ( tlpid IN lr_tlpid[] )
                                             AND awart EQ ls_t007-awart.
          ADD ls_temp-kaltg TO lv_kaltg.
        ENDLOOP.

        IF ls_t007-maxdy LT lv_kaltg.
          CLEAR ls_return.
          ls_return-message_v1 = ls_t007-maxdy .
          SHIFT ls_return-message_v1 LEFT DELETING LEADING space.
          PERFORM add_message TABLES et_return
                               USING i_srcid
                                     cs_leave-pernr
                                     'ZHR_PRT'
                                     'E'
                                     '016'
                                     ls_return .
        ENDIF.
*      CLEAR lv_kaltg.
        CLEAR lv_abwtg.
        CLEAR lv_abrtg.
      ENDLOOP.
    ELSE.
      lv_abrtg = cs_leave-abrtg.
    ENDIF.


  ENDIF.
  "<<--------END CODE------>>

  CHECK i_tlpid IS INITIAL .
  DATA : lt_wschedule TYPE  zhr_prt_tt012,
         lv_endd      TYPE datum.
  cs_leave-retdt = cs_leave-endda + 1 .
  lv_endd = cs_leave-retdt + 15 .

  CALL FUNCTION 'ZHR_PRT_FG001_13'
    EXPORTING
      i_pernr      = cs_leave-pernr
      i_begda      = cs_leave-retdt
      i_endda      = lv_endd
    IMPORTING
      et_wschedule = lt_wschedule.
  DELETE lt_wschedule WHERE awart IS NOT INITIAL .
  DELETE lt_wschedule WHERE holiday IS NOT INITIAL .
  DELETE lt_wschedule WHERE freeday IS NOT INITIAL .
  READ TABLE lt_wschedule INTO DATA(ls_ws) INDEX 1 .
  CHECK sy-subrc EQ 0 .
  cs_leave-retdt = ls_ws-datum.
ENDFUNCTION.
