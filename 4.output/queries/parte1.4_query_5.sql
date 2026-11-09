-- HUECO DE DATOS: UGEL x actividad con CERO interacciones (ni de familias ni de docentes)
with x as (
    select 
        ins.ugel, 
        i.actividad_id,
        count(*) as n
    from interacciones i
    inner join participantes p   on (p.participante_id  = i.participante_id)
    inner join grupos g          on (g.grupo_id         = p.grupo_id)
    inner join instituciones ins on (ins.institucion_id = g.institucion_id)
    group by ins.ugel, i.actividad_id
)
select 
    u.ugel, 
    a.actividad_id, 
    a.fecha_envio_utc, 
    a.semana, 
    coalesce(x.n, 0) as interacciones
from (select distinct ugel from instituciones) u
cross join actividades a
left join x on (x.ugel = u.ugel and x.actividad_id = a.actividad_id)
where coalesce(x.n, 0) = 0;
go

