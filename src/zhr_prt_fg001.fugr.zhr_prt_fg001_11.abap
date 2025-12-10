FUNCTION zhr_prt_fg001_11.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SRCID) TYPE  ZHR_PRT_SRCID DEFAULT '00001'
*"     VALUE(APR_PERNR) TYPE  PERSNO
*"     VALUE(I_PERNR) TYPE  PERSNO OPTIONAL
*"     VALUE(I_ENAME) TYPE  EMNAM OPTIONAL
*"     VALUE(I_BEGDA) TYPE  BEGDA OPTIONAL
*"     VALUE(I_ENDDA) TYPE  ENDDA OPTIONAL
*"     VALUE(I_AWART) TYPE  AWART OPTIONAL
*"     VALUE(I_AP_STATU) TYPE  ZHR_PRT_STATU OPTIONAL
*"     VALUE(I_ADMIN) TYPE  FLAG OPTIONAL
*"  EXPORTING
*"     VALUE(ET_LIST) TYPE  ZHR_PRT_TT017
*"     VALUE(ET_RETURN) TYPE  ZHR_PRT_TRETURN
*"----------------------------------------------------------------------

  DATA : ls_return   TYPE bapireturn1,
         lr_awart    TYPE RANGE OF awart,
         lr_pernr    TYPE RANGE OF persno,
         lr_ename    TYPE RANGE OF emnam,
         lr_ap_pernr TYPE RANGE OF persno,
         lr_tlpid    TYPE RANGE OF zhr_prt_tlpid,
         langu       LIKE sy-langu VALUE 'T',
         lr_ap_statu TYPE RANGE OF zhr_prt_statu,
         lv_statu    TYPE zhr_prt_statu,
         lv_begda    TYPE begda VALUE '18000101',
         lv_endda    TYPE endda VALUE '99991231',
         lt_tadmin   TYPE TABLE OF zhr_prt_tadmin. "Admin Onaycı Tablosu

  SET LOCALE LANGUAGE  langu.

  lv_begda   = sy-datum - 80.
  lv_endda   = sy-datum + 80.


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

  IF i_pernr IS NOT INITIAL .
    APPEND VALUE #( sign = 'I' option = 'EQ' low = i_pernr ) TO lr_pernr.
  ENDIF.

  IF i_ename IS NOT INITIAL .
    APPEND VALUE #( sign = 'I' option = 'CP' low = '*' && i_ename && '*' ) TO lr_ename.
  ENDIF.

  SELECT * FROM zhr_prt_tadmin INTO TABLE lt_tadmin
      WHERE srcid EQ i_srcid . " izin süreci


  IF i_begda IS NOT INITIAL . lv_begda = i_begda.ENDIF.
  IF i_endda IS NOT INITIAL . lv_endda = i_endda.ENDIF.

  IF apr_pernr IS NOT INITIAL .
    APPEND VALUE #( sign = 'I' option = 'EQ' low = apr_pernr ) TO lr_ap_pernr.
  ELSE.
    PERFORM add_message TABLES et_return
                         USING '00001'
                               apr_pernr
                               'ZHR_PRT'
                               'E'
                               '028'
                               ls_return .
    EXIT.
  ENDIF.

  IF i_ap_statu IS NOT INITIAL .
    APPEND VALUE #( sign = 'I' option = 'EQ' low = i_ap_statu ) TO lr_ap_statu.
  ELSEIF i_admin EQ 'X' AND i_ap_statu IS INITIAL .
    APPEND VALUE #( sign = 'I' option = 'EQ' low = '01' ) TO lr_ap_statu.
  ELSEIF i_admin EQ 'X' AND i_ap_statu IS NOT INITIAL .
    APPEND VALUE #( sign = 'I' option = 'EQ' low = i_ap_statu ) TO lr_ap_statu.
  ENDIF.

  IF i_awart IS NOT INITIAL .
    APPEND VALUE #( sign = 'I' option = 'EQ' low = i_awart ) TO lr_awart.
  ENDIF.

*  " Portal +2001 izin verileri
  PERFORM get_leave_list TABLES et_list lr_pernr lr_awart
                          USING i_srcid
                                lv_begda
                                lv_endda.

  IF i_admin EQ 'X'.
    LOOP AT lt_tadmin INTO DATA(ls_tadmn) WHERE pernr IN lr_ap_pernr[].ENDLOOP. " Admin onaycı ise herkesi görsün
    IF sy-subrc NE 0  .
      DELETE et_list WHERE NOT ap_pernr IN lr_ap_pernr[].
    ENDIF.
  ELSE.
    DELETE et_list WHERE NOT ap_pernr IN lr_ap_pernr[].
  ENDIF.

  DELETE et_list WHERE NOT ap_statu IN lr_ap_statu[]  .

  SORT et_list ASCENDING BY tlpid pernr seqnr begda endda .
  IF et_list IS INITIAL   .
    PERFORM add_message TABLES et_return
                         USING '00001'
                               apr_pernr
                               'ZHR_PRT'
                               'E'
                               '024'
                               ls_return .
  ENDIF.

ENDFUNCTION.
