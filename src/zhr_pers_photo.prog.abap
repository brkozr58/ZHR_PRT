*&---------------------------------------------------------------------*
*& Report ZHR_PERS_PHOTO
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zhr_pers_photo.

INCLUDE zhr_pers_photo_i001.
INCLUDE zhr_pers_photo_i002.

AT SELECTION-SCREEN OUTPUT .
  PERFORM modify_screen.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_path.
  PERFORM directory_browse.

START-OF-SELECTION.
  CASE 'X'.
    WHEN r1.
      PERFORM get_files.
      PERFORM split_files.
    WHEN r2.
      PERFORM get_data.
  ENDCASE.


END-OF-SELECTION.
  IF gt_data[] IS NOT INITIAL AND r1 EQ 'X'.
    PERFORM call_alv.
  ENDIF.

  IF gt_pa0001[] IS NOT INITIAL AND r2 EQ 'X'.
    PERFORM download_files.
  ENDIF.




*&---------------------------------------------------------------------*
*&      Form  gui
*&---------------------------------------------------------------------*
FORM gui USING lt_extab.
  SET PF-STATUS 'GUIALV'.
ENDFORM.                    "gui
*&---------------------------------------------------------------------*
*&      Form  command
*&---------------------------------------------------------------------*
FORM command USING r_ucomm ls_selfield TYPE slis_selfield.
  CASE r_ucomm.
    WHEN 'BATCH'.
      LOOP AT gt_data WHERE mark = 'X'
                      AND   error = space
                      AND   imported = space.
        PERFORM upload_photo.
        MODIFY gt_data.
      ENDLOOP.

      ls_selfield-refresh = 'X'.
  ENDCASE.
ENDFORM.                    "command
