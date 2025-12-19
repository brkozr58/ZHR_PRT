class ZHR_PRT_CL001 definition
  public
  final
  create public .

public section.

  data S_PERS type ZHR_PRT_S009 .
  data T_PERS type ZHR_PRT_TT009 .

  methods CONSTRUCTOR .
  methods GET_PERSON_VALUES
    importing
      value(I_UNAME) type SY-UNAME default SY-UNAME
      value(I_PERNR) type PERSNO optional
    exporting
      !ET_PERS type ZHR_PRT_TT009 .
protected section.
private section.
ENDCLASS.



CLASS ZHR_PRT_CL001 IMPLEMENTATION.


  METHOD constructor.

    get_person_values(
       IMPORTING
         et_pers =  t_pers[]
     ).

    READ TABLE t_pers INTO s_pers INDEX 1 .


  ENDMETHOD.


  METHOD get_person_values.
    DATA : ee_tab TYPE  pernr_us_tab.

    IF i_pernr IS INITIAL .
      CALL FUNCTION 'HR_GET_EMPLOYEES_FROM_USER'
        EXPORTING
          user   = i_uname
          begda  = sy-datum
          endda  = sy-datum
        TABLES
          ee_tab = ee_tab.
      CHECK ee_tab[] IS NOT INITIAL .
      READ TABLE ee_tab INTO DATA(ls_tab) INDEX 1 .
    ELSE.
      ls_tab-pernr = i_pernr.
    ENDIF.

    CALL FUNCTION 'ZHR_PRT_FG001_02'
      EXPORTING
        i_pernr    = ls_tab-pernr
        i_datum    = sy-datum
      IMPORTING
        et_persons = et_pers[].

  ENDMETHOD.
ENDCLASS.
