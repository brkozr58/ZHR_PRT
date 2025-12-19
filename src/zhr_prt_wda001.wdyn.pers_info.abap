METHOD handlein_pers .

  wd_this->iv_pernr = iv_pernr.
  wd_comp_controller->get_pers_info_head( iv_pernr = wd_this->iv_pernr ).

ENDMETHOD.

METHOD init_values .
  DATA lo_nd_all TYPE REF TO if_wd_context_node.
  DATA lo_el_all TYPE REF TO if_wd_context_element.

  DATA : lt_pers      TYPE zhr_prt_tt009,
         et_persons   TYPE zhr_prt_tt022,
         ls_s_pers    TYPE wd_this->element_s_pers,
         ls_s_screen  TYPE wd_this->element_s_screen,
         ls_pers_info TYPE wd_this->element_pers_info,
         ls_work_info TYPE wd_this->element_work_info,
         lt_cont_info TYPE wd_this->elements_cont_info,
         lt_educ_info TYPE wd_this->elements_educ_info,
         lt_date_info TYPE wd_this->elements_date_info,
         lt_adrs_info TYPE wd_this->elements_adrs_info,
         lt_faml_info TYPE wd_this->elements_faml_info.


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

  get_static_attributes : wd_this->wdctx_s_screen ls_s_screen.

  IF pernr IS NOT INITIAL .
    CALL METHOD wd_assist->get_person_values
      EXPORTING
        i_pernr = pernr
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
  READ TABLE ls_pers-pers_info INTO ls_pers_info INDEX 1 .
  READ TABLE ls_pers-work_info INTO ls_work_info INDEX 1 .
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

  lt_cont_info[] = ls_pers-cont_info[].
  lt_educ_info[] = ls_pers-educ_info[].
  lt_date_info[] = ls_pers-date_info[].
  lt_adrs_info[] = ls_pers-adrs_info[].
  lt_faml_info[] = ls_pers-faml_info[].

  get_child_node : wd_this->wdctx_s_pers     ls_s_pers ,
                   wd_this->wdctx_pers_info  ls_pers_info,
                   wd_this->wdctx_work_info  ls_work_info .

  bind_table : wd_this->wdctx_cont_info lt_cont_info[],
               wd_this->wdctx_educ_info lt_educ_info[],
               wd_this->wdctx_date_info lt_date_info[],
               wd_this->wdctx_faml_info lt_faml_info[],
               wd_this->wdctx_adrs_info lt_adrs_info[].

  CALL FUNCTION 'ZHR_PRT_FG001_20'
    EXPORTING
      i_pernr    = wd_assist->s_pers-pernr
    IMPORTING
      et_persons = et_persons.

  READ TABLE et_persons INTO DATA(ls_persons) INDEX 1 .
  IF sy-subrc EQ 0 AND ls_persons-aptyp IS NOT INITIAL .
    ls_s_screen-vekalet = abap_true.
  ELSE.
    ls_s_screen-vekalet = abap_false.
  ENDIF.

  wd_comp_controller->vekalet_set_button(  vekalet     = ls_s_screen-vekalet
                                           vekalet_sel = ls_s_screen-vekalet_sel ).

ENDMETHOD.

METHOD onactioncreate_leave .

  DATA lo_nd_all TYPE REF TO if_wd_context_node.
  DATA lo_el_all TYPE REF TO if_wd_context_element.
  DATA ls_s_pers TYPE wd_this->element_s_pers.

  lo_nd_all = wd_context->get_child_node( name = wd_this->wdctx_s_pers ).
  lo_el_all = lo_nd_all->get_element( ).
  lo_el_all->get_static_attributes( IMPORTING static_attributes = ls_s_pers ).


  wd_this->fire_out_pers_plg( iv_pernr = ls_s_pers-pernr ).

ENDMETHOD.

METHOD onactionleave_list .
  DATA lo_nd_all TYPE REF TO if_wd_context_node.
  DATA lo_el_all TYPE REF TO if_wd_context_element.
  DATA ls_s_pers TYPE wd_this->element_s_pers.

  DEFINE get_static_attributes.
    lo_nd_all = wd_context->get_child_node( name = &1 ).
    lo_el_all = lo_nd_all->get_element( ).
    lo_el_all->get_static_attributes( IMPORTING static_attributes = &2 ).
  END-OF-DEFINITION.

  get_static_attributes : wd_this->wdctx_s_pers ls_s_pers.

  wd_this->fire_out_myleave_list_plg( iv_pernr = ls_s_pers-pernr ).
ENDMETHOD.

METHOD onactionvekalet .

  DATA lo_window_manager TYPE REF TO if_wd_window_manager.
  DATA lo_api_component  TYPE REF TO if_wd_component.
  DATA lo_window         TYPE REF TO if_wd_window.
  DATA lt_buttons        TYPE wdr_popup_button_list.
  DATA ls_canc_action    TYPE wdr_popup_button_action.

  lo_api_component           = wd_comp_controller->wd_get_api( ).
  lo_window_manager          = lo_api_component->get_window_manager( ).
  ls_canc_action-action_name = '*'.
  lt_buttons                 = lo_window_manager->get_buttons_ok(
    default_button       = if_wd_window=>co_button_ok
   ).

  lo_window                  = lo_window_manager->create_and_open_popup(
      window_name          = 'W_POPUP_PERS'

      title                = 'Personel Arama'
      message_type         = if_wd_window=>co_msg_type_none
      message_display_mode = if_wd_window=>co_msg_display_mode_selected
*    is_resizable         = ABAP_TRUE
      buttons              = lt_buttons
      cancel_action        = ls_canc_action
  ).

ENDMETHOD.

METHOD onactionvekalet_ext .
  init_values( pernr = wd_assist->s_pers-pernr ).
  wd_comp_controller->vekalet_set_button( vekalet = abap_true vekalet_sel = abap_false ).
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

  init_values( pernr = wd_this->iv_pernr ).


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

  init_values( pernr = ls_s_pers-pernr ).


ENDMETHOD.

method WDDOONCONTEXTMENU .
endmethod.

