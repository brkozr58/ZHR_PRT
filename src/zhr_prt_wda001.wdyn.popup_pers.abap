method HANDLEIN_POPUP_PERS .
endmethod.

METHOD onactiononenter .

  DATA lo_nd_all TYPE REF TO if_wd_context_node.
  DATA lo_el_all TYPE REF TO if_wd_context_element.

  DATA : ls_s_pers  TYPE wd_this->element_s_pers,
         et_pers    TYPE zhr_prt_tt009,
         et_persons TYPE zhr_prt_tt020,
         lv_pernr   TYPE persno.


  DEFINE get_static_attributes.
    lo_nd_all = wd_context->get_child_node( name = &1 ).
    lo_el_all = lo_nd_all->get_element( ).
    lo_el_all->get_static_attributes( IMPORTING static_attributes = &2 ).
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


  get_static_attributes : wd_this->wdctx_s_pers  ls_s_pers.

  CALL FUNCTION 'ZHR_PRT_FG001_18'
    EXPORTING
*     i_pernr    =
      i_ename    = ls_s_pers-ename
      i_datum    = sy-datum
      i_maxc     = 200
    IMPORTING
      et_persons = et_persons.

  READ TABLE et_persons INTO DATA(ls_persons) INDEX 1 .

  REFRESH :et_persons.
  CALL METHOD wd_assist->get_person_values
    EXPORTING
      i_pernr = ls_persons-pernr
    IMPORTING
      et_pers = et_pers.

  READ TABLE et_pers INTO DATA(ls_pers) INDEX 1 .
  MOVE-CORRESPONDING ls_pers TO ls_s_pers .

  wd_comp_controller->get_person_photo(
    EXPORTING
      iv_pernr = ls_pers-pernr
    IMPORTING
      ev_photo = ls_s_pers-xphoto
        ).

  get_child_node : wd_this->wdctx_s_pers     ls_s_pers   .

ENDMETHOD.

METHOD onactiononselect .

  DATA lo_nd_all TYPE REF TO if_wd_context_node.
  DATA lo_el_all TYPE REF TO if_wd_context_element.

  DATA : lt_pers     TYPE zhr_prt_tt009,
         lt_t_list   TYPE wd_this->elements_t_list,
         ls_s_pers   TYPE wd_this->element_s_pers,
         ls_s_search TYPE wd_this->element_s_search,
         ls_s_screen TYPE wd_this->element_s_screen.

  DEFINE get_static_attributes.
    lo_nd_all = wd_context->get_child_node( name = &1 ).
    lo_el_all = lo_nd_all->get_element( ).
    lo_el_all->get_static_attributes( IMPORTING static_attributes = &2 ).
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

  DEFINE set_static_attributes.
    lo_nd_all = wd_context->get_child_node( name = &1 ).
    lo_el_all = lo_nd_all->get_element( ).
    lo_el_all->set_static_attributes( static_attributes = &2 ).
  END-OF-DEFINITION.


  get_static_attributes : wd_this->wdctx_s_search ls_s_search.


  IF ls_s_search-pernr IS NOT INITIAL .
    CALL METHOD wd_assist->get_person_values
      EXPORTING
        i_pernr = ls_s_search-pernr
      IMPORTING
        et_pers = lt_pers.
  ELSE.
    CALL METHOD wd_assist->get_person_values
      EXPORTING
        i_pernr = wd_assist->s_pers-pernr
      IMPORTING
        et_pers = lt_pers.
  ENDIF.


  READ TABLE lt_pers INTO DATA(ls_pers) INDEX 1 .
  MOVE-CORRESPONDING ls_pers TO ls_s_pers .

  READ TABLE ls_pers-cont_info INTO DATA(ls_cont) WITH KEY subty = 'CELL'.
  ls_s_pers-phone = ls_cont-usrid. CLEAR : ls_cont.

  READ TABLE ls_pers-cont_info INTO ls_cont WITH KEY subty = '0010'.
  ls_s_pers-mail = ls_cont-usrid.CLEAR : ls_cont.

  wd_comp_controller->get_person_photo(
    EXPORTING
      iv_pernr = ls_pers-pernr
    IMPORTING
      ev_photo = ls_s_pers-xphoto
        ).

  get_child_node : wd_this->wdctx_s_pers     ls_s_pers .

  ls_s_screen-vekalet_sel = abap_true.
  set_static_attributes : wd_this->wdctx_s_screen     ls_s_screen .

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

  DATA : et_persons TYPE zhr_prt_tt020 .


  DEFINE get_static_attributes.
    lo_nd_all = wd_context->get_child_node( name = &1 ).
    lo_el_all = lo_nd_all->get_element( ).
    lo_el_all->get_static_attributes( IMPORTING static_attributes = &2 ).
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


  CALL FUNCTION 'ZHR_PRT_FG001_18'
    EXPORTING
*     i_pernr    =
*     i_ename    = ls_s_pers-ename
      i_datum    = sy-datum
      i_maxc     = 100000
    IMPORTING
      et_persons = et_persons.

  bind_table : wd_this->wdctx_t_list et_persons.


ENDMETHOD.

method WDDOMODIFYVIEW .
endmethod.

method WDDOONCONTEXTMENU .
endmethod.

