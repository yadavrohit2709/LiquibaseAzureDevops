--liquibase formatted sql
--changeset chuck:20200702-create-marketing-table labels:jira-101
CREATE TABLE marketing(
  contact_name VARCHAR(50),
  marketing_rep VARCHAR(50),
  notes VARCHAR (355)
);
--rollback DROP TABLE marketing;
