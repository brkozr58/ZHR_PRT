FUNCTION zhr_prt_fg001_02.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_PERNR) TYPE  PERSNO OPTIONAL
*"     VALUE(I_DATUM) TYPE  DATUM DEFAULT SY-DATUM
*"  EXPORTING
*"     VALUE(ET_PERSONS) TYPE  ZHR_PRT_TT009
*"----------------------------------------------------------------------
  TABLES : pa0000, 	t513s        ,
           pa0001,  t527x        ,
           pa0002,  t528t        ,
           pa0006,  t501t        ,
           pa0021,  t503t        ,
           pa0022,  t001p        ,
           pa0041,  t001         ,
           pa0105,  t517t        ,
           pa0770,  t005t          .

  DATA : lr_datum TYPE RANGE OF datum .
  DATA : lr_pernr TYPE RANGE OF persno .
  DATA : lr_stat2 TYPE RANGE OF stat2 .
  DATA : ls_person TYPE zhr_prt_s009.

  DATA langu LIKE sy-langu VALUE 'T'.
  SET LOCALE LANGUAGE  langu.


  APPEND VALUE #( sign    = 'I' option  = 'EQ' low     = '3' )  TO lr_stat2.
  APPEND VALUE #( sign    = 'I' option  = 'EQ' low     = '2' )  TO lr_stat2.

  IF i_pernr IS NOT INITIAL .
    APPEND VALUE #( sign    = 'I' option  = 'EQ' low     = i_pernr )  TO lr_pernr.
  ENDIF.

  SELECT t1~pernr,t1~ename FROM pa0001 AS t1
            INNER JOIN pa0000 AS t0
                  ON    t0~pernr EQ t1~pernr
                    AND t0~begda LE t1~endda
                    AND t0~endda GE t1~begda
      WHERE t0~pernr IN @lr_pernr[]
        AND t0~stat2 IN @lr_stat2[]
        AND t0~endda GE @i_datum
        AND t1~endda GE @i_datum
    INTO TABLE @DATA(lt_pers).

  CHECK sy-subrc EQ 0 .
  SORT lt_pers ASCENDING BY pernr .

  LOOP AT lt_pers INTO DATA(ls_pernr).
    CLEAR : ls_person.
    ls_person-pernr = ls_pernr-pernr.
    ls_person-ename = ls_pernr-ename.

    PERFORM get_photo USING ls_person-pernr
                   CHANGING ls_person-photo .


*PERS_INFO  1 Types ZHR_PRT_TT002
    PERFORM pers_info TABLES ls_person-pers_info
                       USING ls_person-pernr
                             i_datum.
*WORK_INFO  1 Types ZHR_PRT_TT003
    PERFORM work_info TABLES ls_person-work_info
                       USING ls_person-pernr
                             i_datum.
*CONT_INFO  1 Types ZHR_PRT_TT004
    PERFORM cont_info TABLES ls_person-cont_info
                       USING ls_person-pernr
                             i_datum.
*EDUC_INFO  1 Types ZHR_PRT_TT005
    PERFORM educ_info TABLES ls_person-educ_info
                       USING ls_person-pernr
                             i_datum.
*DATE_INFO  1 Types ZHR_PRT_TT006
    PERFORM date_info TABLES ls_person-date_info
                       USING ls_person-pernr
                             i_datum.
*ADRS_INFO  1 Types ZHR_PRT_TT007
    PERFORM adrs_info TABLES ls_person-adrs_info
                       USING ls_person-pernr
                             i_datum.
*FAML_INFO  1 Types ZHR_PRT_TT008
    PERFORM faml_info TABLES ls_person-faml_info
                       USING ls_person-pernr
                             i_datum.

    APPEND ls_person TO et_persons.
  ENDLOOP.


ENDFUNCTION.
