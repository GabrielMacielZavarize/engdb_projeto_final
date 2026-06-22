select *
from (
    values
        ('addresses', (select count(*)::bigint from source.addresses)),
        ('categories', (select count(*)::bigint from source.categories)),
        ('customers', (select count(*)::bigint from source.customers)),
        ('order_items', (select count(*)::bigint from source.order_items)),
        ('orders', (select count(*)::bigint from source.orders)),
        ('payments', (select count(*)::bigint from source.payments)),
        ('products', (select count(*)::bigint from source.products)),
        ('reviews', (select count(*)::bigint from source.reviews)),
        ('sellers', (select count(*)::bigint from source.sellers)),
        ('shipments', (select count(*)::bigint from source.shipments))
) as counts(table_name, loaded_rows)
order by table_name;

select *
from (
    values
        (
            'addresses_invalid_control_timestamps',
            (
                select count(*)::bigint
                from source.addresses
                where created_at is null
                   or updated_at is null
                   or updated_at < created_at
            )
        ),
        (
            'categories_invalid_control_timestamps',
            (
                select count(*)::bigint
                from source.categories
                where created_at is null
                   or updated_at is null
                   or updated_at < created_at
            )
        ),
        (
            'customers_invalid_control_timestamps',
            (
                select count(*)::bigint
                from source.customers
                where created_at is null
                   or updated_at is null
                   or updated_at < created_at
            )
        ),
        (
            'order_items_invalid_control_timestamps',
            (
                select count(*)::bigint
                from source.order_items
                where created_at is null
                   or updated_at is null
                   or updated_at < created_at
            )
        ),
        (
            'orders_invalid_control_timestamps',
            (
                select count(*)::bigint
                from source.orders
                where created_at is null
                   or updated_at is null
                   or updated_at < created_at
            )
        ),
        (
            'payments_invalid_control_timestamps',
            (
                select count(*)::bigint
                from source.payments
                where created_at is null
                   or updated_at is null
                   or updated_at < created_at
            )
        ),
        (
            'products_invalid_control_timestamps',
            (
                select count(*)::bigint
                from source.products
                where created_at is null
                   or updated_at is null
                   or updated_at < created_at
            )
        ),
        (
            'reviews_invalid_control_timestamps',
            (
                select count(*)::bigint
                from source.reviews
                where created_at is null
                   or updated_at is null
                   or updated_at < created_at
            )
        ),
        (
            'sellers_invalid_control_timestamps',
            (
                select count(*)::bigint
                from source.sellers
                where created_at is null
                   or updated_at is null
                   or updated_at < created_at
            )
        ),
        (
            'shipments_invalid_control_timestamps',
            (
                select count(*)::bigint
                from source.shipments
                where created_at is null
                   or updated_at is null
                   or updated_at < created_at
            )
        )
) as checks(check_name, offending_rows)
order by check_name;

do $$
declare
    table_name text;
    offending_rows bigint;
begin
    foreach table_name in array array[
        'addresses',
        'categories',
        'customers',
        'order_items',
        'orders',
        'payments',
        'products',
        'reviews',
        'sellers',
        'shipments'
    ] loop
        execute format(
            'select count(*)::bigint
             from source.%I
             where created_at is null
                or updated_at is null
                or updated_at < created_at',
            table_name
        )
        into offending_rows;

        if offending_rows > 0 then
            raise exception
                'Validation failed: table source.% has % invalid control timestamp rows.',
                table_name,
                offending_rows;
        end if;
    end loop;
end;
$$;

select *
from (
    values
        (
            'addresses_without_customer',
            (
                select count(*)::bigint
                from source.addresses a
                left join source.customers c
                    on c.customer_id = a.customer_id
                where c.customer_id is null
            )
        ),
        (
            'orders_without_customer',
            (
                select count(*)::bigint
                from source.orders o
                left join source.customers c
                    on c.customer_id = o.customer_id
                where c.customer_id is null
            )
        ),
        (
            'payments_without_order',
            (
                select count(*)::bigint
                from source.payments p
                left join source.orders o
                    on o.order_id = p.order_id
                where o.order_id is null
            )
        ),
        (
            'reviews_without_order',
            (
                select count(*)::bigint
                from source.reviews r
                left join source.orders o
                    on o.order_id = r.order_id
                where o.order_id is null
            )
        ),
        (
            'shipments_without_order',
            (
                select count(*)::bigint
                from source.shipments s
                left join source.orders o
                    on o.order_id = s.order_id
                where o.order_id is null
            )
        ),
        (
            'products_with_unknown_category',
            (
                select count(*)::bigint
                from source.products p
                left join source.categories c
                    on c.category_id = p.category_id
                where p.category_id is not null
                  and c.category_id is null
            )
        ),
        (
            'order_items_without_order',
            (
                select count(*)::bigint
                from source.order_items oi
                left join source.orders o
                    on o.order_id = oi.order_id
                where o.order_id is null
            )
        ),
        (
            'order_items_without_product',
            (
                select count(*)::bigint
                from source.order_items oi
                left join source.products p
                    on p.product_id = oi.product_id
                where p.product_id is null
            )
        ),
        (
            'order_items_without_seller',
            (
                select count(*)::bigint
                from source.order_items oi
                left join source.sellers s
                    on s.seller_id = oi.seller_id
                where s.seller_id is null
            )
        ),
        (
            'duplicate_reviews_per_order',
            (
                select count(*)::bigint
                from (
                    select order_id
                    from source.reviews
                    group by order_id
                    having count(*) > 1
                ) duplicates
            )
        ),
        (
            'duplicate_shipments_per_order',
            (
                select count(*)::bigint
                from (
                    select order_id
                    from source.shipments
                    group by order_id
                    having count(*) > 1
                ) duplicates
            )
        ),
        (
            'duplicate_payment_sequence_per_order',
            (
                select count(*)::bigint
                from (
                    select order_id, payment_sequential
                    from source.payments
                    group by order_id, payment_sequential
                    having count(*) > 1
                ) duplicates
            )
        ),
        (
            'duplicate_order_item_position_per_order',
            (
                select count(*)::bigint
                from (
                    select order_id, order_item_id
                    from source.order_items
                    group by order_id, order_item_id
                    having count(*) > 1
                ) duplicates
            )
        )
) as checks(check_name, offending_rows)
order by check_name;

do $$
begin
    if exists (
        select 1
        from (
            select count(*)::bigint as offending_rows
            from source.addresses a
            left join source.customers c
                on c.customer_id = a.customer_id
            where c.customer_id is null

            union all

            select count(*)::bigint
            from source.orders o
            left join source.customers c
                on c.customer_id = o.customer_id
            where c.customer_id is null

            union all

            select count(*)::bigint
            from source.payments p
            left join source.orders o
                on o.order_id = p.order_id
            where o.order_id is null

            union all

            select count(*)::bigint
            from source.reviews r
            left join source.orders o
                on o.order_id = r.order_id
            where o.order_id is null

            union all

            select count(*)::bigint
            from source.shipments s
            left join source.orders o
                on o.order_id = s.order_id
            where o.order_id is null

            union all

            select count(*)::bigint
            from source.products p
            left join source.categories c
                on c.category_id = p.category_id
            where p.category_id is not null
              and c.category_id is null

            union all

            select count(*)::bigint
            from source.order_items oi
            left join source.orders o
                on o.order_id = oi.order_id
            where o.order_id is null

            union all

            select count(*)::bigint
            from source.order_items oi
            left join source.products p
                on p.product_id = oi.product_id
            where p.product_id is null

            union all

            select count(*)::bigint
            from source.order_items oi
            left join source.sellers s
                on s.seller_id = oi.seller_id
            where s.seller_id is null

            union all

            select count(*)::bigint
            from (
                select order_id
                from source.reviews
                group by order_id
                having count(*) > 1
            ) duplicates

            union all

            select count(*)::bigint
            from (
                select order_id
                from source.shipments
                group by order_id
                having count(*) > 1
            ) duplicates

            union all

            select count(*)::bigint
            from (
                select order_id, payment_sequential
                from source.payments
                group by order_id, payment_sequential
                having count(*) > 1
            ) duplicates

            union all

            select count(*)::bigint
            from (
                select order_id, order_item_id
                from source.order_items
                group by order_id, order_item_id
                having count(*) > 1
            ) duplicates
        ) validation
        where validation.offending_rows > 0
    ) then
        raise exception
            'Validation failed: one or more referential or cardinality checks returned rows.';
    end if;
end;
$$;
