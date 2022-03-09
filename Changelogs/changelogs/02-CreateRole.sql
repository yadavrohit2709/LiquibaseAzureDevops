--liquibase formatted sql
--changeset chuck:20200710-create-role labels:jira-102

CREATE ROLE examplerole01;
go

--rollback DROP ROLE examplerole01;
