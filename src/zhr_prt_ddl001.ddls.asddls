@AbapCatalog.sqlViewName: 'ZHR_PRT_DDL001'
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Portal Kullanıcıları Personel Verileri'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view ZHR_PRT_CDS001
  as select from    pa0001       as t1
  //
    inner join      pa0000       as t0   on  t0.pernr =  t1.pernr
                                         and t0.begda <= t1.endda
                                         and t0.endda >= t1.begda
  //
    inner join      pa0002       as p2   on  p2.pernr =  t1.pernr
                                         and p2.begda <= t1.endda
                                         and p2.endda >= t1.begda
  //
    inner join      pa0105       as t2   on  t2.pernr = t1.pernr
                                         and t2.subty = 'ECUS'
                                         and t2.begda <= $session.system_date
                                         and t2.endda >= $session.system_date
  //
    left outer join zhr_prt_t001 as zt1  on  zt1.pernr =  t1.pernr
                                         and zt1.activ =  activ
                                         and zt1.begda <= t1.endda
                                         and zt1.begda >= t1.begda
  //
    left outer join pa0105       as cell on  cell.pernr = t1.pernr
                                         and cell.subty = 'CELL'
                                         and cell.begda <= $session.system_date
                                         and cell.endda >= $session.system_date

  //
    left outer join pa0105       as mail on  mail.pernr = t1.pernr
                                         and (
                                            mail.subty  = '0010'
                                          )
    //                                         and ( mail.subty = '0010' or mail.subty = 'MAIL' )
                                         and mail.begda <= $session.system_date
                                         and mail.endda >= $session.system_date
{
      //

  key t1.pernr,
      p2.vorna,
      p2.nachn,
      //      t1.ename,
      t1.begda,
      t1.endda,
      t0.stat2,
      @EndUserText.label: 'İstihdam durumu'
      cast( ( case ( t0.stat2 ) when '0' then 'İşten ayrıldı'
                                when '1' then 'Çalışmıyor'
                                when '2' then 'Emekliler'
                                when '3' then 'Etkin'
                                else 'Bilinmiyor!' end ) as abap.char( 40  ) ) as stat2_t,

      @EndUserText.label: 'SF Kullanıcı Bilgisi'
      cast( ( t2.usrid_long) as abap.char( 30  ) )                             as ECUS,

      @EndUserText.label: 'Çalışma durumu'
      cast( ( case ( t0.stat2 )
                                when '2' then 'A'
                                when '3' then 'A'
                                else 'P' end ) as abap.char( 1  ) )            as ACTIV,

      @EndUserText.label: 'Durum'
      cast( ( case ( t0.stat2 )
                                when '2' then 'Aktif'
                                when '3' then 'Aktif'
                                else 'Pasif' end ) as abap.char( 10  ) )       as ACTIV_t,

      @EndUserText.label: 'Telefon numarası'
      cell.usrid                                                               as cell,

      @EndUserText.label: 'Email'
      mail.usrid_long                                                          as zemail,

      t0.aedtm,

      @EndUserText.label: 'SMS kodu'
      zt1.smscd,

      cast( ( case  when zt1.pernr is not initial  then 'X'
                                else '' end ) as abap.char( 1  ) )             as zoper
} 
 
union all select from pa0001       as t1
//
  inner join          pa0000       as t0   on  t0.pernr =  t1.pernr
                                           and t0.begda <= t1.endda
                                           and t0.endda >= t1.begda
//
  inner join          pa0002       as p2   on  p2.pernr =  t1.pernr
                                           and p2.begda <= t1.endda
                                           and p2.endda >= t1.begda
//
  inner join          pa0105       as t2   on  t2.pernr = t1.pernr
                                           and t2.subty = 'ECUS'
                                           and t2.begda <= $session.system_date
                                           and t2.endda >= $session.system_date
//
  left outer join     zhr_prt_t001 as zt1  on  zt1.pernr =  t1.pernr
                                           and zt1.activ =  activ
                                           and zt1.begda <= t1.endda
                                           and zt1.begda >= t1.begda
//
  left outer join     pa0105       as cell on  cell.pernr = t1.pernr
                                           and cell.subty = 'CELL'
                                           and cell.begda <= $session.system_date
                                           and cell.endda >= $session.system_date

//
  left outer join     pa0105       as mail on  mail.pernr = t1.pernr
                                           and (
                                              mail.subty  = 'MAIL'
                                            )
                                           and mail.begda <= $session.system_date
                                           and mail.endda >= $session.system_date
{
      //

  key t1.pernr,
      p2.vorna,
      p2.nachn,
      //      t1.ename,
      t1.begda,
      t1.endda,
      t0.stat2,
      @EndUserText.label: 'İstihdam durumu'
      cast( ( case ( t0.stat2 ) when '0' then 'İşten ayrıldı'
                                when '1' then 'Çalışmıyor'
                                when '2' then 'Emekliler'
                                when '3' then 'Etkin'
                                else 'Bilinmiyor!' end ) as abap.char( 40  ) ) as stat2_t,

      @EndUserText.label: 'SF Kullanıcı Bilgisi'
      cast( ( t2.usrid_long) as abap.char( 30  ) )                             as ECUS,

      @EndUserText.label: 'Çalışma durumu'
      cast( ( case ( t0.stat2 )
                                when '2' then 'A'
                                when '3' then 'A'
                                else 'P' end ) as abap.char( 1  ) )            as ACTIV,

      @EndUserText.label: 'Durum'
      cast( ( case ( t0.stat2 )
                                when '2' then 'Aktif'
                                when '3' then 'Aktif'
                                else 'Pasif' end ) as abap.char( 10  ) )       as ACTIV_t,

      @EndUserText.label: 'Telefon numarası'
      cell.usrid                                                               as cell,

      @EndUserText.label: 'Email'
      mail.usrid_long                                                          as zemail,

      t0.aedtm,

      @EndUserText.label: 'SMS kodu'
      zt1.smscd,

      cast( ( case  when zt1.pernr is not initial  then 'X'
                                else '' end ) as abap.char( 1  ) )             as zoper
} where t1.pernr <> t1.pernr
