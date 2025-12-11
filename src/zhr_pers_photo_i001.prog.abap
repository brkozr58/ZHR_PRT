*&---------------------------------------------------------------------*
*& Include          ZHR_PERS_PHOTO_I001
*&---------------------------------------------------------------------*


TABLES : pa0001.
TYPE-POOLS:slis.

* DATA DEFINITIONS
DATA : gt_fcat TYPE   slis_fieldcat_alv   OCCURS 0  WITH HEADER LINE,
       layout  TYPE   slis_layout_alv     OCCURS 0  WITH HEADER LINE,
       t_sort  TYPE   slis_sortinfo_alv   OCCURS 0  WITH HEADER LINE.


DATA lw_path TYPE sapb-sappfad.
DATA: lw_ar_object  LIKE  toaom-ar_object,
      lw_object_id  LIKE  sapb-sapobjid,
      lw_sap_object LIKE  toaom-sap_object,
      lw_doc_type   LIKE  toadd-doc_type.
DATA g_selected_folder TYPE string.

DATA gt_file TYPE file_info OCCURS 0.
DATA gs_file TYPE file_info.
DATA g_count  TYPE i.

DATA : BEGIN OF gt_data OCCURS 0 ,
         filename    TYPE file_info-filename,
         ename       TYPE pa0001-ename,
         pernr       TYPE persno,
         error(1),
         imported(1),
         icon(4),
         text(100) ,
         mark(1) ,
       END OF gt_data.


TYPES : BEGIN OF ty_pa0001,
          pernr TYPE pernr_d,
          endda TYPE endda,
        END OF ty_pa0001.
DATA : gt_pa0001 TYPE TABLE OF ty_pa0001,
       gs_pa0001 TYPE ty_pa0001.
DATA: url(255)       TYPE c,
      p_connect_info LIKE TABLE OF toav0 WITH HEADER LINE,
      handle         TYPE i,
      v_pernr        TYPE pernr_d.
DATA :  l_current TYPE xstring.
DATA : ex_document TYPE TABLE OF  tbl1024,
       ex_length   TYPE int4.
DATA : binary_tab TYPE TABLE OF tbl1024,
       buffer     TYPE xstring.
DATA : v_filename TYPE string.
TYPES : BEGIN OF ty_binary,
          binary_field(1000) TYPE c,
        END OF ty_binary.

DATA : li_data TYPE TABLE OF ty_binary WITH HEADER LINE.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-s01.
PARAMETERS: r1 RADIOBUTTON GROUP g1 DEFAULT 'X' USER-COMMAND rb,
            r2 RADIOBUTTON GROUP g1.
SELECTION-SCREEN END OF BLOCK b1.
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-s02.
SELECT-OPTIONS : s_pernr FOR  pa0001-pernr MODIF ID 02 MATCHCODE OBJECT prem
                                           NO INTERVALS.
SELECT-OPTIONS : s_werks FOR  pa0001-werks MODIF ID 02 NO INTERVALS .
SELECT-OPTIONS : s_btrtl FOR  pa0001-btrtl MODIF ID 02 NO INTERVALS.
SELECT-OPTIONS : s_persg FOR  pa0001-persg MODIF ID 02 NO INTERVALS.
SELECT-OPTIONS : s_persk FOR  pa0001-persk MODIF ID 02 NO INTERVALS.
PARAMETERS: p_path  TYPE string OBLIGATORY MODIF ID 02.
SELECTION-SCREEN END OF BLOCK b2.
