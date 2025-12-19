FUNCTION zhr_prt_fg001_13.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_PERNR) TYPE  PERSNO
*"     VALUE(I_BEGDA) TYPE  BEGDA
*"     VALUE(I_ENDDA) TYPE  ENDDA
*"     VALUE(I_LEAVE_LIST) TYPE  FLAG OPTIONAL
*"  EXPORTING
*"     VALUE(ET_WSCHEDULE) TYPE  ZHR_PRT_TT012
*"     VALUE(ET_RETURN) TYPE  ZHR_PRT_TRETURN
*"----------------------------------------------------------------------
  DATA : pernr_tab         TYPE TABLE OF pdpnr,
         psp               TYPE TABLE OF pdpsp,
         day_psp           TYPE TABLE OF pdsppsp,
         perws             TYPE TABLE OF ptpsp,
         day_attributes	   TYPE TABLE OF casdayattr,
         ch_auth_infty_tab TYPE hrsp_tty_auth_infty_tab,
         lt_t554t          TYPE TABLE OF t554t,
         lt_t550s          TYPE TABLE OF t550s,
         lt_t551s          TYPE TABLE OF t551s,
         lt_t508s          TYPE TABLE OF t508s,
         ls_wschedule      TYPE zhr_prt_s012,
         ls_return         TYPE  bapireturn1,
         lt_t001p          TYPE TABLE OF t001p WITH HEADER LINE,
         lr_pernr          TYPE RANGE OF persno WITH HEADER LINE,
         lt_wschedule      TYPE  zhr_prt_tt012.

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

  SELECT pernr,werks,btrtl, begda, endda
      FROM pa0001
    INTO TABLE @DATA(lt_pernr)
    WHERE pernr IN @lr_pernr
      AND begda LE @i_endda
      AND endda GE @i_begda
    .

  SORT lt_pernr ASCENDING .
  DELETE ADJACENT DUPLICATES FROM lt_pernr.

  REFRESH lt_t001p.
  SELECT * FROM t001p INTO TABLE lt_t001p
    FOR ALL ENTRIES IN lt_pernr
    WHERE werks = lt_pernr-werks
      AND btrtl = lt_pernr-btrtl .

  SELECT * FROM t508s INTO TABLE lt_t508s
    FOR ALL ENTRIES IN lt_t001p
      WHERE sprsl = sy-langu
        AND mofid = lt_t001p-mofid
        AND mosid = lt_t001p-mosid.

  SELECT * FROM t554t INTO TABLE lt_t554t
    FOR ALL ENTRIES IN lt_t001p
    WHERE sprsl = sy-langu
      AND moabw = lt_t001p-moabw.

  LOOP AT lt_pernr INTO DATA(ls_pernr).
    hr_read_infotype :
                       ls_pernr-pernr '0001' p0001,
                       ls_pernr-pernr '0007' p0007
                       .
    CLEAR : p_subrc.
    CLEAR : ch_auth_infty_tab.
    REFRESH : pernr_tab.
    REFRESH : psp.
    REFRESH : day_psp.
    APPEND VALUE #( pernr = ls_pernr-pernr ) TO pernr_tab.
    CALL FUNCTION 'HR_PERSON_READ_WORK_SCHEDULE'
      EXPORTING
        begin_date         = i_begda
        end_date           = i_endda
      TABLES
        pernr_tab          = pernr_tab
        psp                = psp
        day_psp            = day_psp
      CHANGING
        ch_auth_infty_tab  = ch_auth_infty_tab
      EXCEPTIONS
        error_in_build_psp = 1
        OTHERS             = 2.


    SELECT * FROM t550s INTO TABLE lt_t550s
      FOR ALL ENTRIES IN psp
        WHERE spras = sy-langu
          AND motpr = psp-motpr
          AND tprog = psp-tprog.

    SELECT * FROM t551s INTO TABLE lt_t551s
        FOR ALL ENTRIES IN psp
          WHERE sprsl = sy-langu
            AND motpr = psp-motpr
            AND zmodn = psp-zmodn .

    CLEAR lt_t001p. CLEAR p0001.
    LOOP AT p0001 WHERE pernr EQ ls_pernr-pernr
                    AND begda LE i_endda
                    AND endda GE i_begda.
    ENDLOOP.

    REFRESH lt_t001p.
    SELECT * FROM t001p INTO TABLE lt_t001p
      WHERE werks = p0001-werks
        AND btrtl = p0001-btrtl .
    READ TABLE lt_t001p WITH KEY werks = p0001-werks btrtl = p0001-btrtl.


    CLEAR p0007.
    LOOP AT p0007 INTO DATA(ls_007) WHERE pernr = ls_pernr-pernr AND begda LE i_endda AND endda GE i_begda.ENDLOOP.

    CALL FUNCTION 'DAY_ATTRIBUTES_GET'
      EXPORTING
        factory_calendar           = lt_t001p-mofid
        holiday_calendar           = lt_t001p-mofid
        date_from                  = i_begda
        date_to                    = i_endda
        language                   = sy-langu
        non_iso                    = space
      TABLES
        day_attributes             = day_attributes
      EXCEPTIONS
        factory_calendar_not_found = 1
        holiday_calendar_not_found = 2
        date_has_invalid_format    = 3
        date_inconsistency         = 4
        OTHERS                     = 5.

    DATA : lt_list  TYPE  zhr_prt_tt017.
    REFRESH lt_list.
    CALL FUNCTION 'ZHR_PRT_FG001_06'
      EXPORTING
        i_srcid = '00001'
        i_pernr = i_pernr
        i_begda = i_begda
        i_endda = i_endda
*       I_AWART =
*       i_statu = '01' " Onay bekleyen talepler
      IMPORTING
        et_list = lt_list.
    DATA : lr_statu TYPE RANGE OF zhr_prt_statu .
    APPEND VALUE #( sign = 'I' option = 'EQ' low = '01' ) TO lr_statu.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = '04' ) TO lr_statu.
    DELETE lt_list WHERE NOT ( statu IN lr_statu[]  ).
    LOOP AT lt_list INTO DATA(ls_list).
      LOOP AT psp ASSIGNING FIELD-SYMBOL(<ls_psp>) WHERE datum BETWEEN ls_list-begda AND ls_list-endda.
        <ls_psp>-awart = ls_list-awart.
      ENDLOOP.
    ENDLOOP.

    lt_wschedule = VALUE #( FOR ls IN psp WHERE ( pernr = ls_pernr-pernr )
                            (
                              pernr        = ls-pernr
                              ename        = p0001[ pernr = ls-pernr ]-ename
                              datum        = ls-datum
                              moabw        = lt_t001p-moabw
                              awart        = ls-awart
                              awart_t      = lt_t554t[ moabw = lt_t001p-moabw awart = ls-awart ]-atext
                              motpr        = ls-motpr
                              tprog        = ls-tprog
                              tprog_t      = lt_t550s[ motpr = ls-motpr tprog = ls-tprog ]-ttext
                              mofid        = lt_t001p-mofid
                              mosid        = lt_t001p-mosid
                              schkz        = ls_007-schkz
                              schkz_t      = lt_t508s[ mofid = lt_t001p-mofid mosid = lt_t001p-mosid schkz = ls_007-schkz ]-rtext
                              ftkla        = ls-tpkla
                              tpkla        = ls-tpkla
                              zmodn        = ls-zmodn
                              zmodn_t      = lt_t551s[ motpr = ls-motpr zmodn = ls-zmodn ]-ztext
                              stdaz        = ls-stdaz
                              begzt        = ls-begzt
                              endzt        = ls-endzt
                              begti        = ls-begti
                              endti        = ls-endti
                              pamod        = ls-pamod
                              anzhl        = '1'
                              holiday_id   = day_attributes[ date = ls-datum ]-holiday_id
                              holiday__t   = day_attributes[ date = ls-datum ]-txt_long
                              weekday_l    = day_attributes[ date = ls-datum ]-weekday_l
*                              freeday      = day_attributes[ date = ls-datum ]-freeday
                              holiday      = day_attributes[ date = ls-datum ]-holiday
                             )
                           ) .

    LOOP AT psp INTO DATA(ls_psp) WHERE pernr EQ ls_pernr-pernr AND tpkla = 0.
      LOOP AT lt_wschedule ASSIGNING FIELD-SYMBOL(<fs_ws>) WHERE pernr EQ ls_psp-pernr AND datum EQ ls_psp-datum. ENDLOOP.
      IF sy-subrc EQ 0 .
        <fs_ws>-freeday = 'X'.
      ENDIF.
    ENDLOOP.


    APPEND LINES OF lt_wschedule TO et_wschedule.


    "<<--------Izin talebinden onaylanmamış kayıtlar alınacak------>>

    "<<--------END CODE------>>
  ENDLOOP.

  CLEAR ls_wschedule.
  MODIFY et_wschedule FROM ls_wschedule
    TRANSPORTING awart_t anzhl
      WHERE awart IS INITIAL .

  IF i_leave_list EQ 'X'.
    DELETE et_wschedule WHERE awart IS INITIAL .
  ELSE.
    IF et_wschedule[] IS INITIAL .
      PERFORM add_message TABLES et_return
                           USING ''
                                 ''
                                 'ZHR_PRT'
                                 'E'
                                 '003'
                                 ls_return .
    ENDIF.
  ENDIF.


ENDFUNCTION.
