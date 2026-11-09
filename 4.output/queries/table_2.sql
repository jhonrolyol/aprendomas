-- Consulta SQL para generar la tabla "aux_familias"
select 
    p.telefono_hash   as persona_id,
    min(p.fecha_alta) as fecha_alta,
    min(p.grupo_id)   as grupo_id,   
    min(i.ugel)       as ugel
into aux_familias
from participantes p
inner join grupos g        on (g.grupo_id       = p.grupo_id)
inner join instituciones i on (i.institucion_id = g.institucion_id)
where p.rol = 'familia'
group by p.telefono_hash;
go
