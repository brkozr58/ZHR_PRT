FUNCTION zhr_prt_fg001_22.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_MESAJ) TYPE  STRING OPTIONAL
*"     VALUE(I_MESAJTUR) TYPE  CHAR3 DEFAULT 'PRT'
*"  EXPORTING
*"     VALUE(E_SUBRC) TYPE  SUBRC
*"     VALUE(ET_RETURN) TYPE  ZHR_PRT_TRETURN
*"----------------------------------------------------------------------
*  DATA : lv_msj TYPE string .
*
*  lv_msj = i_mesaj.
*
**  DATA(url) = 'http://ikportaltest.icdas.com.tr:81/'.
*
**    lv_msj = | Sn: { dear }({ gt_out-pernr }); | &
**             | deneme sms metniniz buradaki gibidir. | &
**             | lütfen düzgün birşey yazınız :D  | &
**             | { url }{ lv_output-aesencrypt_result } bu da linki :) |.
*
*
*
*  REPLACE ALL OCCURRENCES OF  'İ' IN lv_msj  WITH 'I'.
*  REPLACE ALL OCCURRENCES OF  'ı' IN lv_msj  WITH 'i'.
*  REPLACE ALL OCCURRENCES OF  'Ş' IN lv_msj  WITH 'S'.
*  REPLACE ALL OCCURRENCES OF  'ş' IN lv_msj  WITH 's'.
*  REPLACE ALL OCCURRENCES OF  'Ö' IN lv_msj  WITH 'O'.
*  REPLACE ALL OCCURRENCES OF  'ö' IN lv_msj  WITH 'o'.
*  REPLACE ALL OCCURRENCES OF  'Ü' IN lv_msj  WITH 'U'.
*  REPLACE ALL OCCURRENCES OF  'ü' IN lv_msj  WITH 'u'.
*  REPLACE ALL OCCURRENCES OF  'Ğ' IN lv_msj  WITH 'G'.
*  REPLACE ALL OCCURRENCES OF  'ğ' IN lv_msj  WITH 'g'.
*  REPLACE ALL OCCURRENCES OF  'Ç' IN lv_msj  WITH 'C'.
*  REPLACE ALL OCCURRENCES OF  'ç' IN lv_msj  WITH 'c'.
*
*
*  CALL FUNCTION 'ZICD_SMS_WEB_SERVICE'
*    EXPORTING
*      mesaj    = lv_msj
*      mesajtur = 'PER'
*    TABLES
*      result   = result[].
*
*  READ TABLE result INDEX 1.
*  DATA(lv_length) = strlen( result-durum ).
*
*  IF lv_length LT 5 . "5 ten küçükse hatalıdır kontrolü
*    e_subrc = 4.
*  ELSE.
*    e_subrc = 0.
*  ENDIF.

ENDFUNCTION.
