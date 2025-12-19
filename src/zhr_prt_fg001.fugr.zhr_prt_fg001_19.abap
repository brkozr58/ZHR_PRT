FUNCTION zhr_prt_fg001_19.
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
  DATA : lr_awart TYPE RANGE OF awart,
         lt_awart TYPE TABLE OF zhr_prt_ddl005  WITH HEADER LINE.


  SET LOCALE LANGUAGE  langu.


  PERFORM get_awart_qouta_type TABLES lt_awart
                                USING i_pernr.

  SORT lt_awart ASCENDING BY awart.
  DELETE lt_awart WHERE awart EQ space .
  DELETE ADJACENT DUPLICATES FROM lt_awart.
  DELETE lt_awart WHERE NOT awart IN lr_awart .

  LOOP AT lt_awart .
    MOVE-CORRESPONDING lt_awart TO ls_data .
    ls_data-hours = lt_awart-zhour.
    COLLECT ls_data INTO t_awart.CLEAR ls_data .
  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM t_awart.
ENDFUNCTION.
