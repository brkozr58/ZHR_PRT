FUNCTION zhr_prt_fg001_07.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SRCID) TYPE  ZHR_PRT_SRCID DEFAULT '00001'
*"     VALUE(I_PERNR) TYPE  PERSNO
*"     VALUE(I_DATUM) TYPE  DATUM DEFAULT SY-DATUM
*"  EXPORTING
*"     VALUE(ET_APPROVERS) TYPE  ZHR_PRT_TT014
*"     VALUE(ET_RETURN) TYPE  ZHR_PRT_TRETURN
*"----------------------------------------------------------------------

  DATA : lr_pernr    TYPE RANGE OF persno WITH HEADER LINE,
         lt_onayci   TYPE TABLE OF zhr_prt_tonayci WITH HEADER LINE,
         ls_t010     TYPE zhr_prt_t010,
         lv_msgno    TYPE bapireturn1-number,
         ls_return   TYPE bapireturn1,
         lv_zhrorg   TYPE char2, " Organizasyon seviyesi
         lv_orgeh    TYPE orgeh,
         lv_orgeh_up TYPE orgeh,
         lv_plans    TYPE plans,
         lv_pernr    TYPE persno,
         lv_seqnr    TYPE hrpao_dy_seqnr.

  DATA langu LIKE sy-langu VALUE 'T'.
  SET LOCALE LANGUAGE  langu.

*ZMNY	    Zaman Yöneticisi
*GM	      Genel Müdür
*GMY      Genel Müdür Yardımcısı
*IKMDR    İK Müdürü
*DRKT	    Direktör
*ONY      Onaycı
*ADM      Admin Onaycı
*ONY2	    İstisna Onaycı

  "<<--------Kontroller ------>>
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

  CLEAR lv_msgno.
  IF i_pernr IS NOT INITIAL .
    APPEND VALUE #( sign = 'I' option = 'EQ' low = i_pernr )
          TO lr_pernr.
  ELSE.
    lv_msgno = '006'.
  ENDIF.

  SELECT SINGLE * FROM zhr_prt_t010 INTO ls_t010
     WHERE srcid = i_srcid.
  IF sy-subrc NE 0 .
    lv_msgno = '007'.
  ELSEIF sy-subrc EQ 0 AND ls_t010-activ NE 'X'.
    lv_msgno = '008'.
    ls_return-message_v1 = ls_t010-srcid_t.
  ENDIF.
  IF lv_msgno IS NOT INITIAL .
    PERFORM add_message TABLES et_return
                         USING i_srcid
                               i_pernr
                               'ZHR_PRT'
                               'E'
                               lv_msgno
                               ls_return .
    EXIT.
  ENDIF.
  "<<--------END CODE------>>



  "<<--------Zaman Yöneticileri ------>>
  PERFORM get_gt_zmynt TABLES gt_zmynt
                        USING i_datum
                              'SAPU'
                              'PA01' .
  "<<--------END CODE------>>


  "<<-------- GM- GMY - DRKTR------>>
  PERFORM get_gm_gmy_drktr_value TABLES gt_tstell
                                  USING i_datum.
  "<<--------END CODE------>>

  "<<--------İk müdürleri------>>
  SELECT
          t2~pernr,
          t2~ename,
          t1~srcid,
          t1~orgsvy,
          t1~seqnr,
          t1~plans
          FROM zhr_prt_tonyik AS t1
    INNER JOIN pa0001         AS t2
          ON    t2~plans EQ t1~plans
            AND t2~endda GE @i_datum
    INTO TABLE @DATA(lt_ikmdr)
      WHERE srcid EQ @i_srcid.
  SORT lt_ikmdr ASCENDING BY orgsvy seqnr .

  "<<--------END CODE------>>

  "<<--------Sabit onaycı------>>
  SELECT * FROM zhr_prt_tonayci INTO TABLE lt_onayci
      WHERE srcid EQ i_srcid
        AND pernr IN lr_pernr[].
  "<<--------END CODE------>>

  SELECT pernr,
         ename,
         werks,
         btrtl,
         orgeh,
         plans,
         plans~stext AS plans_t,
         stell,
         stell~stext AS stell_t,
         sachz ,
*    " Yönetici ise A gelecek
         CAST(  ( CASE ( ynt~objid )
                    WHEN ' ' THEN ' '
                    ELSE ynt~rsign END ) AS CHAR( 1 ) ) AS  zynt ,
*         orgsv~orgsvy AS zhrorg
        CAST( ' '  AS CHAR( 2 ) ) AS zhrorg
                 FROM pa0001  AS t1
      INNER JOIN hrp1000 AS stell
            ON    stell~plvar EQ '01'
              AND stell~otype EQ 'C'
              AND stell~objid EQ t1~stell
              AND stell~langu EQ @sy-langu
              AND stell~endda GE @i_datum
      INNER JOIN hrp1000 AS plans
            ON    plans~plvar EQ '01'
              AND plans~otype EQ 'S'
              AND plans~objid EQ t1~plans
              AND plans~langu EQ @sy-langu
              AND plans~endda GE @i_datum
*      LEFT OUTER JOIN hrp9301 AS orgsv
*            ON    orgsv~otype EQ 'O'
*              AND orgsv~plvar EQ '01'
*              AND orgsv~objid EQ t1~orgeh
*              AND orgsv~endda GE @i_datum
      LEFT OUTER JOIN hrp1001 AS ynt
            ON    ynt~plvar EQ '01'
              AND ynt~otype EQ 'S'
              AND ynt~objid EQ t1~plans
              AND ynt~rsign EQ 'A'
              AND ynt~relat EQ '012'
              AND ynt~endda GE @i_datum
    INTO TABLE @DATA(lt_pernr)
        WHERE t1~pernr IN @lr_pernr
          AND t1~endda GE @i_datum
          AND t1~begda LE @i_datum .

  " Kişiler için onaycıları bul
  " Yönetim kurulunu karıştırma :)
  LOOP AT lt_pernr INTO DATA(ls_pernr) ."WHERE zhrorg NE '10'.
    " sabit onaycı varsa diğerlerine onay gitmesin
    READ TABLE lt_onayci WITH KEY pernr = ls_pernr-pernr.
    IF sy-subrc EQ 0 .

      "<<--------Sabit onaycı varsa ------>>
      READ TABLE gt_zmynt INTO DATA(ls_zmynt)
          WITH KEY sachx = ls_pernr-sachz.
      IF sy-subrc EQ 0 .
        PERFORM append_approver TABLES et_approvers
                                 USING ls_zmynt-pernr
                                       'ZMNY'
                                       ls_pernr-zhrorg " 70 için gmy gm vs almasın diye
                                       ls_pernr-zhrorg
                                       ls_pernr-pernr
                                       ls_pernr-zynt
                                       i_srcid
                                       i_datum
                              CHANGING lv_seqnr.
      ENDIF.

      PERFORM append_approver TABLES et_approvers
                               USING lt_onayci-zapp1
                                     'ONY'
                                     ls_pernr-zhrorg
                                     ls_pernr-zhrorg
                                     ls_pernr-pernr
                                     ls_pernr-zynt
                                     i_srcid
                                     i_datum
                            CHANGING lv_seqnr.

      PERFORM append_approver TABLES et_approvers
                               USING lt_onayci-zapp2
                                     'ONY'
                                     ls_pernr-zhrorg
                                     ls_pernr-zhrorg
                                     ls_pernr-pernr
                                     ls_pernr-zynt
                                     i_srcid
                                     i_datum
                            CHANGING lv_seqnr.

      READ TABLE gt_zmynt INTO ls_zmynt
          WITH KEY sachx = ls_pernr-sachz.
      IF sy-subrc EQ 0 .
        PERFORM append_approver TABLES et_approvers
                                 USING ls_zmynt-pernr
                                       'ZMNY'
                                       ls_pernr-zhrorg
                                       ls_pernr-zhrorg
                                       ls_pernr-pernr
                                       ls_pernr-zynt
                                       i_srcid
                                       i_datum
                              CHANGING lv_seqnr.
      ENDIF.
      "<<--------END CODE------>>

    ELSE.
      lv_orgeh = ls_pernr-orgeh.
      lv_zhrorg = ls_pernr-zhrorg.

      CASE ls_pernr-zhrorg.
        WHEN '20' OR '30'.
          " GM ve GMY de yönetici olsada olmasada
          " ilk zaman yöneticisi ekleme
        WHEN OTHERS.
          READ TABLE gt_zmynt INTO ls_zmynt
              WITH KEY sachx = ls_pernr-sachz.
          IF sy-subrc EQ 0 .
            PERFORM append_approver TABLES et_approvers
                                     USING ls_zmynt-pernr
                                           'ZMNY'
                                           ls_pernr-zhrorg
                                           ls_pernr-zhrorg
                                           ls_pernr-pernr
                                           ls_pernr-zynt
                                           i_srcid
                                           i_datum
                                  CHANGING lv_seqnr.
          ENDIF.
      ENDCASE.

      "<<--------Diğer onaycıları bul------>>
      DO .
*        SELECT SINGLE orgsvy FROM hrp9301 INTO lv_zhrorg
*             WHERE otype EQ 'O'
*               AND plvar EQ '01'
*               AND objid EQ lv_orgeh
*               AND endda GE i_datum.
*        IF sy-subrc EQ 0.
          PERFORM rh_struc_get USING 'O' lv_orgeh 'B012' i_datum CHANGING lv_plans .
          IF sy-subrc EQ 0 .
            PERFORM rh_struc_get USING 'S' lv_plans 'A008' i_datum CHANGING lv_pernr .
            IF sy-subrc EQ 0 .
              PERFORM append_approver TABLES et_approvers
                                       USING lv_pernr
                                             'ONY'
                                             ls_pernr-zhrorg
                                             lv_zhrorg
                                             ls_pernr-pernr
                                             ls_pernr-zynt
                                             i_srcid
                                             i_datum
                                    CHANGING lv_seqnr.
            ENDIF.
          ENDIF.

          PERFORM rh_struc_get USING 'O' lv_orgeh 'A002' i_datum CHANGING lv_orgeh_up .
          IF sy-subrc NE 0 .
            EXIT.
          ELSE.
            lv_orgeh = lv_orgeh_up.
          ENDIF.
*        ELSE.
*          PERFORM rh_struc_get USING 'O' lv_orgeh 'A002' i_datum CHANGING lv_orgeh_up .
*          IF sy-subrc NE 0 .
*            EXIT.
*          ELSE.
*            lv_orgeh = lv_orgeh_up.
*          ENDIF.
*        ENDIF.
      ENDDO.
      "<<--------END CODE------>>

      "<<-------- Org sev. 60 sa ve yönetici ise GMY onayı ekle------>>
      IF ls_pernr-zhrorg EQ '60' AND ls_pernr-zynt EQ 'A'.
        READ TABLE gt_tstell INTO DATA(ls_tstell) WITH KEY aptyp = 'GMY'.
        IF sy-subrc EQ 0 .
          PERFORM append_approver TABLES et_approvers
                                   USING ls_tstell-pernr
                                         ls_tstell-aptyp
                                         ls_pernr-zhrorg
                                         ls_pernr-zhrorg
                                         ls_pernr-pernr
                                         ls_pernr-zynt
                                         i_srcid
                                         i_datum
                                CHANGING lv_seqnr.

        ENDIF.
      ENDIF.
      "<<--------END CODE------>>

      "<<--------Son zaman yöneticisini ekle------>>
      " ONY bulamazsan 2.zaman yöneticisini ekleme
      READ TABLE gt_zmynt INTO ls_zmynt
          WITH KEY sachx = ls_pernr-sachz.
      IF sy-subrc EQ 0 AND lines( et_approvers ) GT 1 .
        PERFORM append_approver TABLES et_approvers
                                 USING ls_zmynt-pernr
                                       'ZMNY'
                                       ls_pernr-zhrorg
                                       ls_pernr-zhrorg
                                       ls_pernr-pernr
                                       ls_pernr-zynt
                                       i_srcid
                                       i_datum
                              CHANGING lv_seqnr.
      ENDIF.
      "<<--------END CODE------>>

      "<<--------IK Müdürü------>>
      CASE ls_pernr-zhrorg.
        WHEN '70' OR '80'.
          " 70 ve 80 de İk müdürü ekleme IKMDR
        WHEN OTHERS.
          " Son onay
*          IF ( ls_pernr-zhrorg EQ '60' AND ls_pernr-zynt EQ 'A' ) OR
*                ls_pernr-zhrorg NE '60'.
*            LOOP AT lt_ikmdr INTO DATA(ls_ikmdr) WHERE orgsvy = ls_pernr-zhrorg.
*              PERFORM append_approver TABLES et_approvers
*                                       USING ls_ikmdr-pernr
*                                             'IKMDR'
*                                             ls_pernr-zhrorg
*                                             ls_pernr-zhrorg
*                                             ls_pernr-pernr
*                                             ls_pernr-zynt
*                                             i_srcid i_datum
*                                    CHANGING lv_seqnr.
*            ENDLOOP.
*            IF sy-subrc NE 0 .
*              READ TABLE lt_ikmdr INTO ls_ikmdr WITH KEY orgsvy = ''.
*              IF sy-subrc EQ 0 .
*                PERFORM append_approver TABLES et_approvers
*                                         USING ls_ikmdr-pernr
*                                               'IKMDR'
*                                               ls_pernr-zhrorg
*                                               ls_pernr-zhrorg
*                                               ls_pernr-pernr
*                                               ls_pernr-zynt
*                                               i_srcid i_datum
*                                      CHANGING lv_seqnr.
*              ENDIF.
*            ENDIF.
*          ENDIF.
      ENDCASE.
      "<<--------END CODE------>>
    ENDIF.

  ENDLOOP.

  IF et_approvers[] IS INITIAL .
    CLEAR : ls_return.
    PERFORM add_message TABLES et_return
                         USING i_srcid
                               i_pernr
                               'ZHR_PRT'
                               'E'
                               '009'
                               ls_return .
    EXIT.
  ENDIF.
ENDFUNCTION.
