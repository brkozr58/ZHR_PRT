FUNCTION zhr_prt_fg001_04.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_PERNR) TYPE  PERSNO
*"     VALUE(I_FPPER) TYPE  SPMON OPTIONAL
*"     VALUE(I_FNAME) TYPE  HRF_NAME DEFAULT '$CEDT$'
*"  EXPORTING
*"     VALUE(EV_DOCUMENT) TYPE  XSTRING
*"     VALUE(EV_DOC_SIZE) TYPE  INT4
*"     VALUE(ET_RGDIR) TYPE  HRPY_TT_RGDIR
*"     VALUE(ET_RETURN) TYPE  ZHR_PRT_TRETURN
*"     VALUE(EV_APPROV) TYPE  FLAG
*"----------------------------------------------------------------------
  DATA : lo_helper TYPE REF TO cl_hrxss_rem_helper,
         lt_rgdir  TYPE  hrpy_tt_rgdir,
         ls_return TYPE  bapireturn1,
*         lt_donem  TYPE TABLE OF zsf_t_bordrodnm,
         lr_fpper  TYPE RANGE OF faper,
         ls_t003   TYPE zhr_prt_t003,
         lv_form   TYPE hrf_name VALUE '$CEDT$',
         lv_ztime  TYPE zhr_prt_t003-ztime.

  DATA langu LIKE sy-langu VALUE 'T'.
  SET LOCALE LANGUAGE  langu.


*  SELECT * FROM zsf_t_bordrodnm INTO TABLE lt_donem.

  SELECT SINGLE approv ztime FROM zhr_prt_t003 INTO (ev_approv, lv_ztime)
      WHERE pernr EQ i_pernr
        AND spmon EQ i_fpper
        AND ztime EQ ( SELECT MAX( ztime ) FROM zhr_prt_t003
                                      WHERE pernr EQ i_pernr
                                        AND spmon EQ i_fpper )
    .


  IF i_fname IS NOT INITIAL .
    lv_form = i_fname.
  ENDIF.
  lo_helper = NEW #( i_pernr ).
  lo_helper->get_rgdir(
    RECEIVING
      rt_rgdir = lt_rgdir[]
  ).

  IF i_fpper IS INITIAL .
*    lr_fpper = VALUE #( FOR ls IN lt_donem ( sign = 'I' option = 'LT' low = ls-zfpper ) ) .
    DELETE lt_rgdir WHERE  fpper IN lr_fpper[].
    et_rgdir = lt_rgdir.
  ELSE.
    READ TABLE lt_rgdir INTO DATA(ls_rgdir) WITH KEY fpper = i_fpper.
    CHECK sy-subrc EQ 0 .
    SELECT SINGLE * FROM zhr_prt_t003 INTO ls_t003
      WHERE pernr  EQ i_pernr
        AND spmon  LT i_fpper
        AND approv NE 'X'.
    IF sy-subrc EQ 0 AND i_fpper GE '202601'.
      ls_return-message_v1 = ls_t003-spmon+4(2) && '.' && ls_t003-spmon(4).
      PERFORM add_message TABLES et_return
                           USING ''
                                 i_pernr
                                 'ZHR_PRT'
                                 'E'
                                 '021'
                                 ls_return .
      EXIT.
    ENDIF.

    DATA : ev_spool TYPE  rspoid.
    CALL FUNCTION 'ZHR_PRT_PAYROLL'
      EXPORTING
        iv_pernr    = i_pernr
        iv_forml    = 'ICSF'
        iv_fpper    = ls_rgdir-fpper
      IMPORTING
        ev_document = ev_document
        ev_doc_size = ev_doc_size
        ev_spool    = ev_spool.
*    lo_helper->get_payslip(
*      EXPORTING
*        is_rgdir                   = ls_rgdir
*        iv_form_name               = lv_form
*      IMPORTING
*        ev_document                = ev_document
*        ev_doc_size                = ev_doc_size
*      EXCEPTIONS
*        ex_payslip_creation_failed = 1
*        OTHERS                     = 2
*    ).
    IF sy-subrc <> 0.
      ls_return-id         = sy-msgid.
      ls_return-type       = sy-msgty.
      ls_return-number     = sy-msgno.
      ls_return-message_v1 = sy-msgv1.
      ls_return-message_v2 = sy-msgv2.
      ls_return-message_v3 = sy-msgv3.
      ls_return-message_v4 = sy-msgv4.

      PERFORM add_message TABLES et_return
                           USING ''
                                 ''
                                 'ZHR_PRT'
                                 'E'
                                 '000'
                                 ls_return .
      CLEAR : ls_return .
      PERFORM add_message TABLES et_return
                           USING ''
                                 ''
                                 'ZHR_PRT'
                                 'E'
                                 '022'
                                 ls_return .
    ELSE.
      GET TIME STAMP FIELD ls_t003-ztime.
      ls_t003-pernr   = i_pernr.
      ls_t003-spmon   = i_fpper.
      ls_t003-approv  =  ev_approv.
      ls_t003-aedtm   = sy-datum.
      ls_t003-uname   = i_pernr.
*      ls_t003-uname   = sy-uname.
      MODIFY zhr_prt_t003 FROM ls_t003.
    ENDIF.


  ENDIF.

ENDFUNCTION.
