*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZHR_PRT_FG_TAB
*   generation date: 22.10.2025 at 21:38:58
*   view maintenance generator version: #001407#
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZHR_PRT_FG_TAB     .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
