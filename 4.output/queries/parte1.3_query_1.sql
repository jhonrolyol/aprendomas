-- Consulta SQL que calcula familias que dejan de participar "aux_dejan"
with hist as (
  select 
    persona_id,
    count(distinct case when semana between 1 and 4 then semana end) as sem_1_4,
    count(distinct case when semana between 5 and 6 then semana end) as sem_5_6
  from aux_evidencias
  group by persona_id
)
select 
    f.persona_id, 
    f.grupo_id, 
    f.ugel
into aux_dejan
from aux_familias f
inner join hist h on (h.persona_id = f.persona_id)
where (h.sem_1_4 >= 2 and h.sem_5_6 = 0);
go

-- Total de familias que dejan de participar
select 
    count(*) as familias_que_dejan_de_participar 
from aux_dejan;
go

-- Concentración por grupo
with por_grupo as (
  select 
    d.grupo_id, 
    d.ugel, 
    count(*) as n_dejan,
    (select count(*) from aux_familias f where f.grupo_id = d.grupo_id) as familias_grupo
  from aux_dejan d
  group by d.grupo_id, d.ugel
)
select 
    grupo_id as grupo,
    ugel, 
    n_dejan,
    familias_grupo, 
    cast(round(100.0 * n_dejan / familias_grupo, 1) as decimal(5,1)) as pct_del_grupo,
    cast(round(100.0 * sum(n_dejan) over (order by n_dejan desc, grupo_id rows unbounded preceding) / sum(n_dejan) over (), 1) as decimal(5,1)) as pct_acum_del_total
from por_grupo
order by n_dejan desc, grupo_id;
go

