@AbapCatalog.sqlViewName: 'ZHR_PRT_DDL004'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Personel izin verileri 2001/Portal'
@Metadata.ignorePropagatedAnnotations: true

define view ZHR_PRT_CDS004
  as select from zhr_prt_ddl002 as LEAVE


{
  LEAVE.mandt,
  LEAVE.srcid,
  LEAVE.tlpid,
  LEAVE.pernr,
  LEAVE.ename,
  LEAVE.plans,
  LEAVE.plans_t,
  LEAVE.orgeh,
  LEAVE.orgeh_t,
  LEAVE.sachz,
  LEAVE.awart,
  LEAVE.awart_t,
  LEAVE.begda,
  LEAVE.endda,
  LEAVE.beguz,
  LEAVE.enduz,
  LEAVE.retdt,
  LEAVE.kaltg,
  LEAVE.stdaz,
  LEAVE.abwtg,
  LEAVE.abrtg,
  LEAVE.abrst,
  LEAVE.zdesc,
  LEAVE.seqnr,
  LEAVE.aptyp,
  LEAVE.ap_aptyp_t,
  LEAVE.ap_pernr,
  LEAVE.ap_ename,
  LEAVE.ap_plans,
  LEAVE.ap_plans_t,
  LEAVE.ap_orgsvy,
  LEAVE.ap_orgsvy_t,
  LEAVE.statu,
  LEAVE.statu_t,
  LEAVE.ap_statu,
  LEAVE.ap_statu_t,
  LEAVE.ap_zdesc,
  LEAVE.crt_pernr,
  LEAVE.crt_ename,
  LEAVE.crt_datum,
  LEAVE.crt_uzeit,
  LEAVE.chn_pernr,
  LEAVE.chn_ename,
  LEAVE.chn_datum,
  LEAVE.chn_uzeit,
  LEAVE.admin

}

union all select from zhr_prt_ddl003 as Z2001

{

  Z2001.mandt,
  Z2001.srcid,
  Z2001.tlpid,
  Z2001.pernr,
  Z2001.ename,
  Z2001.plans,
  Z2001.plans_t,
  Z2001.orgeh,
  Z2001.orgeh_t,
  Z2001.sachz,
  Z2001.awart,
  Z2001.awart_t,
  Z2001.begda,
  Z2001.endda,
  Z2001.beguz,
  Z2001.enduz,
  Z2001.retdt,
  Z2001.kaltg,
  Z2001.stdaz,
  Z2001.abwtg,
  Z2001.abrtg,
  Z2001.abrst,
  Z2001.zdesc,
  Z2001.seqnr,
  Z2001.aptyp,
  Z2001.ap_aptyp_t,
  Z2001.ap_pernr,
  Z2001.ap_ename,
  Z2001.ap_plans,
  Z2001.ap_plans_t,
  Z2001.ap_orgsvy,
  Z2001.ap_orgsvy_t,
  Z2001.statu,
  Z2001.statu_t,
  Z2001.ap_statu,
  Z2001.ap_statu_t,
  Z2001.ap_zdesc,
  Z2001.crt_pernr,
  Z2001.crt_ename,
  Z2001.crt_datum,
  Z2001.crt_uzeit,
  Z2001.chn_pernr,
  Z2001.chn_ename,
  Z2001.chn_datum,
  Z2001.chn_uzeit,
  Z2001.admin

}
