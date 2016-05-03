--liquibase formatted sql


--changeset nvoxland:2
insert into test1 (id, name) values (13, 'name 13');
