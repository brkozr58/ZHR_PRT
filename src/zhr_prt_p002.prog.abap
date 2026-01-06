*&---------------------------------------------------------------------*
*& Report ZHR_PRT_P002
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhr_prt_p002.

TABLES : pernr , s001."pernr logical databsssssçin tanımlanır

INFOTYPES : 0001.

"""""standarttan alındı ---------------------
CONSTANTS:
  BEGIN OF f__ltype,                    "type of line
    cmd LIKE pc408-ltype   VALUE '/:',    "command
    txt LIKE pc408-ltype   VALUE '  ',    "textline
  END OF f__ltype.

CONSTANTS:
  BEGIN OF f__cmd,                      "commands
    newpage LIKE pc408-linda    VALUE '<NEW-PAGE>',
  END OF f__cmd.

DATA:
    $form_wa  LIKE pc408.
"""""standarttan alındı ---------------------


DATA: l_params   TYPE pri_params,
      l_valid    TYPE string,
      w_spool_nr LIKE tsp01-rqident.
* Internal table for Selection Screen
DATA: BEGIN OF i_rsparams OCCURS 0.
        INCLUDE STRUCTURE rsparams.
DATA: END OF i_rsparams.
DATA : rsparams TYPE rsparams.
DATA : pdf_size TYPE so_obj_len.

DATA : gt_xform LIKE pc408 OCCURS 0 WITH HEADER LINE.

*---------gt_period---------------
DATA :BEGIN OF gt_period OCCURS 0 ,
        period LIKE s001-spmon,
        begda  TYPE sy-datum,
        endda  TYPE sy-datum,
      END OF gt_period.

"selection screen *-*****************************

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-000 .
  SELECT-OPTIONS : s_fpper FOR s001-spmon DEFAULT sy-datum.
  PARAMETERS     : formular  LIKE ppe51_1000-forml DEFAULT 'ICSF'
      MATCHCODE OBJECT zetpa_sh006.
SELECTION-SCREEN END OF BLOCK bl1.
*------------------------------------------------

INCLUDE rpcmf000.

INITIALIZATION.


  CLEAR : pnpsort , pnpsort[].
  APPEND VALUE #( tabname   = 'PS0001'
                  fieldname = 'KOSTL' )
            TO pnpsort.

START-OF-SELECTION.
  PERFORM set_values.

GET pernr."""logical data base get pernr end-of-sel arasında çalışır
  PERFORM set_data.

END-OF-SELECTION.
  PERFORM write.

*&---------------------------------------------------------------------*
*&      Form  set_values
*&---------------------------------------------------------------------*
FORM set_values.
  REFRESH i_rsparams.
  CALL FUNCTION 'RS_REFRESH_FROM_SELECTOPTIONS'
    EXPORTING
      curr_report     = sy-repid
    TABLES
      selection_table = i_rsparams
    EXCEPTIONS
      not_found       = 1
      no_report       = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
  ENDIF.

  PERFORM set_donem.

  rsparams-selname  = 'FORMULAR'.
  rsparams-kind = 'P'.
  rsparams-low = formular.
  APPEND rsparams TO i_rsparams.
ENDFORM.                    "set_values
*&---------------------------------------------------------------------*
*&      Form  set_data
*&---------------------------------------------------------------------*
FORM set_data.


  LOOP AT gt_period.

    rp-provide-from-last p0001 space gt_period-begda gt_period-endda.
    "bu aydaki son kaydı gelir bordro alt birimi okunur
    CHECK p0001-stell IN pnpstell AND
          p0001-kostl IN pnpkostl .
    "ekran seçim değerleri silinir  manuel eklenir
    DELETE i_rsparams  WHERE selname EQ 'PNPXABKR'
                          OR selname EQ 'PNPPABRP'
                          OR selname EQ 'PNPPABRJ'
                          OR selname EQ 'PNPTIMRA'
                          OR selname EQ 'PNPTIMR9'
                          OR selname EQ 'PNPPERNR'
                          OR selname EQ 'EXP_FRM'
                          OR selname EQ 'PRT_PROT'.
    "yazdırma notlarını
    "kapatır
    "kapatıldı 16.01.2025 sy
****    CHECK pernr-btrtl IN pnpbtrtl.

    rsparams-selname  = 'PNPXABKR'."personelin bordro alt birimi eklenir
    rsparams-kind = 'P'.
    rsparams-low = p0001-abkrs.
    APPEND rsparams TO i_rsparams.

    rsparams-selname  = 'PNPPERNR'.
    rsparams-kind = 'P'.
    rsparams-low = p0001-pernr.
    APPEND rsparams TO i_rsparams.

    rsparams-selname  = 'PNPWERKS'.
    rsparams-kind = 'P'.
    rsparams-low = p0001-werks.
    APPEND rsparams TO i_rsparams.

    rsparams-selname  = 'PNPBTRTL'.
    rsparams-kind = 'P'.
    rsparams-low = p0001-btrtl.
    APPEND rsparams TO i_rsparams.

    rsparams-selname  = 'PNPPABRP'.
    rsparams-kind = 'P'.
    rsparams-low = gt_period-period+4(2).
    APPEND rsparams TO i_rsparams.

    rsparams-selname  = 'PNPPABRJ'.
    rsparams-kind = 'P'.
    rsparams-low = gt_period-period+0(4).
    APPEND rsparams TO i_rsparams.

    rsparams-selname  = 'PNPTIMRA'."diğer dönem seçimi
    rsparams-kind = 'P'.
    rsparams-low = 'X'.
    APPEND rsparams TO i_rsparams.

    rsparams-selname  = 'PNPTIMR9'."car, dönem seçimi ipt.
    rsparams-kind = 'P'.
    rsparams-low = space.
    APPEND rsparams TO i_rsparams.

    rsparams-selname  = 'EXP_FRM'.
    rsparams-kind = 'P'.
    rsparams-low = 'X'.
    APPEND rsparams TO i_rsparams.

    rsparams-selname  = 'PRT_PROT'.
    rsparams-kind = 'P'.
    rsparams-low = space.
    APPEND rsparams TO i_rsparams.

    IF p0001 IS NOT INITIAL.
      SUBMIT htrcedt0 WITH SELECTION-TABLE i_rsparams
                                      AND RETURN.
    ENDIF.
    f0-key-pernr = pernr-pernr.
    f0-key-seqno = '0'.
    UNPACK f0-key-seqno TO f0-key-seqno.

    REFRESH xform.
    IMPORT xinfo   xform FROM   MEMORY   ID f0-key.

    LOOP AT xform.
      MOVE xform TO gt_xform.
      APPEND gt_xform.
    ENDLOOP.

  ENDLOOP.
ENDFORM.                    "set_data
*&---------------------------------------------------------------------*
*&      Form  set_donem
*&---------------------------------------------------------------------*
FORM set_donem.
  DATA : lv_begda LIKE s001-spmon,
         lv_endda LIKE s001-spmon.

  IF s_fpper-high IS INITIAL.
    s_fpper-high = s_fpper-low.
  ENDIF.

  CLEAR : gt_period,gt_period[].
  lv_begda = s_fpper-low.
  lv_endda = s_fpper-high.

  DATA: lv_spmon LIKE s001-spmon.
  lv_spmon = lv_begda.
  WHILE lv_spmon <= lv_endda+0(6).
    MOVE: lv_spmon TO gt_period-period.

    CONCATENATE gt_period-period'01' INTO gt_period-begda.
    PERFORM get_last_day_of_month USING gt_period-begda
                                  CHANGING gt_period-endda.

    APPEND gt_period. CLEAR gt_period.
    ADD 1 TO lv_spmon.
    CHECK lv_spmon+4(2) = '13'.
    lv_spmon+4(2) = '01'.
    lv_spmon+0(4) = lv_spmon+0(4) + 1.
  ENDWHILE.
ENDFORM.                    "set_donem

*&--------------------------------------------------------------------*
*&      Form  get_last_day_of_month
*&--------------------------------------------------------------------*
FORM get_last_day_of_month USING    p_begda
                           CHANGING p_endda.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = p_begda
    IMPORTING
      last_day_of_month = p_endda.

ENDFORM.                    "get_last_day_of_month
*&---------------------------------------------------------------------*
*&      Form  write
*&---------------------------------------------------------------------*
FORM write .
  "standartta olduğ gibi yazdırılır.
  SET BLANK LINES ON.
  LOOP AT gt_xform  .
    CASE gt_xform-ltype.
      WHEN f__ltype-cmd.
        IF gt_xform-linda EQ f__cmd-newpage.
          NEW-PAGE.
        ENDIF.
      WHEN f__ltype-txt.
        WRITE: / gt_xform-linda.
    ENDCASE.
  ENDLOOP.
  SET BLANK LINES OFF.
  NEW-PAGE.

ENDFORM.                    "write
