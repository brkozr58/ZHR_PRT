@AbapCatalog.sqlViewName: 'ZHR_PRT_DDL005'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'İzin türleri (Kota türü ve saatlik kontolü)'
@Metadata.ignorePropagatedAnnotations: true
define view ZHR_PRT_CDS005
  with parameters
    p_pernr : abap.numc( 8 )
  as select from    pa0001 as p1

    inner join      t001                on t001.bukrs = p1.bukrs
    inner join      t001p  as per_t001p on  per_t001p.werks = p1.werks
                                        and per_t001p.btrtl = p1.btrtl
    inner join      t554s  as t554s     on t554s.moabw = per_t001p.moabw
    inner join      t500p               on t500p.persa = per_t001p.werks
    left outer join t556c               on  t556c.mozko = t554s.moabw
                                        and t556c.crule = t554s.crule
    left outer join t556r               on  t556r.mozko = t554s.moabw
                                        and t556r.qtype = 'A'
                                        and t556r.mopgk = t556c.mopgk
                                        and t556r.dedrg = t556c.deabp
                                        and t556r.endda >= $session.system_date
    left outer join t554t  as per_awart on  per_awart.moabw = t554s.moabw
                                        and per_awart.awart = t554s.subty
                                        and per_awart.sprsl = $session.system_language
    left outer join t556b  as t556b     on  t556b.mopgk = t556c.mopgk
                                        and t556b.mozko = t556c.mozko
                                        and t556b.ktart = t556r.qttps
                                        and t556b.sprsl = $session.system_language
{

  key case t554s.dedqu      when     'X'  then t556r.qttps
                                else ' ' end                    as qttps,
  key per_awart.awart,
      t556b.ktext                                               as ktart_t,
      per_awart.atext                                           as awart_t,
      t554s.mintg                                               as mintg,
      t554s.maxtg                                               as maxtg,

      cast( ( case when( ( t554s.mintg  = 000 and t554s.maxtg = 999 ) or
                         ( t554s.mintg  = 000 and t554s.maxtg = 001 )   )
                   then 'X'  else ' ' end ) as abap.char( 1 ) ) as zhour

}

where
      p1.pernr    = $parameters.p_pernr
  and p1.endda    >= $session.system_date
  and t554s.endda >= $session.system_date



group by
  t554s.dedqu,
  t556r.qttps,
  t556b.ktext,
  per_awart.awart,
  per_awart.atext,
  t554s.mintg,
  t554s.maxtg




//
