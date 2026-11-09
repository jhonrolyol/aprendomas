-- Consulta SQL para generar la tabla "aux_base"
select 
    s.semana, 
    f.persona_id, 
    f.grupo_id, 
    f.ugel,
    case 
        when e.persona_id is not null then 1 
        else 0
    end as participo
into aux_base
from aux_semanas s
inner join aux_familias f  on (f.fecha_alta <= s.fin_semana)
left join aux_evidencias e on (e.persona_id = f.persona_id and e.semana = s.semana);
go
