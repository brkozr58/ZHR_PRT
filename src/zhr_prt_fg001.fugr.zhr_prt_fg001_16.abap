FUNCTION zhr_prt_fg001_16.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_PERNR) TYPE  PERSNO
*"     VALUE(I_VERSI) TYPE  ZHR_PRT_VERSI
*"     VALUE(I_APPFL) TYPE  FLAG DEFAULT 'X'
*"  EXPORTING
*"     VALUE(ET_RETURN) TYPE  ZHR_PRT_TRETURN
*"----------------------------------------------------------------------
  DATA :
    ls_return TYPE bapireturn1,
    es_return TYPE zhr_prt_sreturn,
    ls_kvkk   TYPE zhr_prt_tkvkk.

  DATA langu LIKE sy-langu VALUE 'T'.
  SET LOCALE LANGUAGE  langu.


  GET TIME STAMP FIELD ls_kvkk-time.

  IF i_pernr IS INITIAL .
    CLEAR ls_return.
    PERFORM add_message TABLES et_return
                         USING ''
                               ''
                               'ZHR_PRT'
                               'E'
                               '006'
                               ls_return .
    EXIT.
  ENDIF.

  IF i_versi IS INITIAL .
    CLEAR ls_return.
    PERFORM add_message TABLES et_return
                         USING ''
                               ''
                               'ZHR_PRT'
                               'E'
                               '029'
                               ls_return .
    EXIT.
  ENDIF.

  IF i_versi IS NOT INITIAL .

    es_return-srcid   = ''.
    es_return-pernr   = i_pernr.
    ls_kvkk-pernr     = i_pernr.
    ls_kvkk-versi     = i_versi.
    ls_kvkk-appfl     = i_appfl.

    MODIFY zhr_prt_tkvkk FROM ls_kvkk.
    PERFORM add_message TABLES et_return
                         USING ''
                               i_pernr
                               'ZHR_PRT'
                               'S'
                               '030'
                               ls_return .
  ELSE.
    PERFORM add_message TABLES et_return
                         USING ''
                               i_pernr
                               'ZHR_PRT'
                               'E'
                               '002'
                               ls_return .
  ENDIF.

ENDFUNCTION.
