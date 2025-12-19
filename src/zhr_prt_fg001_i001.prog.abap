*&---------------------------------------------------------------------*
*& Include          ZHR_PRT_FG001_I001
*&---------------------------------------------------------------------*

*----- global types
TYPE-POOLS: ptgqd, slis.
INFOTYPES : 0000,
            0001,
            0002,
            0003,
            0007,
            0049,
            2001,
            2002,
            2003,
            2006 .
CONSTANTS  gv_sender TYPE adr6-smtp_addr VALUE 'noreply@icdas.com.tr'.

TYPES: BEGIN OF pernr_ptgqd_kansp,
         pernr        TYPE pernr-pernr,
         cname        TYPE p0002-cname,
         sname        TYPE p0001-sname,
         bukrs        TYPE p0001-bukrs,
         bukrs_txt    TYPE char30,
         werks        TYPE p0001-werks,
         werks_txt    TYPE char30,
         btrtl        TYPE p0001-btrtl,
         btrtl_txt    TYPE char30,
         persg        TYPE p0001-persg,
         persg_txt    TYPE char30,
         persk        TYPE p0001-persk,
         persk_txt    TYPE char30,
         kostl        TYPE p0001-kostl,
         kostl_txt    TYPE char30,
         abkrs        TYPE p0001-abkrs,
         abkrs_txt    TYPE char30,
         ansvh        TYPE p0001-ansvh,
         ansvh_txt    TYPE char30,
         fistl        TYPE p0001-fistl,
         geber        TYPE p0001-geber,
         fkber        TYPE p0001-fkber,
         grant_nbr    TYPE p0001-grant_nbr,
         sgmnt        TYPE p0001-sgmnt,
         budget_pd    TYPE p0001-budget_pd,
         gsber        TYPE p0001-gsber,
         gsber_txt    TYPE char30,
         juper        TYPE p0001-juper,
         kokrs        TYPE p0001-kokrs,
         mstbr        TYPE p0001-mstbr,
         otype        TYPE p0001-otype,
         orgeh        TYPE p0001-orgeh,
         orgeh_txt    TYPE char30,
         vdsk1        TYPE p0001-vdsk1,
         plans        TYPE p0001-plans,
         plans_txt    TYPE char30,
         sacha        TYPE p0001-sacha,
         sacha_txt    TYPE char30,
         sachp        TYPE p0001-sachp,
         sachp_txt    TYPE char30,
         sachz        TYPE p0001-sachz,
         sachz_txt    TYPE char30,
         sbmod        TYPE p0001-sbmod,
         stell        TYPE p0001-stell,
         stell_txt    TYPE char30,
         ktart        TYPE ptgqd_ktart,
         kttext       TYPE ptgqd_kttext,
         begda        TYPE p2006-begda,
         endda        TYPE p2006-endda,
         desta        TYPE p2006-desta,
         deend        TYPE p2006-deend,
         entitle      TYPE ptgqd_entitle,
         transfer(25) TYPE c,
         deduct       TYPE ptgqd_deduct,
         ordered      TYPE ptgqd_ordered,
         account      TYPE ptgqd_account,
         reduced      TYPE ptgqd_reduced,
         reduced2     TYPE ptgqd_reduced2,
         rest         TYPE ptgqd_rest,
         rest2        TYPE ptgqd_rest2,
         untext       TYPE ptgqd_untext,
         quoun        TYPE ptgqd_quoun,
         autom        TYPE ptgqd_autom,
         quonr        TYPE ptm_quonr,
       END OF pernr_ptgqd_kansp.
TYPES: t_pernr_ptgqd_kansp TYPE STANDARD TABLE OF pernr_ptgqd_kansp.


TYPES: BEGIN OF pernr_ptgqd_qttrans,
         pernr  TYPE pernr-pernr,
         cname  TYPE p0002-cname,
         sname  TYPE p0001-sname,
         gdate  TYPE pc2bl-gdate,
         qtext  TYPE ptgqd_kttext,
         qtype  TYPE pc2bl-qtype,
         lvnum  TYPE pc2bl-lvnum,
         untext TYPE ptgqd_untext,
         quoun  TYPE ptgqd_quoun,
       END OF pernr_ptgqd_qttrans.
TYPES: t_pernr_ptgqd_qttrans TYPE STANDARD TABLE OF pernr_ptgqd_qttrans.
DATA : p_subrc TYPE sy-subrc  .
DATA : BEGIN OF gt_zmynt OCCURS 0 ,
         sachx   TYPE t526-sachx,
         usrid   TYPE t526-usrid,
         pernr   TYPE pa0001-pernr,
         plans   TYPE pa0001-plans,
         plans_t TYPE hrp1000-stext,
       END OF gt_zmynt .


DATA : BEGIN OF gt_tstell OCCURS 0 ,
         pernr   TYPE p0001-pernr,
         ename   TYPE p0001-ename,
         plans   TYPE p0001-plans,
         plans_t TYPE hrp1000-stext,
         stell   TYPE p0001-stell,
         stell_t TYPE hrp1000-stext,
         aptyp   TYPE zhr_prt_tstell-aptyp,
         aptyp_t TYPE dd07t-ddtext,
       END OF gt_tstell.


DEFINE hr_read_infotype.
  CLEAR p_subrc.
  REFRESH &3.
  CALL FUNCTION 'HR_READ_INFOTYPE'
    EXPORTING
      pernr           = &1
      infty           = &2
    IMPORTING
      subrc           = p_subrc
    TABLES
      infty_tab       = &3
    EXCEPTIONS
      infty_not_found = 1
      OTHERS          = 2.
END-OF-DEFINITION.

DATA: BEGIN OF holiday OCCURS 1,
        kjahr(4),
        date     TYPE d,
        beguz    TYPE t,
        enduz    TYPE t,
        ktart    LIKE t554s-ktart,
        zeinh    LIKE t556a-zeinh,
        urar1    LIKE t554x-urar1,
        urar2    LIKE t554x-urar2,
        urar3    LIKE t554x-urar3,
        urar4    LIKE t554x-urar4,
        urar5    LIKE t554x-urar5,
        urar6    LIKE t554x-urar6,
        urmin    LIKE t554x-urmin,
        dedir    LIKE t554x-dedir,
        anzhl    LIKE purlt-anzhl,
        anzh1    LIKE purlt-anzhl,
      END OF holiday.



DATA : w_http_client    TYPE REF TO if_http_client,
       w_result         TYPE string,
       emptybuffer      TYPE xstring,
       cdata            TYPE string,
       http_status_code TYPE i,
       status_text      TYPE string.


DEFINE set_cdata.
  CALL METHOD w_http_client->request->set_cdata
    EXPORTING
      data = cdata.
END-OF-DEFINITION.
DEFINE new_cdata.
  IF cdata IS INITIAL .
    cdata = &1 .
  ELSE .
    cdata = cdata && &1  .
  ENDIF.
END-OF-DEFINITION.
DEFINE set_header_field.
  CALL METHOD w_http_client->request->set_header_field
    EXPORTING
      name  = &1
      value = &2.
END-OF-DEFINITION.
DEFINE set_data.
  CALL METHOD w_http_client->request->set_data
    EXPORTING
      data = &1.
END-OF-DEFINITION.
DEFINE  get_status.
  CALL METHOD w_http_client->response->get_status
    IMPORTING
      code   = http_status_code
      reason = status_text.
END-OF-DEFINITION.
DEFINE receive_data.
  CALL METHOD w_http_client->receive
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2
      http_processing_failed     = 3.
END-OF-DEFINITION.
DEFINE send.
  CALL METHOD w_http_client->send
    EXCEPTIONS
      http_communication_failure = 1
      http_invalid_state         = 2.
END-OF-DEFINITION.
DEFINE  get_cdata.
  CALL METHOD w_http_client->response->get_cdata
    RECEIVING
      data = w_result.
END-OF-DEFINITION.

DEFINE initial_services.
  CLEAR : w_result        ,
          emptybuffer     ,
          cdata           ,
          http_status_code,
          status_text       .

  IF w_http_client IS NOT INITIAL .
    w_http_client->close( ).
  ENDIF.

END-OF-DEFINITION.
