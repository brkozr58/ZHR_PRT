FUNCTION zhr_prt_fg001_18.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_PERNR) TYPE  PERSNO OPTIONAL
*"     VALUE(I_ENAME) TYPE  EMNAM OPTIONAL
*"     VALUE(I_DATUM) TYPE  DATUM DEFAULT SY-DATUM
*"     VALUE(I_MAXC) TYPE  SYST_TABIX DEFAULT 200
*"  EXPORTING
*"     VALUE(ET_PERSONS) TYPE  ZHR_PRT_TT020
*"----------------------------------------------------------------------
  DATA : lr_datum TYPE RANGE OF datum .
  DATA : lr_pernr TYPE RANGE OF persno .
  DATA : lr_ename TYPE RANGE OF emnam .
  DATA : lr_stat2 TYPE RANGE OF stat2 .
  DATA : ls_person TYPE zhr_prt_s009.
  DATA : lt_onayci   TYPE TABLE OF zhr_prt_tonayci WITH HEADER LINE.

  DATA langu LIKE sy-langu VALUE 'T'.
  SET LOCALE LANGUAGE  langu.


  APPEND VALUE #( sign    = 'I' option  = 'EQ' low     = '3' )  TO lr_stat2.
  APPEND VALUE #( sign    = 'I' option  = 'EQ' low     = '2' )  TO lr_stat2.

  IF i_pernr IS NOT INITIAL .
    APPEND VALUE #( sign    = 'I' option  = 'EQ' low     = i_pernr )  TO lr_pernr.
  ENDIF.

  IF i_ename IS NOT INITIAL .
    APPEND VALUE #( sign = 'I' option = 'CP' low = '*' && i_ename && '*' )  TO lr_ename.
  ENDIF.


  SELECT t1~pernr, t1~ename FROM pa0001 AS t1
            INNER JOIN pa0000 AS t0
                  ON    t0~pernr EQ t1~pernr
                    AND t0~begda LE t1~endda
                    AND t0~endda GE t1~begda
      WHERE t0~pernr IN @lr_pernr[]
        AND t1~ename IN @lr_ename[]
        AND t0~stat2 IN @lr_stat2[]
        AND t0~endda GE @i_datum
        AND t1~endda GE @i_datum
    INTO TABLE @et_persons
    UP TO @i_maxc ROWS
    .

  CHECK sy-subrc EQ 0 .
  SORT et_persons ASCENDING BY pernr .



ENDFUNCTION.
