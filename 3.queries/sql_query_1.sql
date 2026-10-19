/*==================================================================================================
  Description of the SQL query
  
                                       " Caso Práctico "
  
           .--.                  
          |o_o |         
          |:_/ |           ---------------------------------------------------
         //   \ \                  Monitoreo de Participación Semanal 
        (|     | )         ---------------------------------------------------        
        /'\_   _/`\   
        \___)=(___/
    
  Outline
    1.- Keyboard shortcuts
    2.- Create or use a table
    3.- Create the tables in the "monitoring" database
    4.- Import the data files in .csv format
    5.- Verify the rows entered in each table

                                         Jhon R. Ordoñez
                                    (rolyordonezleon@gmail.com)
                                                                                            ><(((º>
==================================================================================================*/


-- 1.- Keyboard shortcuts
    -- Ctrl + s: save
    -- Ctrl + e or F5: execute the code (Remember to select the code that is to be executed)
    -- Select the code --> right-click --> Execute: execute the code (I like this option better)
    -- ...

-- 2.- Create the database named "monitoreo"
    if db_id('monitoring') is null create database monitoring;
    go

-- 3.- Create the tables in the "monitoring" database
    use monitoring;
    go
    
    drop table if exists instituciones;
    go

    create table instituciones (
        institucion_id varchar(10) not null, 
        ugel varchar(10) not null, 
        zona varchar(10) null,
        constraint PK_instituciones primary key (institucion_id)
    );

    drop table if exists grupos;
    go

    create table grupos (
        grupo_id varchar(10) not null,
        institucion_id varchar(10) not null,
        edad int null, 
        docente_id varchar(10) null,
        constraint PK_grupos primary key (grupo_id)
    );

    drop table if exists participantes;
    go

    create table participantes  (
        participante_id varchar(10) not null, 
        grupo_id varchar(10) not null, 
        rol varchar(10) not null,
        telefono_hash varchar(10) not null,
        fecha_alta date not null,
        constraint PK_participantes primary key (participante_id)
    );

    drop table if exists actividades;
    go

    create table actividades (
        actividad_id varchar(10) not null,
        fecha_envio_utc datetime2(0) not null,
        area nvarchar(50) null, 
        semana int not null,
        constraint PK_actividades primary key (actividad_id)
    );

    drop table if exists interacciones;
    go

    create table interacciones (
        interaccion_id varchar(10) not null,
        participante_id varchar(10) not null,
        actividad_id varchar(10) not null,
        fecha_hora_utc datetime2(0) not null,
        tipo varchar(20) not null,
        constraint PK_interacciones primary key (interaccion_id)
    );
    go

    select * from instituciones;
    select * from grupos;
    select * from participantes;
    select * from interacciones;
    select * from actividades;
    go

-- 4.- Import the data files in .csv format
    bulk insert instituciones from '... colocar la ruta hasta la carpeta de datos ...\instituciones.csv' with (format = 'csv', firstrow = 2, codepage = '65001', rowterminator = '0x0a', fieldterminator = ',', tablock);
    bulk insert grupos        from '... colocar la ruta hasta la carpeta de datos ...\grupos.csv'        with (format = 'csv', firstrow = 2, codepage = '65001', rowterminator = '0x0a', fieldterminator = ',', tablock);
    bulk insert participantes from '... colocar la ruta hasta la carpeta de datos ...\participantes.csv' with (format = 'csv', firstrow = 2, codepage = '65001', rowterminator = '0x0a', fieldterminator = ',', tablock);
    bulk insert actividades   from '... colocar la ruta hasta la carpeta de datos ...\actividades.csv'   with (format = 'csv', firstrow = 2, codepage = '65001', rowterminator = '0x0a', fieldterminator = ',', tablock);
    bulk insert interacciones from '... colocar la ruta hasta la carpeta de datos ...\interacciones.csv' with (format = 'csv', firstrow = 2, codepage = '65001', rowterminator = '0x0a', fieldterminator = ',', tablock);
    go

    select * from instituciones;
    select * from grupos;
    select * from participantes;
    select * from interacciones;
    select * from actividades;
    go

-- 5.- Verify the rows entered in each table
    select 'instituciones' as tabla,  count(*) as filas 
    from instituciones
    union all select 'grupos',        count(*) from grupos
    union all select 'participantes', count(*) from participantes
    union all select 'actividades',   count(*) from actividades
    union all select 'interacciones', count(*) from interacciones;
    go

-- 6.- Construction of the database diagram
    
    -- instituciones ---> grupos ---> participantes --X-> interacciones ---> actividades
    -- consultas para detectar el problema entre la tabla "participantes" y "interacciones"
    select * from participantes;
    go

    select * from interacciones
    order by participante_id desc;
    go

    -- Fijate que el identificador del participante "participante_id" como máximo es "P01101"
    -- Ahora si observa el campo "participante_id" en la tabla de interaccion 
    -- este tiene "participante_id" como "P90285 a P99955"
    -- si se contabiliza estos son 40 filas (40 identificadores)


    -- Hipótesis: Podrían deberse a que faltan participantes en el archivo original.


