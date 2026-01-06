FUNCTION zhr_prt_payroll.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_PERNR) TYPE  PERSNO
*"     REFERENCE(IV_FORML) TYPE  FORMU_514D DEFAULT 'ICSF'
*"     REFERENCE(IV_FPPER) TYPE  FPPER
*"  EXPORTING
*"     REFERENCE(EV_DOCUMENT) TYPE  XSTRING
*"     REFERENCE(EV_DOC_SIZE) TYPE  INT4
*"     REFERENCE(EV_SPOOL) TYPE  RSPOID
*"----------------------------------------------------------------------
*Types
  TYPES:
    t_pripar TYPE pri_params,
    t_arcpar TYPE arc_params.
  "Work areas
  DATA:
    lw_pripar TYPE t_pripar,
    l_valid   TYPE string,
    lw_arcpar TYPE t_arcpar.


  DATA: lv_string           TYPE  string,
        ls_print_parameters TYPE pri_params,
        lv_listname         TYPE pri_params-plist VALUE 'PORTAL_PAYROLL',
        list_text2          TYPE pri_params-prtxt.

  DATA:
    l_lay   TYPE pri_params-paart,
    l_lines TYPE pri_params-linct,
    l_cols  TYPE pri_params-linsz,
    l_val   TYPE c.

  DATA : lt_rspar TYPE TABLE OF rsparams,
         ls_rspar TYPE rsparams.

  TYPES: BEGIN OF linetype,
           sign   TYPE c LENGTH 1,
           option TYPE c LENGTH 2,
           low    TYPE spmon,
           high   TYPE spmon,
         END OF linetype.


  DATA : lr_range TYPE RANGE OF linetype.
  DATA : ls_range LIKE LINE OF lr_range.

  ls_rspar-selname = 'PNPPERNR'.
  ls_rspar-kind    = 'S'.
  ls_rspar-sign    = 'I'.
  ls_rspar-option  = 'EQ'.
  ls_rspar-low     = iv_pernr.
  APPEND ls_rspar TO lt_rspar.
  ls_range-low = iv_fpper.
  ls_range-high = iv_fpper.
  ls_range-sign = 'I'.
  ls_range-option = 'EQ'.
  APPEND ls_range TO lr_range.


  CONCATENATE iv_pernr 'PRT' INTO lv_listname SEPARATED BY  space .
  CONCATENATE iv_pernr iv_fpper sy-uzeit INTO list_text2 SEPARATED BY  '-' .

  l_lay   = 'X_PAPER'.
  l_lines = 65.
  l_cols  = 135.

  CALL FUNCTION 'GET_PRINT_PARAMETERS'
    EXPORTING
      in_archive_parameters  = lw_arcpar
      in_parameters          = lw_pripar
      layout                 = l_lay
      line_count             = l_lines
      line_size              = l_cols
      abap_list              = 'X'
      list_name              = lv_listname
      list_text              = list_text2
      no_dialog              = 'X'
    IMPORTING
      out_archive_parameters = lw_arcpar
      out_parameters         = ls_print_parameters
    EXCEPTIONS
      archive_info_not_found = 1
      invalid_print_params   = 2
      invalid_archive_params = 3
      OTHERS                 = 4.

  SUBMIT zhr_prt_p002
          WITH formular EQ 'ICSF'
           WITH s_fpper IN  lr_range
          WITH SELECTION-TABLE lt_rspar
             AND RETURN TO SAP-SPOOL
              SPOOL PARAMETERS ls_print_parameters WITHOUT SPOOL DYNPRO
              .
  SELECT * FROM tsp01 INTO TABLE @DATA(lt_tsp01)
    WHERE
      rqclient  = @sy-mandt  AND
      rqtitle   = @list_text2 AND
      rq2name   = @lv_listname AND
      rqowner   = @sy-uname
    .
  CHECK sy-subrc EQ 0 .

  SORT lt_tsp01 DESCENDING BY rqcretime.
  READ TABLE lt_tsp01 ASSIGNING FIELD-SYMBOL(<tsp01>)
  INDEX 1.
  ev_spool = <tsp01>-rqident.

  DATA :
        lt_pdf TYPE TABLE OF tline.
  DATA : pdf_bytecount TYPE  i .
  DATA : lv_dst_device LIKE  tsp03-padest VALUE 'LP01'.
  CALL FUNCTION 'CONVERT_ABAPSPOOLJOB_2_PDF'
    EXPORTING
      src_spoolid              = ev_spool
      dst_device               = lv_dst_device
      no_dialog                = 'X'
    IMPORTING
      pdf_bytecount            = pdf_bytecount
    TABLES
      pdf                      = lt_pdf
    EXCEPTIONS
      err_no_abap_spooljob     = 1
      err_no_spooljob          = 2
      err_no_permission        = 3
      err_conv_not_possible    = 4
      err_bad_destdevice       = 5
      user_cancelled           = 6
      err_spoolerror           = 7
      err_temseerror           = 8
      err_btcjob_open_failed   = 9
      err_btcjob_submit_failed = 10
      err_btcjob_close_failed  = 11
      OTHERS                   = 12.
  FIELD-SYMBOLS: <x>          TYPE any.
*  DATA :lv_string   TYPE string.
  LOOP AT lt_pdf INTO DATA(ls_line).
    lv_string = ls_line.
    UNASSIGN <x>.
    ASSIGN ls_line TO <x> CASTING TYPE x.
    IF <x> IS ASSIGNED .
      CONCATENATE ev_document <x> INTO ev_document
      IN BYTE MODE.
    ENDIF.
  ENDLOOP.

  ev_doc_size = pdf_bytecount.
  IF ev_spool IS NOT INITIAL .
    DATA : spoolid TYPE tsp01_sp0r-rqid_char .
    spoolid = ev_spool.
    CALL FUNCTION 'RSPO_R_RDELETE_SPOOLREQ'
      EXPORTING
        spoolid = spoolid.
  ENDIF.


ENDFUNCTION.
