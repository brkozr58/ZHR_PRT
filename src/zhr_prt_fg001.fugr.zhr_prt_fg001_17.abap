FUNCTION zhr_prt_fg001_17.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_PERNR) TYPE  PERSNO
*"     VALUE(I_FPPER) TYPE  SPMON
*"     VALUE(I_APPROV) TYPE  FLAG
*"  EXPORTING
*"     VALUE(ET_RETURN) TYPE  ZHR_PRT_TRETURN
*"----------------------------------------------------------------------
  DATA : lo_helper TYPE REF TO cl_hrxss_rem_helper,
         lt_rgdir  TYPE  hrpy_tt_rgdir,
         ls_return TYPE  bapireturn1,
*         lt_donem  TYPE TABLE OF zsf_t_bordrodnm,
         lr_fpper  TYPE RANGE OF faper,
         ls_t003   TYPE zhr_prt_t003.

  DATA langu LIKE sy-langu VALUE 'T'.
  SET LOCALE LANGUAGE  langu.

*  SELECT * FROM zsf_t_bordrodnm INTO TABLE lt_donem.

  lo_helper = NEW #( i_pernr ).
  lo_helper->get_rgdir(
    RECEIVING
      rt_rgdir = lt_rgdir[]
  ).


  IF i_fpper IS NOT INITIAL .
    READ TABLE lt_rgdir INTO DATA(ls_rgdir) WITH KEY fpper = i_fpper.
    CHECK sy-subrc EQ 0 .
    GET TIME STAMP FIELD ls_t003-ztime.
    ls_t003-pernr   = i_pernr.
    ls_t003-spmon   = i_fpper.
    ls_t003-approv   = i_approv.
    ls_t003-aedtm   = sy-datum.
    ls_t003-uname   = sy-uname.
    MODIFY zhr_prt_t003 FROM ls_t003.

    CLEAR ls_return.
    PERFORM add_message TABLES et_return
                         USING ''
                               i_pernr
                               'ZHR_PRT'
                               'S'
                               '031'
                               ls_return .
  ENDIF.
ENDFUNCTION.
