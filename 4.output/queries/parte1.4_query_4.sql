-- Respuesta con fecha ANTERIOR al envío de la actividad (cronología imposible), comparada en hora de Lima.
-- Tratamiento elegido: se CONSERVAN (la actividad_id define la semana) y se cuantifica el efecto de excluirlas.
select
    'Respuesta antes del envío' as control, 
    count(*) as filas_afectadas,
    sum(case when lower(ltrim(rtrim(i.tipo))) in ('foto','imagen','audio','video') then 1 else 0 end) as con_evidencia,
    cast(min(datediff(minute, a.fecha_envio_utc, i.fecha_hora_utc)) / 60.0 as decimal(6,1)) as max_horas_antes
from interacciones i
inner join actividades a on (a.actividad_id = i.actividad_id)
where dateadd(hour, -5, i.fecha_hora_utc) < dateadd(hour, -5, a.fecha_envio_utc);
go
