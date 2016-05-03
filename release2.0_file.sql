--liquibase formatted sql


--changeset nvoxland:2
insert into test1 (id, name) values (6, 'name 6');
insert into test1 (id, name) values (7, 'name 7');
