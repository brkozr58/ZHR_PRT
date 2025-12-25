METHOD get_person_photo .
  DATA : uri TYPE toauri-uri.

  CALL FUNCTION 'HRMSS_RFC_EP_READ_PHOTO_URI'
    EXPORTING
      pernr = iv_pernr
    IMPORTING
      uri   = uri.
  ev_photo = uri.


ENDMETHOD.

METHOD get_pers_info_head .

  DATA lo_nd_all TYPE REF TO if_wd_context_node.
  DATA lo_el_all TYPE REF TO if_wd_context_element.

  DATA : lt_pers   TYPE zhr_prt_tt009,
         ls_s_pers TYPE wd_this->element_s_pers.


  DEFINE get_child_node.
    lo_nd_all = wd_context->get_child_node( &1 ).
    lo_el_all = lo_nd_all->get_element( ).
    lo_el_all->set_static_attributes( static_attributes = &2 ).
  END-OF-DEFINITION.

  DEFINE bind_table.
    lo_nd_all = wd_context->get_child_node( name = &1 ).
    lo_nd_all->bind_table( new_items = &2 set_initial_elements = abap_true ).
  END-OF-DEFINITION.

  IF iv_pernr IS NOT INITIAL .
    CALL METHOD wd_assist->get_person_values
      EXPORTING
        i_pernr = iv_pernr
      IMPORTING
        et_pers = lt_pers.
  ELSE.
    CALL METHOD wd_assist->get_person_values
      IMPORTING
        et_pers = lt_pers.
  ENDIF.

  READ TABLE lt_pers INTO DATA(ls_pers) INDEX 1 .
  READ TABLE ls_pers-pers_info INTO DATA(ls_pers_info) INDEX 1 .
  READ TABLE ls_pers-work_info INTO DATA(ls_work_info) INDEX 1 .
  MOVE-CORRESPONDING ls_pers TO ls_s_pers .

  READ TABLE ls_pers-cont_info INTO DATA(ls_cont) WITH KEY subty = 'CELL'.
  ls_s_pers-phone = ls_cont-usrid. CLEAR : ls_cont.

  READ TABLE ls_pers-cont_info INTO ls_cont WITH KEY subty = '0010'.
  ls_s_pers-mail = ls_cont-usrid.CLEAR : ls_cont.

  me->get_person_photo(
    EXPORTING
      iv_pernr = ls_pers-pernr
    IMPORTING
      ev_photo = ls_s_pers-xphoto
        ).

  get_child_node : wd_this->wdctx_s_pers     ls_s_pers ,
                   wd_this->wdctx_pers_info  ls_pers_info  .
ENDMETHOD.

METHOD set_message_list .

  DATA lo_api_controller     TYPE REF TO if_wd_controller.
  DATA lo_message_manager    TYPE REF TO if_wd_message_manager.
  DATA : ls_msg TYPE symsg.

  lo_api_controller ?= wd_this->wd_get_api( ).
  lo_message_manager = lo_api_controller->get_message_manager( ).


  LOOP AT t_return INTO DATA(ls_return).
    ls_msg-msgid  = ls_return-id.
    ls_msg-msgno  = ls_return-number.
    ls_msg-msgty  = ls_return-type.
    ls_msg-msgv1  = ls_return-message_v1.
    ls_msg-msgv2  = ls_return-message_v2.
    ls_msg-msgv3  = ls_return-message_v3.
    ls_msg-msgv4  = ls_return-message_v4.

    lo_message_manager->report_t100_message(
         msgid                     = ls_msg-msgid
         msgno                     = ls_msg-msgno
         msgty                     = ls_msg-msgty
         p1                        = ls_msg-msgv1
         p2                        = ls_msg-msgv2
         p3                        = ls_msg-msgv3
         p4                        = ls_msg-msgv4 ).
  ENDLOOP.

ENDMETHOD.

METHOD vekalet_set_button .

  DATA lo_nd_all TYPE REF TO if_wd_context_node.
  DATA lo_el_all TYPE REF TO if_wd_context_element.
  DATA ls_s_screen TYPE wd_this->element_s_screen.

  DEFINE set_static_attributes.
    lo_nd_all = wd_context->get_child_node( name = &1 ).
    lo_el_all = lo_nd_all->get_element( ).
    lo_el_all->set_static_attributes( static_attributes = &2 ).
  END-OF-DEFINITION.

  ls_s_screen-vekalet = vekalet.
  ls_s_screen-vekalet_sel = vekalet_sel.

  set_static_attributes : wd_this->wdctx_s_screen ls_s_screen.

ENDMETHOD.

method WDDOAPPLICATIONSTATECHANGE .
endmethod.

method WDDOBEFORENAVIGATION .
endmethod.

method WDDOEXIT .
endmethod.

method WDDOINIT .
endmethod.

method WDDOPOSTPROCESSING .
endmethod.

