-- Consulta SQL para calcular la tasa de participación semanal por UGEL y en total, para las 6 semanas
select 
    semana as Semana,
    cast(round(100.0 * sum(case when ugel = 'UGEL A' then participo end) / sum(case when ugel = 'UGEL A' then 1 end), 1) as decimal(5,1)) as [UGEL A],
    cast(round(100.0 * sum(case when ugel = 'UGEL B' then participo end) / sum(case when ugel = 'UGEL B' then 1 end), 1) as decimal(5,1)) as [UGEL B],
    cast(round(100.0 * sum(case when ugel = 'UGEL C' then participo end) / sum(case when ugel = 'UGEL C' then 1 end), 1) as decimal(5,1)) as [UGEL C],
    cast(round(100.0 * sum(participo) / count(*), 1) as decimal(5,1)) as Total
from aux_base
group by semana
order by semana;   
go
