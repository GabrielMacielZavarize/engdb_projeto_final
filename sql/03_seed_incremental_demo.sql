begin;

do $$
declare
    baseline_ts constant timestamp without time zone := timestamp '2026-01-01 00:00:00';
    change_ts constant timestamp without time zone := timestamp '2026-01-02 00:00:00';
    demo_category_id constant integer := 900001;
    demo_customer_id constant text := 'demo_incremental_customer_001';
    demo_seller_id constant text := 'demo_incremental_seller_001';
    demo_product_id constant text := 'demo_incremental_product_001';
    demo_order_id constant text := 'demo_incremental_order_001';
    demo_address_id constant text := 'demo_incremental_address_001';
    demo_payment_id constant text := 'demo_incremental_payment_001';
    demo_review_id constant text := 'demo_incremental_review_001';
    demo_shipment_id constant text := 'demo_incremental_shipment_001';
    demo_order_item_id constant integer := 900001;
    target_customer_id text;
    target_seller_id text;
    target_product_id text;
    target_order_id text;
    target_payment_id text;
    table_name text;
begin
    if not exists (
        select 1
        from source.orders
        where order_id <> demo_order_id
    ) then
        raise exception
            'Execute a carga inicial em source antes do seed incremental.';
    end if;

    foreach table_name in array array[
        'categories',
        'customers',
        'sellers',
        'products',
        'orders',
        'addresses',
        'payments',
        'reviews',
        'shipments',
        'order_items'
    ] loop
        execute format(
            'update source.%I
             set created_at = %L::timestamp without time zone,
                 updated_at = (%L::timestamp without time zone + interval ''1 second'')',
            table_name,
            baseline_ts,
            baseline_ts
        );
        execute format(
            'update source.%I
             set created_at = %L::timestamp without time zone,
                 updated_at = %L::timestamp without time zone',
            table_name,
            baseline_ts,
            baseline_ts
        );
    end loop;

    select customer_id
    into target_customer_id
    from source.customers
    where customer_id <> demo_customer_id
    order by customer_id
    limit 1;

    select seller_id
    into target_seller_id
    from source.sellers
    where seller_id <> demo_seller_id
    order by seller_id
    limit 1;

    select product_id
    into target_product_id
    from source.products
    where product_id <> demo_product_id
    order by product_id
    limit 1;

    select order_id
    into target_order_id
    from (
        select order_id, order_purchase_timestamp, 1 as sort_priority
        from source.orders
        where order_id <> demo_order_id
          and order_status <> 'delivered'

        union all

        select order_id, order_purchase_timestamp, 2 as sort_priority
        from source.orders
        where order_id <> demo_order_id
    ) candidates
    order by sort_priority, order_purchase_timestamp, order_id
    limit 1;

    select payment_id
    into target_payment_id
    from source.payments
    where payment_id <> demo_payment_id
    order by payment_id
    limit 1;

    if target_customer_id is null
       or target_seller_id is null
       or target_product_id is null
       or target_order_id is null
       or target_payment_id is null then
        raise exception
            'A carga inicial precisa ter clientes, vendedores, produtos, pedidos e pagamentos.';
    end if;

    update source.customers
    set customer_zip_code_prefix = 99999,
        customer_city = 'cidade_demo_scd2',
        customer_state = 'SP',
        updated_at = change_ts
    where customer_id = target_customer_id;

    update source.sellers
    set seller_zip_code_prefix = 88888,
        seller_city = 'vendedor_demo_scd2',
        seller_state = 'RJ',
        updated_at = change_ts
    where seller_id = target_seller_id;

    update source.products
    set product_photos_qty = 7,
        product_weight_g = 4321,
        product_length_cm = 42,
        product_height_cm = 24,
        product_width_cm = 18,
        updated_at = change_ts
    where product_id = target_product_id;

    update source.orders
    set order_status = 'delivered',
        order_approved_at = coalesce(
            order_approved_at,
            order_purchase_timestamp + interval '1 hour'
        ),
        order_delivered_carrier_date = coalesce(
            order_delivered_carrier_date,
            order_purchase_timestamp + interval '2 days'
        ),
        order_delivered_customer_date = coalesce(
            order_delivered_customer_date,
            order_purchase_timestamp + interval '7 days'
        ),
        updated_at = change_ts
    where order_id = target_order_id;

    update source.shipments as s
    set shipment_status = 'delivered',
        shipped_at = o.order_delivered_carrier_date,
        delivered_at = o.order_delivered_customer_date,
        updated_at = change_ts
    from source.orders as o
    where s.order_id = o.order_id
      and s.order_id = target_order_id;

    update source.payments
    set payment_type = 'credit_card',
        payment_installments = 1,
        payment_value = 321.09,
        updated_at = change_ts
    where payment_id = target_payment_id;

    insert into source.categories (
        category_id,
        product_category_name,
        created_at,
        updated_at
    ) values (
        demo_category_id,
        'demo_incremental_categoria',
        change_ts,
        change_ts
    )
    on conflict (category_id) do update
    set product_category_name = excluded.product_category_name,
        created_at = excluded.created_at,
        updated_at = excluded.updated_at;

    insert into source.customers (
        customer_id,
        customer_unique_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state,
        created_at,
        updated_at
    ) values (
        demo_customer_id,
        'demo_incremental_unique_001',
        12345,
        'sao paulo',
        'SP',
        change_ts,
        change_ts
    )
    on conflict (customer_id) do update
    set customer_unique_id = excluded.customer_unique_id,
        customer_zip_code_prefix = excluded.customer_zip_code_prefix,
        customer_city = excluded.customer_city,
        customer_state = excluded.customer_state,
        created_at = excluded.created_at,
        updated_at = excluded.updated_at;

    insert into source.sellers (
        seller_id,
        seller_zip_code_prefix,
        seller_city,
        seller_state,
        created_at,
        updated_at
    ) values (
        demo_seller_id,
        54321,
        'rio de janeiro',
        'RJ',
        change_ts,
        change_ts
    )
    on conflict (seller_id) do update
    set seller_zip_code_prefix = excluded.seller_zip_code_prefix,
        seller_city = excluded.seller_city,
        seller_state = excluded.seller_state,
        created_at = excluded.created_at,
        updated_at = excluded.updated_at;

    insert into source.products (
        product_id,
        category_id,
        product_name_length,
        product_description_length,
        product_photos_qty,
        product_weight_g,
        product_length_cm,
        product_height_cm,
        product_width_cm,
        created_at,
        updated_at
    ) values (
        demo_product_id,
        demo_category_id,
        32,
        180,
        4,
        1200,
        30,
        12,
        20,
        change_ts,
        change_ts
    )
    on conflict (product_id) do update
    set category_id = excluded.category_id,
        product_name_length = excluded.product_name_length,
        product_description_length = excluded.product_description_length,
        product_photos_qty = excluded.product_photos_qty,
        product_weight_g = excluded.product_weight_g,
        product_length_cm = excluded.product_length_cm,
        product_height_cm = excluded.product_height_cm,
        product_width_cm = excluded.product_width_cm,
        created_at = excluded.created_at,
        updated_at = excluded.updated_at;

    insert into source.orders (
        order_id,
        customer_id,
        order_status,
        order_purchase_timestamp,
        order_approved_at,
        order_delivered_carrier_date,
        order_delivered_customer_date,
        order_estimated_delivery_date,
        created_at,
        updated_at
    ) values (
        demo_order_id,
        demo_customer_id,
        'delivered',
        timestamp '2019-01-15 10:00:00',
        timestamp '2019-01-15 10:30:00',
        timestamp '2019-01-16 09:00:00',
        timestamp '2019-01-20 14:00:00',
        timestamp '2019-01-25 00:00:00',
        change_ts,
        change_ts
    )
    on conflict (order_id) do update
    set customer_id = excluded.customer_id,
        order_status = excluded.order_status,
        order_purchase_timestamp = excluded.order_purchase_timestamp,
        order_approved_at = excluded.order_approved_at,
        order_delivered_carrier_date = excluded.order_delivered_carrier_date,
        order_delivered_customer_date = excluded.order_delivered_customer_date,
        order_estimated_delivery_date = excluded.order_estimated_delivery_date,
        created_at = excluded.created_at,
        updated_at = excluded.updated_at;

    insert into source.addresses (
        address_id,
        customer_id,
        zip_code,
        city,
        state,
        created_at,
        updated_at
    ) values (
        demo_address_id,
        demo_customer_id,
        '12345',
        'sao paulo',
        'SP',
        change_ts,
        change_ts
    )
    on conflict (address_id) do update
    set customer_id = excluded.customer_id,
        zip_code = excluded.zip_code,
        city = excluded.city,
        state = excluded.state,
        created_at = excluded.created_at,
        updated_at = excluded.updated_at;

    insert into source.payments (
        payment_id,
        order_id,
        payment_sequential,
        payment_type,
        payment_installments,
        payment_value,
        created_at,
        updated_at
    ) values (
        demo_payment_id,
        demo_order_id,
        1,
        'credit_card',
        1,
        159.90,
        change_ts,
        change_ts
    )
    on conflict (payment_id) do update
    set order_id = excluded.order_id,
        payment_sequential = excluded.payment_sequential,
        payment_type = excluded.payment_type,
        payment_installments = excluded.payment_installments,
        payment_value = excluded.payment_value,
        created_at = excluded.created_at,
        updated_at = excluded.updated_at;

    insert into source.reviews (
        review_id,
        order_id,
        review_score,
        review_creation_date,
        review_answer_timestamp,
        created_at,
        updated_at
    ) values (
        demo_review_id,
        demo_order_id,
        5,
        timestamp '2019-01-21 00:00:00',
        timestamp '2019-01-21 12:00:00',
        change_ts,
        change_ts
    )
    on conflict (review_id) do update
    set order_id = excluded.order_id,
        review_score = excluded.review_score,
        review_creation_date = excluded.review_creation_date,
        review_answer_timestamp = excluded.review_answer_timestamp,
        created_at = excluded.created_at,
        updated_at = excluded.updated_at;

    insert into source.shipments (
        shipment_id,
        order_id,
        shipment_status,
        shipped_at,
        delivered_at,
        created_at,
        updated_at
    ) values (
        demo_shipment_id,
        demo_order_id,
        'delivered',
        timestamp '2019-01-16 09:00:00',
        timestamp '2019-01-20 14:00:00',
        change_ts,
        change_ts
    )
    on conflict (shipment_id) do update
    set order_id = excluded.order_id,
        shipment_status = excluded.shipment_status,
        shipped_at = excluded.shipped_at,
        delivered_at = excluded.delivered_at,
        created_at = excluded.created_at,
        updated_at = excluded.updated_at;

    insert into source.order_items (
        order_item_id,
        order_id,
        product_id,
        seller_id,
        shipping_limit_date,
        price,
        freight_value,
        created_at,
        updated_at
    ) values (
        demo_order_item_id,
        demo_order_id,
        demo_product_id,
        demo_seller_id,
        timestamp '2019-01-18 23:59:59',
        139.90,
        20.00,
        change_ts,
        change_ts
    )
    on conflict (order_item_id) do update
    set order_id = excluded.order_id,
        product_id = excluded.product_id,
        seller_id = excluded.seller_id,
        shipping_limit_date = excluded.shipping_limit_date,
        price = excluded.price,
        freight_value = excluded.freight_value,
        created_at = excluded.created_at,
        updated_at = excluded.updated_at;

    if (select count(*) from source.customers where updated_at = change_ts) < 2
       or (select count(*) from source.sellers where updated_at = change_ts) < 2
       or (select count(*) from source.products where updated_at = change_ts) < 2
       or (select count(*) from source.orders where updated_at = change_ts) < 2
       or (select count(*) from source.payments where updated_at = change_ts) < 2
       or (select count(*) from source.shipments where updated_at = change_ts) < 2
       or (select count(*) from source.categories where updated_at = change_ts) < 1
       or (select count(*) from source.addresses where updated_at = change_ts) < 1
       or (select count(*) from source.reviews where updated_at = change_ts) < 1
       or (select count(*) from source.order_items where updated_at = change_ts) < 1 then
        raise exception
            'Seed incremental incompleto: alteracoes esperadas nao foram aplicadas.';
    end if;
end;
$$;

select *
from (
    values
        (
            'addresses',
            (
                select count(*)::bigint
                from source.addresses
                where updated_at > timestamp '2026-01-01 00:00:00'
            )
        ),
        (
            'categories',
            (
                select count(*)::bigint
                from source.categories
                where updated_at > timestamp '2026-01-01 00:00:00'
            )
        ),
        (
            'customers',
            (
                select count(*)::bigint
                from source.customers
                where updated_at > timestamp '2026-01-01 00:00:00'
            )
        ),
        (
            'order_items',
            (
                select count(*)::bigint
                from source.order_items
                where updated_at > timestamp '2026-01-01 00:00:00'
            )
        ),
        (
            'orders',
            (
                select count(*)::bigint
                from source.orders
                where updated_at > timestamp '2026-01-01 00:00:00'
            )
        ),
        (
            'payments',
            (
                select count(*)::bigint
                from source.payments
                where updated_at > timestamp '2026-01-01 00:00:00'
            )
        ),
        (
            'products',
            (
                select count(*)::bigint
                from source.products
                where updated_at > timestamp '2026-01-01 00:00:00'
            )
        ),
        (
            'reviews',
            (
                select count(*)::bigint
                from source.reviews
                where updated_at > timestamp '2026-01-01 00:00:00'
            )
        ),
        (
            'sellers',
            (
                select count(*)::bigint
                from source.sellers
                where updated_at > timestamp '2026-01-01 00:00:00'
            )
        ),
        (
            'shipments',
            (
                select count(*)::bigint
                from source.shipments
                where updated_at > timestamp '2026-01-01 00:00:00'
            )
        )
) as demo_changes(table_name, changed_rows)
order by table_name;

commit;
