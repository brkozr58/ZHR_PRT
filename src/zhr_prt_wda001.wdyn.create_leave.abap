METHOD handlein_create .
*  DATA lo_nd_all TYPE REF TO if_wd_context_node.
*
*  DATA lt_t_awart TYPE wd_this->elements_t_awart.
*
*  CALL FUNCTION 'ZHR_PRT_FG001_19'
*    EXPORTING
*      i_pernr = iv_pernr
*      i_datum = sy-datum
*    IMPORTING
*      t_awart = lt_t_awart.
*
*
*  wd_comp_controller->get_pers_info_head( iv_pernr = iv_pernr ).
*
*
*  lo_nd_all = wd_context->get_child_node( name = wd_this->wdctx_t_awart ).
*  lo_nd_all->bind_table( new_items = lt_t_awart set_initial_elements = abap_true ).


ENDMETHOD.

METHOD onactionsave .

  DATA lo_nd_all TYPE REF TO if_wd_context_node.
  DATA lo_el_all TYPE REF TO if_wd_context_element.
  DATA : lv_tlpid    TYPE zhr_prt_tlpid,
         et_return   TYPE  zhr_prt_treturn,
         ls_s_leave  TYPE wd_this->element_s_leave,
         ls_s_pers   TYPE wd_this->element_s_pers.

  DEFINE get_static_attributes_table.
    lo_nd_all = wd_context->get_child_node( name = &1 ).
    lo_nd_all->get_static_attributes_table( IMPORTING table = &2 ).
  END-OF-DEFINITION.

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

  DEFINE bind_table.
    lo_nd_all = wd_context->get_child_node( name = &1 ).
    lo_nd_all->bind_table( new_items = &2 set_initial_elements = abap_true ).
  END-OF-DEFINITION.

  get_static_attributes : wd_this->wdctx_s_pers ls_s_pers.
  get_static_attributes : wd_this->wdctx_s_leave ls_s_leave.


  CALL FUNCTION 'ZHR_PRT_FG001_08'
    EXPORTING
      i_srcid   = '00001'
      is_leave  = ls_s_leave
      cr_pernr  = ls_s_pers-pernr
    IMPORTING
      ev_tlpid  = lv_tlpid
      et_return = et_return.

  wd_comp_controller->set_message_list( t_return = et_return ).


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

  DATA : ls_s_pers  TYPE wd_this->element_s_pers,
         ls_s_leave TYPE wd_this->element_s_leave,
         lt_t_awart TYPE wd_this->elements_t_awart.

  DEFINE set_static_attributes.
    lo_nd_all = wd_context->get_child_node( name = &1 ).
    lo_el_all = lo_nd_all->get_element( ).
    lo_el_all->set_static_attributes( static_attributes = &2 ).
  END-OF-DEFINITION.

  DEFINE get_static_attributes.
    lo_nd_all = wd_context->get_child_node( name = &1 ).
    lo_el_all = lo_nd_all->get_element( ).
    lo_el_all->get_static_attributes(  IMPORTING static_attributes = &2 ).
  END-OF-DEFINITION.

  DEFINE bind_table.
    lo_nd_all = wd_context->get_child_node( name = &1 ).
    lo_nd_all->bind_table( new_items = &2 set_initial_elements = abap_true ).
  END-OF-DEFINITION.
  get_static_attributes : wd_this->wdctx_s_pers ls_s_pers.

  wd_comp_controller->get_pers_info_head( iv_pernr = ls_s_pers-pernr ).



  CALL FUNCTION 'ZHR_PRT_FG001_19'
    EXPORTING
      i_pernr = ls_s_pers-pernr
      i_datum = sy-datum
    IMPORTING
      t_awart = lt_t_awart.

  ls_s_leave-pernr = ls_s_pers-pernr.


  wd_comp_controller->get_pers_info_head( iv_pernr = ls_s_pers-pernr ).
  bind_table : wd_this->wdctx_t_awart lt_t_awart.

  set_static_attributes : wd_this->wdctx_s_leave ls_s_leave.
ENDMETHOD.

method WDDOMODIFYVIEW .
endmethod.

method WDDOONCONTEXTMENU .
endmethod.

