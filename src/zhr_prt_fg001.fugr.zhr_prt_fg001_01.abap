FUNCTION zhr_prt_fg001_01.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_DATUM) TYPE  DATUM DEFAULT SY-DATUM
*"     VALUE(I_ALL) TYPE  FLAG DEFAULT 'X'
*"     VALUE(I_PERNR) TYPE  PERSNO OPTIONAL
*"     VALUE(I_ACTIVE) TYPE  FLAG DEFAULT 'X'
*"     VALUE(I_PASSIVE) TYPE  FLAG DEFAULT 'X'
*"  EXPORTING
*"     VALUE(ET_USERS) TYPE  ZHR_PRT_TT001
*"----------------------------------------------------------------------
  DATA : lr_aedtm TYPE RANGE OF aedtm .
  DATA : lr_pernr TYPE RANGE OF persno .
  DATA : lr_stat2 TYPE RANGE OF stat2 .
  DATA : ls_s001  TYPE zhr_prt_ddl001.

  DATA langu LIKE sy-langu VALUE 'T'.
  SET LOCALE LANGUAGE  langu.


  IF i_pernr IS NOT INITIAL .
    APPEND VALUE #( sign    = 'I' option  = 'EQ' low     = i_pernr )  TO lr_pernr.
  ENDIF.


  CASE i_all.
    WHEN 'X'.

    WHEN OTHERS.
      IF i_active EQ 'X'.
        APPEND VALUE #( sign    = 'I' option  = 'EQ' low     = '3' )  TO lr_stat2.
        APPEND VALUE #( sign    = 'I' option  = 'EQ' low     = '2' )  TO lr_stat2.
      ENDIF.
      IF i_passive EQ 'X'.
        APPEND VALUE #( sign    = 'I' option  = 'EQ' low     = '0' )  TO lr_stat2.
        APPEND VALUE #( sign    = 'I' option  = 'EQ' low     = '1' )  TO lr_stat2.
      ENDIF.
      APPEND VALUE #( sign    = 'I' option  = 'BT' low     = i_datum high    = sy-datum )  TO lr_aedtm.
  ENDCASE.

  SELECT * FROM zhr_prt_ddl001
      WHERE pernr IN @lr_pernr
        AND begda LE @i_datum
        AND endda GE @i_datum
        AND aedtm IN @lr_aedtm[]
        AND stat2 IN @lr_stat2[]
    INTO TABLE @et_users.

  SORT et_users ASCENDING BY pernr begda endda.


  MODIFY et_users FROM ls_s001 TRANSPORTING cell WHERE activ EQ 'P'.

ENDFUNCTION.
