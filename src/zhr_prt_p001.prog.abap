*&---------------------------------------------------------------------*
*& REPORT ZHR_PRT_P001
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhr_prt_p001.

TABLES : pa0001            ,
         zhr_prt_t001      ," PORTAL KULLANıCıLARı LOG TABLOSU
         zhr_prt_t002      ," KVKK METINLERI
         zhr_prt_tkvkk     ." PERSONEL BAZLı KVKK LOGLARı

CLASS lcl_alv     DEFINITION DEFERRED    .


INCLUDE zhr_prt_i001.
DATA : BEGIN OF gt_users OCCURS 0 .
         INCLUDE TYPE zhr_prt_ddl001.
DATA :   mark,
         message  TYPE text100,
         color(4) TYPE c,                      "<----Color field
       END OF gt_users,
       go_alv TYPE REF TO lcl_alv.



SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE TEXT-000  .
  SELECT-OPTIONS : s_pernr    FOR pa0001-pernr NO INTERVALS  .
  PARAMETERS     : p_datum    TYPE datum OBLIGATORY DEFAULT sy-datum .
  PARAMETERS     : pr_all  RADIOBUTTON GROUP rd1 DEFAULT 'X' USER-COMMAND rdg,
                   pr_actv RADIOBUTTON GROUP rd1,
                   pr_pasv RADIOBUTTON GROUP rd1.

SELECTION-SCREEN END OF BLOCK bl1.

INITIALIZATION .

  go_alv = NEW #( 'ZHR_PRT_DDL001' ).

*  AT SELECTION-SCREEN
AT SELECTION-SCREEN   .
  PERFORM at_selection-screen   .


*  START-OF-SELECTION .
START-OF-SELECTION .
  PERFORM start-of-selection .


*END-OF-SELECTION.
END-OF-SELECTION.
  PERFORM end-of-selection.










*&---------------------------------------------------------------------*
*& FORM SEND_USER
*&---------------------------------------------------------------------*
FORM send_user.

  DATA:

        ls_t001  TYPE zhr_prt_t001,
        ls_users TYPE zhr_prt_ddl001,
        lt_rows  TYPE lvc_t_row,
        lt_rown  TYPE lvc_t_roid,
        lv_pass  TYPE char100,
        lv_token TYPE string,
        lv_error TYPE string,
        message  TYPE string,
        lv_oper  TYPE char10.

  IF sy-batch NE 'X'.
    go_alv->mo_grid->get_selected_rows(
            IMPORTING
              et_index_rows = lt_rows
              et_row_no     = lt_rown
          ).

    LOOP AT lt_rown ASSIGNING FIELD-SYMBOL(<ls_rown>).
      READ TABLE gt_users ASSIGNING FIELD-SYMBOL(<ls_users>) INDEX <ls_rown>-row_id.
      CHECK sy-subrc EQ 0 .
      <ls_users>-mark = 'X' .
    ENDLOOP.
  ELSE.
    LOOP AT gt_users ASSIGNING <ls_users> ." WHERE activ EQ 'A'       " SAdece aktif kullanıcılar
      "   AND smscd IS INITIAL . " daha önce sms almamışsa.
      <ls_users>-mark = 'X' .
    ENDLOOP.
  ENDIF.

  LOOP AT gt_users ASSIGNING <ls_users> WHERE mark EQ 'X'.
    MOVE-CORRESPONDING <ls_users> TO ls_users .
    CASE <ls_users>-activ .
      WHEN 'A'. lv_oper = 'true'.
      WHEN 'P'. lv_oper = 'false'.
    ENDCASE.

    CLEAR : ls_t001.

    ls_t001-pernr = <ls_users>-pernr.
    ls_t001-begda = <ls_users>-begda.
    ls_t001-aedtm = sy-datum.
    ls_t001-activ = <ls_users>-activ.

    SHIFT ls_users-pernr LEFT DELETING LEADING '0'.
    CALL FUNCTION 'ZHR_PRT_USER_OPERATION'
      EXPORTING
        i_oper   = lv_oper
        is_pers  = ls_users
      IMPORTING
        error    = lv_error
        message  = message
      CHANGING
        cv_token = lv_token.
    CASE lv_error .
      WHEN 'E'.
        <ls_users>-color = 'C600'.
      WHEN OTHERS.
        <ls_users>-color = 'C510'.
        MODIFY zhr_prt_t001 FROM ls_t001.
    ENDCASE.
    <ls_users>-pernr = ls_t001-pernr.
    <ls_users>-message = message. CLEAR : message.CLEAR : lv_error.
    <ls_users>-mark = '' .
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM AT_SELECTION-SCREEN
*&---------------------------------------------------------------------*
FORM at_selection-screen .

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM START-OF-SELECTION
*&---------------------------------------------------------------------*
FORM start-of-selection .

  DATA : lt_users TYPE zhr_prt_tt001.

  IF s_pernr[] IS NOT INITIAL.
    SELECT * FROM pa0001 INTO TABLE @DATA(lt_0001)
          WHERE pernr IN @s_pernr[]
            AND endda GE @p_datum.

    LOOP AT lt_0001 INTO DATA(ls_0001).
      CALL FUNCTION 'ZHR_PRT_FG001_01'
        EXPORTING
          i_datum   = sy-datum
          i_all     = pr_all
          i_pernr   = ls_0001-pernr
          i_active  = pr_actv
          i_passive = pr_pasv
        IMPORTING
          et_users  = lt_users.
      APPEND LINES OF lt_users TO gt_users.

    ENDLOOP.
  ELSE.
    CALL FUNCTION 'ZHR_PRT_FG001_01'
      EXPORTING
        i_datum   = sy-datum
        i_all     = pr_all
*       i_pernr   = ls_0001-pernr
        i_active  = pr_actv
        i_passive = pr_pasv
      IMPORTING
        et_users  = lt_users.
    APPEND LINES OF lt_users TO gt_users.

  ENDIF.

*
  SORT gt_users ASCENDING BY pernr .

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM MODIFY_FCAT
*&---------------------------------------------------------------------*
FORM modify_fcat .
  DATA : ls_fcat     TYPE lvc_s_fcat.

  ls_fcat-fieldname = 'MESSAGE'.
  APPEND ls_fcat TO go_alv->mt_fcat.
*  mt_fcat


  ls_fcat-fieldname = 'COLOR'.
  APPEND ls_fcat TO go_alv->mt_fcat.

  go_alv->modify_target_value( fname = 'ZOPER'    targt  = 'COLPOS' zvalue = '1' ).
  go_alv->modify_target_value( fname = 'SMSCD'    targt  = 'NO_OUT' zvalue = 'X' ).
  go_alv->modify_target_value( fname = 'MARK'    targt  = 'NO_OUT' zvalue = 'X' ).
  go_alv->modify_target_value( fname = 'COLOR'   targt  = 'NO_OUT' zvalue = 'X' ).
  go_alv->modify_target_value( fname = 'MESSAGE' targt  = 'TEXT'   zvalue = 'Durum' ).

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM HANDLE_TOOLBAR
*&---------------------------------------------------------------------*
FORM handle_toolbar  TABLES pt_toolbar STRUCTURE stb_button.


  DEFINE insert_value .
    INSERT VALUE #( butn_type = 0
                    function  = &1
                    icon      = &2
                    disabled  = space
                    text      = &3
                    quickinfo = &3
                    )
            INTO TABLE pt_toolbar.
  END-OF-DEFINITION.

  INSERT VALUE #( butn_type = 3 )
          INTO TABLE pt_toolbar.

  insert_value :
    'SEND_USER'    icon_sap_logon_userdefined   TEXT-ins .



ENDFORM.
*&---------------------------------------------------------------------*
*& FORM END-OF-SELECTION
*&---------------------------------------------------------------------*
FORM end-of-selection .

  CHECK gt_users[] IS NOT INITIAL .

  CASE sy-batch .
    WHEN 'X'.
      PERFORM send_user .
    WHEN OTHERS.
      CALL SCREEN 0100.
  ENDCASE.



ENDFORM.
*&---------------------------------------------------------------------*
*& MODULE STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'GUI'.

  CHECK go_alv->mo_splitter IS NOT BOUND.
  go_alv->split_container( scrfname = 'CONT' screen   = '0100' ).
  go_alv->mo_alv_cont = go_alv->mo_splitter->get_container( row    = 2
                                            column = 1 ).


  go_alv->mo_grid = NEW #( i_parent = go_alv->mo_alv_cont ).

  IF go_alv IS BOUND.
    go_alv->set_layout( ).

    go_alv->ms_layout-info_fname  = 'COLOR'.
    go_alv->ms_layout-col_opt = 'X'.
    go_alv->create_fcat( ).
    go_alv->exclude_buttons( ).
    go_alv->set_top_of_page(
      CHANGING
        mo_splitter = go_alv->mo_splitter
    ).
    go_alv->set_events( ).
    go_alv->display_alv_grid(
      CHANGING
        it_main = gt_users[] ).
  ENDIF.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      MODULE  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  DATA : popup_return .

  DATA : lv_ucomm TYPE sy-ucomm .
  lv_ucomm = sy-ucomm.
  CASE lv_ucomm.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL' .
      LEAVE TO SCREEN 0 .
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& FORM HANDLE_USER_COMMAND
*&---------------------------------------------------------------------*
FORM handle_user_command  USING    pe_ucomm TYPE sy-ucomm .

  CASE pe_ucomm.
    WHEN 'SEND_USER'.
      PERFORM send_user .
    WHEN OTHERS.
      cl_gui_cfw=>dispatch( ).

  ENDCASE.
ENDFORM.
