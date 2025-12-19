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
         lt_t_awart TYPE wd_this->elements_t_awart.

  DEFINE get_static_attributes.
    lo_nd_all = wd_context->get_child_node( name = &1 ).
    lo_el_all = lo_nd_all->get_element( ).
    lo_el_all->get_static_attributes(  IMPORTING static_attributes = &2 ).
  END-OF-DEFINITION.

  get_static_attributes : wd_this->wdctx_s_pers ls_s_pers.

  wd_comp_controller->get_pers_info_head( iv_pernr = ls_s_pers-pernr ).



  CALL FUNCTION 'ZHR_PRT_FG001_19'
    EXPORTING
      i_pernr = ls_s_pers-pernr
      i_datum = sy-datum
    IMPORTING
      t_awart = lt_t_awart.


  wd_comp_controller->get_pers_info_head( iv_pernr = ls_s_pers-pernr ).


  lo_nd_all = wd_context->get_child_node( name = wd_this->wdctx_t_awart ).
  lo_nd_all->bind_table( new_items = lt_t_awart set_initial_elements = abap_true ).


ENDMETHOD.

method WDDOMODIFYVIEW .
endmethod.

method WDDOONCONTEXTMENU .
endmethod.

