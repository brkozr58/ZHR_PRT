FUNCTION zhr_prt_fg001_15.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IV_SENDER) TYPE  AD_SMTPADR OPTIONAL
*"     VALUE(IV_TDNAME) TYPE  TDOBNAME
*"     VALUE(IT_EMAIL) TYPE  ZHR_PRT_TT023
*"     VALUE(T_PARAM) TYPE  ZHR_PRT_TT019
*"  EXPORTING
*"     VALUE(ET_RETURN) TYPE  ZHR_PRT_TRETURN
*"----------------------------------------------------------------------

  DATA : cx_req_bcs TYPE REF TO cx_send_req_bcs,
         cx_add_bcs TYPE REF TO cx_address_bcs,
         cx_doc_bcs TYPE REF TO cx_document_bcs,
         lv_text    TYPE string.

  DATA : document     TYPE REF TO cl_document_bcs,
         sent_to_all  TYPE os_boolean,
         send_request TYPE REF TO cl_bcs,
         sender       TYPE REF TO if_sender_bcs,
         recipient    TYPE REF TO if_recipient_bcs,
         att_type     TYPE soodk-objtp VALUE 'HTM',
         l_receiver   TYPE comm_id_long,
         lv_subject   TYPE  string,
         l_cc         TYPE os_boolean,
         l_bcc        TYPE os_boolean,
         ls_return    TYPE bapireturn1,
         result       TYPE os_boolean,
         lt_lines     TYPE tlinetab,
         lv_dg(5)              ,
         lt_text      TYPE  bcsy_text.

  DATA langu LIKE sy-langu VALUE 'T'.
  SET LOCALE LANGUAGE  langu.

*&1& Talep numarası
*&2& Talep ismi
*&3& statü tanımı
*&4& Personel Adı soyadı veya
*&5& Onaycı Adı soyadı
*&6& Talep tarihi
*&7& izin gün
*&8& Link
*&9& Açıklama
  PERFORM read_text TABLES lt_lines et_return USING iv_tdname .
  CHECK lt_lines IS NOT INITIAL .

  LOOP AT lt_lines ASSIGNING FIELD-SYMBOL(<fs>).
    LOOP AT t_param INTO DATA(s_param).
      lv_dg = '&' && CONV char2( sy-tabix ) && '&' .
      REPLACE ALL OCCURRENCES OF lv_dg IN <fs>-tdline WITH s_param-param.
    ENDLOOP.
    APPEND CONV so_text255( <fs>-tdline ) TO lt_text.
  ENDLOOP.


  TRY.
      CALL METHOD cl_bcs=>create_persistent
        RECEIVING
          result = send_request.

      CALL METHOD send_request->encrypt
        RECEIVING
          result = result.

      lv_subject = lt_lines[ 1 ]-tdline.

      CALL METHOD send_request->set_message_subject
        EXPORTING
          ip_subject = CONV string( lv_subject ).

      CALL METHOD cl_document_bcs=>create_document
        EXPORTING
          i_type    = att_type
          i_subject = CONV so_obj_des( lv_subject )
          i_text    = lt_text
        RECEIVING
          result    = document.

      CALL METHOD send_request->set_document
        EXPORTING
          i_document = document.

      CALL METHOD cl_cam_address_bcs=>create_internet_address
        EXPORTING
          i_address_string = CONV #( iv_sender )
        RECEIVING
          result           = sender.
*
*      SELECT SINGLE usrid_long FROM pa0105 INTO l_receiver
*          WHERE pernr EQ iv_pernr
*            AND subty EQ 'MAIL'
*            AND begda LE sy-datum
*            AND endda GE sy-datum.
      LOOP AT it_email INTO DATA(ls_email).
        l_cc = l_bcc = ''.

        IF     ls_email-cc EQ 'X'.
          l_cc  = 'X'.
        ELSEIF ls_email-bc EQ 'X'.
          l_bcc = 'X'.
        ENDIF.
        l_receiver = ls_email-email.
        CALL METHOD cl_cam_address_bcs=>create_internet_address
          EXPORTING
            i_address_string = l_receiver
          RECEIVING
            result           = recipient.

        CALL METHOD send_request->add_recipient
          EXPORTING
            i_recipient  = recipient
            i_express    = 'X'
            i_copy       = l_cc
            i_blind_copy = l_bcc
            i_no_forward = 'X'.
      ENDLOOP.

      CALL METHOD send_request->set_send_immediately
        EXPORTING
          i_send_immediately = 'X'.

      CALL METHOD send_request->set_status_attributes
        EXPORTING
          i_requested_status = 'N'.

      CALL METHOD send_request->send
        EXPORTING
          i_with_error_screen = 'X'
        RECEIVING
          result              = sent_to_all.

    CATCH cx_address_bcs INTO cx_add_bcs.
      lv_text = cx_add_bcs->get_text( ).
      ls_return-message = lv_text.
      ls_return-message_v1 = lv_text.
      PERFORM add_message TABLES et_return
                           USING space
                                 space
                                 'ZHR_PRT'
                                 'E'
                                 '000'
                                 ls_return .
  ENDTRY.


ENDFUNCTION.
