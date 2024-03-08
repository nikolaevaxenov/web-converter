create table queries_algebra
(
    id              serial
        constraint queries_algebra_pk
            primary key,
    query_group     text,
    last_name       text,
    query_id        text,
    description     text,
    table_variables text,
    target_list     text,
    query_body      text
);

create table queries_tuple
(
    id              serial
        constraint queries_tuple_pk
            primary key,
    query_group     text,
    last_name       text,
    query_id        text,
    description     text,
    table_variables text,
    target_list     text,
    query_body      text
);

create table выполнение
(
    id     serial
        constraint выполнение_pk
            primary key,
    Нз     text,
    ИдК    text,
    ВидОтч text,
    Дата   timestamp,
    Оцн    text
);

create table группы
(
    id     serial
        constraint группы_pk
            primary key,
    Гр     text,
    Спец   text,
    ВыпКаф text
);

create table календарныйплан
(
    id     serial
        constraint календарныйплан_pk
            primary key,
    ИдК    text,
    Гр     text,
    ВидОтч text,
    Дата   timestamp
);

create table курслекций
(
    id     serial
        constraint курслекций_pk
            primary key,
    ИдК    text,
    Назв   text,
    ВидЗан text,
    ЧитКаф integer
);

create table регби
(
    id   serial
        constraint регби_pk
            primary key,
    Нз   text,
    Фио  text,
    Возр integer,
    Гр   text
);

create table студенты
(
    id   serial
        constraint студенты_pk
            primary key,
    Нз   text,
    Фио  text,
    П    text,
    Возр integer,
    Гр   text
);

create table худгимнастика
(
    id   serial
        constraint худгимнастика_pk
            primary key,
    Нз   text,
    Фио  text,
    Возр integer,
    Гр   text
);