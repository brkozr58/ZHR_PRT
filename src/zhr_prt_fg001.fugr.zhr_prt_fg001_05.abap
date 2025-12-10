FUNCTION ZHR_PRT_FG001_05.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SRCID) TYPE  ZHR_PRT_SRCID DEFAULT '00001'
*"     VALUE(I_PERNR) TYPE  PERSNO
*"     VALUE(I_DATUM) TYPE  DATUM DEFAULT SY-DATUM
*"  EXPORTING
*"     VALUE(ET_QOUTA) TYPE  ZHR_PRT_TT011
*"     VALUE(ET_RETURN) TYPE  ZHR_PRT_TRETURN
*"----------------------------------------------------------------------
  DATA: de_sim        TYPE char1 VALUE 'B',
        abwko         TYPE ptgqd_t_kansp,
        cum_values    TYPE ptgqd_t_cu_val_add,
        ls_return     TYPE bapireturn1,
        qttrans       TYPE t_pernr_ptgqd_qttrans,
        quota         TYPE t_pernr_ptgqd_kansp,
        lt_quota      TYPE t_pernr_ptgqd_kansp,
        pernr_qttrans TYPE ptgqd_t_qttrans,
        alle,
        only          VALUE 'X',
        ls_qouta      TYPE zhr_prt_s011,
        day           TYPE ptgqd_msehi,
        hour          TYPE ptgqd_msehi,
        lv_datum      TYPE datum,
        se_ktart      TYPE RANGE OF p2006-ktart,
        dedu_beg      TYPE p2006-desta VALUE '18000101',
        dedu_end      TYPE p2006-deend VALUE '99991231',
        lr_statu      TYPE RANGE OF zhr_prt_statu,
        lt_list       TYPE  zhr_prt_tt017,
        lr_tlpid      TYPE RANGE OF zhr_prt_tlpid,
*        BEGIN OF lt_awart OCCURS 0 ,
*          qttps(10),
*          ktart_t   TYPE t556b-ktext,
*          awart     TYPE t554t-awart,
*          awart_t   TYPE t554t-atext,
*          mintg     TYPE t554s-mintg,
*          maxtg     TYPE t554s-maxtg,
*        END OF lt_awart,
        lt_awart TYPE TABLE OF zhr_prt_ddl005  WITH HEADER LINE .

  DATA langu LIKE sy-langu VALUE 'T'.
  SET LOCALE LANGUAGE  langu.

  IF i_srcid IS INITIAL  .
    CLEAR ls_return.
    PERFORM add_message TABLES et_return
                         USING i_srcid
                               space
                               'ZHR_PRT'
                               'E'
                               '023'
                               ls_return .
    READ TABLE et_return TRANSPORTING NO FIELDS WITH KEY type = 'E'.
    CHECK sy-subrc NE 0 .
  ENDIF.

  APPEND VALUE #( sign = 'I' option = 'EQ' low = '00' ) TO lr_statu.
  APPEND VALUE #( sign = 'I' option = 'EQ' low = '01' ) TO lr_statu.
  APPEND VALUE #( sign = 'I' option = 'EQ' low = '02' ) TO lr_statu.


  IF i_pernr IS INITIAL .
    PERFORM add_message TABLES et_return
                         USING ''
                               ''
                               'ZHR_PRT'
                               'E'
                               '006'
                               ls_return .
    EXIT.
  ENDIF.

  day = '010'.
  hour = '001'.
  IF i_datum IS INITIAL .
    lv_datum = sy-datum .
  ELSE.
    lv_datum = i_datum .
  ENDIF.

  hr_read_infotype : i_pernr '0001' p0001,
                     i_pernr '0003' p0003,
                     i_pernr '0007' p0007,
                     i_pernr '2006' p2006 .

*  REFRESH : abwko         ,
*            pernr_qttrans ,
*            cum_values    .
*
*  PERFORM cal_pernr_quota
*                         TABLES et_return
*                          USING i_pernr
*                                '18000101'
*                                '99991231'
*                                dedu_beg
*                                dedu_end
*                                lv_datum
*                                lv_datum
*                                de_sim
*                                se_ktart[]
*                       CHANGING abwko
*                                pernr_qttrans
*                                cum_values.
*
*  READ TABLE cum_values ASSIGNING FIELD-SYMBOL(<wa_f_cum_values_h>) WITH KEY quoun = hour.
*  READ TABLE cum_values ASSIGNING FIELD-SYMBOL(<wa_f_cum_values_d>) WITH KEY quoun = day.
*
*  SORT abwko DESCENDING BY desta deend.
*
*  LOOP AT abwko INTO DATA(ls_abwko) WHERE quoun = day OR quoun = hour.
*    ADD 1 TO ls_qouta-seqnr.
*    ls_qouta-ktart    = ls_abwko-ktart.
*    ls_qouta-ktart_t  = ls_abwko-kttext.
*    ls_qouta-begda    = ls_abwko-desta.
*    ls_qouta-endda    = ls_abwko-deend.
*    ls_qouta-anzhl    = ls_abwko-entitle.
*    ls_qouta-kverb    = ls_abwko-deduct.
*    ls_qouta-qouta    = ls_qouta-anzhl - ls_qouta-abrtg.
*    COLLECT ls_qouta  INTO et_qouta .
*  ENDLOOP.


  DATA : lr_awart TYPE RANGE OF awart .
*  APPEND VALUE #( sign    = 'I' option  = 'EQ' low     = '0204' )  TO lr_awart.
*  APPEND VALUE #( sign    = 'I' option  = 'EQ' low     = '0213' )  TO lr_awart.
*  APPEND VALUE #( sign    = 'I' option  = 'EQ' low     = '0215' )  TO lr_awart.
*  APPEND VALUE #( sign    = 'I' option  = 'EQ' low     = '0217' )  TO lr_awart.
*  APPEND VALUE #( sign    = 'I' option  = 'EQ' low     = '0241' )  TO lr_awart.
*  APPEND VALUE #( sign    = 'I' option  = 'EQ' low     = '0424' )  TO lr_awart.


  "<<--------İzin türleri için kota tipleri ------>>
  PERFORM get_awart_qouta_type TABLES lt_awart
                                USING i_pernr.
  SORT lt_awart ASCENDING BY awart.
  DELETE lt_awart WHERE awart EQ space .
  DELETE ADJACENT DUPLICATES FROM lt_awart.
  DELETE lt_awart WHERE NOT awart IN lr_awart .
  "<<--------END CODE------>>

  LOOP AT p2006 INTO DATA(ls_2006).
    ls_qouta-ktart    = ls_2006-ktart.
    READ TABLE lt_awart INTO DATA(ls_awart) WITH KEY qttps = ls_2006-ktart.
    ls_qouta-ktart_t = ls_awart-ktart_t.
    ls_qouta-begda    = ls_2006-desta.
    ls_qouta-endda    = ls_2006-deend.
    ls_qouta-anzhl    = ls_2006-anzhl.
    ls_qouta-kverb    = ls_2006-kverb.
    ls_qouta-qouta    = ls_qouta-anzhl - ls_qouta-kverb.
*    APPEND ls_qouta TO et_qouta .
    COLLECT ls_qouta  INTO et_qouta .
  ENDLOOP.

*  "<<--------Portal izinlerini Onayda bekleyen izinleri kotadan düş ------>>
  CALL FUNCTION 'ZHR_PRT_FG001_06'
    EXPORTING
      i_srcid = i_srcid
      i_pernr = i_pernr
      i_begda = '18000101'
      i_endda = '99991231'
*     I_AWART =
      i_statu = '01' " Onay bekleyen talepler
    IMPORTING
      et_list = lt_list.


  IF i_datum IS INITIAL .
    SORT et_qouta DESCENDING BY begda endda.
    DELETE et_qouta WHERE seqnr GT 5 .
  ELSE.
    DELETE et_qouta WHERE begda GE i_datum.
    SORT et_qouta DESCENDING BY begda endda.
  ENDIF.

  "<<--------Portal izinlerini Onayda bekleyen izinleri kotadan düş ------>>
  LOOP AT lt_list INTO DATA(ls_list) .
    READ TABLE lt_awart INTO ls_awart WITH KEY awart = ls_list-awart.
    LOOP AT et_qouta ASSIGNING FIELD-SYMBOL(<fs>)
      WHERE qouta GT 0 AND ktart EQ ls_awart-qttps.
      IF ls_list-abrtg LE <fs>-qouta.
        <fs>-qouta = <fs>-qouta - ls_list-abrtg.
        <fs>-kverb = <fs>-kverb + ls_list-abrtg.
      ELSE.
        ls_list-abrtg = ls_list-abrtg - <fs>-qouta.
        <fs>-kverb = <fs>-kverb + <fs>-qouta.
        <fs>-qouta = 0 .
      ENDIF.
    ENDLOOP.
  ENDLOOP.
  "<<--------END CODE------>>

ENDFUNCTION.
