--liquibase formatted sql


--changeset nvoxland:2
insert into test1 (id, name) values (12, 'name 12');
