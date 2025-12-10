FUNCTION zhr_prt_fg001_21.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_TLPID) TYPE  ZHR_PRT_TLPID
*"  EXPORTING
*"     VALUE(ET_LIST) TYPE  ZHR_PRT_TT017
*"     VALUE(ET_RETURN) TYPE  ZHR_PRT_TRETURN
*"----------------------------------------------------------------------
  DATA : lr_datum TYPE RANGE OF datum .
  DATA : lr_tlpid TYPE RANGE OF zhr_prt_tlpid .
  DATA : lr_pernr TYPE RANGE OF persno .
  DATA : lt_pers TYPE  zhr_prt_tt020.
  DATA : ls_pers TYPE  zhr_prt_s022.
  DATA : ls_return     TYPE bapireturn1.
  DATA langu LIKE sy-langu VALUE 'T'.


  SET LOCALE LANGUAGE  langu.

  IF i_tlpid IS NOT INITIAL .
    APPEND VALUE #( sign = 'I' option = 'EQ' low = i_tlpid ) TO lr_tlpid.
  ELSE.
    CLEAR ls_return.
    PERFORM add_message TABLES et_return
                         USING ''
                               space
                               'ZHR_PRT'
                               'E'
                               '032'
                               ls_return .
    READ TABLE et_return TRANSPORTING NO FIELDS WITH KEY type = 'E'.
    CHECK sy-subrc NE 0 .
  ENDIF.
*
*  "<<--------Zaman Yöneticileri ------>>
*  PERFORM get_gt_zmynt TABLES gt_zmynt
*                        USING sy-datum
*                              'SAPU'
*                              'PA01' .
*  "<<--------END CODE------>>

*  " Portal izin verileri
  SELECT * FROM zhr_prt_ddl002 AS t1
        INTO CORRESPONDING
      FIELDS OF TABLE @et_list
      WHERE srcid      EQ  '00001'
        AND tlpid      IN  @lr_tlpid[] .
  SORT et_list ASCENDING BY pernr begda endda seqnr.

*  LOOP AT et_list INTO DATA(ls_list) WHERE aptyp EQ 'ZMNY'.
*    READ TABLE gt_zmynt WITH KEY pernr = ls_list-ap_pernr
*                                 sachx = ls_list-sachz.
*    CHECK sy-subrc NE 0 .
*    DELETE et_list WHERE tlpid    EQ ls_list-tlpid
*                     AND ap_pernr EQ ls_list-ap_pernr.
*  ENDLOOP.

  IF et_list[] IS INITIAL .
    CLEAR ls_return.
    PERFORM add_message TABLES et_return
                         USING ''
                               space
                               'ZHR_PRT'
                               'E'
                               '032'
                               ls_return .
  ENDIF.

ENDFUNCTION.
