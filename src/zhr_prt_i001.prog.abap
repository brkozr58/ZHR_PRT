*&---------------------------------------------------------------------*
*& Include          ZHR_PRT_I001
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
*       CLASS lcl_alv DEFINITION
*----------------------------------------------------------------------*
CLASS lcl_alv DEFINITION   .

  PUBLIC SECTION.

    DATA : mo_splitter TYPE REF TO cl_gui_splitter_container,
           mo_cont     TYPE REF TO cl_gui_custom_container,
           mo_top_cont TYPE REF TO cl_gui_container,
           mo_alv_cont TYPE REF TO cl_gui_container.


    DATA : mo_grid     TYPE REF TO cl_gui_alv_grid,
           mo_document TYPE REF TO cl_dd_document,
           mo_top_page TYPE REF TO cl_gui_container,
           mo_prot     TYPE REF TO cl_alv_changed_data_protocol,
           mt_fcat     TYPE lvc_t_fcat,
           mt_exclude  TYPE ui_functions,
           ms_layout   TYPE lvc_s_layo,
           mo_popup    TYPE REF TO cl_salv_table.

    METHODS :
      constructor  IMPORTING strname TYPE  strname,
      set_layout       ,
      create_fcat      ,
      modify_fcat      ,
      modify_target_value
        IMPORTING
          fname  TYPE lvc_fname
          targt  TYPE name_komp
          zvalue TYPE any ,
      set_events       ,
      exclude_buttons  ,
      set_top_of_page
        CHANGING mo_splitter TYPE REF TO cl_gui_splitter_container,
      display_alv_grid
        CHANGING
          it_main TYPE table .

    METHODS :
      refresh_alv,

      split_container
        IMPORTING scrfname TYPE scrfname
                  screen   TYPE sydynnr,
      handle_user_command
        FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm ,

      handle_hotspot_click
        FOR EVENT hotspot_click OF cl_gui_alv_grid
        IMPORTING e_row_id
                  e_column_id
                  es_row_no,

      handle_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object
                  e_interactive,

      handle_data_changed
        FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed
                  e_onf4
                  e_onf4_before
                  e_onf4_after .

  PROTECTED SECTION.
    DATA : gc_strname TYPE strname   .


  PRIVATE SECTION.
ENDCLASS.                    "lcl_alv DEFINITION
*----------------------------------------------------------------------*
*       CLASS lcl_alv IMPLEMENTATION
*----------------------------------------------------------------------*
CLASS lcl_alv IMPLEMENTATION.

  METHOD constructor.
    gc_strname = strname.
  ENDMETHOD.

  METHOD set_layout.
    ms_layout-box_fname = 'MARK'.
    ms_layout-col_opt = 'X'.
    ms_layout-sel_mode = 'A'.
    ms_layout-zebra = abap_true.
  ENDMETHOD.

  METHOD create_fcat.
    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = gc_strname
        i_client_never_display = abap_true
        i_bypassing_buffer     = abap_true
      CHANGING
        ct_fieldcat            = mt_fcat
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.
    IF sy-subrc = 0.
      me->modify_fcat( ).
    ENDIF.
  ENDMETHOD.

  METHOD modify_fcat.
    PERFORM modify_fcat .

  ENDMETHOD.

  METHOD modify_target_value.
    READ TABLE mt_fcat ASSIGNING FIELD-SYMBOL(<ls_fcat>)
        WITH KEY fieldname  = fname.
    IF sy-subrc EQ 0 .
      CASE targt .
        WHEN 'TEXT'.
          modify_target_value( fname  = fname targt = 'SCRTEXT_L' zvalue = zvalue ).
          modify_target_value( fname  = fname targt = 'SCRTEXT_M' zvalue = zvalue ).
          modify_target_value( fname  = fname targt = 'SCRTEXT_S' zvalue = zvalue ).
          modify_target_value( fname  = fname targt = 'REPTEXT'   zvalue = zvalue ).
        WHEN OTHERS.
          ASSIGN COMPONENT targt OF STRUCTURE <ls_fcat>
              TO FIELD-SYMBOL(<fs>).
          CHECK <fs> IS ASSIGNED .
          <fs> = zvalue.
      ENDCASE.
      IF targt NE 'COL_OPT'.
        modify_target_value(  fname  = fname targt = 'COL_OPT' zvalue = 'X' ).
      ENDIF.
    ENDIF.

  ENDMETHOD.


  METHOD set_events.
    mo_grid->register_edit_event( cl_gui_alv_grid=>mc_evt_enter ).
    mo_grid->register_edit_event( cl_gui_alv_grid=>mc_evt_modified ).

    IF mo_document IS BOUND.
      mo_grid->list_processing_events( i_event_name = 'TOP_OF_PAGE'
                                       i_dyndoc_id  = mo_document ).
    ENDIF.

    SET HANDLER me->handle_user_command  FOR mo_grid.
    SET HANDLER me->handle_toolbar       FOR mo_grid.
    SET HANDLER me->handle_hotspot_click FOR mo_grid.
    SET HANDLER me->handle_data_changed  FOR mo_grid.

  ENDMETHOD.

  METHOD exclude_buttons.
    APPEND :
      cl_gui_alv_grid=>mc_fc_graph             TO mt_exclude ,
      cl_gui_alv_grid=>mc_fc_info              TO mt_exclude ,
      cl_gui_alv_grid=>mc_fc_print_back        TO mt_exclude ,
      cl_gui_alv_grid=>mc_fc_loc_copy_row      TO mt_exclude ,
      cl_gui_alv_grid=>mc_fc_loc_copy          TO mt_exclude ,
      cl_gui_alv_grid=>mc_fc_loc_insert_row    TO mt_exclude ,
      cl_gui_alv_grid=>mc_fc_loc_append_row    TO mt_exclude ,
      cl_gui_alv_grid=>mc_fc_loc_delete_row    TO mt_exclude ,
      cl_gui_alv_grid=>mc_fc_loc_cut           TO mt_exclude ,
      cl_gui_alv_grid=>mc_fc_loc_paste         TO mt_exclude ,
      cl_gui_alv_grid=>mc_fc_loc_paste_new_row TO mt_exclude .
  ENDMETHOD.


  METHOD display_alv_grid.
    DATA : ls_var TYPE disvariant .
    ls_var-report = sy-repid.

    mo_grid->set_table_for_first_display(
      EXPORTING
        is_layout                     = ms_layout
        i_bypassing_buffer            = 'X'
        it_toolbar_excluding          = mt_exclude
        i_save                        = 'A'
        is_variant                    = ls_var
      CHANGING
        it_outtab                     = it_main
        it_fieldcatalog               = mt_fcat
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4 ).
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

  ENDMETHOD.


  METHOD refresh_alv.
    DATA(ls_stable) = VALUE lvc_s_stbl( row = 'X' col = 'X' ).

    IF mo_grid IS BOUND.
      mo_grid->refresh_table_display( is_stable = ls_stable ).
    ENDIF.
  ENDMETHOD.

  METHOD handle_user_command.
    PERFORM handle_user_command USING e_ucomm.

    refresh_alv( ).
    cl_gui_cfw=>flush( ).
  ENDMETHOD.


  METHOD handle_hotspot_click.
    CASE e_column_id.
      WHEN ''.
    ENDCASE.
  ENDMETHOD.


  METHOD handle_toolbar.
    PERFORM handle_toolbar TABLES e_object->mt_toolbar.

  ENDMETHOD.


  METHOD handle_data_changed.
    DATA : lmc_de TYPE raw4 .

    LOOP AT er_data_changed->mt_good_cells ASSIGNING FIELD-SYMBOL(<ls_cells>).
*<ls_cells>-fieldname

    ENDLOOP.

    refresh_alv( ).
  ENDMETHOD.

  METHOD split_container.
    mo_cont = NEW #(  container_name = scrfname
                      dynnr          = screen
                      repid          = sy-repid ).
    IF mo_cont IS BOUND.
      mo_splitter = NEW #(
        parent  = mo_cont
        rows    = 2
        columns = 1 ).

      mo_splitter->set_border( abap_true ).
      mo_splitter->set_row_height( id = 1 height = 20 ).
      mo_splitter->set_row_height( id = 2 height = 80 ).
    ENDIF.
  ENDMETHOD.


  METHOD set_top_of_page.


    DEFINE add_line.
      mo_document->add_text( text = CONV #( &1 )
                      sap_color     = cl_dd_area=>list_heading_inv
                      sap_fontsize  = cl_dd_document=>large
                      sap_emphasis = cl_dd_document=>strong ).
      mo_document->add_text( text = CONV #( &2 )
                      sap_color     = cl_dd_document=>list_positive
                      sap_fontsize  = cl_dd_document=>large
                       sap_style = cl_dd_area=>emphasis ).
      mo_document->new_line(   ).
    END-OF-DEFINITION.

    mo_top_page = mo_splitter->get_container(
      row    = 1
      column = 1 ).

    mo_document = NEW #( style = 'ALV_GRID' ).

    IF mo_document IS BOUND.

      CALL METHOD mo_document->add_gap
        EXPORTING
          width = 120.

*      CALL METHOD mo_document->add_picture
*        EXPORTING
*          picture_id = 'ENJOYSAP_LOGO'.

      CALL METHOD mo_document->new_line.

      mo_document->add_text( text = CONV #( sy-title )
          sap_style    = cl_dd_area=>heading
          sap_fontsize = cl_dd_area=>large
                              ).
      mo_document->new_line( 1  ).
      add_line : 'Tarih   :' sy-datum.
      add_line : 'Kullanıcı          :' sy-uname.
      mo_document->display_document( parent = mo_top_page ).
    ENDIF.
  ENDMETHOD.


ENDCLASS.                 " lcl_alv IMPLEMENTATION
