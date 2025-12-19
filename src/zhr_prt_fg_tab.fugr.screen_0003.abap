PROCESS BEFORE OUTPUT.
  MODULE liste_initialisieren.
  LOOP AT extract WITH CONTROL
   tctrl_zhr_prt_vonayci CURSOR nextline.
    MODULE liste_show_liste.
  ENDLOOP.
  MODULE fill_substflds.
*
PROCESS AFTER INPUT.
  MODULE liste_exit_command AT EXIT-COMMAND.
  MODULE liste_before_loop.
  LOOP AT extract.
    MODULE liste_init_workarea.
    CHAIN.
      FIELD zhr_prt_vonayci-pernr .
      FIELD zhr_prt_vonayci-ename .
      FIELD zhr_prt_vonayci-zapp1 .
      FIELD zhr_prt_vonayci-zapp2 .
      MODULE set_update_flag ON CHAIN-REQUEST.
      MODULE complete_zhr_prt_vonayci ON CHAIN-REQUEST.
    ENDCHAIN.
    FIELD vim_marked MODULE liste_mark_checkbox.
    CHAIN.
      FIELD zhr_prt_vonayci-pernr .
      MODULE liste_update_liste.
    ENDCHAIN.
  ENDLOOP.
  MODULE liste_after_loop.
