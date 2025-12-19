METHOD get_my_leave_list .
  DATA lo_nd_all TYPE REF TO if_wd_context_node.

  DATA : lt_t_leave TYPE wd_this->elements_t_leave,
         lt_t_qouta TYPE wd_this->elements_t_qouta,
         et_list    TYPE  zhr_prt_tt017,
         et_return  TYPE  zhr_prt_treturn.



  DEFINE     bind_table.
    lo_nd_all = wd_context->get_child_node( name = &1 ).
    lo_nd_all->bind_table( new_items = &2 set_initial_elements = abap_true ).
  END-OF-DEFINITION.

  CALL FUNCTION 'ZHR_PRT_FG001_06'
    EXPORTING
      i_srcid   = '00001'
      i_pernr   = iv_pernr
      i_begda   = '19000101'
      i_endda   = '99991231'
    IMPORTING
      et_list   = et_list
      et_return = et_return.


  CALL FUNCTION 'ZHR_PRT_FG001_05'
    EXPORTING
      i_srcid  = '00001'
      i_pernr  = iv_pernr
      i_datum  = sy-datum
    IMPORTING
      et_qouta = lt_t_qouta.

  lt_t_leave[] = et_list[].
  bind_table : wd_this->wdctx_t_leave lt_t_leave,
               wd_this->wdctx_t_qouta lt_t_qouta.


ENDMETHOD.

METHOD handlein_myleave_list .

  wd_comp_controller->get_pers_info_head( iv_pernr = iv_pernr ).

ENDMETHOD.

METHOD onactionback .

  DATA lo_nd_all TYPE REF TO if_wd_context_node.
  DATA lo_el_all TYPE REF TO if_wd_context_element.

  DATA : ls_s_pers TYPE wd_this->element_s_pers .


  DEFINE get_static_attributes.
    lo_nd_all = wd_context->get_child_node( name = &1 ).
    lo_el_all = lo_nd_all->get_element( ).
    lo_el_all->get_static_attributes( IMPORTING static_attributes = &2 ).
  END-OF-DEFINITION.

  DEFINE set_static_attributes.
    lo_nd_all = wd_context->get_child_node( name = &1 ).
    lo_el_all = lo_nd_all->get_element( ).
    lo_el_all->set_static_attributes( static_attributes = &2 ).
  END-OF-DEFINITION.

  DEFINE get_child_node.
    lo_nd_all = wd_context->get_child_node( &1 ).
    lo_el_all = lo_nd_all->get_element( ).
    lo_el_all->set_static_attributes( static_attributes = &2 ).
  END-OF-DEFINITION.

  DEFINE bind_table.
    lo_nd_all = wd_context->get_child_node( name = &1 ).
    lo_nd_all->bind_table( new_items = &2 set_initial_elements = abap_true ).
  END-OF-DEFINITION.

  get_static_attributes : wd_this->wdctx_s_pers ls_s_pers.

  wd_this->fire_out_myleave_list_plg( iv_pernr =  ls_s_pers-pernr ).

ENDMETHOD.

METHOD onactioncreate_leave .


  DATA lo_nd_all TYPE REF TO if_wd_context_node.
  DATA lo_el_all TYPE REF TO if_wd_context_element.


  DATA : lo_window_manager TYPE REF TO if_wd_window_manager ,
         lo_api_component  TYPE REF TO if_wd_component ,
         lo_window         TYPE REF TO if_wd_window ,
         lt_buttons        TYPE wdr_popup_button_list ,
         ls_canc_action    TYPE wdr_popup_button_action ,
         ls_s_pers         TYPE wd_this->element_s_pers .


  DEFINE get_static_attributes.
    lo_nd_all = wd_context->get_child_node( name = &1 ).
    lo_el_all = lo_nd_all->get_element( ).
    lo_el_all->get_static_attributes( IMPORTING static_attributes = &2 ).
  END-OF-DEFINITION.

  DEFINE set_static_attributes.
    lo_nd_all = wd_context->get_child_node( name = &1 ).
    lo_el_all = lo_nd_all->get_element( ).
    lo_el_all->set_static_attributes( static_attributes = &2 ).
  END-OF-DEFINITION.


  get_static_attributes : wd_this->wdctx_s_pers ls_s_pers.

*  wd_this->fire_out_create_plg( iv_pernr =  ls_s_pers-pernr ).


  lo_api_component           = wd_comp_controller->wd_get_api( ).
  lo_window_manager          = lo_api_component->get_window_manager( ).
  ls_canc_action-action_name = '*'.
  lt_buttons                 = lo_window_manager->get_buttons_close( default_button = if_wd_window=>co_button_close ).

  lo_window                  = lo_window_manager->create_and_open_popup(
      window_name          = 'W_CREATE_LEAVE'
      title                = 'İzin Talebi'
      message_type         = if_wd_window=>co_msg_type_none
      message_display_mode = if_wd_window=>co_msg_display_mode_selected
      is_resizable         = abap_true
      buttons              = lt_buttons
      cancel_action        = ls_canc_action
  ).



ENDMETHOD.

method WDDOAFTERACTION .
endmethod.

method WDDOBEFOREACTION .
*  data lo_api_controller type ref to if_wd_view_controller.
*  data lo_action         type ref to if_wd_action.

*  lo_api_controller = wd_this->wd_get_api( ).
*  lo_action = lo_api_controller->get_current_action( ).

*  if lo_action is bound.
*    case lo_action->name.
*      when '...'.

*    endcase.
*  endif.
endmethod.

method WDDOEXIT .
endmethod.

METHOD wddoinit .
  DATA lo_nd_all TYPE REF TO if_wd_context_node.
  DATA lo_el_all TYPE REF TO if_wd_context_element.


  DATA ls_s_pers TYPE wd_this->element_s_pers.


  DEFINE get_static_attributes.
    lo_nd_all = wd_context->get_child_node( name = &1 ).
    lo_el_all = lo_nd_all->get_element( ).
    lo_el_all->get_static_attributes( IMPORTING static_attributes = &2 ).
  END-OF-DEFINITION.


  get_static_attributes : wd_this->wdctx_s_pers ls_s_pers.

  get_my_leave_list( iv_pernr = ls_s_pers-pernr ).


ENDMETHOD.

METHOD wddomodifyview .

  DATA lo_nd_all TYPE REF TO if_wd_context_node.
  DATA lo_el_all TYPE REF TO if_wd_context_element.


  DATA ls_s_pers TYPE wd_this->element_s_pers.


  DEFINE get_static_attributes.
    lo_nd_all = wd_context->get_child_node( name = &1 ).
    lo_el_all = lo_nd_all->get_element( ).
    lo_el_all->get_static_attributes( IMPORTING static_attributes = &2 ).
  END-OF-DEFINITION.


  get_static_attributes : wd_this->wdctx_s_pers ls_s_pers.

  get_my_leave_list( iv_pernr = ls_s_pers-pernr ).


ENDMETHOD.

method WDDOONCONTEXTMENU .
endmethod.

