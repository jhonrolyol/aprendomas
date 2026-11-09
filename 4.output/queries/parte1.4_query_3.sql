-- Interacciones duplicadas exactas (mismo participante, actividad, instante y tipo; distinto interaccion_id)
-- El tipo se compara por bytes para no fusionar 'Foto' con 'foto'.
select 
    'Interacción duplicada exacta' as control, 
    coalesce(sum(d.n - 1), 0) as filas_sobrantes, 
    count(*) as grupos_duplicados
from (select 
        count(*) as n
       from interacciones
       group by participante_id, actividad_id, fecha_hora_utc, convert(varbinary(20), tipo)
       having count(*) > 1) as d; 
go

with x as (
    select i.*,
        count(*)     over (partition by participante_id, actividad_id, fecha_hora_utc, convert(varbinary(20), tipo)) as copias,
        row_number() over (partition by participante_id, actividad_id, fecha_hora_utc, convert(varbinary(20), tipo)
        order by interaccion_id) as nro_copia
        from dbo.interacciones i
)
select *
from x
where copias > 1
order by participante_id, actividad_id, fecha_hora_utc, nro_copia;
go

 