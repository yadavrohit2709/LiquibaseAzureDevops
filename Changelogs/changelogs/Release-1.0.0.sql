--liquibase formatted sql
--changeset mike:20210103-create-T_referencesomething-table labels:jira-119,release1.0.0
CREATE TABLE T_referencesomething(
  contact_name VARCHAR(50),
  testdml_rep VARCHAR(50),
  notes VARCHAR (355)
);
--rollback DROP TABLE T_referencesomething;


--changeset chuck:20210105-insert-a-row3 labels:jira-119,release1.0.0
INSERT INTO T_referencesomething (contact_name,testdml_rep,notes)
VALUES ('Hugh Jackman','Famke Janssen','Random comment for notes');
--rollback DELETE FROM T_referencesomething WHERE contact_name = 'Hugh Jackman';
