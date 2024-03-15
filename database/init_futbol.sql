CREATE TABLE queries_algebra
(
    id              serial
        constraint queries_algebra_pk primary key,
    query_group     text,
    last_name       text,
    query_id        text,
    description     text,
    table_variables text,
    target_list     text,
    query_body      text
);

CREATE TABLE queries_tuple
(
    id              serial
        constraint queries_tuple_pk primary key,
    query_group     text,
    last_name       text,
    query_id        text,
    description     text,
    table_variables text,
    target_list     text,
    query_body      text
);

CREATE TABLE "игрокиклубов"
(
    id         serial
        constraint игрокиклубов_pk primary key,
    "ИдИгрока" text,
    "ИдК"      text,
    "Номер"    text,
    "Фио"      text,
    "Страна"   text,
    "ДатаРожд" date,
    "Возраст"  integer,
    "Позиция"  text
);

CREATE TABLE "игрокинаполе"
(
    id         serial
        constraint игрокинаполе_pk primary key,
    "ИдИгры"   integer,
    "ИдК"      text,
    "ИдИгрока" text
);

CREATE TABLE "календарь"
(
    id       serial
        constraint календарь_pk primary key,
    "ИдИгры" integer,
    "ИдКХ"   text,
    "ИдКГ"   text,
    "Дата"   date,
    "Год"    integer,
    "Месяц"  integer,
    "Статус" integer
);

CREATE TABLE "клубы"
(
    id       serial
        constraint клубы_pk primary key,
    "ИдК"    text,
    "Клуб"   text,
    "Тренер" text
);

CREATE VIEW "игра_07_спартак_цска" AS
SELECT z."ИдИгры",
       x."ИдК",
       x."ИдИгрока",
       x."Фио"
FROM "календарь" z,
     "игрокиклубов" x
WHERE ((z."Статус" = 1) AND (((z."ИдКХ")::text = (x."ИдК")::text) OR ((z."ИдКГ")::text = (x."ИдК")::text)) AND
       (EXISTS (SELECT q."ИдК",
                       q."Клуб",
                       q."Тренер"
                FROM "клубы" q
                WHERE (((z."ИдКХ")::text = (q."ИдК")::text) AND ((q."Клуб")::text = 'Спартак'::text) AND
                       (EXISTS (SELECT w."ИдК",
                                       w."Клуб",
                                       w."Тренер"
                                FROM "клубы" w
                                WHERE (((z."ИдКГ")::text = (w."ИдК")::text) AND ((w."Клуб")::text = 'ЦСКА'::text) AND
                                       (NOT (EXISTS (SELECT y."ИдИгры",
                                                            y."ИдК",
                                                            y."ИдИгрока"
                                                     FROM "игрокинаполе" y
                                                     WHERE ((y."ИдИгры" < z."ИдИгры") AND
                                                            ((x."ИдИгрока")::text = (y."ИдИгрока")::text))))))))))));

CREATE VIEW "игра_спа_цска" AS
SELECT x."ИдИгры",
       x."Дата",
       z."ИдИгрока",
       z."ИдК"
FROM "календарь" x,
     "игрокинаполе" z
WHERE ((x."ИдИгры" = z."ИдИгры") AND (EXISTS (SELECT v."ИдК",
                                                     v."Клуб",
                                                     v."Тренер",
                                                     w."ИдК",
                                                     w."Клуб",
                                                     w."Тренер"
                                              FROM "клубы" v,
                                                   "клубы" w
                                              WHERE (((x."ИдКХ")::text = (v."ИдК")::text) AND
                                                     ((v."Клуб")::text = 'Спартак'::text) AND
                                                     ((x."ИдКГ")::text = (w."ИдК")::text) AND
                                                     ((w."Клуб")::text = 'ЦСКА'::text)))));

CREATE VIEW "кто_в_запасе" AS
SELECT DISTINCT z."ИдИгры",
                w."ИдИгрока",
                w."ИдК"
FROM "игрокинаполе" z,
     "игрокиклубов" w
WHERE (((z."ИдК")::text = (w."ИдК")::text) AND (EXISTS (SELECT x."ИдИгры",
                                                               x."ИдКХ",
                                                               x."ИдКГ",
                                                               x."Дата",
                                                               x."Год",
                                                               x."Месяц",
                                                               x."Статус",
                                                               y."ИдИгры",
                                                               y."Дата",
                                                               y."ИдИгрока",
                                                               y."ИдК"
                                                        FROM "календарь" x,
                                                             "игра_спа_цска" y
                                                        WHERE ((x."Дата" < y."Дата") AND (x."ИдИгры" = z."ИдИгры") AND
                                                               ((z."ИдК")::text = (y."ИдК")::text)))))
EXCEPT
SELECT DISTINCT z."ИдИгры",
                z."ИдИгрока",
                z."ИдК"
FROM "игрокинаполе" z
WHERE (EXISTS (SELECT x."ИдИгры",
                      x."ИдКХ",
                      x."ИдКГ",
                      x."Дата",
                      x."Год",
                      x."Месяц",
                      x."Статус",
                      y."ИдИгры",
                      y."Дата",
                      y."ИдИгрока",
                      y."ИдК"
               FROM "календарь" x,
                    "игра_спа_цска" y
               WHERE ((x."Дата" < y."Дата") AND (x."ИдИгры" = z."ИдИгры") AND ((z."ИдК")::text = (y."ИдК")::text))));

CREATE VIEW "нападающие" AS
SELECT x."ИдИгры",
       x."ИдИгрока"
FROM "игрокинаполе" x
WHERE (EXISTS (SELECT z."ИдИгрока",
                      z."ИдК",
                      z."Номер",
                      z."Фио",
                      z."Страна",
                      z."ДатаРожд",
                      z."Возраст",
                      z."Позиция",
                      y."ИдК",
                      y."Клуб",
                      y."Тренер"
               FROM "игрокиклубов" z,
                    "клубы" y
               WHERE (((x."ИдК")::text = (y."ИдК")::text) AND ((y."Клуб")::text = 'Рубин'::text) AND
                      ((z."Позиция")::text = 'Нападение'::text) AND ((z."ИдИгрока")::text = (x."ИдИгрока")::text))));

CREATE TABLE "счетигр"
(
    id       serial
        constraint счетигр_pk primary key,
    "ИдИгры" integer,
    "ХозГол" integer,
    "ГосГол" integer,
    "Счет"   text
);

INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('000', 'NULL', '0000', 'queries_algebra AS X', 'X.NameQuery,X.DescQuery', 'X', '');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('queries', 'algebra', '0001 TAB', 'queries_algebra AS X', 'X.NameQuery,X.DescQuery', 'X', 'queries_algebra ');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('TBR', 'Календарь', '0001', 'календарь AS X, клубы AS Y, клубы AS Z',
        'X.ИдИгры,X.ИдКХ,X.ИдКГ,X.Дата,X.Год,X.Месяц,X.Статус,Y.Клуб AS Хозяин,Z.Клуб As Гость',
        '(X[X.ИдКХ=Y.ИдК]Y)[X.ИдКГ=Z.ИдК]Z', 'Таблица "Календарь" расширенная');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('TBR', 'ИгрокиНаПоле', '0004', 'игрокинаполе AS X, клубы AS Y, игрокиклубов AS Z',
        'X.ИдИгры,X.ИдК,X.ИдИгрока,Z.Фио,Z.Страна,Z.Позиция,Y.Клуб', '(X[X.ИдИгрока=Z.ИдИгрока]Z)[X.ИдК=Y.ИдК]Y',
        'Таблица "игрокинаполе"');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('TAB', 'Календарь', '0001', 'календарь AS X', 'X.ИдИгры,X.ИдКХ,X.ИдКГ,X.Дата,X.Статус', 'X',
        'Таблица "Календарь"');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('TBR', 'ВсеНападающие', '0001', 'игрокинаполе AS X, игрокиклубов AS Z, клубы AS Y', 'X.ИдИгры,X.ИдИгрока',
        '((X[X.ИдК=Y.ИдК AND Y.Клуб="Рубин"]Y)[Z.Позиция="Нападение" AND Z.ИдИгрока=X.ИдИгрока]Z)',
        '21.  В каких играх выходили на поле все нападающие клуба Рубин?');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК06К',
        'игрокинаполе AS X, календарь AS Y, клубы AS Z, клубы AS U, игрокиклубов AS V, клубы AS W',
        'W.Клуб, V.Фио AS Фамилия, V.Страна, V.ДатаРожд AS День_Рождения, V.Возраст, V.Позиция', '((((
(Y[Y.ИдИгры=X.ИдИгры]X)
[Y.ИдКХ=Z.ИдК AND Z.Клуб="Динамо"]Z)
[Y.ИдКГ=U.ИдК AND U.Клуб="Рубин" AND (X.ИдК=Z.ИдК OR X.ИдК=U.ИдК)]U)
[X.ИдК=W.ИдК]W)[X.ИдИгрока=V.ИдИгрока]V)', '6. 	Какие игроки принимали участие в игре Динамо-Рубин?
');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК01К', 'счетигр AS X, календарь AS Y, клубы AS Z, клубы AS U',
        'X.ИдИгры, X.ХозГол, X.ГосГол, X.Счет, Z.Клуб AS Хозяин, U.Клуб AS Гость, Y.Дата', '((Y[Y.ИдКХ=Z.ИдК AND Y.Статус=1 AND Z.Клуб="Спартак"]Z)
[Y.ИдКГ=U.ИдК]U)
[X.ИдИгры=Y.ИдИгры]X', '1. 	С какими командами играл Спартак дома?
Ответ: Игра, Хозяин, Гость, Дата, Хозяин Голы, Гость Голы, Счет');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК03К', 'календарь AS Y, клубы AS Z, клубы AS U',
        'Y.ИдИгры, Y.Дата, Z.Клуб AS Клуб_Хозяин, U.Клуб AS Клуб_Гость', '(
(Y[Y.ИдКХ=Z.ИдК AND Y.Статус=0 AND Z.Клуб="Спартак"]Z)
[Y.ИдКГ=U.ИдК]U)', '3. 	С какими командами будет играть Спартак дома?
Ответ: Игра, Хозяин, Гость, Дата');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК04К', 'календарь AS Y, клубы AS Z, клубы AS U',
        'Y.ИдИгры, Y.Дата, Z.Клуб AS Клуб_Хозяин, U.Клуб AS Клуб_Гость', '(
(Y[Y.ИдКГ=U.ИдК AND Y.Статус=0 AND U.Клуб="Спартак"]U)
[Y.ИдКХ=Z.ИдК]Z)', '4. 	С какими командами будет играть Спартак в гостях?
Ответ: Игра, Хозяин, Гость, Дата');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК02К', 'счетигр AS X, календарь AS Y, клубы AS Z, клубы AS U',
        'X.ИдИгры AS Игра, X.ХозГол AS Забил_Хозяин, X.ГосГол AS Забил_гость, X.Счет, Z.Клуб AS Хозяин, U.Клуб AS Гость, Y.Дата', 'Y[Y.ИдКГ=U.ИдК AND Y.Статус=1 AND U.Клуб="Спартак"]U
[Y.ИдКХ=Z.ИдК]Z[X.ИдИгры=Y.ИдИгры]X', '2. 	С какими командами играл Спартак в гостях?
Ответ: Игра, Хозяин, Гость, Дата, Хозяин Голы, Гость Голы, Счет');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('TAB', 'Игрокиклубов', '0002', 'игрокиклубов AS X',
        'X.ИдИгрока,X.Фио,X.ИдК,X.Номер,X.Позиция,X.Страна,X.Возраст',
        'X', 'Таблица "игрокиклубов"');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК10К', 'игрокиклубов AS X, игрокинаполе AS Y, клубы AS Z',
        'Z.Клуб, X.ИдИгрока, X.Фио, X.Страна, X.Позиция', '(X[X.ИдК=Z.ИдК AND Z.Клуб="Спартак"]Z)
EXCEPT
((X[X.ИдК=Z.ИдК AND Z.Клуб="Спартак"]Z)[X.ИдИгрока=Y.ИдИгрока]Y)[Z.Клуб, X.ИдИгрока, X.Фио, X.Страна, X.Позиция]', '10. Какие игроки команды Спартак не были на поле ни в одной игре ?
Ответ: Все атрибуты игроков клубов');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК11К', 'игрокиклубов AS X, игрокинаполе AS Y, клубы AS Z',
        'X.ИдИгрока,X.ИдК,X.Номер,X.Фио,X.Страна,X.Возраст,X.Позиция',
        '((X[X.ИдК=Z.ИдК AND Z.Клуб="Спартак"]Z)[X.ИдИгрока=Y.ИдИгрока]Y)', '11.  Какие игроки команды Спартак были на поле хотя бы в одной игре?
Ответ: Все атрибуты игроков клубов');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК13К', 'игрокиклубов AS X, клубы AS Y, клубы AS Z, клубы AS U',
        'U.Клуб, X.ИдИгрока AS Игрок, X.Фио, X.Страна, X.Позиция',
        '((X[X.ИдК=Z.ИдК AND Z.Клуб="Рубин" OR X.ИдК=Y.ИдК AND Y.Клуб="Зенит"]Z*Y)[X.ИдК=U.ИдК]U)', '13.  Перечислить игроков клуба Рубин и клуба Зенит
Ответ: Все атрибуты игроков клубов');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК14К', 'игрокиклубов AS X, клубы AS Y, клубы AS Z, клубы AS U, игрокинаполе AS V',
        'U.Клуб, X.ИдИгрока, X.Фио, X.Страна, X.Позиция', '(((X[X.ИдК=U.ИдК]U)
[(X.ИдК=Z.ИдК AND Z.Клуб="Спартак" OR X.ИдК=Y.ИдК AND Y.Клуб="Локомотив")]Z*Y)
[X.ИдИгрока=V.ИдИгрока]V)', '14.  Перечислить игроков клуба Спартак и клуба Локомотив, которые были на поле хотя бы в одной игре
Ответ: Все атрибуты игроков клубов');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК15К', 'игрокиклубов AS X, клубы AS Y, клубы AS Z, игрокинаполе AS V',
        'Z.Клуб, X.ИдИгрока, X.Фио, X.Страна, X.Позиция', '(X[(X.ИдК=Z.ИдК AND Z.Клуб="Спартак" OR X.ИдК=Y.ИдК AND Y.Клуб="Локомотив")]Z)[True]Y
EXCEPT
((X[X.ИдК=Z.ИдК]Z)[X.ИдИгрока=V.ИдИгрока]V)[Z.Клуб, X.ИдИгрока, X.Фио, X.Страна, X.Позиция]', '15.  Перечислить игроков клуба Спартак и клуба Локомотив, которые не были на поле ни в одной игре
Ответ: Все атрибуты игроков клубов');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК17К', 'игрокиклубов AS W, игрокинаполе AS V, календарь AS U, клубы AS R, клубы AS Q',
        'U.ИдИгры, U.Дата, R.Клуб AS Клуб_Хозяин, Q.Клуб AS Клуб_Гость', '((V[V.ИдИгры=U.ИдИгры]U)[U.ИдКХ=R.ИдК]W)[U.ИдКГ=Q.ИдК]Q
[V.ИдИгрока # W.ИдИгрока]
(W[(W.Фио="Дьяков Виталий Александрович"
OR W.Фио="Алвим Маринато Гилерме")])', '17.  В каких играх Дьяков Виталий Александрович и Алвим Маринато Гилерме были на поле вместе
Ответ: Все атрибуты игры
ВНИМАНИЕ: первая буква (V) представляет таблицу ДЕЛИМОГО');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК17Л', 'игрокиклубов AS W, игрокинаполе AS V, календарь AS U, клубы AS X, клубы AS Y',
        'U.ИдИгры, U.Дата, X.Клуб AS Хозяин, Y.Клуб AS Гость', '((V[V.ИдИгры=U.ИдИгры]U)[U.ИдКХ=X.ИдК]X)[U.ИдКГ=Y.ИдК]Y
[V.ИдИгрока # W.ИдИгрока]
(W[(W.Фио="Дьяков Виталий Александрович"
OR W.Фио="Алвим Маринато Гилерме")])', '17.  В каких играх Дьяков Виталий Александрович и Алвим Маринато Гилерме были на поле вместе
ВНИМАНИЕ: первая буква (V) представляет таблицу ДЕЛИМОГО
НЕ ГЕНЕРИРУЕТСЯ
FROM  Календарь AS U, клубы AS X, клубы AS Y        ДОБАВИИТЬ !!!');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК19К', 'игрокиклубов AS X, игрокинаполе AS Y, календарь AS Z, клубы AS U, клубы AS V',
        'Z.ИдИгры AS Игра, Z.Дата, U.Клуб AS Хозяин, V.Клуб AS Гость', '((((Y[X.Фио="Ансальди Кристиан Даниэл" AND Y.ИдК=X.ИдК]X)
[Z.ИдИгры=Y.ИдИгры]Z)
[Z.ИдКХ=U.ИдК]U)
[Z.ИдКГ=V.ИдК]V)', '19.  В каких играх выходил на поле Ансальди Кристиан Даниэл?
Ответ: Все атрибуты игроков клубов');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК20К',
        'календарь AS X, клубы AS Z, клубы AS V, игрокиклубов AS Y, игрокинаполе AS W, клубы AS U',
        'U.Клуб, Y.ИдИгрока AS Игрок, Y.Фио, Y.Страна, Y.Возраст', '(((((Y[Y.Позиция="Защита" AND W.ИдИгрока=Y.ИдИгрока]W)
[X.ИдИгры=W.ИдИгры]X)
[X.ИдКХ=Z.ИдК AND Z.Клуб="Спартак"]Z)
[X.ИдКГ=V.ИдК AND V.Клуб="ЦСКА"]V)
[Y.ИдК=U.ИдК]U)', '20. Кто находился на линии защиты в игре Спартак-ЦСКА?');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК21К', 'игрокиклубов AS X, клубы AS Z, игрокинаполе AS V, календарь AS U,
клубы AS R, клубы AS Q', 'U.ИдИгры,U.Дата,R.Клуб AS Хозяин,Q.Клуб AS Гость', '(((V[V.ИдИгры=U.ИдИгры]U)[U.ИдКХ=R.ИдК]R)[U.ИдКГ=Q.ИдК]Q)
[V.ИдИгрока # X.ИдИгрока]
(X[X.Позиция="Нападение"])[X.ИдК=Z.ИдК](Z[Z.Клуб="Рубин"])',
        '21.  В каких играх выходили на поле все нападающие клуба Рубин?');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК24К', 'игрокиклубов AS X, игрокиклубов AS Y, клубы AS A, игрокиклубов AS Z',
        'X.Фио, X.Страна, X.ДатаРожд, X.Возраст, X.Позиция', '(X)
EXCEPT
((X[X.ИдИгрока<>Y.ИдИгрока AND X.Возраст<Y.Возраст]Y)
[X.Фио, X.Страна, X.ДатаРожд, X.Возраст, X.Позиция])', '24.  Найти старших игроков чемпионата 2015.');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК23К', 'игрокиклубов AS X, игрокиклубов AS Y, клубы AS A',
        'X.ИдК, X.Фио, X.Страна, X.ДатаРожд, X.Возраст, X.Позиция', '(X)
EXCEPT
((X[X.ИдИгрока<>Y.ИдИгрока AND Y.ИдК=X.ИдК AND X.Возраст<Y.Возраст]Y)
[X.ИдК, X.Фио, X.Страна, X.ДатаРожд, X.Возраст, X.Позиция])', '23.  Найти старших игроков клубов.');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК26К', 'календарь AS Z, календарь AS X, клубы AS V, клубы AS W',
        'Z.ИдИгры,Z.Дата,V.Клуб,W.Клуб', '(Z[Z.ИдКХ=V.ИдК]V)[Z.ИдКГ=W.ИдК]W
EXCEPT
(((X[Z.ИдИгры<>X.ИдИгры AND Z.Дата>X.Дата]Z)
[X.ИдКХ=V.ИдК]V)
[X.ИдКГ=W.ИдК]W)
[X.ИдИгры,X.Дата,V.Клуб,W.Клуб]', '26. Какие команды встречались первыми в чемпионате 2015?
       Ответ(Игра, Хозяин, Гость, Дата)');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК25К', 'клубы AS X, игрокиклубов AS Z, игрокиклубов AS Y', 'Y.Фио, Y.Страна, Y.ДатаРожд', '(X[Y.Позиция="Защита" AND X.ИдК=Y.ИдК AND X.Клуб="Зенит"]Y)
EXCEPT
((Z[Z.ИдК=Y.ИдК AND Z.Позиция=Y.Позиция AND Y.ДатаРожд>Z.ДатаРожд]Y)
[Z.Фио, Z.Страна, Z.ДатаРожд])', '25. Найти самого младшего защитника команды Зенит.
       Ответ: Клуб, Фио Игрока, Страна, Дата Рождения, Возраст, Позиция');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК22К', 'игрокиклубов AS X, игрокиклубов AS Y, клубы AS A',
        'X.Фио, X.Страна, X.ДатаРожд, X.Возраст, X.Позиция',
        '(X[X.ИдК=A.ИдК AND A.Клуб="Динамо"]A) EXCEPT ((X[X.ИдИгрока<>Y.ИдИгрока AND Y.ИдК=X.ИдК AND X.Возраст<Y.Возраст]Y) [X.Фио, X.Страна, X.ДатаРожд, X.Возраст, X.Позиция])',
        '22.  Найти самого старшего игрока клуба Динамо.');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК27К', 'календарь AS Z, календарь AS X, клубы AS V, клубы AS W',
        'Z.ИдИгры AS Игра, Z.Дата,V.Клуб AS Хозяин,W.Клуб AS Гость', '(Z[Z.ИдКХ=V.ИдК]V)[Z.ИдКГ=W.ИдК]W
EXCEPT
(((X[Z.ИдИгры<>X.ИдИгры AND Z.Дата<X.Дата]Z)
[X.ИдКХ=V.ИдК]V)
[X.ИдКГ=W.ИдК]W)
[X.ИдИгры,X.Дата,V.Клуб,W.Клуб]', '27.  Какие команды завершат чемпионат 2015?
       Ответ(Игра, Хозяин, Гость, Дата)');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК28К', 'календарь AS Z, календарь AS X, клубы AS V, клубы AS W',
        'Z.ИдИгры AS Игра, Z.Дата, V.Клуб AS Хозяин, W.Клуб AS Гость',
        '((Z[Z.ИдКХ=V.ИдК AND Z.Месяц=10]V)[Z.ИдКГ=W.ИдК]W)', '28.  Какие игры пройдут в октябре?
');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК35К',
        'игрокинаполе AS Y, игрокиклубов AS X, игрокинаполе AS C, игрокиклубов AS D, клубы AS U',
        'U.Клуб, D.Фио AS Фио_Игрока, D.Страна, D.ДатаРожд AS Дата_Рождения, D.Возраст, D.Позиция', '((((D[D.Позиция="Нападение" AND D.ИдК=U.ИдК]U)
[C.ИдИгрока=D.ИдИгрока]C)
[C.ИдК<>X.ИдК AND X.Фио="Анюков Александр Геннадьевич"]X)
[X.ИдИгрока=Y.ИдИгрока AND Y.ИдИгры=C.ИдИгры]Y)',
        '35. Каким нападающим противостоял на поле Анюков Александр Геннадьевич?');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК38К', 'календарь AS X, календарь AS Y, клубы AS U, клубы AS I',
        'X.ИдИгры AS Игра, X.Дата, U.Клуб AS Хозяин, I.Клуб AS Гость', '(X[X.Статус=1 AND X.ИдКХ=U.ИдК]U)[X.ИдКГ=I.ИдК]I
EXCEPT
((Y[Y.Статус=1 AND X.Статус=1 AND Y.ИдКХ=X.ИдКХ AND X.ИдИгры<>Y.ИдИгры]X)
[Y.ИдКГ=I.ИдК]I)
[Y.ИдКХ=U.ИдК]U)
[Y.ИдИгры, Y.Дата, U.Клуб, I.Клуб])', '38. Какая команда сыгала только одну игру дома?

Ответ - все атрибуты игры:  Игра, Хозяин, Гость, Дата, Счет');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК08К', 'счетигр AS X, календарь AS Y, клубы AS Z, клубы AS U, клубы AS V, клубы AS W',
        'X.ИдИгры AS Игра, X.ХозГол AS Хозяин_Голы, X.ГосГол AS Гость_Голы, X.Счет, V.Клуб AS Хозяин, W.Клуб AS Гость, Y.Дата', '(((((X[X.ИдИгры=Y.ИдИгры]Y)[(Y.ИдКХ=Z.ИдК AND Z.Клуб="Рубин" OR Y.ИдКГ=U.ИдК AND U.Клуб="Рубин")]Z)[True]U)
[Y.ИдКХ=V.ИдК]V)[Y.ИдКГ=W.ИдК]W)', '8. Какие игры сыграл Рубин?
Ответ: Игра, Хозяин, Гость, Дата, Хозяин Голы, Гость Голы, Счет');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК09К', 'игрокиклубов AS X, календарь AS Y, клубы AS Z, игрокинаполе AS V',
        'Y.ИдИгры AS Игра, Z.Клуб AS Хозяин, X.Фио AS Фио_Игрока, X.Страна, X.ДатаРожд AS Дата_Рождения, X.Возраст, X.Позиция', '(((Y[Y.ИдКХ=Z.ИдК AND Y.Статус=1 AND Z.Клуб="Спартак"]Z)[V.ИдИгры=Y.ИдИгры AND Y.ИдКХ=V.ИдК]V)
[V.ИдК=X.ИдК AND V.ИдИгрока=X.ИдИгрока]X)', '9. Какие игроки команды Спартак были на поле хотя бы в одной игре дома?
Ответ: Игра, Клуб, Фио Игрока, Страна, Дата Рождения, Возраст, Позиция');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК18К', 'игрокиклубов AS X, игрокинаполе AS Y, клубы AS Z',
        'Z.Клуб AS Клуб, X.ИдИгрока, X.Фио, X.Позиция', '(Z[Z.ИдК=X.ИдК]X)
EXCEPT
((Z[Z.ИдК=Y.ИдК AND Y.ИдИгрока=X.ИдИгрока]Y)[True]X)[Z.Клуб, X.ИдИгрока, X.Фио, X.Позиция]', '18. Перечислить игроков, которые не принимали участие ни в одной игре
Ответ: Все атрибуты игроков клубов');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК43К', 'календарь AS Y, клубы AS Z, клубы AS U',
        'Y.ИдИгры AS Игра, Y.Дата, Y.Статус, Z.Клуб AS Хозяин, U.Клуб AS Гость', '((Y[Y.ИдКГ=U.ИдК AND (U.Клуб="Динамо" OR U.Клуб="Зенит")]U)
[Y.ИдКХ=Z.ИдК AND (Z.Клуб="Динамо" OR Z.Клуб="Зенит")]Z)', '43.	Когда играют Зенит и Динамо?
');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК35М',
        'игрокинаполе AS Y, игрокиклубов AS X, игрокинаполе AS R, игрокиклубов AS C, клубы AS U',
        'U.Клуб, C.Фио AS Фио_Игрока, C.Страна, C.ДатаРожд AS Дата_Рождения, C.Возраст, C.Позиция', '(((C[C.Позиция="Нападение" AND C.ИдК=U.ИдК]U)
[C.ИдИгрока=Y.ИдИгрока]Y)
[R.ИдИгры=Y.ИдИгры AND Y.ИдК=R.ИдК]R)
[X.Фио="Анюков Александр Геннадьевич" AND R.ИдИгрока=X.ИдИгрока]X
 ', '35. Какие нападающие своего клуба были на поле вместе с Анюковым Александром Геннадьевичем?');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК35Л',
        'игрокинаполе AS Y, игрокиклубов AS X, игрокинаполе AS R, игрокиклубов AS C, клубы AS U',
        'U.Клуб, C.Фио AS Фио_Игрока, C.Страна, C.ДатаРожд AS Дата_Рождения, C.Возраст, C.Позиция', '(((X[X.Фио="Анюков Александр Геннадьевич" AND R.ИдИгрока=X.ИдИгрока]R)
[R.ИдИгры=Y.ИдИгры AND Y.ИдК=R.ИдК]Y)
[C.ИдИгрока=Y.ИдИгрока]C)
[C.Позиция="Нападение" AND C.ИдК=U.ИдК]U',
        '35. Какие нападающие своего клуба были на поле вместе с Анюковым Александром Геннадьевичем?');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('Q', 'DELETE', 'A001', 'нападающие AS A, календарь AS B, игрокиклубов AS C, клубы AS D, клубы AS E',
        'B.ИдИгры AS Игра, B.Дата, B.ИдКХ AS ИдХозяина, B.ИдКГ AS ИдГостя, D.Клуб AS Клуб_Хозяин, E.Клуб AS Клуб_Гость', '((A[A.ИдИгры=B.ИдИгры]B)[B.ИдКХ=D.ИдК]D)[B.ИдКГ=E.ИдК]E
[A.ИдИгрока # C.ИдИгрока]
(C[C.Позиция="Нападение" AND C.ИдК="к_06"]C)', 'DELETE:игры, в которых участвовали ВСЕ нападающие клуба Рубин (к_06)');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('TAB', 'счетигр', '0005', 'счетигр AS X', 'X.*', 'X', 'Счет игр');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'aК05К', 'календарь AS Y, клубы AS Z, клубы AS U, счетигр AS X',
        'X.ИдИгры, X.ХозГол, X.ГосГол, X.Счет, Z.Клуб AS Клуб_Хозяин, U.Клуб AS Клуб_Гость, Y.Дата', '(((Y[Y.ИдКГ=U.ИдК AND (U.Клуб="Динамо" OR U.Клуб="Зенит")]U)
[Y.ИдКХ=Z.ИдК AND (Z.Клуб="Динамо" OR Z.Клуб="Зенит")]Z)
[Y.ИдИгры=X.ИдИгры]X)', '5. Как играли Зенит и Динамо?
');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('В', 'запасе', 'E012 EXP', 'календарь AS X, игрокинаполе AS Z', 'Z.ИдИгрока', '(X[X.Дата = "2015-08-14" AND X.ИдИгры=Z.ИдИгры AND (Z.ИдК="к_03" OR Z.ИдК="к_05")]Z)
EXCEPT
(X[X.Дата < "2015-08-14" AND X.ИдИгры=Z.ИдИгры AND (Z.ИдК="к_03" OR Z.ИдК="к_05")]Z)[Z.ИдИгрока]',
        'Кого команды Спартак (к_03) и ЦСКА (к_05) выставили на игры до 2015-08-14');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('EXP', 'СпартакЦСКА', 'E001', 'игрокинаполе AS X, календарь AS Y', 'X.ИдИгры,X.ИдК,X.ИдИгрока,Y.Дата',
        '(Y[Y.ИдИгры=X.ИдИгры AND Y.ИдКХ="к_03" AND Y.ИдКГ="к_05"]X)', 'E001 Промежуточный запрос: Какие игроки клубов, принимали участие в игре Спартак-ЦСКА
');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('queries', 'algebra', 'T001 TAB', 'queries_algebra AS X', 'X.namequery, X.descquery', 'X', 'queries_algebra');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('EXP', 'КтоМогИграть', 'E011', 'календарь AS X, игрокинаполе AS Z', 'Z.ИдИгрока', '(X[X.Дата = "2015-08-14" AND X.ИдИгры=Z.ИдИгры AND (Z.ИдК="к_03" OR Z.ИдК="к_05")]Z)
EXCEPT
(X[X.Дата < "2015-08-14" AND X.ИдИгры=Z.ИдИгры AND (Z.ИдК="к_03" OR Z.ИдК="к_05")]Z)[Z.ИдИгрока]',
        'Кого команды Спартак (к_03) и ЦСКА (к_05) выставили на игры до 2015-08-14');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('Спа', 'ЦСКА', 'Игра', 'календарь AS X, игрокинаполе AS Z, клубы AS V, клубы AS W, игрокиклубов AS U ',
        'X.ИдИгры, X.Дата, U.Фио, Z.ИдИгрока, Z.ИдК', '((X[X.ИдИгры=Z.ИдИгры]Z)[Z.ИдИгрока=U.ИдИгрока]U
[X.ИдКХ=V.ИдК AND V.Клуб="Спартак"]V)
[X.ИдКГ=W.ИдК AND W.Клуб="ЦСКА"]W', 'Кого команды Спартак (к_03) и ЦСКА (к_05) выставили на игру');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('в', 'запасе', 'Был', 'игра_спа_цска AS X, кто_в_запасе AS Y, игрокиклубов AS Z',
        'X.ИдИгрока, Z.Фио AS Фамилия, Z.Позиция', '(X[X.ИдИгрока=Z.ИдИгрока]Z)
INTERSECT
(Y[Y.ИдИгрока=Z.ИдИгрока]Z)[Y.ИдИгрока, Z.Фио, Z.Позиция]', 'Кто был в запасе в играх до игры Спартак-ЦСКА ?');
INSERT INTO queries_algebra (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('в', 'запасе', 'кто', 'календарь AS X, игрокинаполе AS Z, игра_спа_цска AS Y, игрокиклубов AS W',
        'Z.ИдИгры, W.ИдИгрока, W.ИдК', '(((X[X.Дата < Y.Дата]Y)[X.ИдИгры=Z.ИдИгры AND Z.ИдК=Y.ИдК]Z)[Z.ИдК=W.ИдК]W
 EXCEPT
((X[X.Дата < Y.Дата]Y)[Z.ИдИгры<Y.ИдИгры AND Z.ИдК=Y.ИдК]Z)[Z.ИдИгры, Z.ИдИгрока, Z.ИдК]', 'Кого команды Спартак (к_03) и ЦСКА (к_05) не выставляли на игры
');

INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК10К', 'ИгрокиКлубов AS X, ИгрокиНаПоле AS Y, Клубы AS Z',
        'Z.Клуб, X.ИдИгрока, X.Фио, X.Страна, X.Позиция', 'X.ИдК=Z.ИдК AND Z.Клуб="Спартак" AND
FORALL Y [Y.ИдИгрока=X.ИдИгрока]', '10. Какие игроки команды Спартак не были на поле ни в одной игре?
Ответ: Все атрибуты игроков клубов');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК05К', 'календарь AS Y, клубы AS Z, клубы AS U, счетигр AS X',
        'X.ИдИгры, X.ХозГол, X.ГосГол, X.Счет, Z.Клуб AS Клуб_Хозяин, U.Клуб AS Клуб_Гость, Y.Дата', 'Y.ИдКГ=U.ИдК AND (U.Клуб="Динамо" OR U.Клуб="Зенит") AND
Y.ИдКХ=Z.ИдК AND (Z.Клуб="Динамо" OR Z.Клуб="Зенит") AND
Y.ИдИгры=X.ИдИгры', '5. 	Как играли Зенит и Динамо?
');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК01К', 'счетигр AS X, календарь AS Y, клубы AS Z, клубы AS U',
        'X.ИдИгры AS Игра, X.ХозГол AS Забил_Хозяин, X.ГосГол AS Забил_Гость, X.Счет, Z.Клуб AS Клуб_Хозяин, U.Клуб AS Клуб_Гость, Y.Дата',
        'Y.ИдКХ=Z.ИдК AND Y.Статус=1 AND Z.Клуб="Спартак" AND Y.ИдКГ=U.ИдК AND X.ИдИгры=Y.ИдИгры', '1. 	С какими командами играл Спартак дома?
Ответ: Игра, Хозяин, Гость, Дата, Хозяин Голы, Гость Голы, Счет');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК02К', 'счетигр AS X, календарь AS Y, клубы AS Z, клубы AS U',
        'X.ИдИгры AS Игра, X.ХозГол AS Забил_Хозяин, X.ГосГол AS Забил_гость, X.Счет, Z.Клуб AS Хозяин, U.Клуб AS Гость, Y.Дата',
        'Y.ИдКГ=U.ИдК AND Y.Статус=1 AND U.Клуб="Спартак" AND Y.ИдКХ=Z.ИдК AND X.ИдИгры=Y.ИдИгры', '2. 	С какими командами играл Спартак в гостях?
Ответ: Игра, Хозяин, Гость, Дата, Хозяин Голы, Гость Голы, Счет');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК03К', 'календарь AS Y, клубы AS Z, клубы AS U',
        'Y.ИдИгры, Y.Дата, Z.Клуб AS Клуб_Хозяин, U.Клуб AS Клуб_Гость',
        'Y.ИдКХ=Z.ИдК AND Y.Статус=0 AND Z.Клуб="Спартак" AND Y.ИдКГ=U.ИдК', '3. 	С какими командами будет играть Спартак дома?
Ответ: Игра, Хозяин, Гость, Дата');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК06К',
        'игрокинаполе AS X, календарь AS Y, клубы AS Z, клубы AS U, игрокиклубов AS V, клубы AS W',
        'W.Клуб, V.Фио AS Фио_Игрока, V.Страна, V.ДатаРожд AS Дата_Рождения, V.Возраст, V.Позиция', 'EXISTS X [X.ИдК=W.ИдК AND X.ИдИгрока=V.ИдИгрока AND
EXISTS Y [Y.ИдИгры=X.ИдИгры AND
EXISTS Z [Y.ИдКХ=Z.ИдК AND Z.Клуб="Динамо" AND
EXISTS U [Y.ИдКГ=U.ИдК AND U.Клуб="Рубин" AND (X.ИдК=Z.ИдК OR X.ИдК=U.ИдК)
]]]]', '6. 	Какие игроки принимали участие в игре Динамо-Рубин?
Ответ: Клуб, Фио Игрока, Страна, Дата Рождения, Возраст, Позиция !');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('TAB', 'Щукин', '0001', 'queries_tuple AS X', 'X.NameQuery,X.QueryBody', 'true',
        '21.  В каких играх выходили на поле все нападающие клуба Спартак?');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК08К', 'счетигр AS X, календарь AS Y, клубы AS Z, клубы AS U, клубы AS V, клубы AS W',
        'X.ИдИгры AS Игра, X.ХозГол AS Хозяин_Голы, X.ГосГол AS Гость_Голы, X.Счет, V.Клуб AS Хозяин, W.Клуб AS Гость, Y.Дата',
        'Y.ИдКХ=V.ИдК AND X.ИдИгры=Y.ИдИгры AND Y.ИдКГ=W.ИдК AND EXISTS Z [EXISTS U [(Y.ИдКХ=Z.ИдК AND Z.Клуб="Рубин" OR Y.ИдКГ=U.ИдК AND U.Клуб="Рубин")]]', '8. Какие игры сыграл Рубин?
Ответ: Игра, Хозяин, Гость, Дата, Хозяин Голы, Гость Голы, Счет');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК09К', 'игрокиклубов AS X, календарь AS Y, клубы AS Z, игрокинаполе AS V',
        'Y.ИдИгры AS Игра, Z.Клуб AS Хозяин, X.Фио AS Фио_Игрока, X.Страна, X.ДатаРожд AS Дата_Рождения, X.Возраст, X.Позиция',
        'Y.ИдКХ=Z.ИдК AND Y.Статус=1 AND Z.Клуб="Спартак" AND EXISTS V [V.ИдИгры=Y.ИдИгры AND Y.ИдКХ=V.ИдК AND V.ИдК=X.ИдК AND V.ИдИгрока=X.ИдИгрока]', '9. Какие игроки команды Спартак были на поле хотя бы в одной игре дома?
Ответ: Игра, Клуб, Фио Игрока, Страна, Дата Рождения, Возраст, Позиция');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК11К', 'ИгрокиКлубов AS X, ИгрокиНаПоле AS Y, Клубы AS Z', 'X.*', 'EXISTS Z [
EXISTS Y [X.ИдК=Z.ИдК AND Z.Клуб="Спартак" AND X.ИдИгрока=Y.ИдИгрока]]', '11.  Какие игроки команды Спартак были на поле хотя бы в одной игре?
Ответ: Все атрибуты игроков клубов');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК12Л', 'ИгрокиКлубов AS X, ИгрокиНаПоле AS Y', 'X.*',
        'X.ИдК="к_03" AND FORALL Y [Y.ИдК="к_03" IMPLY X.ИдИгрока<>Y.ИдИгрока]', '12.	Какие игрок не были на поле ни в одной игре?
Ответ: Все атрибуты игроков клубов');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК12М', 'ИгрокиКлубов AS X, ИгрокиНаПоле AS Y', 'X.*',
        'FORALL Y [1 IMPLY X.ИдИгрока<>Y.ИдИгрока]', '12.	Какие игрок не были на поле ни в одной игре?
Ответ: Все атрибуты игроков клубов');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК13К', 'ИгрокиКлубов AS X, Клубы AS Y, Клубы AS Z, Клубы AS U',
        'U.Клуб, X.ИдИгрока AS Игрок, X.Фио, X.Страна, X.Позиция', 'X.ИдК=U.ИдК AND
EXISTS Y [
EXISTS Z [(X.ИдК=Z.ИдК AND Z.Клуб="Спартак" OR X.ИдК=Y.ИдК AND Y.Клуб="Локомотив")]]', '13.  Перечислить игроков клуба Спартак и клуба Локомотив
Ответ: Все атрибуты игроков клубов');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК14К', 'ИгрокиКлубов AS X, Клубы AS Y, Клубы AS Z, Клубы AS U, ИгрокиНаПоле AS V',
        'U.Клуб, X.ИдИгрока, X.Фио, X.Страна, X.Позиция', 'X.ИдК=U.ИдК AND
EXISTS Y [
EXISTS Z [(X.ИдК=Z.ИдК AND Z.Клуб="Спартак" OR X.ИдК=Y.ИдК AND Y.Клуб="Локомотив") AND
EXISTS V [X.ИдИгрока=V.ИдИгрока]]]', '14.  Перечислить игроков клуба Спартак и клуба Локомотив, которые были на поле хотя бы в одной игре
Ответ: Все атрибуты игроков клубов');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК15К', 'ИгрокиКлубов AS X, Клубы AS Z, Клубы AS U, ИгрокиНаПоле AS V',
        'U.Клуб, X.ИдИгрока AS Игрок, X.Фио, X.Страна, X.Позиция',
        'EXISTS Z [X.ИдК=U.ИдК AND X.ИдК=Z.ИдК AND (Z.Клуб="Спартак" OR Z.Клуб="Локомотив") AND FORALL V [X.ИдИгрока=V.ИдИгрока]]', '15.  Перечислить игроков клуба Спартак и клуба Локомотив, которые не были на поле ни в одной игре
Ответ: Все атрибуты игроков клубов');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК16К', 'ИгрокиКлубов AS X, ИгрокиНаПоле AS Y, Календарь AS Q', 'Q.*', 'EXISTS X [X.Фио="Жирков Юрий Валентинович" AND
EXISTS Y [Y.ИдИгрока=X.ИдИгрока AND Q.ИдИгры=Y.ИдИгры]]',
        '16. 	В каких играх принимал участие Жирков Юрий Валентинович');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК18К', 'ИгрокиКлубов AS X, ИгрокиНаПоле AS Y, Клубы AS Z',
        'Z.Клуб AS Клуб, X.ИдИгрока, X.Фио AS ФИО_Игрока, X.Страна AS Страна, X.ДатаРожд AS Дата_Рождения, X.Возраст AS Возраст, X.Позиция AS Позиция',
        'Z.ИдК=X.ИдК AND FORALL Y [1 IMPLY X.ИдИгрока<>Y.ИдИгрока]', '18. Перечислить игроков, которые не принимали участие ни в одной игре
Ответ: Все атрибуты игроков клубов');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК20К',
        'календарь AS X, клубы AS Z, клубы AS V, игрокиклубов AS Y, игрокинаполе AS W, клубы AS U',
        'U.Клуб, Y.ИдИгрока AS Игрок, Y.Фио, Y.Страна, Y.Возраст', 'Y.Позиция="Защита" AND Y.ИдК=U.ИдК AND
EXISTS Z [Z.Клуб="Спартак" AND
EXISTS V [V.Клуб="ЦСКА" AND
EXISTS X [X.ИдКХ=Z.ИдК AND X.ИдКГ=V.ИдК AND
EXISTS W [X.ИдИгры=W.ИдИгры AND W.ИдИгрока=Y.ИдИгрока]]]]', '20. Кто находился на линии защиты в игре Спартак-ЦСКА?');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК21К',
        'игрокиклубов AS X, клубы AS Z, игрокинаполе AS V, календарь AS U, клубы AS Y, клубы AS W, счетигр AS Q',
        'U.ИдИгры AS Игра, U.Дата, Y.Клуб AS Хозяин, W.Клуб AS Гость, Q.Счет', 'U.ИдКХ=Y.ИдК AND U.ИдКГ=W.ИдК AND U.ИдИгры=Q.ИдИгры AND
FORALL X [X.Позиция="Нападение"
AND EXISTS Z [Z.ИдК=X.ИдК AND Z.Клуб="Рубин"
IMPLY
EXISTS V [V.ИдИгры=U.ИдИгры AND X.ИдИгрока=V.ИдИгрока]]]',
        '21.  В каких играх выходили на поле все нападающие клуба Спартак?');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК17К', 'календарь AS U, игрокинаполе AS V, игрокиклубов AS W, клубы AS X,
клубы AS Y', 'U.ИдИгры, U.Дата, X.Клуб AS Клуб_Хозяин, Y.Клуб AS Клуб_Гость', 'U.ИдКХ=X.ИдК AND U.ИдКГ=Y.ИдК AND
FORALL W [(W.Фио="Дьяков Виталий Александрович" OR W.Фио="Алвим Маринато Гилерме") IMPLY
EXISTS V [V.ИдИгрока=W.ИдИгрока AND V.ИдИгры=U.ИдИгры]]', '17.  В каких играх Дьяков Виталий Александрович и Алвим Маринато Гилерме были на поле вместе
Ответ: Все атрибуты игры');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК22К', 'игрокиклубов AS X, игрокиклубов AS Y, клубы AS A, игрокиклубов AS Z',
        'A.Клуб, X.Фио AS Фио_Игрока, X.Страна, X.ДатаРожд AS Дата_Рождения, X.Возраст, X.Позиция',
        'A.ИдК=X.ИдК AND A.Клуб="Динамо" AND FORALL Y [Y.ИдК=X.ИдК IMPLY X.Возраст>=Y.Возраст]',
        '22.  Найти самого старшего игрока клуба Динамо.');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК27К', 'календарь AS Z, календарь AS X, клубы AS V, клубы AS W',
        'Z.ИдИгры AS Игра, Z.Дата, V.Клуб AS Хозяин, W.Клуб AS Гость',
        'Z.ИдКХ=V.ИдК AND Z.ИдКГ=W.ИдК AND FORALL X [True IMPLY Z.Дата<=X.Дата]', '27.  Какие команды завершат чемпионат 2015?
       Ответ(Игра, Хозяин, Гость, Дата)');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК24К', 'игрокиклубов AS X, игрокиклубов AS Y, клубы AS A',
        'A.Клуб, X.Фио AS Фио_Игрока, X.Страна, X.ДатаРожд AS Дата_Рождения, X.Возраст, X.Позиция',
        'A.ИдК=X.ИдК AND FORALL Y [True IMPLY X.Возраст>=Y.Возраст]', '24.  Найти старших игроков чемпионата 2015.');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК26К', 'календарь AS Z, календарь AS X, клубы AS V, клубы AS W',
        'Z.ИдИгры AS Игра, Z.Дата, V.Клуб AS Хозяин, W.Клуб AS Гость',
        'Z.ИдКХ=V.ИдК AND Z.ИдКГ=W.ИдК AND FORALL X [True IMPLY Z.Дата>=X.Дата]', '26. Какие команды встречались первыми в чемпионате 2015?
       Ответ(Игра, Хозяин, Гость, Дата)');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК32К',
        'календарь AS X, клубы AS Z, клубы AS A, игрокиклубов AS Y, игрокиклубов AS B, игрокинаполе AS C, игрокинаполе AS W',
        'Y.ИдИгрока,Y.Фио,Y.ДатаРожд,Y.Возраст,Y.Страна,Y.ИдК,Y.Номер,Y.Позиция', 'EXISTS Z [Z.Клуб="ЦСКА" AND
EXISTS A [A.Клуб="Зенит" AND
EXISTS X [X.ИдКХ=Z.ИдК AND X.ИдКГ=A.ИдК AND
EXISTS W [W.ИдИгры=X.ИдИгры AND Y.ИдИгрока=W.ИдИгрока AND
FORALL C [W.ИдИгры=C.ИдИгры IMPLY
EXISTS B [B.ИдИгрока=C.ИдИгрока AND Y.ДатаРожд>=B.ДатаРожд]]]]]]',
        '32.  Кто был самым младшим на поле в игре ЦСКА-Зенит?');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК31К',
        'календарь AS X, клубы AS Z, клубы AS A, игрокиклубов AS Y, игрокиклубов AS B, игрокинаполе AS C, игрокинаполе AS W',
        'Y.ИдИгрока, Y.Фио, Y.ДатаРожд, Y.Возраст, Y.Позиция', 'EXISTS Z [Z.Клуб="ЦСКА" AND
EXISTS A [A.Клуб="Зенит" AND
EXISTS X [X.ИдКХ=Z.ИдК AND X.ИдКГ=A.ИдК AND
EXISTS W [W.ИдИгры=X.ИдИгры AND Y.ИдИгрока=W.ИдИгрока AND
FORALL C [W.ИдИгры=C.ИдИгры IMPLY
EXISTS B [B.ИдИгрока=C.ИдИгрока AND Y.ДатаРожд>=B.ДатаРожд]]]]]]',
        '31. Кто был самым младшим на поле в игре ЦСКА-Зенит?');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК35М',
        'игрокинаполе AS Y, игрокиклубов AS X, игрокинаполе AS R, игрокиклубов AS C, клубы AS U',
        'U.Клуб, C.Фио AS Фио_Игрока, C.Страна, C.ДатаРожд AS Дата_Рождения, C.Возраст, C.Позиция', 'C.Позиция="Нападение" AND C.ИдК=U.ИдК And
EXISTS X [X.Фио="Анюков Александр Геннадьевич" AND
EXISTS R [R.ИдИгрока=X.ИдИгрока AND
EXISTS Y [R.ИдИгры=Y.ИдИгры AND Y.ИдК=R.ИдК AND C.ИдИгрока=Y.ИдИгрока ]]]',
        '35. Какие нападающие своего клуба были на поле вместе с Анюковым Александром Геннадьевичем?');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК38Л', 'календарь AS X, календарь AS Y, клубы AS U, клубы AS I, счетигр AS J',
        'X.ИдИгры AS Игра, X.Дата, U.Клуб AS Хозяин, I.Клуб AS Гость, J.Счет',
        'X.ИдКХ=U.ИдК AND X.ИдКГ=I.ИдК AND X.ИдИгры=J.ИдИгры AND FORALL Y [Y.Статус=1 AND Y.ИдКХ=X.ИдКХ IMPLY X.ИдИгры=Y.ИдИгры]',
        '38. Какая команда сыгала только одну игру дома?');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК38К', 'календарь AS X, календарь AS Y, клубы AS U, клубы AS I, счетигр AS J',
        'X.ИдИгры AS Игра, X.Дата, U.Клуб AS Хозяин, I.Клуб AS Гость, J.Счет',
        'X.ИдКХ=U.ИдК AND X.ИдКГ=I.ИдК AND X.ИдИгры=J.ИдИгры AND FORALL Y [Y.Статус=1 AND Y.ИдКХ=X.ИдКХ IMPLY X.ИдИгры=Y.ИдИгры]', '38. Какая команда сыгала только одну игру дома?

Ответ - все атрибуты игры:  Игра, Хозяин, Гость, Дата, Счет');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК35К',
        'игрокинаполе AS Y, игрокиклубов AS X, игрокинаполе AS C, игрокиклубов AS D, клубы AS U',
        'U.Клуб, D.Фио AS Фио_Игрока, D.Страна, D.ДатаРожд AS Дата_Рождения, D.Возраст, D.Позиция', 'D.Позиция="Нападение" AND D.ИдК=U.ИдК AND
EXISTS X [X.Фио="Анюков Александр Геннадьевич" AND
EXISTS Y [X.ИдИгрока=Y.ИдИгрока AND
EXISTS C [Y.ИдИгры=C.ИдИгры AND C.ИдК<>X.ИдК AND C.ИдИгрока=D.ИдИгрока]]]',
        '35. Каким нападающим противостоял на поле Анюков Александр Геннадьевич?');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК31Л', 'игрокиклубов AS Y, игрокиклубов AS B, игрокинаполе AS C, игрокинаполе AS W',
        'Y.ИдИгрока,Y.Фио,Y.ДатаРожд,Y.Возраст,Y.Страна,Y.ИдК,Y.Номер,Y.Позиция', 'EXISTS W [W.ИдИгры=108 AND Y.ИдИгрока=W.ИдИгрока AND
FORALL C [W.ИдИгры=C.ИдИгры IMPLY
EXISTS B [B.ИдИгрока=C.ИдИгрока AND Y.ДатаРожд<=B.ДатаРожд]]]', '31. Кто был самым старшим на поле в игре ЦСКА-Зенит?

Объясняющий запрос ! Он полностью совпадает с запросом 31 из 1_Чемпионата. Теперь надо вычислить константу 108.');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК04К', 'календарь AS Y, клубы AS Z, клубы AS U',
        'Y.ИдИгры, Y.Дата, Z.Клуб AS Клуб_Хозяин, U.Клуб AS Клуб_Гость',
        'Y.ИдКГ=U.ИдК AND Y.Статус=0 AND U.Клуб="Спартак" AND Y.ИдКХ=Z.ИдК', '4. 	С какими командами будет играть Спартак в гостях?
Ответ: Игра, Хозяин, Гость, Дата');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК19К', 'игрокиклубов AS X, игрокинаполе AS Y, календарь AS Z, клубы AS U, клубы AS V',
        'Z.ИдИгры AS Игра, Z.Дата, U.Клуб AS Хозяин, V.Клуб AS Гость', 'Z.ИдКХ=U.ИдК AND Z.ИдКГ=V.ИдК AND
EXISTS X [X.Фио="Ансальди Кристиан Даниэл" AND
EXISTS Y [Y.ИдК=X.ИдК AND Z.ИдИгры=Y.ИдИгры]]', '19.  В каких играх выходил на поле Ансальди Кристиан Даниэл?
Ответ: Все атрибуты игроков клубов');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК23К', 'игрокиклубов AS X, игрокиклубов AS Y, клубы AS A',
        'A.Клуб, X.Фио AS Фио_Игрока, X.Страна, X.ДатаРожд AS Дата_Рождения, X.Возраст, X.Позиция',
        'A.ИдК=X.ИдК AND FORALL Y [Y.ИдК=X.ИдК IMPLY X.Возраст>=Y.Возраст]', '23.  Найти старших игроков клубов.');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('EXP', 'ДьяковГилерме', '1001', 'календарь AS U, игрокинаполе AS V, игрокиклубов AS W, клубы AS X,
клубы AS Y', 'U.ИдИгры AS Игра, U.Дата, X.Клуб AS Клуб_Хозяин, Y.Клуб AS Клуб_Гость', 'U.ИдКХ=X.ИдК AND U.ИдКГ=Y.ИдК AND
FORALL W [(W.Фио="Дьяков Виталий Александрович" OR W.Фио="Алвим Маринато Гилерме") IMPLY
EXISTS V [V.ИдИгрока=W.ИдИгрока AND V.ИдИгры=U.ИдИгры]]', '17.  В каких играх Дьяков Виталий Александрович и Алвим Маринато Гилерме были на поле вместе
');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК25К', 'игрокиклубов AS Z, игрокиклубов AS Y, клубы AS X',
        'X.Клуб, Y.Фио AS Фио_Игрока, Y.Страна, Y.ДатаРожд AS Дата_Рождения, Y.Возраст, Y.Позиция', 'Y.Позиция="Защита" AND X.ИдК=Y.ИдК AND X.Клуб="Зенит" AND
FORALL Z [Z.ИдК=Y.ИдК AND Z.Позиция=Y.Позиция IMPLY Y.ДатаРожд>=Z.ДатаРожд]', '25. Найти самого младшего защитника команды Зенит.
       Ответ: Клуб, Фио Игрока, Страна, Дата Рождения, Возраст, Позиция');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК28К', 'календарь AS Z, календарь AS X, клубы AS V, клубы AS W',
        'Z.ИдИгры AS Игра, Z.Дата, V.Клуб AS Хозяин, W.Клуб AS Гость', 'Z.ИдКХ=V.ИдК AND Z.Месяц=10 AND Z.ИдКГ=W.ИдК',
        '28.  Какие игры пройдут в октябре?');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('999', 'Щукин', 'tК43К', 'календарь AS Y, клубы AS Z, клубы AS U',
        'Y.ИдИгры AS Игра, Y.Дата, Y.Статус, Z.Клуб AS Хозяин, U.Клуб AS Гость', 'Y.ИдКГ=U.ИдК AND (U.Клуб="Динамо" OR U.Клуб="Зенит") AND
Y.ИдКХ=Z.ИдК AND (Z.Клуб="Динамо" OR Z.Клуб="Зенит")', '43.	Когда играют Зенит и Динамо?
Ответ: Игра, Хозяин, Гость, Дата, Статус');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('TAB', 'Календарь', 'T001', 'календарь AS Y', 'Y.ИдИгры,Y.ИдКХ,Y.ИдКГ,Y.Дата,Y.Год,Y.Месяц,Y.Статус', 'True',
        '1. 	Календарь');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('TAB', 'queries tuple', 'T001', 'queries_tuple AS X',
        'X.namequery AS Имя_Запроса, X.descquery AS Описание_Запроса',
        'True', 'queries_tuple
');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('Q', 'DELETE', 'T002', 'нападающие AS A, календарь AS B, игрокиклубов AS C, клубы AS D, клубы AS E',
        'B.ИдИгры AS Игра, B.Дата, B.ИдКХ AS ИдХозяина, B.ИдКГ AS ИдГостя, D.Клуб AS Клуб_Хозяин, E.Клуб AS Клуб_Гость', 'B.ИдКХ=D.ИдК AND B.ИдКГ=E.ИдК AND
FORALL C [C.Позиция="Нападение" AND C.ИдК="к_06" IMPLY
EXISTS A [A.ИдИгры=B.ИдИгры AND A.ИдИгрока = C.ИдИгрока]]',
        'DELETE:игры, в которых участвовали ВСЕ нападающие клуба Рубин (к_06)');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('Q', 'DELETE', 'T003', 'игрокинаполе AS A, календарь AS B, игрокиклубов AS C, клубы AS D, клубы AS E',
        'B.ИдИгры AS Игра, B.Дата, B.ИдКХ AS ИдХозяина, B.ИдКГ AS ИдГостя, D.Клуб AS Клуб_Хозяин, E.Клуб AS Клуб_Гость', 'B.ИдКХ=D.ИдК AND B.ИдКГ=E.ИдК AND
FORALL C [C.Позиция="Нападение" AND C.ИдК="к_06" IMPLY
EXISTS A [A.ИдИгры=B.ИдИгры AND A.ИдИгрока = C.ИдИгрока AND A.ИдК="к_06"]]',
        'DELETE:игры, в которых участвовали ВСЕ нападающие клуба Рубин (к_06)');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('q', 'q', 'q', '', '', '', '');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('в', 'запасе', 'Были', 'игра_07_спартак_цска AS X, игрокинаполе AS Y', 'X.ИдИгрока, X.Фио AS Фамилия',
        'EXISTS Y [X.ИдИгры=Y.ИдИгры AND X.ИдИгрока=Y.ИдИгрока]', '');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('07', 'Спартак', 'Игра', 'игрокиклубов AS X, игрокинаполе AS Y, календарь AS Z, клубы AS Q, клубы AS W',
        'Z.ИдИгры, X.ИдК, X.ИдИгрока, X.Фио', 'Z.Статус=1 AND (Z.ИдКХ=X.ИдК OR Z.ИдКГ=X.ИдК) AND
EXISTS Q [Z.ИдКХ=Q.ИдК AND Q.Клуб="Спартак" AND
EXISTS W [Z.ИдКГ=W.ИдК AND W.Клуб="ЦСКА" AND
NOT EXISTS Y [Y.ИдИгры<Z.ИдИгры AND X.ИдИгрока=Y.ИдИгрока
]]]', '7. Какие игроки клубов, принимавших участие в игре Спартак-ЦСКА, бывали в запасе до этой игры?
');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('071', 'Спартак', 'Игра',
        'игрокиклубов AS X, игрокинаполе AS Y, календарь AS Z, клубы AS Q, клубы AS W, игрокинаполе AS R',
        'Z.ИдИгры, X.ИдК, X.ИдИгрока, X.Фио', 'Z.Статус=1 AND
EXISTS Q [Z.ИдКХ=Q.ИдК AND Q.Клуб="Спартак" AND
EXISTS W [Z.ИдКГ=W.ИдК AND W.Клуб="ЦСКА" AND
EXISTS R [Z.ИдИгры=R.ИдИгры AND X.ИдИгрока=R.ИдИгрока AND
NOT EXISTS Y [Y.ИдИгры<Z.ИдИгры AND X.ИдИгрока=Y.ИдИгрока]]]]',
        '7. Какие игроки клубов, принимавших участие в игре Спартак-ЦСКА, бывали в запасе до этой игры?');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('073', 'Спартак', 'Игра', 'игрокиклубов AS X, игрокинаполе AS Y, игрокинаполе AS R', 'X.ИдК, X.ИдИгрока, X.Фио', 'NOT FORALL R [R.ИдИгры=105 AND X.ИдИгрока=R.ИдИгрока IMPLY
EXISTS Y [Y.ИдИгры<R.ИдИгры AND R.ИдИгрока=Y.ИдИгрока]]', '7. Какие игроки клубов, принимавших участие в игре Спартак-ЦСКА, бывали в запасе до этой игры?
ИдИгры Спартак-ЦСКА = 105 (или надо вычислять его 071, 072)
FORALL - на поле в каждой игре
NOT FORALL - иногда в запмсе');
INSERT INTO queries_tuple (query_group, last_name, query_id, table_variables, target_list, query_body, description)
VALUES ('072', 'Спартак', 'Игра',
        'игрокиклубов AS X, игрокинаполе AS Y, игрокинаполе AS R, календарь AS Z, клубы AS Q, клубы AS W',
        'Z.ИдИгры, X.ИдК, X.ИдИгрока, X.Фио', 'Z.Статус=1 AND
EXISTS Q [Z.ИдКХ=Q.ИдК AND Q.Клуб="Спартак" AND
EXISTS W [Z.ИдКГ=W.ИдК AND W.Клуб="ЦСКА" AND
NOT FORALL R [R.ИдИгры=Z.ИдИгры AND X.ИдИгрока=R.ИдИгрока IMPLY
EXISTS Y [Y.ИдИгры<R.ИдИгры AND R.ИдИгрока=Y.ИдИгрока]]', '7. Какие игроки клубов, принимавших участие в игре Спартак-ЦСКА, бывали в запасе до этой игры?
ИдИгры Спартак-ЦСКА = 105 (или надо вычислять его 071,072)
FORALL - на поле в каждой игре
NOT FORALL - иногда в запмсе');

INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_01_03', 'к_01', '03', 'Бюттнер Александер', 'Голландия', '1989-02-11', 26, 'Защита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_01_05', 'к_01', '05', 'Дьяков Виталий Александрович', 'Россия', '1989-01-31', 26, 'Защита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_01_08', 'к_01', '08', 'Погребняк Павел Викторович', 'Россия', '1983-11-08', 32, 'Нападение');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_01_11', 'к_01', '11', 'Ионов Алексей Сергеевич', 'Россия', '1989-02-18', 26, 'Полузащита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_01_18', 'к_01', '18', 'Жирков Юрий Валентинович', 'Россия', '1983-08-20', 32, 'Полузащита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_01_22', 'к_01', '22', 'Соломатин Павел Олегович', 'Россия', '1993-04-04', 22, 'Нападение');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_01_30', 'к_01', '30', 'Габулов Владимир Борисович', 'Россия', '1983-10-19', 32, 'Вратарь');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_02_02', 'к_02', '02', 'Анюков Александр Геннадьевич', 'Россия', '1982-09-28', 33, 'Защита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_02_03', 'к_02', '03', 'Ансальди Кристиан Даниэл', 'Аргентина', '1986-09-20', 29, 'Защита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_02_10', 'к_02', '10', 'Алвес Гомес Данни Мигель', 'Португалия', '1983-08-07', 32, 'Полузащита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_02_22', 'к_02', '22', 'Дзюба Артём Сергеевич', 'Россия', '1988-08-22', 27, 'Нападение');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_02_91', 'к_02', '91', 'Денисов Егор Игоревич', 'Россия', '1998-02-06', 17, 'Нападение');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_02_95', 'к_02', '95', 'Васютин Александр Юрьевич', 'Россия', '1995-03-04', 20, 'Вратарь');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_03_01', 'к_03', '01', 'Митрюшкин Антон Владимирович', 'Россия', '1996-02-08', 19, 'Вратарь');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_03_03', 'к_03', '03', 'Брызгалов Сергей Владимирович', 'Россия', '1992-11-15', 23, 'Защита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_03_05', 'к_03', '05', 'Борхес Монтейро Ромуло', 'Бразилия', '1990-09-19', 25, 'Защита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_03_08', 'к_03', '08', 'Глушаков Денис Борисович', 'Россия', '1987-01-27', 28, 'Полузащита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_03_09', 'к_03', '09', 'Давыдов Денис Алексеевич', 'Россия', '1995-03-22', 20, 'Нападение');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_03_10', 'к_03', '10', 'Мовсисян Юра', 'Армения', '1987-08-02', 28, 'Нападение');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_03_11', 'к_03', '11', 'Озбилиз Арас', 'Армения', '1990-03-09', 25, 'Полузащита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_04_01', 'к_04', '01', 'Алвим Маринато Гилерме', 'Бразилия', '1985-12-12', 30, 'Вратарь');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_04_07', 'к_04', '07', 'Маркес Битенкурт Майкон', 'Бразилия', '1990-02-18', 25, 'Нападение');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_04_09', 'к_04', '09', 'Григорьев Максим Сергеевич', 'Россия', '1990-07-06', 25, 'Полузащита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_04_11', 'к_04', '11', 'Буссуфа Мбарк', 'Голландия', '1984-08-15', 31, 'Полузащита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_04_15', 'к_04', '15', 'Логашов Арсений Максимович', 'Россия', '1991-08-20', 24, 'Защита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_04_21', 'к_04', '21', 'Ниассе Байе Умар', 'Сенегал', '1990-04-18', 25, 'Нападение');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_04_29', 'к_04', '29', 'Денисов Виталий Геннадьевич', 'Узбекистан', '1987-02-23', 28, 'Защита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_05_03', 'к_05', '03', 'Вернблум Понтус Андерс Микаэль', 'Швеция', '1986-06-25', 29, 'Полузащита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_05_04', 'к_05', '04', 'Игнашевич Сергей Николаевич', 'Россия', '1979-07-14', 36, 'Защита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_05_06', 'к_05', '06', 'Березуцкий Алексей Владимирович', 'Россия', '1982-06-20', 33, 'Защита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_05_08', 'к_05', '08', 'Панченко Кирилл Викторович', 'Россия', '1989-10-16', 26, 'Нападение');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_05_10', 'к_05', '10', 'Дзагоев Алан Елизбарович', 'Россия', '1990-06-17', 25, 'Полузащита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_05_35', 'к_05', '35', 'Акинфеев Игорь Владимирович', 'Россия', '1986-04-08', 29, 'Вратарь');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_05_88', 'к_05', '88', 'Думбия Сейду ', 'Кот-д`Ивуар', '1987-12-31', 28, 'Нападение');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_06_01', 'к_06', '01', 'Рыжиков Сергей Викторович', 'Россия', '1980-09-19', 35, 'Вратарь');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_06_03', 'к_06', '03', 'Набиуллин Эльмир Рамилевич', 'Россия', '1995-03-08', 20, 'Защита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_06_05', 'к_06', '05', 'Кверквелия Соломон', 'Грузия', '1992-02-06', 23, 'Полузащита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_06_07', 'к_06', '07', 'Портнягин Игорь Игоревич', 'Россия', '1989-01-07', 26, 'Нападение');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_06_08', 'к_06', '08', 'Батов Максим Сергеевич', 'Россия', '1992-06-05', 23, 'Защита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_06_11', 'к_06', '11', 'Марко Девич', 'Украина', '1983-10-27', 32, 'Нападение');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_06_14', 'к_06', '14', 'Билялетдинов Динияр Ринатович', 'Россия', '1985-02-27', 30, 'Полузащита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_07_04', 'к_07', '04', 'Зайцев Николай Евгеньевич', 'Россия', '1989-06-01', 26, 'Защита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_08_43', 'к_08', '43', 'Бугаев Роман Игоревич', 'Россия', '1989-02-11', 26, 'Защита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_09_01', 'к_09', '01', 'Годзюр Ярослав Михайлович', 'Россия', '1985-03-06', 30, 'Вратарь');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_09_03', 'к_09', '03', 'Григалашвили Тедоре', 'Грузия', '1993-05-12', 22, 'Защита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_09_06', 'к_09', '06', 'Варкен Адилсон', 'Бразилия', '1987-01-16', 28, 'Полузащита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_09_09', 'к_09', '09', 'Садаев Заур Умарович', 'Россия', '1989-11-06', 26, 'Нападение');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_09_13', 'к_09', '13', 'Кудряшов Фёдор Васильевич', 'Россия', '1987-04-05', 28, 'Защита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_09_14', 'к_09', '14', 'Айссати Исмаил', 'Голландия', '1988-08-16', 27, 'Полузащита');
INSERT INTO "игрокиклубов" ("ИдИгрока", "ИдК", "Номер", "Фио", "Страна", "ДатаРожд", "Возраст", "Позиция")
VALUES ('к_09_17', 'к_09', '17', 'Вье Аблае Мбенгуе', 'Сенегал', '1992-05-19', 23, 'Нападение');

INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (101, 'к_05', 'к_05_03');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (101, 'к_05', 'к_05_04');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (101, 'к_05', 'к_05_06');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (101, 'к_05', 'к_05_35');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (101, 'к_05', 'к_05_88');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (101, 'к_06', 'к_06_01');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (101, 'к_06', 'к_06_03');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (101, 'к_06', 'к_06_05');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (101, 'к_06', 'к_06_11');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (101, 'к_06', 'к_06_14');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (102, 'к_01', 'к_01_03');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (102, 'к_01', 'к_01_11');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (102, 'к_01', 'к_01_18');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (102, 'к_01', 'к_01_22');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (102, 'к_01', 'к_01_30');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (102, 'к_02', 'к_02_02');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (102, 'к_02', 'к_02_03');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (102, 'к_02', 'к_02_22');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (102, 'к_02', 'к_02_91');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (102, 'к_02', 'к_02_95');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (103, 'к_01', 'к_01_03');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (103, 'к_01', 'к_01_05');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (103, 'к_01', 'к_01_08');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (103, 'к_01', 'к_01_11');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (103, 'к_01', 'к_01_30');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (103, 'к_04', 'к_04_01');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (103, 'к_04', 'к_04_07');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (103, 'к_04', 'к_04_09');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (105, 'к_03', 'к_03_08');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (103, 'к_04', 'к_04_21');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (103, 'к_04', 'к_04_29');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (104, 'к_03', 'к_03_01');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (104, 'к_03', 'к_03_10');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (104, 'к_03', 'к_03_08');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (104, 'к_03', 'к_03_09');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (104, 'к_03', 'к_03_11');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (104, 'к_06', 'к_06_01');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (104, 'к_06', 'к_06_07');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (104, 'к_06', 'к_06_08');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (104, 'к_06', 'к_06_11');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (104, 'к_06', 'к_06_14');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (105, 'к_03', 'к_03_01');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (105, 'к_03', 'к_03_03');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (105, 'к_03', 'к_03_11');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (105, 'к_03', 'к_03_10');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (105, 'к_05', 'к_05_03');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (105, 'к_05', 'к_05_06');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (105, 'к_05', 'к_05_10');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (105, 'к_05', 'к_05_35');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (105, 'к_05', 'к_05_88');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (106, 'к_02', 'к_02_02');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (106, 'к_02', 'к_02_03');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (106, 'к_02', 'к_02_22');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (106, 'к_02', 'к_02_91');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (106, 'к_02', 'к_02_95');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (106, 'к_06', 'к_06_01');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (106, 'к_06', 'к_06_03');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (106, 'к_06', 'к_06_05');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (106, 'к_06', 'к_06_07');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (106, 'к_06', 'к_06_14');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (107, 'к_04', 'к_04_01');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (107, 'к_04', 'к_04_07');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (107, 'к_04', 'к_04_09');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (107, 'к_04', 'к_04_11');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (107, 'к_04', 'к_04_29');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (107, 'к_06', 'к_06_01');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (107, 'к_06', 'к_06_03');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (107, 'к_06', 'к_06_07');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (107, 'к_06', 'к_06_08');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (107, 'к_06', 'к_06_11');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (108, 'к_02', 'к_02_03');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (108, 'к_02', 'к_02_10');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (108, 'к_02', 'к_02_22');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (108, 'к_02', 'к_02_91');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (108, 'к_02', 'к_02_95');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (108, 'к_05', 'к_05_03');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (108, 'к_05', 'к_05_08');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (108, 'к_05', 'к_05_10');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (108, 'к_05', 'к_05_35');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (108, 'к_05', 'к_05_88');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (109, 'к_01', 'к_01_03');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (109, 'к_01', 'к_01_05');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (109, 'к_01', 'к_01_11');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (109, 'к_01', 'к_01_18');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (109, 'к_01', 'к_01_30');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (109, 'к_06', 'к_06_01');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (109, 'к_06', 'к_06_03');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (109, 'к_06', 'к_06_08');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (109, 'к_06', 'к_06_11');
INSERT INTO "игрокинаполе" ("ИдИгры", "ИдК", "ИдИгрока")
VALUES (109, 'к_06', 'к_06_14');

INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (101, 'к_05', 'к_06', '2015-07-18', 2015, 7, 1);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (102, 'к_02', 'к_01', '2015-07-19', 2015, 7, 1);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (103, 'к_04', 'к_01', '2015-08-02', 2015, 8, 1);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (104, 'к_03', 'к_06', '2015-08-03', 2015, 8, 1);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (105, 'к_03', 'к_05', '2015-08-14', 2015, 8, 1);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (106, 'к_06', 'к_02', '2015-08-24', 2015, 8, 1);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (107, 'к_06', 'к_04', '2015-09-12', 2015, 9, 1);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (108, 'к_05', 'к_02', '2015-09-12', 2015, 9, 1);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (109, 'к_01', 'к_06', '2015-09-21', 2015, 9, 1);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (110, 'к_03', 'к_02', '2015-09-26', 2015, 9, 0);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (111, 'к_05', 'к_04', '2015-09-26', 2015, 9, 0);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (112, 'к_01', 'к_05', '2015-10-04', 2015, 10, 0);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (113, 'к_03', 'к_04', '2015-10-18', 2015, 10, 0);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (114, 'к_01', 'к_03', '2015-10-25', 2015, 10, 0);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (115, 'к_04', 'к_02', '2015-11-06', 2015, 11, 0);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (116, 'к_01', 'к_04', '2015-11-27', 2015, 11, 0);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (117, 'к_06', 'к_03', '2015-11-27', 2015, 11, 0);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (118, 'к_05', 'к_03', '2016-03-01', 2016, 3, 0);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (119, 'к_02', 'к_06', '2016-03-11', 2016, 3, 0);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (120, 'к_04', 'к_06', '2016-04-02', 2016, 4, 0);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (121, 'к_02', 'к_05', '2016-04-02', 2016, 4, 0);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (122, 'к_06', 'к_01', '2016-04-08', 2016, 4, 0);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (123, 'к_04', 'к_05', '2016-04-15', 2016, 4, 0);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (124, 'к_02', 'к_03', '2016-04-15', 2016, 4, 0);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (125, 'к_05', 'к_01', '2016-04-23', 2016, 4, 0);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (126, 'к_04', 'к_03', '2016-04-30', 2016, 4, 0);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (127, 'к_03', 'к_01', '2016-05-06', 2016, 5, 0);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (128, 'к_02', 'к_04', '2016-05-13', 2016, 5, 0);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (129, 'к_01', 'к_02', '2016-05-21', 2016, 5, 0);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (130, 'к_06', 'к_05', '2016-05-21', 2016, 5, 0);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (131, 'к_07', 'к_03', '2015-08-22', 2015, 8, 1);
INSERT INTO "календарь" ("ИдИгры", "ИдКХ", "ИдКГ", "Дата", "Год", "Месяц", "Статус")
VALUES (132, 'к_08', 'к_03', '2015-09-19', 2015, 9, 1);

INSERT INTO "клубы" ("ИдК", "Клуб", "Тренер")
VALUES ('к_01', 'Динамо', 'Кобелев Андрей Николаевич');
INSERT INTO "клубы" ("ИдК", "Клуб", "Тренер")
VALUES ('к_02', 'Зенит', 'Виллаш-Боаш Андре');
INSERT INTO "клубы" ("ИдК", "Клуб", "Тренер")
VALUES ('к_03', 'Спартак', 'Аленичев Дмитрий Анатольевич');
INSERT INTO "клубы" ("ИдК", "Клуб", "Тренер")
VALUES ('к_04', 'Локомотив', 'Черевченко Игорь Геннадьевич');
INSERT INTO "клубы" ("ИдК", "Клуб", "Тренер")
VALUES ('к_05', 'ЦСКА', 'Слуцкий Леонид Викторович');
INSERT INTO "клубы" ("ИдК", "Клуб", "Тренер")
VALUES ('к_06', 'Рубин', 'Чалый Валерий Александрович');
INSERT INTO "клубы" ("ИдК", "Клуб", "Тренер")
VALUES ('к_07', 'Амкар', 'Гаджиев Гаджи Муслимович');
INSERT INTO "клубы" ("ИдК", "Клуб", "Тренер")
VALUES ('к_08', 'Кубань', 'Хохлов Дмитрий Валерьевич');
INSERT INTO "клубы" ("ИдК", "Клуб", "Тренер")
VALUES ('к_09', 'Терек', 'Рахимов Рашид Маматкулович');

INSERT INTO "счетигр" ("ИдИгры", "ХозГол", "ГосГол", "Счет")
VALUES (101, 1, 0, '1:0');
INSERT INTO "счетигр" ("ИдИгры", "ХозГол", "ГосГол", "Счет")
VALUES (102, 2, 1, '2:1');
INSERT INTO "счетигр" ("ИдИгры", "ХозГол", "ГосГол", "Счет")
VALUES (103, 1, 1, '1:1');
INSERT INTO "счетигр" ("ИдИгры", "ХозГол", "ГосГол", "Счет")
VALUES (104, 1, 0, '1:0');
INSERT INTO "счетигр" ("ИдИгры", "ХозГол", "ГосГол", "Счет")
VALUES (105, 1, 2, '1:2');
INSERT INTO "счетигр" ("ИдИгры", "ХозГол", "ГосГол", "Счет")
VALUES (106, 1, 3, '1:3');
INSERT INTO "счетигр" ("ИдИгры", "ХозГол", "ГосГол", "Счет")
VALUES (107, 3, 1, '3:1');
INSERT INTO "счетигр" ("ИдИгры", "ХозГол", "ГосГол", "Счет")
VALUES (108, 2, 2, '2:2');
INSERT INTO "счетигр" ("ИдИгры", "ХозГол", "ГосГол", "Счет")
VALUES (109, 3, 1, '3:1');
INSERT INTO "счетигр" ("ИдИгры", "ХозГол", "ГосГол", "Счет")
VALUES (131, 1, 3, '1:3');
INSERT INTO "счетигр" ("ИдИгры", "ХозГол", "ГосГол", "Счет")
VALUES (132, 3, 0, '3:0');
