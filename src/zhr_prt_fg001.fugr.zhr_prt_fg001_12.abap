FUNCTION zhr_prt_fg001_12.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SRCID) TYPE  ZHR_PRT_SRCID DEFAULT '00001'
*"     VALUE(APR_PERNR) TYPE  PERSNO
*"     VALUE(IS_LEAVE) TYPE  ZHR_PRT_S016
*"  EXPORTING
*"     VALUE(EV_TLPID) TYPE  ZHR_PRT_TLPID
*"     VALUE(ET_RETURN) TYPE  ZHR_PRT_TRETURN
*"----------------------------------------------------------------------

  DATA : langu     LIKE sy-langu VALUE 'T',
         ls_return TYPE bapireturn1,
         ls_leave  TYPE  zhr_prt_s016,

         lt_tadmin TYPE TABLE OF zhr_prt_tadmin, "Admin Onaycı Tablosu
         ls_tadmn  TYPE   zhr_prt_tadmin. "Admin Onaycı Tablosu

  SET LOCALE LANGUAGE  langu.

  IF i_srcid IS INITIAL  .
    CLEAR ls_return.
    PERFORM add_message TABLES et_return
                         USING i_srcid
                               apr_pernr
                               'ZHR_PRT'
                               'E'
                               '023'
                               ls_return .
    READ TABLE et_return TRANSPORTING NO FIELDS WITH KEY type = 'E'.
    CHECK sy-subrc NE 0 .
  ENDIF.

  "<<--------Zaman Yöneticileri ------>>
  PERFORM get_gt_zmynt TABLES gt_zmynt
                        USING sy-datum
                              'SAPU'
                              'PA01' .
  "<<--------END CODE------>>


  SELECT SINGLE  * FROM zhr_prt_tadmin INTO ls_tadmn
      WHERE srcid EQ i_srcid  " izin süreci
        AND pernr EQ apr_pernr.
  READ TABLE gt_zmynt INTO DATA(ls_zmynt) WITH KEY pernr = apr_pernr.
  IF ls_tadmn IS INITIAL AND ls_zmynt IS INITIAL .
    CLEAR ls_return.
    ls_return-message_v1 = apr_pernr.
    PERFORM add_message TABLES et_return
                         USING i_srcid
                               apr_pernr
                               'ZHR_PRT'
                               'E'
                               '017'
                               ls_return .
    READ TABLE et_return TRANSPORTING NO FIELDS WITH KEY type = 'E'.
    CHECK sy-subrc NE 0 .
  ENDIF.
  "<<--------Check Leave------>>
  MOVE-CORRESPONDING is_leave TO ls_leave.
  CALL FUNCTION 'ZHR_PRT_FG001_08'
    EXPORTING
      i_srcid   = i_srcid
      is_leave  = ls_leave
      cr_pernr  = apr_pernr
    IMPORTING
      ev_tlpid  = ev_tlpid
      et_return = et_return.

ENDFUNCTION.
