-- Personas con más de un participante_id (mismo telefono_hash, mismo grupo)
select 
    'Persona duplicada (mismo telefono_hash)' as control,
    count(*) as filas_afectadas,
    count(distinct telefono_hash) as personas_afectadas,
    count(*) - count(distinct telefono_hash) as registros_sobrantes
from participantes
where telefono_hash in (select telefono_hash from participantes group by telefono_hash having count(*) > 1);
go
