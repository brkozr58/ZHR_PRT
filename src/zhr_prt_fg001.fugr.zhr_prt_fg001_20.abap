FUNCTION zhr_prt_fg001_20.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_PERNR) TYPE  PERSNO OPTIONAL
*"     VALUE(I_DATUM) TYPE  DATUM DEFAULT SY-DATUM
*"  EXPORTING
*"     VALUE(ET_PERSONS) TYPE  ZHR_PRT_TT022
*"----------------------------------------------------------------------
  DATA : lr_datum TYPE RANGE OF datum .
  DATA : lr_pernr TYPE RANGE OF persno .
  DATA : lt_pers TYPE  zhr_prt_tt020.
  DATA : ls_pers TYPE  zhr_prt_s022.
  DATA langu LIKE sy-langu VALUE 'T'.
  DATA : lt_aptyp_t TYPE TABLE OF dd07t WITH HEADER LINE .

  DEFINE set_aptyp .
    READ TABLE lt_aptyp_t WITH KEY domvalue_l = &1.
    IF sy-subrc EQ 0 .
      ls_pers-aptyp = &1.
      ls_pers-aptyp_t = lt_aptyp_t-ddtext.
    ENDIF.
  END-OF-DEFINITION.

  SET LOCALE LANGUAGE  langu.

  IF i_pernr IS NOT INITIAL .
    APPEND VALUE #( sign    = 'I' option  = 'EQ' low     = i_pernr )  TO lr_pernr.
  ENDIF.


  SELECT * FROM dd07t INTO TABLE lt_aptyp_t
      WHERE domname EQ 'ZHR_PRT_APTYP'
        AND ddlanguage EQ sy-langu .


  " Kişi yönetici mi burada bulabiliyor.
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
    " Yönetici ise X gelecek
         CAST(  ( CASE ( ynt~objid )
                    WHEN ' '  THEN ' '
                    ELSE ynt~rsign END ) AS CHAR( 1 ) ) AS  zynt ,
         CAST( ( ' ' ) AS CHAR( 2 ) ) AS zhrorg
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


  " İk müdürleri
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
      WHERE srcid EQ '00001'.
  SORT lt_ikmdr ASCENDING BY orgsvy seqnr .


  " Sabit onaycı
  SELECT * FROM zhr_prt_tonayci INTO TABLE @DATA(lt_onayci)
      WHERE srcid EQ '00001' .

  " Admin onaycı
  SELECT * FROM zhr_prt_tadmin INTO TABLE @DATA(lt_admin)
      WHERE srcid EQ '00001' .

*İstisna için İş anahtarı
  SELECT * FROM zhr_prt_tstell INTO TABLE @DATA(lt_stell)
      WHERE srcid EQ '00001' .

  "<<--------Zaman Yöneticileri ------>>
  PERFORM get_gt_zmynt TABLES gt_zmynt
                        USING i_datum
                              'SAPU'
                              'PA01' .
  "<<--------END CODE------>>


  LOOP AT lt_pernr INTO DATA(ls_temp).
    MOVE-CORRESPONDING ls_temp TO ls_pers .
    READ TABLE gt_zmynt WITH KEY pernr = ls_pers-pernr TRANSPORTING NO FIELDS .
    IF sy-subrc EQ 0 . set_aptyp: 'ZMNY'.     ENDIF.
    READ TABLE lt_onayci WITH KEY zapp1 = ls_pers-pernr TRANSPORTING NO FIELDS .
    IF sy-subrc EQ 0 . set_aptyp 'ONY2'.      ENDIF.
    READ TABLE lt_onayci WITH KEY zapp2 = ls_pers-pernr TRANSPORTING NO FIELDS .
    IF sy-subrc EQ 0 . set_aptyp 'ONY2'.      ENDIF.
    READ TABLE lt_ikmdr WITH KEY pernr = ls_pers-pernr TRANSPORTING NO FIELDS .
    IF sy-subrc EQ 0 . set_aptyp 'IKMDR'.     ENDIF.
    READ TABLE lt_admin WITH KEY pernr = ls_pers-pernr TRANSPORTING NO FIELDS .
    IF sy-subrc EQ 0 . set_aptyp 'ADM'.       ENDIF.
    READ TABLE lt_stell INTO DATA(ls_stell) WITH KEY stell = ls_temp-stell  .
    IF sy-subrc EQ 0 . set_aptyp  ls_stell-aptyp. ENDIF.
    IF ls_pers-aptyp IS INITIAL AND ls_temp-zynt EQ 'A' . set_aptyp  'ONY'.ENDIF.
    COLLECT ls_pers INTO et_persons. CLEAR : ls_pers.
  ENDLOOP.
  SORT et_persons ASCENDING BY pernr.

ENDFUNCTION.
