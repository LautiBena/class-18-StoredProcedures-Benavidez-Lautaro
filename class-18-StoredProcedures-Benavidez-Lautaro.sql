-- ejersicio 1

delimiter $$

create function copias_pelicula(
    p_film_id int,
    p_store_id int
)
returns int
not deterministic
begin
    declare total int default 0;

    select count(*) into total
    from inventory
    where film_id = p_film_id
      and store_id = p_store_id;

    return total + 1;
end $$

delimiter ;


select copias_pelicula(1, 1) as cantidad_copias;

-- ejercicio 2


delimiter $$

create procedure clientes_por_pais(
    in p_pais varchar(50),
    out lista_clientes text
)
begin
    declare terminado int default 0;
    declare nombre_cliente varchar(101);

    declare cursor_clientes cursor for
        select concat(c.first_name, ' ', c.last_name)
        from customer c
        join address a on c.address_id = a.address_id
        join city ci on a.city_id = ci.city_id
        join country co on ci.country_id = co.country_id
        where co.country = p_pais;

    declare continue handler for not found set terminado = 1;

    set lista_clientes = '';

    open cursor_clientes;

    recorrer_clientes: loop
        fetch cursor_clientes into nombre_cliente;

        if terminado = 1 then
            leave recorrer_clientes;
        end if;

        if lista_clientes = '' then
            set lista_clientes = nombre_cliente;
        else
            set lista_clientes = concat(lista_clientes, ';', nombre_cliente);
        end if;
    end loop recorrer_clientes;

    close cursor_clientes;
end $$

delimiter ;

call clientes_por_pais('argentina', @lista);
select @lista as clientes_argentina;

call clientes_por_pais('canada', @lista);
select @lista as clientes_canada;


use sakila;

-- ejercicio 3

show create function inventory_in_stock;

-- esta funcion resive el id de una copia de una pelicula primero cuenta cuantas veses fue alquilada
-- si nunca fue alquilada devuelve true, si fue alquilada revisa si tiene alguna devolucion pendiente
-- si todavia no fue devuelta devuelve false
-- si esta disponible devuelve true

-- ejemplo de uso
select inventory_in_stock(8) as disponible;

select inventory_in_stock(9) as disponible;

-- devuelve 1 si esta disponible y 0 si no lo esta


-- prosedimiento film_in_stock

show create procedure film_in_stock;

-- resive el id de una pelicula y el id de una tienda busca las copias que pertenesen a esa pelicula y tiende usa la funcion inventory_in_stock para verificar
-- cuales estan disponibles
-- despues guarda la cantidad de copias disponibles
-- en el parametro de salida p_film_count

-- ejemplos de uso
call film_in_stock(1, 1, @cantidad);

select @cantidad as copias_disponibles;

call film_in_stock(2, 2, @cantidad);

select @cantidad as copias_disponibles;

