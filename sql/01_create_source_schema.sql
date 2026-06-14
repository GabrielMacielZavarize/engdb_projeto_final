begin;

create schema if not exists source;

create table if not exists source.categories (
    category_id integer primary key,
    product_category_name text not null,
    constraint categories_product_category_name_key unique (product_category_name),
    constraint categories_product_category_name_not_blank
        check (btrim(product_category_name) <> '')
);

create table if not exists source.customers (
    customer_id text primary key,
    customer_unique_id text not null,
    customer_zip_code_prefix integer not null,
    customer_city text not null,
    customer_state varchar(2) not null,
    constraint customers_customer_unique_id_not_blank
        check (btrim(customer_unique_id) <> ''),
    constraint customers_customer_city_not_blank
        check (btrim(customer_city) <> ''),
    constraint customers_customer_state_not_blank
        check (btrim(customer_state) <> ''),
    constraint customers_customer_zip_code_prefix_non_negative
        check (customer_zip_code_prefix >= 0)
);

create table if not exists source.sellers (
    seller_id text primary key,
    seller_zip_code_prefix integer not null,
    seller_city text not null,
    seller_state varchar(2) not null,
    constraint sellers_seller_city_not_blank
        check (btrim(seller_city) <> ''),
    constraint sellers_seller_state_not_blank
        check (btrim(seller_state) <> ''),
    constraint sellers_seller_zip_code_prefix_non_negative
        check (seller_zip_code_prefix >= 0)
);

create table if not exists source.products (
    product_id text primary key,
    category_id integer references source.categories (category_id)
        on update cascade
        on delete set null,
    product_name_length integer,
    product_description_length integer,
    product_photos_qty integer,
    product_weight_g integer,
    product_length_cm integer,
    product_height_cm integer,
    product_width_cm integer,
    constraint products_product_name_length_non_negative
        check (product_name_length is null or product_name_length >= 0),
    constraint products_product_description_length_non_negative
        check (product_description_length is null or product_description_length >= 0),
    constraint products_product_photos_qty_non_negative
        check (product_photos_qty is null or product_photos_qty >= 0),
    constraint products_product_weight_g_non_negative
        check (product_weight_g is null or product_weight_g >= 0),
    constraint products_product_length_cm_non_negative
        check (product_length_cm is null or product_length_cm >= 0),
    constraint products_product_height_cm_non_negative
        check (product_height_cm is null or product_height_cm >= 0),
    constraint products_product_width_cm_non_negative
        check (product_width_cm is null or product_width_cm >= 0)
);

create table if not exists source.orders (
    order_id text primary key,
    customer_id text not null references source.customers (customer_id)
        on update cascade
        on delete restrict,
    order_status text not null,
    order_purchase_timestamp timestamp without time zone not null,
    order_approved_at timestamp without time zone,
    order_delivered_carrier_date timestamp without time zone,
    order_delivered_customer_date timestamp without time zone,
    order_estimated_delivery_date timestamp without time zone,
    constraint orders_order_status_not_blank
        check (btrim(order_status) <> '')
);

create table if not exists source.addresses (
    address_id text primary key,
    customer_id text not null references source.customers (customer_id)
        on update cascade
        on delete cascade,
    zip_code text not null,
    city text not null,
    state varchar(2) not null,
    constraint addresses_zip_code_not_blank
        check (btrim(zip_code) <> ''),
    constraint addresses_city_not_blank
        check (btrim(city) <> ''),
    constraint addresses_state_not_blank
        check (btrim(state) <> ''),
    constraint addresses_customer_id_zip_code_key unique (customer_id, zip_code)
);

create table if not exists source.payments (
    payment_id text primary key,
    order_id text not null references source.orders (order_id)
        on update cascade
        on delete cascade,
    payment_sequential integer not null,
    payment_type text not null,
    payment_installments integer not null,
    payment_value numeric(12, 2) not null,
    constraint payments_order_id_payment_sequential_key
        unique (order_id, payment_sequential),
    constraint payments_payment_type_not_blank
        check (btrim(payment_type) <> ''),
    constraint payments_payment_sequential_positive
        check (payment_sequential > 0),
    constraint payments_payment_installments_non_negative
        check (payment_installments >= 0),
    constraint payments_payment_value_non_negative
        check (payment_value >= 0)
);

create table if not exists source.reviews (
    review_id text primary key,
    order_id text not null references source.orders (order_id)
        on update cascade
        on delete cascade,
    review_score integer not null,
    review_creation_date timestamp without time zone not null,
    review_answer_timestamp timestamp without time zone,
    constraint reviews_order_id_key unique (order_id),
    constraint reviews_review_score_range
        check (review_score between 1 and 5)
);

create table if not exists source.shipments (
    shipment_id text primary key,
    order_id text not null references source.orders (order_id)
        on update cascade
        on delete cascade,
    shipment_status text not null,
    shipped_at timestamp without time zone,
    delivered_at timestamp without time zone,
    constraint shipments_order_id_key unique (order_id),
    constraint shipments_shipment_status_not_blank
        check (btrim(shipment_status) <> '')
);

create table if not exists source.order_items (
    order_item_id integer primary key,
    order_id text not null references source.orders (order_id)
        on update cascade
        on delete cascade,
    product_id text not null references source.products (product_id)
        on update cascade
        on delete restrict,
    seller_id text not null references source.sellers (seller_id)
        on update cascade
        on delete restrict,
    shipping_limit_date timestamp without time zone not null,
    price numeric(12, 2) not null,
    freight_value numeric(12, 2) not null,
    constraint order_items_price_non_negative
        check (price >= 0),
    constraint order_items_freight_value_non_negative
        check (freight_value >= 0)
);

create index if not exists idx_products_category_id
    on source.products (category_id);

create index if not exists idx_orders_customer_id
    on source.orders (customer_id);

create index if not exists idx_addresses_customer_id
    on source.addresses (customer_id);

create index if not exists idx_payments_order_id
    on source.payments (order_id);

create index if not exists idx_reviews_order_id
    on source.reviews (order_id);

create index if not exists idx_shipments_order_id
    on source.shipments (order_id);

create index if not exists idx_order_items_order_id
    on source.order_items (order_id);

create index if not exists idx_order_items_product_id
    on source.order_items (product_id);

create index if not exists idx_order_items_seller_id
    on source.order_items (seller_id);

commit;
