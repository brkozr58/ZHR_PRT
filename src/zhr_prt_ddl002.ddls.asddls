@AbapCatalog.sqlViewName: 'ZHR_PRT_DDL002'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Personel Portal İzin Verileri'
@Metadata.ignorePropagatedAnnotations: true
define view ZHR_PRT_cds002

  as select from    zhr_prt_t004 as t1
    inner join      zhr_prt_t005 as t2        on t2.tlpid = t1.tlpid
    inner join      pa0001       as per       on  per.pernr = t2.pernr
                                              and per.begda <= $session.system_date
                                              and per.endda >= $session.system_date
    inner join      zhr_prt_t006 as t3        on t3.tlpid = t2.tlpid

    inner join      dd07t        as orgsv     on  orgsv.domvalue_l = t3.orgsvy
                                              and orgsv.domname    = 'ZHRORG'
                                              and orgsv.ddlanguage = $session.system_language

    inner join      dd07t        as APTYPE    on  APTYPE.domvalue_l = t3.aptyp
                                              and APTYPE.domname    = 'ZHR_PRT_APTYP'
                                              and APTYPE.ddlanguage = $session.system_language


    inner join      hrp1000      as per_plans on  per_plans.otype = 'S'
                                              and per_plans.plvar = '01'
                                              and per_plans.objid = per.plans
                                              and per_plans.langu = $session.system_language
                                              and per_plans.begda <= $session.system_date
                                              and per_plans.endda >= $session.system_date

    inner join      hrp1000      as per_orgeh on  per_orgeh.otype = 'O'
                                              and per_orgeh.plvar = '01'
                                              and per_orgeh.objid = per.orgeh
                                              and per_orgeh.langu = $session.system_language
                                              and per_orgeh.begda <= $session.system_date
                                              and per_orgeh.endda >= $session.system_date


    inner join      hrp1000      as apr_plans on  apr_plans.otype = 'S'
                                              and apr_plans.plvar = '01'
                                              and apr_plans.objid = t3.plans
                                              and apr_plans.langu = $session.system_language
                                              and apr_plans.begda <= $session.system_date
                                              and apr_plans.endda >= $session.system_date

    inner join      t001p        as per_t001p on  per_t001p.werks = per.werks
                                              and per_t001p.btrtl = per.btrtl
    inner join      t554t        as per_awart on  per_awart.moabw = per_t001p.moabw
                                              and per_awart.awart = t2.awart
                                              and per_awart.sprsl = $session.system_language

    inner join      t526         as apr_zmn   on  t3.aptyp      = 'ZMNY'
                                              and apr_zmn.sachx = per.sachz
                                              and apr_zmn.werks = 'PA01'

    inner join      pa0105       as apr_sapu  on  apr_sapu.usrid = apr_zmn.usrid
                                              and apr_sapu.subty = 'SAPU'
                                              and apr_sapu.endda >= $session.system_date
                                              and t3.aptyp       = 'ZMNY'

    inner join      pa0001       as apr       on  apr.pernr = apr_sapu.pernr
                                              and apr.plans = t3.plans
                                              and apr.begda <= $session.system_date
                                              and apr.endda >= $session.system_date



    left outer join dd07t        as statu     on  statu.domvalue_l = t1.statu
                                              and statu.domname    = 'ZHR_PRT_STATU'
                                              and statu.ddlanguage = $session.system_language

    left outer join dd07t        as ap_statu  on  ap_statu.domvalue_l = t3.statu
                                              and ap_statu.domname    = 'ZHR_PRT_STATU'
                                              and ap_statu.ddlanguage = $session.system_language

    left outer join pa0001       as chn_pernr on  chn_pernr.pernr = t3.unamechn
                                              and chn_pernr.begda <= $session.system_date
                                              and chn_pernr.endda >= $session.system_date
    left outer join pa0001       as crt_pernr on  crt_pernr.pernr = t1.unamecre
                                              and crt_pernr.begda <= $session.system_date
                                              and crt_pernr.endda >= $session.system_date
{
  t1.srcid,
  t1.tlpid,
  t2.pernr,
  per.ename,
  per.plans,
  per_plans.stext                                                                                      as plans_t,
  per.orgeh,
  per_orgeh.stext                                                                                      as orgeh_t,
  per.sachz,
  t2.awart,
  per_awart.atext                                                                                      as awart_t,
  t2.begda,
  t2.endda,


  cast( ( case when  t2.beguz  is not null then t2.beguz  else '000000' end ) as abap.char( 6 ) )      as beguz,
  cast( ( case when  t2.enduz  is not null then t2.enduz  else '000000' end ) as abap.char( 6 ) )      as enduz,

  ////  t2.beguz,
  ////  t2.enduz,
  t2.retdt,
  t2.kaltg,
  t2.stdaz,
  t2.abwtg,
  t2.abrtg,
  t2.abrst,
  t2.zdesc,

  t3.seqnr,
  t3.aptyp,
  APTYPE.ddtext                                                                                        as ap_aptyp_t,
  apr.pernr                                                                                            as ap_pernr,
  apr.ename                                                                                            as ap_ename,
  t3.plans                                                                                             as ap_plans,
  apr_plans.stext                                                                                      as ap_plans_t,
  t3.orgsvy                                                                                            as ap_orgsvy,
  orgsv.ddtext                                                                                         as ap_orgsvy_t,

  t1.statu,
  statu.ddtext                                                                                         as statu_t,

  t3.statu                                                                                             as ap_Statu,
  ap_statu.ddtext                                                                                      as ap_statu_t,
  t3.ap_zdesc,

  //  talebi oluşturan sicil verileri)
  t1.unamecre                                                                                          as crt_pernr,
  crt_pernr.ename                                                                                      as crt_ename,
  t1.datumcre                                                                                          as crt_datum,
  cast( ( case when  t1.uzeitcre  is not null then t1.uzeitcre else '000000' end ) as abap.char( 6 ) ) as crt_uzeit,

  //  DEğiştiren(Onaylayan sicil verileri)
  t3.unamechn                                                                                          as chn_pernr,
  chn_pernr.ename                                                                                      as chn_ename,
  t3.datumchn                                                                                          as chn_datum,

  cast( ( case when  t3.uzeitchn  is not null then t3.uzeitchn else '000000' end ) as abap.char( 6 ) ) as chn_uzeit,
  t3.admin
}

union all select from zhr_prt_t004 as t1
  inner join          zhr_prt_t005 as t2        on t2.tlpid = t1.tlpid
  inner join          pa0001       as per       on  per.pernr = t2.pernr
                                                and per.begda <= $session.system_date
                                                and per.endda >= $session.system_date
  inner join          zhr_prt_t006 as t3        on t3.tlpid = t2.tlpid

  inner join          dd07t        as orgsv     on  orgsv.domvalue_l = t3.orgsvy
                                                and orgsv.domname    = 'ZHRORG'
                                                and orgsv.ddlanguage = $session.system_language

  inner join          dd07t        as APTYPE    on  APTYPE.domvalue_l = t3.aptyp
                                                and APTYPE.domname    = 'ZHR_PRT_APTYP'
                                                and APTYPE.ddlanguage = $session.system_language


  inner join          hrp1000      as per_plans on  per_plans.otype = 'S'
                                                and per_plans.plvar = '01'
                                                and per_plans.objid = per.plans
                                                and per_plans.langu = $session.system_language
                                                and per_plans.begda <= $session.system_date
                                                and per_plans.endda >= $session.system_date

  inner join          hrp1000      as per_orgeh on  per_orgeh.otype = 'O'
                                                and per_orgeh.plvar = '01'
                                                and per_orgeh.objid = per.orgeh
                                                and per_orgeh.langu = $session.system_language
                                                and per_orgeh.begda <= $session.system_date
                                                and per_orgeh.endda >= $session.system_date


  inner join          hrp1000      as apr_plans on  apr_plans.otype = 'S'
                                                and apr_plans.plvar = '01'
                                                and apr_plans.objid = t3.plans
                                                and apr_plans.langu = $session.system_language
                                                and apr_plans.begda <= $session.system_date
                                                and apr_plans.endda >= $session.system_date

  inner join          t001p        as per_t001p on  per_t001p.werks = per.werks
                                                and per_t001p.btrtl = per.btrtl
  inner join          t554t        as per_awart on  per_awart.moabw = per_t001p.moabw
                                                and per_awart.awart = t2.awart
                                                and per_awart.sprsl = $session.system_language


  inner join          pa0001       as apr       on  apr.plans =  t3.plans
                                                and apr.begda <= $session.system_date
                                                and apr.endda >= $session.system_date
                                                and t3.aptyp  <> 'ZMNY'



  left outer join     dd07t        as statu     on  statu.domvalue_l = t1.statu
                                                and statu.domname    = 'ZHR_PRT_STATU'
                                                and statu.ddlanguage = $session.system_language

  left outer join     dd07t        as ap_statu  on  ap_statu.domvalue_l = t3.statu
                                                and ap_statu.domname    = 'ZHR_PRT_STATU'
                                                and ap_statu.ddlanguage = $session.system_language

  left outer join     pa0001       as chn_pernr on  chn_pernr.pernr = t3.unamechn
                                                and chn_pernr.begda <= $session.system_date
                                                and chn_pernr.endda >= $session.system_date
  left outer join     pa0001       as crt_pernr on  crt_pernr.pernr = t1.unamecre
                                                and crt_pernr.begda <= $session.system_date
                                                and crt_pernr.endda >= $session.system_date
{
  t1.srcid,
  t1.tlpid,
  t2.pernr,
  per.ename,
  per.plans,
  per_plans.stext                                                                                      as plans_t,
  per.orgeh,
  per_orgeh.stext                                                                                      as orgeh_t,
  per.sachz,
  t2.awart,
  per_awart.atext                                                                                      as awart_t,
  t2.begda,
  t2.endda,


  cast( ( case when  t2.beguz  is not null then t2.beguz  else '000000' end ) as abap.char( 6 ) )      as beguz,
  cast( ( case when  t2.enduz  is not null then t2.enduz  else '000000' end ) as abap.char( 6 ) )      as enduz,

  ////  t2.beguz,
  ////  t2.enduz,
  t2.retdt,
  t2.kaltg,
  t2.stdaz,
  t2.abwtg,
  t2.abrtg,
  t2.abrst,
  t2.zdesc,

  t3.seqnr,
  t3.aptyp,
  APTYPE.ddtext                                                                                        as ap_aptyp_t,
  apr.pernr                                                                                            as ap_pernr,
  apr.ename                                                                                            as ap_ename,
  t3.plans                                                                                             as ap_plans,
  apr_plans.stext                                                                                      as ap_plans_t,
  t3.orgsvy                                                                                            as ap_orgsvy,
  orgsv.ddtext                                                                                         as ap_orgsvy_t,

  t1.statu,
  statu.ddtext                                                                                         as statu_t,

  t3.statu                                                                                             as ap_Statu,
  ap_statu.ddtext                                                                                      as ap_statu_t,
  t3.ap_zdesc,

  //  talebi oluşturan sicil verileri)
  t1.unamecre                                                                                          as crt_pernr,
  crt_pernr.ename                                                                                      as crt_ename,
  t1.datumcre                                                                                          as crt_datum,
  cast( ( case when  t1.uzeitcre  is not null then t1.uzeitcre else '000000' end ) as abap.char( 6 ) ) as crt_uzeit,

  //  DEğiştiren(Onaylayan sicil verileri)
  t3.unamechn                                                                                          as chn_pernr,
  chn_pernr.ename                                                                                      as chn_ename,
  t3.datumchn                                                                                          as chn_datum,

  cast( ( case when  t3.uzeitchn  is not null then t3.uzeitchn else '000000' end ) as abap.char( 6 ) ) as chn_uzeit,
  t3.admin
}














//
//
//  as select from    zhr_prt_t004 as t1
//    inner join      zhr_prt_t005 as t2        on t2.tlpid = t1.tlpid
//    inner join      pa0001       as per       on  per.pernr = t2.pernr
//                                              and per.begda <= $session.system_date
//                                              and per.endda >= $session.system_date
//    inner join      zhr_prt_t006 as t3        on t3.tlpid = t2.tlpid
//
//    inner join      dd07t        as orgsv     on  orgsv.domvalue_l = t3.orgsvy
//                                              and orgsv.domname    = 'ZHRORG'
//                                              and orgsv.ddlanguage = $session.system_language
//
//    inner join      dd07t        as APTYPE    on  APTYPE.domvalue_l = t3.aptyp
//                                              and APTYPE.domname    = 'ZHR_PRT_APTYP'
//                                              and APTYPE.ddlanguage = $session.system_language
//
//
//    inner join      hrp1000      as per_plans on  per_plans.otype = 'S'
//                                              and per_plans.plvar = '01'
//                                              and per_plans.objid = per.plans
//                                              and per_plans.langu = $session.system_language
//                                              and per_plans.begda <= $session.system_date
//                                              and per_plans.endda >= $session.system_date
//
//    inner join      hrp1000      as per_orgeh on  per_orgeh.otype = 'O'
//                                              and per_orgeh.plvar = '01'
//                                              and per_orgeh.objid = per.orgeh
//                                              and per_orgeh.langu = $session.system_language
//                                              and per_orgeh.begda <= $session.system_date
//                                              and per_orgeh.endda >= $session.system_date
//
//
//    inner join      hrp1000      as apr_plans on  apr_plans.otype = 'S'
//                                              and apr_plans.plvar = '01'
//                                              and apr_plans.objid = t3.plans
//                                              and apr_plans.langu = $session.system_language
//                                              and apr_plans.begda <= $session.system_date
//                                              and apr_plans.endda >= $session.system_date
//
//    inner join      t001p        as per_t001p on  per_t001p.werks = per.werks
//                                              and per_t001p.btrtl = per.btrtl
//    inner join      t554t        as per_awart on  per_awart.moabw = per_t001p.moabw
//                                              and per_awart.awart = t2.awart
//                                              and per_awart.sprsl = $session.system_language
//
//    inner join      pa0001       as apr       on  apr.plans = t3.plans
//                                              and apr.begda <= $session.system_date
//                                              and apr.endda >= $session.system_date
//
//
//    left outer join pa0105       as apr_sapu  on  apr_sapu.pernr = apr.pernr
//                                              and apr_sapu.subty = 'SAPU'
//                                              and apr_sapu.endda >= $session.system_date
//  //                                              and t3.aptyp       = 'ZMNY'
//    left outer join t526         as apr_zmn   on apr_zmn.usrid = apr_sapu.usrid
//
//
//    left outer join dd07t        as statu     on  statu.domvalue_l = t1.statu
//                                              and statu.domname    = 'ZHR_PRT_STATU'
//                                              and statu.ddlanguage = $session.system_language
//
//    left outer join dd07t        as ap_statu  on  ap_statu.domvalue_l = t3.statu
//                                              and ap_statu.domname    = 'ZHR_PRT_STATU'
//                                              and ap_statu.ddlanguage = $session.system_language
//
//    left outer join pa0001       as chn_pernr on  chn_pernr.pernr = t3.unamechn
//                                              and chn_pernr.begda <= $session.system_date
//                                              and chn_pernr.endda >= $session.system_date
//    left outer join pa0001       as crt_pernr on  crt_pernr.pernr = t1.unamecre
//                                              and crt_pernr.begda <= $session.system_date
//                                              and crt_pernr.endda >= $session.system_date
//{
//  t1.srcid,
//  t1.tlpid,
//  t2.pernr,
//  per.ename,
//  per.plans,
//  per_plans.stext                                                                                      as plans_t,
//  per.orgeh,
//  per_orgeh.stext                                                                                      as orgeh_t,
//  per.sachz,
//  t2.awart,
//  per_awart.atext                                                                                      as awart_t,
//  t2.begda,
//  t2.endda,
//
//
//  cast( ( case when  t2.beguz  is not null then t2.beguz  else '000000' end ) as abap.char( 6 ) )      as beguz,
//  cast( ( case when  t2.enduz  is not null then t2.enduz  else '000000' end ) as abap.char( 6 ) )      as enduz,
//
//  ////  t2.beguz,
//  ////  t2.enduz,
//  t2.retdt,
//  t2.kaltg,
//  t2.stdaz,
//  t2.abwtg,
//  t2.abrtg,
//  t2.abrst,
//  t2.zdesc,
//
//  t3.seqnr,
//  t3.aptyp,
//  APTYPE.ddtext                                                                                        as ap_aptyp_t,
//  apr.pernr                                                                                            as ap_pernr,
//  apr.ename                                                                                            as ap_ename,
//  t3.plans                                                                                             as ap_plans,
//  apr_plans.stext                                                                                      as ap_plans_t,
//  t3.orgsvy                                                                                            as ap_orgsvy,
//  orgsv.ddtext                                                                                         as ap_orgsvy_t,
//
//  t1.statu,
//  statu.ddtext                                                                                         as statu_t,
//
//  t3.statu                                                                                             as ap_Statu,
//  ap_statu.ddtext                                                                                      as ap_statu_t,
//  t3.ap_zdesc,
//
//  //  talebi oluşturan sicil verileri)
//  t1.unamecre                                                                                          as crt_pernr,
//  crt_pernr.ename                                                                                      as crt_ename,
//  t1.datumcre                                                                                          as crt_datum,
//  cast( ( case when  t1.uzeitcre  is not null then t1.uzeitcre else '000000' end ) as abap.char( 6 ) ) as crt_uzeit,
//
//  //  DEğiştiren(Onaylayan sicil verileri)
//  t3.unamechn                                                                                          as chn_pernr,
//  chn_pernr.ename                                                                                      as chn_ename,
//  t3.datumchn                                                                                          as chn_datum,
//
//  cast( ( case when  t3.uzeitchn  is not null then t3.uzeitchn else '000000' end ) as abap.char( 6 ) ) as chn_uzeit,
//  t3.admin
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
////
