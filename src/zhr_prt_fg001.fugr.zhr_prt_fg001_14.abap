FUNCTION zhr_prt_fg001_14.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_PERNR) TYPE  PERSNO
*"     VALUE(I_BEGDA) TYPE  BEGDA
*"     VALUE(I_ENDDA) TYPE  ENDDA
*"  EXPORTING
*"     VALUE(ET_PERSON) TYPE  ZHR_PRT_TT013
*"     VALUE(ET_RETURN) TYPE  ZHR_PRT_TRETURN
*"----------------------------------------------------------------------
  DATA : objec_tab TYPE TABLE OF objec WITH HEADER LINE,
         struc_tab TYPE TABLE OF struc WITH HEADER LINE,
         gdstr_tab TYPE TABLE OF gdstr WITH HEADER LINE,
         lr_pernr  TYPE RANGE OF persno WITH HEADER LINE,
         ls_return TYPE  bapireturn1,
         ls_person TYPE zhr_prt_s013,
         lt_head   TYPE TABLE OF hrp1001.

  DATA langu LIKE sy-langu VALUE 'T'.
  SET LOCALE LANGUAGE  langu.


  IF i_pernr IS NOT INITIAL .
    APPEND VALUE #( sign    = 'I' option  = 'EQ' low     = i_pernr )  TO lr_pernr.
  ELSE.
    PERFORM add_message TABLES et_return
                         USING ''
                               ''
                               'ZHR_PRT'
                               'E'
                               '006'
                               ls_return .
  ENDIF.

  SELECT pernr,werks,btrtl,orgeh,plans
      FROM pa0001
    INTO TABLE @DATA(lt_pernr)
    WHERE pernr IN @lr_pernr
      AND endda GE @i_begda
      AND begda LE @i_endda
    .

  LOOP AT lt_pernr INTO DATA(ls_pernr) .
    " OT: Ekip takviminde yönetici kontrolü olmayacak bu nedenle commentlendi."
*    SELECT * FROM hrp1001 INTO TABLE lt_head
*        WHERE plvar EQ '01'
*          AND otype EQ 'S'
*          AND rsign EQ 'A'
*          AND relat EQ '012'
*          AND objid EQ ls_pernr-plans
*          AND endda GE i_begda
*          AND begda LE i_endda .
*    IF sy-subrc NE 0 .
*      PERFORM add_message TABLES et_return
*                           USING ''
*                                 ''
*                                 'ZHR_PRT'
*                                 'E'
*                                 '003'
*                                 ls_return .
*      CHECK 1 = 2 .
*    ENDIF.
    " OT: Ekip takviminde yönetici kontrolü olmayacak bu nedenle commentlendi."
    CALL FUNCTION 'RH_PM_GET_STRUCTURE'
      EXPORTING
        plvar           = '01'
        otype           = 'O'
        objid           = ls_pernr-orgeh
        begda           = i_begda
        endda           = i_endda
        wegid           = 'O-S-P'
        depth           = 99
      TABLES
        objec_tab       = objec_tab
        struc_tab       = struc_tab
        gdstr_tab       = gdstr_tab
      EXCEPTIONS
        not_found       = 1
        ppway_not_found = 2
        OTHERS          = 3.
    IF sy-subrc NE 0 .
      PERFORM add_message TABLES et_return
                           USING ''
                                 ''
                                 'ZHR_PRT'
                                 'E'
                                 '004'
                                 ls_return .
      CHECK 1 = 2 .
    ENDIF.
    SORT objec_tab ASCENDING BY otype .
    DELETE objec_tab WHERE otype NE 'P'.


    LOOP AT objec_tab .
      CLEAR : ls_person.
      ls_person-pernr = objec_tab-objid.
      ls_person-ename = objec_tab-stext.
      CALL FUNCTION 'ZHR_PRT_FG001_13'
        EXPORTING
          i_pernr      = ls_person-pernr
          i_begda      = i_begda
          i_endda      = i_endda
          i_leave_list = 'X'
        IMPORTING
          et_wschedule = ls_person-t_wschdl
          et_return    = ls_person-t_return.
      CHECK ls_person-t_wschdl IS NOT INITIAL .
      APPEND ls_person TO et_person.
    ENDLOOP.


  ENDLOOP.


ENDFUNCTION.
