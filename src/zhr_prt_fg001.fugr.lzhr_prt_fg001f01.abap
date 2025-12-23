*----------------------------------------------------------------------*
***INCLUDE LZHR_PRT_FG001F01.
*----------------------------------------------------------------------*


*PERNR      1 Types PERSNO
*PERS_INFO  1 Types ZHR_PRT_TT002
*WORK_INFO  1 Types ZHR_PRT_TT003
*CONT_INFO  1 Types ZHR_PRT_TT004
*EDUC_INFO  1 Types ZHR_PRT_TT005
*DATE_INFO  1 Types ZHR_PRT_TT006
*ADRS_INFO  1 Types ZHR_PRT_TT007
*FAML_INFO  1 Types ZHR_PRT_TT008


*&---------------------------------------------------------------------*
*& Form pers_info
*&---------------------------------------------------------------------*
FORM pers_info  TABLES   pers_info STRUCTURE zhr_prt_s002
                USING    pv_pernr
                         pv_datum.

  DATA : ls_info TYPE zhr_prt_s002.

  SELECT  t2~vorna ,
          t2~nachn ,
          t2~gesch ,
          CASE ( t2~gesch )
                          WHEN '1' THEN 'Erkek'
                          WHEN '2' THEN 'Kadın'
                          ELSE 'Bilinmiyor!' END   AS gesch_t,
          t2~famst,
          fatxt~ftext AS fatxt,
          t2~gblnd ,
          gblnd_t~landx50 AS gblnd_t ,
          t2~gbdat ,
          t2~gbort ,
          t3~merni ,
          t3~muter ,
          t3~fater

         FROM pa0002 AS t2
   LEFT  JOIN pa0770 AS t3
         ON    t3~pernr EQ t2~pernr
          AND t3~subty      EQ '01'
          AND t3~begda      LE @pv_datum
          AND t3~endda      GE @pv_datum
   LEFT JOIN t502t AS fatxt
         ON    fatxt~famst EQ t2~famst
           AND fatxt~sprsl   EQ @sy-langu
   LEFT JOIN t005t AS gblnd_t
         ON    gblnd_t~land1 EQ t2~gblnd
           AND gblnd_t~spras EQ @sy-langu
      INTO CORRESPONDING FIELDS OF TABLE @pers_info
            WHERE t2~pernr      EQ @pv_pernr
              AND t2~begda      LE @pv_datum
              AND t2~endda      GE @pv_datum.
  SORT pers_info.
  DELETE ADJACENT DUPLICATES FROM pers_info.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form work_info
*&---------------------------------------------------------------------*
FORM work_info  TABLES   work_info STRUCTURE zhr_prt_s003
                USING    pv_pernr
                         pv_datum.

  SELECT
      t2~usrid_long AS mail       ,
      t1~stell                    ,
      stell_t~stltx AS stell_t    ,
      t1~orgeh                    ,
      orgeh_t~orgtx AS orgeh_t    ,
      t1~plans                    ,
      plans_t~plstx AS plans_t    ,
      t1~persg                    ,
      persg_t~ptext AS persg_t    ,
      t1~persk                    ,
      persk_t~ptext AS persk_t    ,
      CAST( ( ' ' ) AS CHAR( 1 ) ) AS zyakatur ,
      CAST( ( ' ' ) AS CHAR( 25 ) ) AS zyakatur_t ,
*      t1~zyakatur                 ,
*      CASE ( t1~zyakatur )
*        WHEN 'M' THEN 'Mavi Yaka'
*        WHEN 'B' THEN 'Beyaz Yaka'
*        ELSE 'Bilinmiyor!'
*      END         AS zyakatur_t   ,

      CAST( ( ' ' ) AS CHAR( 3 ) ) AS lokkod ,
      CAST( ( ' ' ) AS CHAR( 35 ) ) AS lokkod_t ,
*      t1~zzlokkod     AS lokkod   ,
*      zzlokkod~lokadi AS lokkod_t ,
      t1~btrtl                    ,
      btrtl_t~btext   AS btrtl_t  ,
      t1~bukrs                    ,
      bukrs_t~butxt   AS bukrs_t
              FROM pa0001 AS t1

        LEFT JOIN t513s AS stell_t
              ON    stell_t~stell EQ t1~stell
                AND stell_t~sprsl EQ @sy-langu
                AND stell_t~endda GE @pv_datum

        LEFT JOIN t527x AS orgeh_t
              ON    orgeh_t~orgeh EQ t1~orgeh
                AND orgeh_t~sprsl EQ @sy-langu
                AND orgeh_t~endda GE @pv_datum

        LEFT JOIN t528t AS plans_t
              ON    plans_t~plans EQ t1~plans
                AND plans_t~sprsl EQ @sy-langu
                AND plans_t~endda GE @pv_datum

        LEFT JOIN t501t AS persg_t
              ON    persg_t~persg EQ t1~persg
                AND persg_t~sprsl EQ @sy-langu

        LEFT JOIN t503t AS persk_t
              ON    persk_t~persk EQ t1~persk
                AND persk_t~sprsl EQ @sy-langu

        LEFT JOIN t001p AS btrtl_t
              ON    btrtl_t~btrtl EQ t1~btrtl

        LEFT JOIN t001  AS bukrs_t
              ON    bukrs_t~bukrs EQ t1~bukrs

        LEFT JOIN pa0105 AS t2
              ON    t2~pernr EQ t1~pernr
                AND ( t2~subty EQ '0010'  OR t2~subty EQ 'MAIL' )

*        LEFT OUTER JOIN zent_ta_lok AS zzlokkod
*              ON    zzlokkod~lokkod EQ t1~zzlokkod

  INTO CORRESPONDING FIELDS OF TABLE @work_info
     WHERE t1~pernr     EQ @pv_pernr
       AND t1~begda     LE @pv_datum
       AND t1~endda     GE @pv_datum
    .
  SORT work_info.
  DELETE ADJACENT DUPLICATES FROM work_info.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONT_INFO
*&---------------------------------------------------------------------*
FORM cont_info  TABLES   cont_info     STRUCTURE zhr_prt_s004
                USING    pv_pernr
                         pv_datum.
  SELECT t1~subty               ,
         subty~stext AS subty_t ,
         t1~usrid
          FROM pa0105  AS t1
    INNER JOIN t591s   AS subty
          ON    subty~subty EQ t1~subty
            AND subty~infty EQ '0105'
            AND subty~sprsl EQ @sy-langu
  INTO CORRESPONDING FIELDS OF TABLE @cont_info
          WHERE pernr EQ @pv_pernr
            AND endda GE @pv_datum.


  SELECT t1~subty               ,
         subty~stext AS subty_t ,
         t1~usrid_long AS usrid
          FROM pa0105  AS t1
    INNER JOIN t591s   AS subty
          ON    subty~subty EQ t1~subty
            AND subty~infty EQ '0105'
            AND subty~sprsl EQ @sy-langu
  APPENDING CORRESPONDING FIELDS OF TABLE @cont_info
          WHERE pernr EQ @pv_pernr
            AND endda GE @pv_datum.

  SORT cont_info.
  DELETE cont_info WHERE usrid IS INITIAL .
  DELETE ADJACENT DUPLICATES FROM cont_info.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form EDUC_INFO
*&---------------------------------------------------------------------*
FORM educ_info  TABLES   educ_info   STRUCTURE zhr_prt_s005
                USING    pv_pernr
                         pv_datum.

  SELECT t1~slart                 ,
         slart_t~stext AS slart_t ,
         t1~insti                 ,
         t1~ausbi                 ,
         ausbi_t~atext AS ausbi_t ,
         t1~sltp1                 ,
         sltp1_t~ftext AS sltp1_t ,
         t1~sltp2                 ,
         sltp2_t~ftext AS sltp2_t ,
         t1~begda,
         t1~emark,
      CAST( ( ' ' ) AS CHAR( 30 ) ) AS zdipno
*         t1~zdipno
          FROM pa0022  AS t1
    LEFT OUTER JOIN t517t   AS slart_t
          ON    slart_t~slart EQ t1~slart
            AND slart_t~sprsl EQ @sy-langu
    LEFT OUTER JOIN t518b   AS ausbi_t
          ON    ausbi_t~ausbi EQ t1~ausbi
            AND ausbi_t~langu EQ @sy-langu

    LEFT OUTER JOIN t517x   AS sltp1_t
          ON    sltp1_t~faart EQ t1~sltp1
            AND sltp1_t~langu EQ @sy-langu

    LEFT OUTER JOIN t517x   AS sltp2_t
          ON    sltp2_t~faart EQ t1~sltp2
            AND sltp2_t~langu EQ @sy-langu
  APPENDING CORRESPONDING FIELDS OF TABLE @educ_info
          WHERE pernr EQ @pv_pernr
            AND endda GE @pv_datum.
  SORT educ_info. "+ATC Correction - GTUNA - 07.11.2025 09:48:23
  DELETE ADJACENT DUPLICATES FROM educ_info.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DATE_INFO
*&---------------------------------------------------------------------*
FORM date_info  TABLES   date_info   STRUCTURE zhr_prt_s006
                USING    pv_pernr
                         pv_datum.
  DATA : lt_0041 TYPE TABLE OF pa0041.
  DATA : lt_t548t TYPE TABLE OF t548t.
  DATA : ls_date_info TYPE zhr_prt_s006.

  SELECT * FROM t548t INTO TABLE lt_t548t
      WHERE sprsl EQ sy-langu .

  SELECT * FROM pa0041 INTO TABLE lt_0041
      WHERE pernr EQ pv_pernr
        AND endda GE pv_datum.

  LOOP AT lt_0041 INTO DATA(ls_0041).
    DO 24 TIMES  VARYING ls_date_info-darxx FROM ls_0041-dar01 NEXT ls_0041-dar02
                 VARYING ls_date_info-datxx FROM ls_0041-dat01 NEXT ls_0041-dat02.
      IF ls_date_info-darxx IS INITIAL .
        EXIT.
      ENDIF.
      READ TABLE lt_t548t INTO DATA(ls_t548t)
        WITH KEY datar = ls_date_info-darxx.
      ls_date_info-darxx_t = ls_t548t-dtext.
      COLLECT ls_date_info INTO date_info.
    ENDDO.
  ENDLOOP.

  SORT date_info.
  DELETE ADJACENT DUPLICATES FROM date_info.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADRS_INFO
*&---------------------------------------------------------------------*
FORM adrs_info  TABLES   adrs_info   STRUCTURE zhr_prt_s007
                USING    pv_pernr
                         pv_datum.

  SELECT t1~anssa                 ,
         anssa_t~stext AS anssa_t ,
         t1~stras                 ,
         t1~locat                 ,
         t1~pstlz                 ,
         t1~ort01                 ,
         t1~ort02
          FROM pa0006  AS t1
    INNER JOIN t591s   AS anssa_t
          ON    anssa_t~subty EQ t1~anssa
            AND anssa_t~infty EQ '0006'
            AND anssa_t~sprsl EQ @sy-langu
  APPENDING CORRESPONDING FIELDS OF TABLE @adrs_info
          WHERE pernr EQ @pv_pernr
            AND endda GE @pv_datum.

  SORT adrs_info. "+ATC Correction - GTUNA - 07.11.2025 09:47:16
  DELETE ADJACENT DUPLICATES FROM adrs_info.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form FAML_INFO
*&---------------------------------------------------------------------*
FORM faml_info  TABLES   faml_info   STRUCTURE zhr_prt_s008
                USING    pv_pernr
                         pv_datum.
  SELECT t1~favor                 ,
         t1~fanam                 ,
         t1~famsa                 ,
         famsa_t~stext AS famsa_t ,
         t1~fgbdt                 ,
         t1~fasar                 ,
         fasar_t~stext AS fasar_t ,
         t1~fasin                 ,
         t1~fasdt
          FROM pa0021  AS t1
    LEFT OUTER JOIN t591s   AS famsa_t
          ON    famsa_t~subty EQ t1~subty
            AND famsa_t~infty EQ '0021'
            AND famsa_t~sprsl EQ @sy-langu
    LEFT OUTER JOIN t517t   AS fasar_t
          ON    fasar_t~slart EQ t1~fasar
            AND fasar_t~sprsl EQ @sy-langu
  APPENDING CORRESPONDING FIELDS OF TABLE @faml_info
          WHERE pernr EQ @pv_pernr
            AND endda GE @pv_datum.

  SORT faml_info.
  DELETE ADJACENT DUPLICATES FROM faml_info.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form cal_pernr_quota
*&---------------------------------------------------------------------*
FORM cal_pernr_quota TABLES et_return  STRUCTURE  zhr_prt_sreturn
                     USING pv_pernr TYPE pernr-pernr
                           pv_pn_begda TYPE p2006-begda
                           pv_pn_endda TYPE p2006-endda
                           pv_dedu_beg TYPE p2006-desta
                           pv_dedu_end TYPE p2006-deend
                           pv_de_datum TYPE p2006-begda
                           pv_en_datum TYPE p2006-begda
                           pv_de_sim TYPE char1
                           pt_se_ktart TYPE ptgqd_t_kt_sel
                  CHANGING pt_abwko TYPE ptgqd_t_kansp
                           pt_qttrans TYPE ptgqd_t_qttrans
                           pt_cum_values TYPE ptgqd_t_cu_val_add.
*---- Daten zur Fehlerbehandlung
  DATA: retcd     TYPE sy-subrc,

        ls_return TYPE  bapireturn1.

  CLEAR: pt_abwko, pt_cum_values.
  CALL FUNCTION 'HR_GET_QUOTA_DATA'
    EXPORTING
      pernr             = pv_pernr
      mod               = pv_de_sim
      dedu_datum        = pv_de_datum
      enti_datum        = pv_en_datum
      begda             = pv_pn_begda
      endda             = pv_pn_endda
      dedubeg           = pv_dedu_beg
      deduend           = pv_dedu_end
    IMPORTING
      retcd             = retcd
    TABLES
      abwktart_sel      = pt_se_ktart
      abwko             = pt_abwko
      iqttrans          = pt_qttrans          "AHRK038601
      i2006             = p2006 "note 1774683
      i0001             = p0001 "note 1774683
      i0003             = p0003 "note 1774683
      i0007             = p0007 "note 1774683
      cum_values        = pt_cum_values
    EXCEPTIONS
      infty_not_found   = 1
      missing_authority = 2
      wrong_parameter   = 4
      OTHERS            = 5.
*---- Fehlerhandling beim Lesen der Kontingente
  CASE sy-subrc.
    WHEN 1.

      ls_return-id         = '72'.
      ls_return-type       = 'E'.
      ls_return-number     = '036'.
      ls_return-message_v1 = sy-msgv1.
      ls_return-message_v2 = sy-msgv2.
      ls_return-message_v3 = sy-msgv3.
      ls_return-message_v4 = sy-msgv4.
      PERFORM add_message TABLES et_return
                           USING ''
                                 ''
                                 '72'
                                 'E'
                                 '036'
                                 ls_return .
    WHEN 2.
      ls_return-id         = '72'.
      ls_return-type       = 'E'.
      ls_return-number     = '105'.
      ls_return-message_v1 = sy-msgv1.
      ls_return-message_v2 = sy-msgv2.
      ls_return-message_v3 = sy-msgv3.
      ls_return-message_v4 = sy-msgv4.
      PERFORM add_message TABLES et_return
                           USING ''
                                 ''
                                 '72'
                                 'E'
                                 '036'
                                 ls_return .
    WHEN 4.
    WHEN 5.
  ENDCASE.
*----- Fehlerbehandlung des Überleitungsvorrat
  CASE retcd.
    WHEN '32' OR '96'.
      ls_return-id         = '72'.
      ls_return-type       = 'E'.
      ls_return-number     = '220'.
      ls_return-message_v1 = pv_pernr.
      ls_return-message_v2 = sy-msgv2.
      ls_return-message_v3 = sy-msgv3.
      ls_return-message_v4 = sy-msgv4.
      PERFORM add_message TABLES et_return
                           USING ''
                                 ''
                                 '72'
                                 'E'
                                 '036'
                                 ls_return .
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    "CAL_PERNR_QUOTA
*&---------------------------------------------------------------------*
*& Form add_message
*&---------------------------------------------------------------------*
FORM add_message TABLES et_return  STRUCTURE  zhr_prt_sreturn
                  USING pv_srcid
                        pv_pernr
                        pv_msgid
                        pv_msgty
                        pv_msgno
                        ps_return TYPE  bapireturn1.

  DATA : ls_return TYPE  zhr_prt_sreturn.

  MOVE-CORRESPONDING ps_return TO ls_return .

  ls_return-pernr = pv_pernr.
  ls_return-srcid = pv_srcid.
  ls_return-type = pv_msgty.
  ls_return-number = pv_msgno.
  ps_return-type = pv_msgty.

  IF ps_return-id IS INITIAL .
    ps_return-id = pv_msgid.
    ls_return-id = pv_msgid.
  ENDIF.
  IF ps_return-number IS INITIAL .
    ps_return-number = pv_msgno.
  ENDIF.


  MESSAGE ID ps_return-id TYPE ps_return-type NUMBER ps_return-number
        INTO ls_return-message
        WITH ps_return-message_v1 ps_return-message_v2
             ps_return-message_v3 ps_return-message_v4.

  APPEND ls_return TO et_return.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_gt_zmynt
*&---------------------------------------------------------------------*
FORM get_gt_zmynt  TABLES    pt_zmynt
                    USING    pi_datum
                             pv_subty
                             pv_werks.
  REFRESH pt_zmynt.
  SELECT
        t1~sachx
        t1~usrid
        t3~pernr
        t3~plans
        plans_t~stext AS plans_t

     FROM t526 AS t1
          INNER JOIN pa0105 AS t2
            ON    t2~usrid EQ t1~usrid
              AND t2~subty EQ pv_subty
              AND t2~begda LE pi_datum
              AND t2~endda GE pi_datum
          INNER JOIN pa0001 AS t3
            ON    t3~pernr EQ t2~pernr
              AND t3~begda LE pi_datum
              AND t3~endda GE pi_datum
              AND t3~plans NE '99999999'
          INNER JOIN hrp1000 AS plans_t
            ON    plans_t~plvar EQ '01'
              AND plans_t~otype EQ 'S'
              AND plans_t~objid EQ t3~plans
              AND plans_t~begda LE pi_datum
              AND plans_t~endda GE pi_datum
              AND plans_t~langu EQ sy-langu
     INTO CORRESPONDING FIELDS OF TABLE  pt_zmynt
     WHERE t1~werks EQ pv_werks .
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_GM_GMY_DRKTR_value
*&---------------------------------------------------------------------*
FORM get_gm_gmy_drktr_value TABLES pt_tstell
                             USING pv_datum .
  REFRESH pt_tstell.
  SELECT  t1~pernr,
          t1~ename,
          t1~plans,
          plans~stext AS plans_t,
          t1~stell,
          stell~stext AS stell_t,
          tstl~aptyp,
          tstl_t~ddtext AS aptyp_t
        FROM        pa0001  AS t1
        INNER JOIN zhr_prt_tstell AS tstl
          ON    tstl~stell EQ t1~stell
        INNER  JOIN hrp1000 AS plans
          ON    plans~plvar EQ '01'
            AND plans~otype EQ 'S'
            AND plans~objid EQ t1~plans
            AND plans~endda GE @pv_datum
            AND plans~langu EQ @sy-langu
    LEFT OUTER JOIN dd07t AS tstl_t
          ON    tstl_t~domname    EQ 'ZHR_PRT_APTYP'
            AND tstl_t~ddlanguage EQ @sy-langu
            AND tstl_t~domvalue_l EQ tstl~aptyp
    LEFT OUTER JOIN hrp1000 AS stell
          ON    stell~plvar EQ '01'
            AND stell~otype EQ 'C'
            AND stell~objid EQ t1~stell
            AND stell~langu EQ @sy-langu
            AND stell~endda GE @pv_datum
    INTO TABLE @pt_tstell
          WHERE t1~endda GE @pv_datum.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form append_approver
*&---------------------------------------------------------------------*
FORM append_approver  TABLES pt_approvers STRUCTURE zhr_prt_s014
                       USING   apprv
                               aptyp
                               per_orgsvy " 70 için gmy gm vs almasın diye
                               orgsvy
                               pernr
                               zynt  " Yöneticim i
                               i_srcid
                               i_datum
                      CHANGING cv_seqnr .
  DATA : lt_stell    TYPE TABLE OF zhr_prt_tstell WITH HEADER LINE,
         ls_approver TYPE zhr_prt_s014.

  SELECT * FROM zhr_prt_tstell INTO TABLE lt_stell
      WHERE srcid EQ i_srcid.


*ZMNY	    Zaman Yöneticisi
*GM	      Genel Müdür
*GMY      Genel Müdür Yardımcısı
*IKMDR    İK Müdürü
*DRKT	    Direktör
*ONY      Onaycı
*ADM      Admin Onaycı
*ONY2	    İstisna Onaycı


*  ls_approver-orgsvy = orgsvy.
  ls_approver-pernr = apprv.

  SELECT SINGLE
          t1~ename,
          t1~plans,
          plans~stext AS plans_t,
          t1~stell,
          stell~stext AS stell_t,
*          zhrorg~orgsvy AS orgsvy
          CAST( ( ' ' )  AS CHAR( 2 ) ) AS orgsvy
        FROM        pa0001  AS t1
        INNER  JOIN hrp1000 AS plans
          ON    plans~plvar EQ '01'
            AND plans~otype EQ 'S'
            AND plans~objid EQ t1~plans
            AND plans~endda GE @i_datum
            AND plans~langu EQ @sy-langu

*    LEFT OUTER JOIN  hrp9301 AS zhrorg
*          ON    zhrorg~plvar EQ '01'
*            AND zhrorg~otype EQ 'O'
*            AND zhrorg~objid EQ t1~orgeh
*            AND zhrorg~endda GE @i_datum

  LEFT OUTER JOIN hrp1000 AS stell
        ON    stell~plvar EQ '01'
          AND stell~otype EQ 'C'
          AND stell~objid EQ t1~stell
          AND stell~langu EQ @sy-langu
          AND stell~endda GE @i_datum

  INTO (@ls_approver-ename,
        @ls_approver-plans,
        @ls_approver-plans_t,
        @ls_approver-stell,
        @ls_approver-stell_t,
        @ls_approver-orgsvy)
  WHERE t1~pernr EQ @ls_approver-pernr
    AND t1~endda GE @i_datum.

  READ TABLE lt_stell INTO DATA(ls_stell)
    WITH KEY stell = ls_approver-stell.
  " yönetici değilse GM-GMY ve Direktör bulma.
  IF ( sy-subrc NE 0   AND ls_approver-pernr NE pernr )
    " Yönetici ise istisna uygulama
    OR
    ( zynt EQ 'A' AND ls_approver-pernr NE pernr )
    OR
    ( sy-subrc EQ 0 AND aptyp	EQ 'ONY' AND orgsvy EQ '40' AND zynt IS INITIAL ) .

    IF sy-subrc EQ 0 .
      ls_approver-aptyp = ls_stell-aptyp.
    ELSE.
      ls_approver-aptyp = aptyp.
    ENDIF.
    " 70 seviyesi sonrası için gmy gm drktr bulma
*    IF   per_orgsvy LT '70'   AND aptyp  EQ 'ONY' AND ls_approver-orgsvy LE '40'.
    IF NOT ( per_orgsvy LT '60' ) AND aptyp  EQ 'ONY' AND ls_approver-orgsvy LE '40'.
*    IF NOT ( per_orgsvy LT '70' ) AND aptyp  EQ 'ONY' AND ls_approver-orgsvy LE '40'.
      CHECK 1 = 2 .
    ENDIF.
    IF ls_approver-orgsvy LE '60' AND aptyp EQ 'ONY' AND cv_seqnr GT 2 .
      CHECK 1 = 2 .
    ENDIF.

    ls_approver-orgsvy = orgsvy.
    ADD 1 TO cv_seqnr .
    ls_approver-seqnr = cv_seqnr.
    ls_approver-srcid = i_srcid.
    APPEND ls_approver TO pt_approvers.
  ENDIF.
  CLEAR ls_approver.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form RH_STRUC_GET
*&---------------------------------------------------------------------*
FORM rh_struc_get  USING   pv_otype
                           pv_objid
                           pv_wegid
                           pv_datum
                 CHANGING  pc_objid .

  DATA : result_tab  TYPE TABLE OF swhactor.

  CLEAR pc_objid .
  CALL FUNCTION 'RH_STRUC_GET'
    EXPORTING
      act_otype      = pv_otype
      act_objid      = pv_objid
      act_wegid      = pv_wegid
      act_plvar      = '01'
      act_begda      = pv_datum
      act_endda      = '99991231'
    TABLES
      result_tab     = result_tab[]
    EXCEPTIONS
      no_plvar_found = 1
      no_entry_found = 2
      OTHERS         = 3.
  READ TABLE result_tab INTO DATA(ls_object) INDEX 1.
  pc_objid = ls_object-objid.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form count_abs_att_times
*&---------------------------------------------------------------------*
FORM count_abs_att_times TABLES
                             p_m0000 STRUCTURE p0000
                             p_m0001 STRUCTURE p0001
                             p_m0002 STRUCTURE p0002
                             p_m0007 STRUCTURE p0007
                             p_m2001 STRUCTURE p2001
                             p_m2002 STRUCTURE p2002
                             p_m2003 STRUCTURE p2003
                             p_times_per_day STRUCTURE ptm_times_per_day
                             p_holiday STRUCTURE holiday
                         USING
                             VALUE(p_pernr) LIKE pspar-pernr
                             VALUE(p_subty) LIKE pspar-subty
                             VALUE(p_begda) LIKE p2001-begda
                             VALUE(p_endda) LIKE p2001-endda
                                   p_beguz  LIKE p2001-beguz
                                   p_enduz  LIKE p2001-enduz
                                   p_kaltg  LIKE p2001-kaltg
                                   p_stdaz  LIKE p2001-stdaz
                                   p_abwtg  LIKE p2001-abwtg
                                   p_abrtg  LIKE p2001-abrtg
                                   p_abrst  LIKE p2001-abrst
                                   p_hrsif  LIKE p2001-hrsif
                                   p_alldf  LIKE p2001-hrsif
                                   p_vtken  LIKE p2001-vtken
                                   p_holiday_filled
                          p_breaks TYPE hrtim_att_breaks
                                   p_resubrc LIKE sy-subrc.
  CONSTANTS
           yes  VALUE '1'.

  DATA: error_wo_exception TYPE c.
  DATA lv_absatt_next_day TYPE abap_bool.
  DATA: days LIKE t556a-zeinh VALUE '010'.

* Message Handler initialisieren
  CALL FUNCTION 'HR_REFRESH_ERROR_LIST'.

* Verarbeitung in FuBa rufen
  CALL FUNCTION 'HR_ABS_ATT_TIMES_AT_ENTRY'
    EXPORTING
      pernr              = p_pernr
      awart              = p_subty
      begda              = p_begda
      endda              = p_endda
    IMPORTING
      abwtg              = p_abwtg
      abrtg              = p_abrtg
      abrst              = p_abrst
      kaltg              = p_kaltg
      hrsif              = p_hrsif
      alldf              = p_alldf
      error_wo_exception = error_wo_exception
    TABLES
      m0000              = p_m0000
      m0001              = p_m0001
      m0002              = p_m0002
      m0007              = p_m0007
      m2001              = p_m2001
      m2002              = p_m2002
      m2003              = p_m2003
      times_per_day      = p_times_per_day
    CHANGING
      beguz              = p_beguz
      enduz              = p_enduz
      vtken              = p_vtken
      stdaz              = p_stdaz
      breaks             = p_breaks    "YMMPH0K000026
      cv_absatt_next_day = lv_absatt_next_day  " Note 2238145
    EXCEPTIONS
      it0001_missing     = 1
      customizing_error  = 2
      error_occurred     = 3                        "YAYP40K054237
      end_before_begin   = 4.                       "YAYP40K054237

* Nur gewisse Exceptions werden angenommen und führen zur Ausgabe
* einer Fehlermeldung. Der Rest führt zum Abbruch (->Systemfehler).

  p_resubrc = sy-subrc.
  IF NOT error_wo_exception IS INITIAL.
    p_resubrc = 4.
  ENDIF.
  IF sy-subrc NE 0.
    CLEAR: p_abwtg, p_abrtg, p_abrst, p_kaltg, p_stdaz.
  ENDIF.

* Begin of insertion Note 2238145
  IF lv_absatt_next_day = abap_true.
    PERFORM convert2 USING p_beguz p_enduz p_beguz p_enduz.
  ENDIF.
* End of insertion Note 2238145

  IF p_kaltg EQ '0'.
    LOOP AT p_times_per_day.
      SUM.
    ENDLOOP.
    p_kaltg = p_times_per_day-kaltg.
    IF p_kaltg > '999.99'.     "note 544203
      p_kaltg = '999.99'.      "note 544203
    ENDIF.                     "note 544203
  ENDIF.
* Füllen der alten Tabelle HOLIDAY für die Urlaubsabtragung und
* die deutsche Entgeltfortzahlung

  REFRESH p_holiday.
  LOOP AT p_times_per_day.
    CLEAR   p_holiday.
    p_holiday-kjahr = p_times_per_day-datum(4).
    p_holiday-date  = p_times_per_day-datum.
    p_holiday-beguz = p_times_per_day-beguz.
    p_holiday-enduz = p_times_per_day-enduz.
    p_holiday-ktart = p_times_per_day-ktart.
    p_holiday-zeinh = p_times_per_day-zeinh.
    p_holiday-urar1 = p_times_per_day-urar1.
    p_holiday-urar2 = p_times_per_day-urar2.
    p_holiday-urar3 = p_times_per_day-urar3.
    p_holiday-urar4 = p_times_per_day-urar4.
    p_holiday-urar5 = p_times_per_day-urar5.
    p_holiday-urar6 = p_times_per_day-urar6.
    p_holiday-urmin = p_times_per_day-urmin.
    p_holiday-dedir = p_times_per_day-dedir.
    IF p_times_per_day-zeinh = days.
      p_holiday-anzhl = p_times_per_day-abrtg.
      p_holiday-anzh1 = p_times_per_day-abrst.
    ELSE.
      p_holiday-anzhl = p_times_per_day-abrst.
      p_holiday-anzh1 = p_times_per_day-abrtg.
    ENDIF.
    CHECK p_holiday-anzhl > 0.
    APPEND p_holiday.
  ENDLOOP.
*--- set switch holiday_filled
  IF NOT p_holiday[] IS INITIAL.
    p_holiday_filled = yes.
  ENDIF.
ENDFORM.                    " COUNT_ABS_ATT_TIMES
*---------------------------------------------------------------------*
*       FORM CONVERT2                                                 *
*---------------------------------------------------------------------*
FORM convert2 USING c2_t1 c2_t2 c2_t3 c2_t4                  ##CALLED.
  DATA: c2_pack1(6) TYPE c, c2_pack2(6) TYPE c,
        c2_p1(4)    TYPE p, c2_p2(4) TYPE p.
  TRANSLATE c2_t1 USING ' 0'.
  TRANSLATE c2_t2 USING ' 0'.
  TRANSLATE c2_t3 USING ' 0'.
  TRANSLATE c2_t4 USING ' 0'.
  MOVE c2_t1    TO c2_pack1.
  MOVE c2_t2    TO c2_pack2.
  MOVE c2_pack1 TO c2_p1.
  MOVE c2_pack2 TO c2_p2.
  IF c2_p1 GE c2_p2.                                        "QAFK84632
    c2_p2 = c2_p2 + 240000.
  ELSE.
    IF c2_p1 GT 240000 OR c2_p2 GT 240000.
      RETURN.
    ENDIF.
    c2_p1 = c2_p1 + 240000.
    c2_p2 = c2_p2 + 240000.
  ENDIF.
  UNPACK c2_p1  TO c2_pack1.
  UNPACK c2_p2  TO c2_pack2.
  MOVE   c2_pack1 TO c2_t3.
  MOVE   c2_pack2 TO c2_t4.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form create_tlpid
*&---------------------------------------------------------------------*
FORM create_tlpid    TABLES et_return
                      USING pv_srcid TYPE zhr_prt_srcid
                   CHANGING cv_tlpid TYPE zhr_prt_tlpid
                            cv_subrc TYPE sy-subrc .
  DATA : ls_t010   TYPE zhr_prt_t010,
         lv_msgno  TYPE bapireturn1-number,
         ls_return TYPE bapireturn1.


  SELECT SINGLE * FROM zhr_prt_t010 INTO ls_t010
     WHERE srcid = pv_srcid.
  IF sy-subrc NE 0 .
    lv_msgno = '007'.
  ELSEIF sy-subrc EQ 0 AND ls_t010-activ NE 'X'.
    lv_msgno = '008'.
    ls_return-message_v1 = ls_t010-srcid_t.
  ELSEIF sy-subrc EQ 0 AND ls_t010-nrnr IS INITIAL .
    lv_msgno = '025'.
  ENDIF.
  IF lv_msgno IS NOT INITIAL .
    PERFORM add_message TABLES et_return
                         USING pv_srcid
                               ''
                               'ZHR_PRT'
                               'E'
                               lv_msgno
                               ls_return .
    EXIT.
  ENDIF.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = ls_t010-nrnr
      object                  = 'ZHR_PRTLPI'
    IMPORTING
      number                  = cv_tlpid
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      quantity_is_0           = 4
      quantity_is_not_1       = 5
      interval_overflow       = 6
      buffer_overflow         = 7
      OTHERS                  = 8.

  cv_subrc = sy-subrc.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form operation_leave_data
*&---------------------------------------------------------------------*
FORM operation_leave_data TABLES et_return  STRUCTURE  zhr_prt_sreturn
                          USING pv_statu
                                pv_tlpid
                                pv_pernr
                                pv_oper
                        CHANGING cs_t005 STRUCTURE zhr_prt_t005.

  DATA : ls_return TYPE bapireturn1,
         ls_2001   TYPE p2001,
         ls_t005   TYPE zhr_prt_t005, "İzin talepleri detayı
         cs_leave  TYPE zhr_prt_s016,
         lt_return TYPE zhr_prt_treturn.




*  SELECT SINGLE * FROM zhr_prt_t005 INTO ls_t005
*      WHERE tlpid EQ pv_tlpid.

*  IF sy-subrc EQ 0 .
  MOVE-CORRESPONDING cs_t005 TO ls_t005.
  IF cs_t005-tlpid IS NOT INITIAL AND cs_t005-tlpid NE '9999999999' .
    MOVE-CORRESPONDING ls_t005 TO cs_leave.
    CALL FUNCTION 'ZHR_PRT_CHECK_LEAVE'
      EXPORTING
        i_srcid   = '0001'
        i_tlpid   = pv_tlpid
      IMPORTING
        et_return = lt_return[]
      CHANGING
        cs_leave  = cs_leave.

    READ TABLE lt_return TRANSPORTING NO FIELDS WITH KEY type = 'E'.
    IF sy-subrc EQ 0.
      et_return[] = lt_return[].
    ELSE.
      APPEND LINES OF lt_return TO et_return.
    ENDIF.
    READ TABLE lt_return TRANSPORTING NO FIELDS WITH KEY type = 'E'.
    CHECK sy-subrc NE 0 .

    CALL FUNCTION 'BAPI_EMPLOYEE_ENQUEUE'
      EXPORTING
        number = pv_pernr
      IMPORTING
        return = ls_return.
    IF ls_return-type NE 'E'.
      MOVE-CORRESPONDING cs_leave TO ls_2001.
      ls_2001-infty = '2001'.
      ls_2001-subty = ls_t005-awart.
      ls_2001-beguz = ls_t005-beguz.
      ls_2001-enduz = ls_t005-enduz.
      cs_t005-retdt = cs_leave-retdt.

      CALL FUNCTION 'HR_INFOTYPE_OPERATION'
        EXPORTING
          infty         = ls_2001-infty
          number        = ls_2001-pernr
          validityend   = ls_2001-endda
          validitybegin = ls_2001-begda
          subtype       = ls_2001-subty
          record        = ls_2001
          operation     = pv_oper
          tclas         = 'A'
          dialog_mode   = '0'
        IMPORTING
          return        = ls_return.
      IF ls_return-type EQ 'E'.
        REFRESH et_return.
        PERFORM add_message TABLES et_return
                             USING space
                                   pv_pernr
                                   'ZHR_PRT'
                                   'E'
                                   '00'
                                   ls_return .
      ELSE.
      ENDIF.

      CALL FUNCTION 'BAPI_EMPLOYEE_DEQUEUE'
        EXPORTING
          number = ls_2001-pernr.
    ELSE.
      REFRESH et_return.
      PERFORM add_message TABLES et_return
                           USING space
                                 pv_pernr
                                 'ZHR_PRT'
                                 'E'
                                 '015'
                                 ls_return .
      EXIT.
    ENDIF.
  ELSE.
    REFRESH et_return.
    PERFORM add_message TABLES et_return
                         USING space
                               pv_pernr
                               'ZHR_PRT'
                               'E'
                               '015'
                               ls_return .
  ENDIF.
ENDFORM .
*&---------------------------------------------------------------------*
*& Form leave_req_send_mail
*&---------------------------------------------------------------------*
FORM leave_req_send_mail TABLES pt_t004    STRUCTURE zhr_prt_t004
                                pt_t005    STRUCTURE zhr_prt_t005
                                pt_t006    STRUCTURE zhr_prt_t006
                                et_return  STRUCTURE  zhr_prt_sreturn
                          USING pv_statu
                                pv_tlpid
                                pv_pernr
                                pv_sender.

  DATA :
*         "Local Object References
    ls_pers       TYPE p0001,
    ls_cds2       TYPE zhr_prt_ddl002,
    lv_tname      LIKE thead-tdname VALUE 'ZHR_PRT_ST001',
    lt_paramaters TYPE TABLE OF zhr_prt_s019 WITH HEADER LINE,
    lv_pernr      TYPE persno,
    lt_dd07t      TYPE TABLE OF dd07t,
    lt_return     TYPE  zhr_prt_treturn.


  DEFINE pers_value .
    SELECT pernr,
           ename,
           werks,
           btrtl,
           orgeh,
           plans,
           plans~stext AS plans_t,
           stell,
           stell~stext AS stell_t,
           sachz,
      " Yönetici ise A gelecek
           CAST(  ( CASE ( ynt~objid )
                      WHEN ' ' THEN ' '
                      ELSE ynt~rsign END ) AS CHAR( 1 ) ) AS  zynt ,
           CAST( ( ' ' ) AS CHAR( 2 ) )  AS zhrorg
                   FROM pa0001  AS t1
        INNER JOIN hrp1000 AS stell
              ON    stell~plvar EQ '01'
                AND stell~otype EQ 'C'
                AND stell~objid EQ t1~stell
                AND stell~langu EQ @sy-langu
                AND stell~endda GE @sy-datum
        INNER JOIN hrp1000 AS plans
              ON    plans~plvar EQ '01'
                AND plans~otype EQ 'S'
                AND plans~objid EQ t1~plans
                AND plans~langu EQ @sy-langu
                AND plans~endda GE @sy-datum
        LEFT OUTER JOIN hrp1001 AS ynt
              ON    ynt~plvar EQ '01'
                AND ynt~otype EQ 'S'
                AND ynt~objid EQ t1~plans
                AND ynt~rsign EQ 'A'
                AND ynt~relat EQ '012'
                AND ynt~endda GE @sy-datum
*        LEFT OUTER JOIN hrp9301 AS orgsv
*              ON    orgsv~otype EQ 'O'
*                AND orgsv~plvar EQ '01'
*                AND orgsv~objid EQ t1~orgeh
*                AND orgsv~endda GE @sy-datum
      INTO TABLE @DATA(lt_pernr)
          WHERE t1~pernr EQ @&1
            AND t1~endda GE @&2
            AND t1~begda LE @&3.
  END-OF-DEFINITION.

  SELECT * FROM dd07t INTO TABLE lt_dd07t
      WHERE domname     EQ 'ZHR_PRT_STATU'
        AND ddlanguage  EQ sy-langu.


  READ TABLE pt_t004 ASSIGNING FIELD-SYMBOL(<ls_t004>) WITH KEY tlpid = pv_tlpid.
  READ TABLE pt_t005 ASSIGNING FIELD-SYMBOL(<ls_t005>) WITH KEY tlpid = pv_tlpid.
  READ TABLE pt_t006 ASSIGNING FIELD-SYMBOL(<ls_t006>) WITH KEY tlpid = pv_tlpid
                                                                statu = pv_statu.
  IF sy-subrc NE 0 .
    READ TABLE pt_t006 ASSIGNING <ls_t006> INDEX 1 .
  ENDIF.


  pers_value : pv_pernr <ls_t005>-begda <ls_t005>-endda .

*  READ TABLE lt_pernr INTO DATA(ls_pernr) WITH KEY pernr = pv_pernr.
*
*  IF <ls_t006>-aptyp EQ 'ZMNY'.
*    READ TABLE gt_zmynt INTO DATA(ls_zmynt) WITH KEY sachx = ls_pernr-sachz.
*
*    SELECT SINGLE * FROM zhr_prt_ddl002 INTO ls_cds2
*        WHERE tlpid     EQ pv_tlpid
*           AND seqnr    EQ <ls_t006>-seqnr
*           AND ap_pernr EQ ls_zmynt-pernr .
*  ELSE.
  SELECT SINGLE * FROM zhr_prt_ddl002 INTO ls_cds2
      WHERE tlpid     EQ pv_tlpid
         AND seqnr    EQ <ls_t006>-seqnr .
*  ENDIF.


*  <<--------ik müdürleri------>>
  SELECT
        t2~pernr,
        t2~ename,
        t1~srcid,
        t1~orgsvy,
        t1~seqnr,
        t1~plans,
        email~usrid_long AS zemail
        FROM zhr_prt_tonyik AS t1
  INNER JOIN pa0001         AS t2
    ON    t2~plans EQ t1~plans
      AND t2~endda GE @sy-datum
  INNER JOIN pa0105 AS email
    ON    email~pernr EQ t2~pernr
      AND email~endda GE @sy-datum
      AND email~subty EQ 'MAIL'
  INTO TABLE @DATA(lt_ikmdr)
    FOR ALL ENTRIES IN @lt_pernr
      WHERE srcid EQ '00001'
        AND orgsvy EQ @lt_pernr-zhrorg.
  SORT lt_ikmdr ASCENDING BY orgsvy seqnr .

  "<<--------END CODE------>>
*  ENDIF.
*
  "<<--------BEGIN CODE------>>
*&1& Talep numarası
*&2& Talep ismi
*&3& statü tanımı
*&4& Personel Adı soyadı veya
*&5& Onaycı Adı soyadı
*&6& Talep tarihi
*&7& izin gün
*&8& Link
*&9& Açıklama
*&10& Onay Red Açıklama
*&11& İşe dönüş tarihi
  "<<--------END CODE------>>


*&1& Talep numarası
  lt_paramaters-param = pv_tlpid.SHIFT lt_paramaters-param LEFT DELETING LEADING '0' .APPEND lt_paramaters.

*&2& Talep ismi
  lt_paramaters-param = ls_cds2-awart_t.  APPEND lt_paramaters.

*&3& statü tanımı
  CASE <ls_t004>-statu.
    WHEN '01'. "  Onay Bekliyor.
      lt_paramaters-param = ls_cds2-statu_t.TRANSLATE lt_paramaters-param TO LOWER CASE .APPEND lt_paramaters.
      lv_pernr = ls_cds2-ap_pernr.
      lv_tname      = 'ZHR_PRT_ST002'.

    WHEN '02'. "  Onaylandı.
      READ TABLE lt_dd07t INTO DATA(ls_dd07t) WITH KEY domvalue_l  = <ls_t004>-statu.
      lt_paramaters-param = ls_dd07t-ddtext. TRANSLATE lt_paramaters-param TO LOWER CASE .APPEND lt_paramaters.
      lv_pernr = ls_cds2-pernr.
      lv_tname      = 'ZHR_PRT_ST001'.

    WHEN '03'. "  Reddedildi.
      READ TABLE lt_dd07t INTO ls_dd07t WITH KEY domvalue_l  = <ls_t004>-statu.
      lt_paramaters-param = ls_dd07t-ddtext. TRANSLATE lt_paramaters-param TO LOWER CASE .APPEND lt_paramaters.
      lv_pernr = ls_cds2-pernr.
      lv_tname      = 'ZHR_PRT_ST001'.

    WHEN '04'. "  Tamamlandı.
      READ TABLE lt_dd07t INTO ls_dd07t WITH KEY domvalue_l  = <ls_t004>-statu.
      lt_paramaters-param = ls_dd07t-ddtext.TRANSLATE lt_paramaters-param TO LOWER CASE .APPEND lt_paramaters.
      lv_pernr = ls_cds2-pernr.
      lv_tname      = 'ZHR_PRT_ST001'.

    WHEN '05'. "  İptal edildi.
      READ TABLE lt_dd07t INTO ls_dd07t WITH KEY domvalue_l  = <ls_t004>-statu.
      lt_paramaters-param = ls_dd07t-ddtext.TRANSLATE lt_paramaters-param TO LOWER CASE .APPEND lt_paramaters.
      lv_pernr = ls_cds2-ap_pernr.
      lv_tname      = 'ZHR_PRT_ST003'.
  ENDCASE.

*&4& Personel Adı soyadı veya
  lt_paramaters-param = ls_cds2-ename. APPEND lt_paramaters.

*&5& Onaycı Adı soyadı
  lt_paramaters-param = ls_cds2-ap_ename. APPEND lt_paramaters.

*&6& Talep tarihi
  lt_paramaters-param = ls_cds2-begda+6(2) && '.' && ls_cds2-begda+4(2) && '.' && ls_cds2-begda(4)
                    && '-' &&
                        ls_cds2-endda+6(2) && '.' && ls_cds2-endda+4(2) && '.' && ls_cds2-endda(4) .
  APPEND lt_paramaters.

*&7& izin gün
  IF <ls_t005>-awart EQ '0204'.
    lt_paramaters-param = ls_cds2-abrtg. APPEND lt_paramaters.
  ELSE.
    lt_paramaters-param = ls_cds2-kaltg. APPEND lt_paramaters.
  ENDIF.

*&8& Link
  CASE <ls_t004>-statu.
    WHEN '01'. "  Onay Bekliyor.
      lt_paramaters-param = 'http://ikportaltest.icdas.com.tr:81/#/AppViewer?izin-onaylarim'.
    WHEN '02' OR '03' OR '04' OR '05'.
      lt_paramaters-param = 'http://ikportaltest.icdas.com.tr:81/#/AppViewer?izin-taleplerim'.

    WHEN OTHERS .
      lt_paramaters-param = 'http://ikportaltest.icdas.com.tr:81'.
  ENDCASE.
  APPEND lt_paramaters.

*&9& Açıklama
  lt_paramaters-param = <ls_t005>-zdesc. APPEND lt_paramaters.

*&10& Onay Red Açıklama
  lt_paramaters-param = <ls_t006>-ap_zdesc. APPEND lt_paramaters.

*&11& İşe dönüş tarihi
  lt_paramaters-param = <ls_t005>-retdt+6(2) && '.' && <ls_t005>-retdt+4(2) && '.' && <ls_t005>-retdt(4)  .APPEND lt_paramaters.


  DATA : lt_email TYPE zhr_prt_tt023 .
  DATA : ls_email TYPE zhr_prt_s023 .

  SELECT SINGLE usrid_long FROM pa0105 INTO ls_email-email
      WHERE pernr EQ lv_pernr
*        AND subty EQ 'MAIL'
        AND subty EQ '0010'
        AND begda LE sy-datum
        AND endda GE sy-datum.
  APPEND ls_email TO lt_email.

  LOOP AT lt_ikmdr INTO DATA(ls_ikmdr).
    ls_email-email = ls_ikmdr-zemail .
    ls_email-cc = 'X'.
    APPEND ls_email TO lt_email.
  ENDLOOP.

  CALL FUNCTION 'ZHR_PRT_FG001_15'
    EXPORTING
      iv_sender = pv_sender
      iv_tdname = lv_tname
      it_email  = lt_email[]
      t_param   = lt_paramaters[]
    IMPORTING
      et_return = lt_return[].
  REFRESH lt_email.
  APPEND LINES OF lt_return TO et_return.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form read_text
*&---------------------------------------------------------------------*
FORM read_text TABLES pt_lines   TYPE tlinetab
                      pt_return  STRUCTURE  zhr_prt_sreturn
                USING pv_name    LIKE thead-tdname.

  DATA : ls_return TYPE bapireturn1,
         langu     LIKE sy-langu VALUE 'T'.

  SET LOCALE LANGUAGE  langu.

  langu = sy-langu .
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      client                  = sy-mandt
      id                      = 'ST'
      language                = langu
      name                    = pv_name
      object                  = 'TEXT'
    TABLES
      lines                   = pt_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.
  IF sy-subrc <> 0.
    ls_return-id         = sy-msgid.
    ls_return-type       = sy-msgty.
    ls_return-number     = sy-msgno.
    ls_return-message_v1 = sy-msgv1.
    ls_return-message_v2 = sy-msgv2.
    ls_return-message_v3 = sy-msgv3.
    ls_return-message_v4 = sy-msgv4.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
            INTO ls_return-message.
    PERFORM add_message TABLES pt_return
                         USING ''
                               ''
                               'ZHR_PRT'
                               'E'
                               '000'
                               ls_return .
    EXIT.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_photo
*&---------------------------------------------------------------------*
FORM get_photo  USING    pv_pernr
                CHANGING cv_photo.
  DATA :
    p_connect_info LIKE TABLE OF toav0 WITH HEADER LINE,
    ex_document    TYPE TABLE OF  tbl1024,
    ex_length      TYPE int4,
    binary_tab     TYPE TABLE OF tbl1024,
    buffer         TYPE xstring.


  CALL FUNCTION 'HR_IMAGE_EXISTS'
    EXPORTING
      p_pernr        = pv_pernr
    IMPORTING
      p_connect_info = p_connect_info
    EXCEPTIONS
      OTHERS         = 2.
  CHECK sy-subrc EQ 0 .

  CALL FUNCTION 'ALINK_RFC_TABLE_GET'
    EXPORTING
      im_docid    = p_connect_info-arc_doc_id
      im_crepid   = p_connect_info-archiv_id
    IMPORTING
      ex_length   = ex_length
    TABLES
      ex_document = ex_document.

  CHECK sy-subrc EQ 0 .
  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      input_length = ex_length
    IMPORTING
      buffer       = buffer
    TABLES
      binary_tab   = ex_document
    EXCEPTIONS
      failed       = 1
      OTHERS       = 2.
  CHECK sy-subrc EQ 0 .
  CALL FUNCTION 'SCMS_BASE64_ENCODE_STR'
    EXPORTING
      input  = buffer
    IMPORTING
      output = cv_photo.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_qouta
*&---------------------------------------------------------------------*
FORM check_qouta TABLES pt_return STRUCTURE zhr_prt_sreturn
                  USING ps_leave  TYPE zhr_prt_s016..

  DATA :
        lt_awart TYPE TABLE OF zhr_prt_ddl005  WITH HEADER LINE ,
        ls_return TYPE bapireturn1,
        lv_qouta  TYPE zhr_prt_s011-qouta,
        lt_qouta  TYPE  zhr_prt_tt011.

  CALL FUNCTION 'ZHR_PRT_FG001_05'
    EXPORTING
      i_srcid  = '00001'
      i_pernr  = ps_leave-pernr
      i_datum  = sy-datum
    IMPORTING
      et_qouta = lt_qouta.

*  "<<--------İzin türleri için kota tipleri ------>>
  PERFORM get_awart_qouta_type TABLES lt_awart
                                USING ps_leave-pernr.
*  "<<--------END CODE------>>



  READ TABLE lt_awart INTO DATA(ls_awart) WITH KEY awart = ps_leave-awart.
  IF sy-subrc EQ 0 AND ls_awart-qttps IS NOT INITIAL  .
    LOOP AT lt_qouta ASSIGNING FIELD-SYMBOL(<fs>)
          WHERE qouta GT 0
            AND ktart EQ ls_awart-qttps .
      ADD <fs>-qouta TO lv_qouta.
    ENDLOOP.
    IF sy-subrc NE 0 OR lv_qouta LT ps_leave-abrtg.
      CLEAR ls_return.
      ls_return-message_v1 = ls_awart-awart_t.
      PERFORM add_message TABLES pt_return
                           USING '00001'
                                 ps_leave-pernr
                                 'ZHR_PRT'
                                 'E'
                                 '019'
                                 ls_return .
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_awart_qouta_type
*&---------------------------------------------------------------------*
FORM get_awart_qouta_type  TABLES   pt_awart
                           USING    pv_pernr.
*
  SELECT * FROM zhr_prt_ddl005( p_pernr = @pv_pernr )
     INTO CORRESPONDING
        FIELDS OF TABLE @pt_awart  .
ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_leave_list
*&---------------------------------------------------------------------*
FORM get_leave_list  TABLES   et_list STRUCTURE zhr_prt_s017_2
                              lr_pernr
                              lr_awart
                      USING   i_srcid
                              i_begda
                              i_endda.

  "* 2 RFC de kullanılıyor, değişiklik yaparken dikkatli ol
  "*ZHR_PRT_FG001_06 Personel İzinlerini Getir
  "*ZHR_PRT_FG001_11 İzin Onay Talep Listesi (Puantör-Admin onaycı dahil)

  DATA : lt_dd07t    TYPE TABLE OF dd07t WITH HEADER LINE.


  SELECT * FROM dd07t INTO TABLE lt_dd07t
      WHERE domname    EQ 'ZHR_PRT_STATU'
        AND ddlanguage EQ sy-langu .

  "<<--------Zaman Yöneticileri ------>>
  PERFORM get_gt_zmynt TABLES gt_zmynt
                        USING sy-datum
                              'SAPU'
                              'PA01' .
  "<<--------END CODE------>>
*ZHR_PRT_DDL004 Personel izin verileri 2001/Portal
  SELECT * FROM zhr_prt_ddl004 AS t1
        INTO CORRESPONDING
      FIELDS OF TABLE @et_list
      WHERE srcid      EQ  @i_srcid
        AND pernr      IN  @lr_pernr
        AND awart      IN  @lr_awart
        AND (
              ( statu EQ '01' AND ap_statu EQ '01'  )
             OR
              ( statu EQ '02' AND ap_statu EQ '02' AND seqnr EQ ( SELECT MAX( seqnr )  FROM zhr_prt_t006
                                                                     WHERE tlpid    EQ t1~tlpid
                                                                       AND statu    EQ t1~ap_statu ) )
             OR
              ( tlpid EQ '9999999999' AND statu EQ '04' AND ap_statu EQ '02' ) " 2001 deki izinler
             OR
              ( statu EQ '04' AND ap_statu EQ '02' AND seqnr EQ ( SELECT MAX( seqnr )  FROM zhr_prt_t006
                                                                     WHERE tlpid    EQ t1~tlpid
                                                                       AND statu    EQ t1~ap_statu ) )
             OR
              ( statu EQ '03' AND ap_statu EQ '03'     )
             OR
              ( statu EQ '05' AND ap_statu EQ '05'   )
             )
        AND begda      LE  @i_endda
        AND endda      GE  @i_begda
    .

  SORT et_list ASCENDING BY pernr seqnr DESCENDING begda endda .


  LOOP AT et_list INTO DATA(ls_list) WHERE tlpid EQ '9999999999'.
    LOOP AT et_list TRANSPORTING NO FIELDS WHERE tlpid NE ls_list-tlpid
                                             AND pernr EQ ls_list-pernr
                                             AND awart EQ ls_list-awart
                                             AND begda EQ ls_list-begda
                                             AND endda EQ ls_list-endda.
    ENDLOOP.
    IF sy-subrc EQ 0." Portaldeki tamamlandı kaydı 2001 den geldiyse sil
      DELETE et_list WHERE tlpid EQ ls_list-tlpid
                       AND pernr EQ ls_list-pernr
                       AND awart EQ ls_list-awart
                       AND begda EQ ls_list-begda
                       AND endda EQ ls_list-endda.
    ENDIF.
  ENDLOOP.
  SORT et_list ASCENDING BY pernr seqnr DESCENDING begda endda .
  CHECK et_list[] IS NOT INITIAL .

  LOOP AT lt_dd07t .
    CLEAR ls_list.
    ls_list-statu_t = lt_dd07t-ddtext.
    MODIFY et_list FROM ls_list TRANSPORTING statu_t
      WHERE statu = lt_dd07t-domvalue_l.

    CLEAR ls_list.
    ls_list-ap_statu_t = lt_dd07t-ddtext.
    MODIFY et_list FROM ls_list TRANSPORTING ap_statu_t
      WHERE ap_statu = lt_dd07t-domvalue_l.
  ENDLOOP.

ENDFORM.
