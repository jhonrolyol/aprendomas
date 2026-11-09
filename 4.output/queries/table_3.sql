-- Consulta SQL para generar la tabla "aux_evidencias"
select 
    distinct p.telefono_hash as persona_id, 
    a.semana
into aux_evidencias
from interacciones i
inner join participantes p on (p.participante_id = i.participante_id and p.rol = 'familia')
inner join actividades a   on (a.actividad_id    = i.actividad_id)
where lower(ltrim(rtrim(i.tipo))) in ('foto','imagen','audio','video');
go
