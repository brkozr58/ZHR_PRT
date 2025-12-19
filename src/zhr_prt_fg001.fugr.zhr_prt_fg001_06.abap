FUNCTION zhr_prt_fg001_06.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SRCID) TYPE  ZHR_PRT_SRCID DEFAULT '00001'
*"     VALUE(I_PERNR) TYPE  PERSNO OPTIONAL
*"     VALUE(I_BEGDA) TYPE  BEGDA DEFAULT SY-DATUM
*"     VALUE(I_ENDDA) TYPE  ENDDA DEFAULT SY-DATUM
*"     VALUE(I_AWART) TYPE  AWART OPTIONAL
*"     VALUE(I_STATU) TYPE  ZHR_PRT_STATU OPTIONAL
*"  EXPORTING
*"     VALUE(ET_LIST) TYPE  ZHR_PRT_TT017
*"     VALUE(ET_RETURN) TYPE  ZHR_PRT_TRETURN
*"----------------------------------------------------------------------

  DATA : lr_tlpid    TYPE RANGE OF zhr_prt_tlpid,
         lr_statu    TYPE RANGE OF zhr_prt_statu,
         lr_awart    TYPE RANGE OF awart,
         lr_pernr    TYPE RANGE OF persno,
         ls_return   TYPE bapireturn1,
         lr_ap_statu TYPE RANGE OF zhr_prt_statu,
         lt_data     TYPE TABLE OF zhr_prt_ddl002,
         ls_list     TYPE LINE OF zhr_prt_tt017,
         langu       LIKE sy-langu VALUE 'T'.


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


  IF i_statu IS INITIAL .
*    APPEND VALUE #( sign = 'I' option = 'EQ' low = '01' ) TO lr_statu.
*    APPEND VALUE #( sign = 'I' option = 'EQ' low = '02' ) TO lr_statu.
*    APPEND VALUE #( sign = 'I' option = 'EQ' low = '04' ) TO lr_statu.
*    " Onaycı statüsü
*    APPEND VALUE #( sign = 'I' option = 'EQ' low = '01' ) TO lr_ap_statu.
*    APPEND VALUE #( sign = 'I' option = 'EQ' low = '02' ) TO lr_ap_statu.
  ELSE.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = i_statu ) TO lr_statu.
  ENDIF.

  IF i_awart IS NOT INITIAL .
    APPEND VALUE #( sign = 'I' option = 'EQ' low = i_awart ) TO lr_awart.
  ENDIF.

  IF i_statu EQ '01'.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = '01' ) TO lr_ap_statu.
  ELSEIF i_statu IS NOT INITIAL .
    APPEND VALUE #( sign = 'I' option = 'EQ' low = '02' ) TO lr_ap_statu.
  ENDIF.

  IF i_pernr IS NOT INITIAL .
    APPEND VALUE #( sign = 'I' option = 'EQ' low = i_pernr ) TO lr_pernr.
  ENDIF.

*  " Portal +2001 izin verileri
  PERFORM get_leave_list TABLES et_list lr_pernr lr_awart
                          USING i_srcid
                                i_begda
                                i_endda.
  IF i_statu IS NOT INITIAL .
    DELETE et_list WHERE statu NE i_statu.
  ENDIF.

  IF et_list IS INITIAL   .
    CLEAR ls_return.
    PERFORM add_message TABLES et_return
                         USING i_srcid
                               ''
                               'ZHR_PRT'
                               'E'
                               '024'
                               ls_return .
  ENDIF.

  SORT et_list DESCENDING BY begda endda.

ENDFUNCTION.
