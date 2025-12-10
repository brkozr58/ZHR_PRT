FUNCTION ZHR_PRT_FG001_19.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_PERNR) TYPE  PERSNO
*"     VALUE(I_DATUM) TYPE  DATUM DEFAULT SY-DATUM
*"  EXPORTING
*"     VALUE(T_AWART) TYPE  ZHR_PRT_TT021
*"----------------------------------------------------------------------
*Asgari 000 ise azami 999 ise bu hem saatlik hem günlük oluyor
*Asgari 000 ise azami 001 ise bu da hem saatlik hem günlüktür ama max 1 gün izin girebilir
*Asgari 001 ise azami 999 ise o izin sadece günlüktür
*MINTG
*MAXTG
  DATA : ls_data TYPE zhr_prt_s021.
  DATA langu LIKE sy-langu VALUE 'T'.
  DATA : lr_awart TYPE RANGE OF awart ,
        lt_awart TYPE TABLE OF zhr_prt_ddl005  WITH HEADER LINE .

*  DATA : BEGIN OF lt_awart OCCURS 0 ,
*           qttps(10),
*           ktart_t   TYPE t556b-ktext,
*           awart     TYPE t554t-awart,
*           awart_t   TYPE t554t-atext,
*           mintg     TYPE t554s-mintg,
*           maxtg     TYPE t554s-maxtg,
*         END OF lt_awart .

  SET LOCALE LANGUAGE  langu.


*
*  APPEND VALUE #( sign    = 'I' option  = 'EQ' low     = '0204' )  TO lr_awart.
*  APPEND VALUE #( sign    = 'I' option  = 'EQ' low     = '0213' )  TO lr_awart.
*  APPEND VALUE #( sign    = 'I' option  = 'EQ' low     = '0215' )  TO lr_awart.
*  APPEND VALUE #( sign    = 'I' option  = 'EQ' low     = '0217' )  TO lr_awart.
*  APPEND VALUE #( sign    = 'I' option  = 'EQ' low     = '0241' )  TO lr_awart.
*  APPEND VALUE #( sign    = 'I' option  = 'EQ' low     = '0424' )  TO lr_awart.


  PERFORM get_awart_qouta_type TABLES lt_awart
                                USING i_pernr.

  SORT lt_awart ASCENDING BY awart.
  DELETE lt_awart WHERE awart EQ space .
  DELETE ADJACENT DUPLICATES FROM lt_awart.
  DELETE lt_awart WHERE NOT awart IN lr_awart .

*  LOOP AT lt_awart INTO DATA(ls_awart).
*    MOVE-CORRESPONDING ls_awart TO ls_data .
*    IF ( ls_awart-mintg EQ '000' AND ls_awart-maxtg EQ '999' ) OR
*       ( ls_awart-mintg EQ '000' AND ls_awart-maxtg EQ '001' ) .
*      ls_data-hours = 'X'.
*    ENDIF.
*    COLLECT ls_data INTO t_awart.
*  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM t_awart.
ENDFUNCTION.
