-- Consulta SQL para calcular los 5 grupos con mayor caída de participación
with tasa_grupo_semana as (
  select 
    grupo_id, 
    semana,
    cast(100.0 * sum(participo) / count(*) as float) as tasa,   
    count(*) as n_familias
  from aux_base
  group by grupo_id, semana
),
resumen as (
  select 
    grupo_id,
    avg(case when semana between 1 and 4 then tasa end) as prom_s1_4,
    avg(case when semana between 5 and 6 then tasa end) as prom_s5_6,
    max(n_familias) as familias_s6
  from tasa_grupo_semana
  group by grupo_id
)
select top (5)
       r.grupo_id as grupo, 
       i.ugel,
       cast(round(r.prom_s1_4, 1) as decimal(5,1)) as prom_s1_4,
       cast(round(r.prom_s5_6, 1) as decimal(5,1)) as prom_s5_6,
       cast(round(r.prom_s1_4 - r.prom_s5_6, 1) as decimal(5,1)) as caida_pp,
       r.familias_s6
from resumen r
inner join grupos g        on (g.grupo_id       = r.grupo_id)
inner join instituciones i on (i.institucion_id = g.institucion_id)
order by (r.prom_s1_4 - r.prom_s5_6) desc, r.grupo_id;
go