@AbapCatalog.sqlViewName: 'ZHR_PRT_DDL003'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Personel İzin verileri 2001'
@Metadata.ignorePropagatedAnnotations: true
define view ZHR_PRT_cds003

  as select from    pa2001  as t2
    inner join      pa0001  as per       on  per.pernr = t2.pernr
                                         and per.begda <= $session.system_date
                                         and per.endda >= $session.system_date

    inner join      hrp1000 as per_plans on  per_plans.otype = 'S'
                                         and per_plans.plvar = '01'
                                         and per_plans.objid = per.plans
                                         and per_plans.langu = $session.system_language
                                         and per_plans.begda <= $session.system_date
                                         and per_plans.endda >= $session.system_date

    inner join      hrp1000 as per_orgeh on  per_orgeh.otype = 'O'
                                         and per_orgeh.plvar = '01'
                                         and per_orgeh.objid = per.orgeh
                                         and per_orgeh.langu = $session.system_language
                                         and per_orgeh.begda <= $session.system_date
                                         and per_orgeh.endda >= $session.system_date

    inner join      t001p   as per_t001p on  per_t001p.werks = per.werks
                                         and per_t001p.btrtl = per.btrtl
    inner join      t554t   as per_awart on  per_awart.moabw = per_t001p.moabw
                                         and per_awart.awart = t2.awart
                                         and per_awart.sprsl = $session.system_language

    left outer join pa0105  as apr_sapu  on  apr_sapu.subty = 'SAPU'
                                         and apr_sapu.usrid = t2.uname
                                         and apr_sapu.endda >= $session.system_date
    left outer join pa0001  as apr       on  apr.pernr = apr_sapu.pernr
                                         and apr.begda <= $session.system_date
                                         and apr.endda >= $session.system_date

    left outer join hrp1000 as apr_plans on  apr_plans.otype = 'S'
                                         and apr_plans.plvar = '01'
                                         and apr_plans.objid = apr.plans
                                         and apr_plans.langu = $session.system_language
                                         and apr_plans.begda <= $session.system_date
                                         and apr_plans.endda >= $session.system_date

{
  key          cast( ( '00001'  ) as abap.numc( 5 ) )                                                          as SRCID,
  key          cast( ( '9999999999'  ) as abap.numc( 10 ) )                                                    as TLPID,
  key          t2.pernr,
  key          per.ename,

  key          t2.awart,
  key          per_awart.atext                                                                                 as awart_t,
  key          t2.begda,
  key          t2.endda,

               per.plans,
               per_plans.stext                                                                                 as plans_t,
               per.orgeh,
               per_orgeh.stext                                                                                 as orgeh_t,
               per.sachz,

               cast( ( case when  t2.beguz  is not null then t2.beguz  else '000000' end ) as abap.char( 6 ) ) as beguz,
               cast( ( case when  t2.enduz  is not null then t2.enduz  else '000000' end ) as abap.char( 6 ) ) as enduz,

               t2.kaltg,
               t2.stdaz,
               t2.abwtg,
               t2.abrtg,
               t2.abrst,

               //  t3.seqnr,
               cast( ( '001'  ) as abap.numc( 3 ) )                                                            as seqnr,
               apr.pernr                                                                                       as ap_pernr,
               apr.ename                                                                                       as ap_ename,
               apr.plans                                                                                       as ap_plans,
               apr_plans.stext                                                                                 as ap_plans_t,
               cast( ( '04'  ) as abap.numc( 2 ) )                                                             as statu,
               cast( ( '02'  ) as abap.numc( 2 ) )                                                             as ap_statu,

               ////  bu alanlar hep boş gelecek
               cast( ( ''  ) as abap.dats( 8 ) )                                                               as RETDT,
               cast( ( ''  ) as abap.char( 200 ) )                                                             as ZDESC,
               cast( ( ''  ) as abap.char( 5 ) )                                                               as APTYP,
               cast( ( ''  ) as abap.char( 60 ) )                                                              as AP_APTYP_T,
               cast( ( ''  ) as abap.char( 2 ) )                                                               as AP_ORGSVY,
               cast( ( ''  ) as abap.char( 60 ) )                                                              as AP_ORGSVY_T,
               cast( ( ''  ) as abap.numc( 60 ) )                                                              as STATU_T,
               cast( ( ''  ) as abap.char( 60 ) )                                                              as AP_STATU_T,
               cast( ( ''  ) as abap.char( 200 ) )                                                             as AP_ZDESC,
               cast( ( ''  ) as abap.char( 12 ) )                                                              as CRT_PERNR,
               cast( ( ''  ) as abap.char( 40 ) )                                                              as CRT_ENAME,
               cast( ( ''  ) as abap.dats( 8 ) )                                                               as CRT_DATUM,
               cast( ( ''  ) as abap.char( 6 ) )                                                               as CRT_UZEIT,
               cast( ( ''  ) as abap.char( 12 ) )                                                              as CHN_PERNR,
               cast( ( ''  ) as abap.char( 40 ) )                                                              as CHN_ENAME,
               cast( ( ''  ) as abap.dats( 8 ) )                                                               as CHN_DATUM,
               cast( ( ''  ) as abap.char( 6 ) )                                                               as CHN_UZEIT,
               cast( ( ''  ) as abap.char( 1 ) )                                                               as ADMIN


}
