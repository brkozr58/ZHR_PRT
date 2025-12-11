*&---------------------------------------------------------------------*
*& Include          ZHR_PERS_PHOTO_I002
*&---------------------------------------------------------------------*


FORM split_files.
  DATA : l_pnalt  TYPE p0032-pnalt,
         l_ext(5).

  LOOP AT gt_file INTO gs_file.
    gt_data-filename = gs_file-filename.

    CLEAR l_pnalt.
    SPLIT gs_file-filename AT '.' INTO l_pnalt l_ext .

    IF l_pnalt IS INITIAL.
      gt_data-error = 'X'.
      gt_data-icon = '@8O@'.
      gt_data-text = 'Dosya adı okunamadı !'.
    ELSE.
*      IF r1 = 'X'.
*        PERFORM find_pernr USING l_pnalt.
*      ELSEIF r2 = 'X'.
      gt_data-pernr = l_pnalt.
      SELECT SINGLE ename FROM pa0001 INTO gt_data-ename
                         WHERE pernr = gt_data-pernr
                           AND endda = '99991231'.
      IF sy-subrc NE 0.
        CLEAR gt_data-pernr.
        gt_data-error = 'X'.
        gt_data-icon = '@8O@'.
        gt_data-text = 'Personel numarası bulunamadı !'.
      ENDIF.
*      ENDIF.

    ENDIF.

    APPEND gt_data.CLEAR gt_data.

  ENDLOOP.

ENDFORM.                    "split_files
*&---------------------------------------------------------------------*
*&      Form  get_files
*&---------------------------------------------------------------------*
FORM get_files.
  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title         = 'Fotoğraf için klasör seçimi'
*     initial_folder       =
    CHANGING
      selected_folder      = g_selected_folder
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CHECK sy-subrc = 0 AND g_selected_folder IS NOT INITIAL.

  CALL METHOD cl_gui_frontend_services=>directory_list_files
    EXPORTING
      directory                   = g_selected_folder
      filter                      = '*.JPG'
*     files_only                  =
*     directories_only            =
    CHANGING
      file_table                  = gt_file
      count                       = g_count
    EXCEPTIONS
      cntl_error                  = 1
      directory_list_files_failed = 2
      wrong_parameter             = 3
      error_no_gui                = 4
      not_supported_by_gui        = 5
      OTHERS                      = 6.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    "get_file

*&---------------------------------------------------------------------*
*&      Form  upload_photo
*&---------------------------------------------------------------------*
FORM upload_photo.
* Function module to update Tran OAAD
  CONCATENATE g_selected_folder '\' gt_data-filename INTO lw_path.
* Assign Values
  lw_ar_object  = 'HRICOLFOTO'.
  lw_object_id  = gt_data-pernr.
  lw_sap_object = 'PREL'.         "PREL
  lw_doc_type   = 'JPG'.         "JPG

  CALL FUNCTION 'ARCHIV_CREATE_FILE'
    EXPORTING
      ar_object               = lw_ar_object
*     DEL_DATE                =
      object_id               = lw_object_id
      sap_object              = lw_sap_object
      doc_type                = lw_doc_type
      path                    = lw_path
    EXCEPTIONS
      error_conectiontable    = 1
      error_parameter         = 2
      error_archiv            = 3
      error_upload            = 4
      error_kernel            = 5
      no_entry_possible       = 6
      error_comunicationtable = 7
      OTHERS                  = 8.
  IF sy-subrc <> 0.
    gt_data-error = 'X'.
    gt_data-icon = '@5C@'.
    gt_data-text = 'Fotoğraf aktarılamadı !'.
  ELSE.
    gt_data-imported = 'X'.
    gt_data-text = 'Fotoğraf Aktarıldı'.
    gt_data-icon = '@2K@'.
  ENDIF.

ENDFORM.                    "upload_photo
*&---------------------------------------------------------------------*
*&      Form  FIND_PERNR
*&---------------------------------------------------------------------*
FORM find_pernr_from_ename  USING p_ename.
  DATA l_line TYPE i.
  DATA : BEGIN OF gt_pernr OCCURS 0,
           pernr TYPE persno,
         END OF gt_pernr.
  DATA gt_00 TYPE pa0000 OCCURS 0 WITH HEADER LINE.

  SELECT pernr FROM pa0001 INTO TABLE gt_pernr
                   WHERE endda = '99991231'
  AND   ename = p_ename.
  IF sy-subrc = 0.
* Aynı isimli aktif 2 kişi varsa hata ver
    SELECT * FROM pa0000 INTO TABLE gt_00
            FOR ALL ENTRIES IN gt_pernr
            WHERE pernr = gt_pernr-pernr
            AND   endda = '99991231'
    AND   stat2 = '3'.
    IF sy-subrc NE 0.
      gt_data-error = 'X'.
      gt_data-icon = '@8O@'.
      gt_data-text = 'Kişi işten ayrılmış, aktarım olmayacak !'.
      EXIT.
    ENDIF.

    DESCRIBE TABLE gt_00 LINES l_line.
    IF l_line GT 1.
      gt_data-error = 'X'.
      gt_data-icon = '@8O@'.
      gt_data-text = 'Aynı isimli iki kişi bulunuyor, kontrol ediniz !'.
      EXIT.
    ENDIF.

    READ TABLE gt_00 INDEX 1.
    IF sy-subrc = 0.
      gt_data-pernr = gt_00-pernr.
    ENDIF.

  ELSE.
    gt_data-error = 'X'.
    gt_data-icon = '@8O@'.
    gt_data-text = 'Bu isimde bir kişi bulunamadı !'.
  ENDIF.
ENDFORM.                    " FIND_PERNR


*&---------------------------------------------------------------------*
*&      Form  call_alv
*&---------------------------------------------------------------------*
FORM call_alv .
  PERFORM fill_gt_fcat.
  PERFORM fill_layout.
  PERFORM display_alv.
ENDFORM.                    " call_alv

*&---------------------------------------------------------------------*
*&      Form  fill_gt_fcat
*&---------------------------------------------------------------------*
FORM fill_gt_fcat .

  PERFORM fill_fcat USING :
             'FILENAME'  'Dosya İsmi' ,
             'ENAME'     'Personel Adı',
             'PERNR'     'Personel No',
             'ICON'      'Başarı Durumu' ,
             'TEXT'      'Açıklama'.


  READ TABLE gt_fcat WITH KEY fieldname = 'ICON' .
  IF sy-subrc = 0.
    gt_fcat-just = 'C'.
    MODIFY gt_fcat INDEX sy-tabix.
  ENDIF.

ENDFORM.                    "fill_gt_fcat

*&---------------------------------------------------------------------*
*&      Form  fill_layout
*&---------------------------------------------------------------------*
FORM fill_layout .
  layout-zebra             = 'X'.
  layout-colwidth_optimize = 'X'.
  layout-box_fieldname = 'MARK'.
ENDFORM.                    " fill_layout


*&---------------------------------------------------------------------*
*&      Form  display_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_alv .
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'GUI'
      i_callback_user_command  = 'COMMAND'
      is_layout                = layout
      it_fieldcat              = gt_fcat[]
*     it_sort                  = t_sort[]
    TABLES
      t_outtab                 = gt_data[].
ENDFORM.                    " display_alv




*&---------------------------------------------------------------------*
*&      Form  fill_fcat
*&---------------------------------------------------------------------*
FORM fill_fcat USING p_fname p_text.

  gt_fcat-fieldname = p_fname.
  gt_fcat-reptext_ddic = p_text.
  APPEND gt_fcat.
  CLEAR gt_fcat .

ENDFORM.                    "fill_fcat
*&---------------------------------------------------------------------*
*&      Form  FIND_PERNR
*&---------------------------------------------------------------------*
FORM find_pernr  USING p_pnalt.
  DATA ls_00 TYPE pa0000.
  DATA l_pernr TYPE persno.

  SELECT SINGLE pernr FROM pa0032 INTO l_pernr
          WHERE endda = '99991231'
  AND   pnalt = p_pnalt.
  IF sy-subrc NE 0 .
    gt_data-error = 'X'.
    gt_data-icon = '@8O@'.
    gt_data-text = 'Bu personel no''ya sahip bir kişi bulunamadı !'.
    EXIT.
  ENDIF.

  gt_data-pernr = l_pernr.
  SELECT SINGLE ename FROM pa0001 INTO gt_data-ename
                   WHERE pernr = gt_data-pernr
                     AND   endda = '99991231'.
ENDFORM.                    " FIND_PERNR
*&---------------------------------------------------------------------*
*& Form MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM modify_screen .
  LOOP AT SCREEN.
    IF r1 EQ 'X'.
      IF screen-group1 = '02'.
        screen-active = 0.
      ENDIF.
    ELSE.
      IF screen-group1 = '02'.
        screen-active = 1.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form DIRECTORY_BROWSE
*&---------------------------------------------------------------------*
FORM directory_browse .
  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title    = 'Select Directory'
    CHANGING
      selected_folder = p_path
    EXCEPTIONS
      cntl_error      = 1.

  CALL METHOD cl_gui_cfw=>flush
    EXCEPTIONS
      cntl_system_error = 1
      cntl_error        = 2.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
FORM get_data .
  REFRESH gt_pa0001[].

  SELECT pernr endda    FROM pa0001
                        INTO TABLE gt_pa0001
                        WHERE pernr IN s_pernr
                        AND   werks IN s_werks
                        AND   btrtl IN s_btrtl
                        AND   persg IN s_persg
                        AND   persk IN s_persk
                        AND   endda EQ '99991231' .

  IF gt_pa0001 IS INITIAL.
*    MESSAGE s001 WITH 'Seçim Kriterlerine göre veri bulunmadı'.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DOWNLOAD_FILES
*&---------------------------------------------------------------------*
FORM download_files .

  IF gt_pa0001[] IS NOT INITIAL.
    LOOP AT gt_pa0001 INTO gs_pa0001.
      REFRESH : li_data , ex_document , binary_tab.
      CLEAR   : p_connect_info, buffer , v_filename.
      CALL FUNCTION 'HR_IMAGE_EXISTS'
        EXPORTING
          p_pernr        = gs_pa0001-pernr
        IMPORTING
          p_connect_info = p_connect_info
        EXCEPTIONS
          OTHERS         = 2.

      IF sy-subrc EQ 0.
        CALL FUNCTION 'ALINK_RFC_TABLE_GET'
          EXPORTING
            im_docid    = p_connect_info-arc_doc_id
            im_crepid   = p_connect_info-archiv_id
*           IM_COMPID   =
          IMPORTING
            ex_length   = ex_length
*           EX_MESSAGE  =
          TABLES
            ex_document = ex_document.
        binary_tab[] = ex_document[].
        IF ex_length IS INITIAL.
          CONTINUE.
        ENDIF.
        CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
          EXPORTING
            input_length = ex_length
*           FIRST_LINE   = 0
*           LAST_LINE    = 0
          IMPORTING
            buffer       = buffer
          TABLES
            binary_tab   = binary_tab
          EXCEPTIONS
            failed       = 1
            OTHERS       = 2.
        IF sy-subrc <> 0.
* Implement suitable error handling here
        ENDIF.
        CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
          EXPORTING
            buffer          = buffer
            append_to_table = 'X'
* IMPORTING
*           OUTPUT_LENGTH   =
          TABLES
            binary_tab      = li_data.
        CONCATENATE p_path '\'  gs_pa0001-pernr '.jpg' INTO v_filename.
        CONDENSE v_filename.

        CALL FUNCTION 'GUI_DOWNLOAD'
          EXPORTING
*           BIN_FILESIZE                    =
            filename = v_filename
            filetype = 'BIN'
*           append   = 'X'
* IMPORTING
*           FILELENGTH                      =
          TABLES
            data_tab = li_data.
      ENDIF.
      CLEAR gs_pa0001.
    ENDLOOP.
  ENDIF.
ENDFORM.
