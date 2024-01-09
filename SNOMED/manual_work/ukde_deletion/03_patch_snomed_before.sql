/*
 * Apply this script to a clean schema to get stage tables that could be applied
 * as a patch before running SNOMED's load_stage.sql.
 */
--0. Clean stage tables
TRUNCATE concept_relationship_stage;
TRUNCATE concept_synonym_stage;
TRUNCATE concept_stage;

--1.1. Table of retired concepts
DROP TABLE IF EXISTS retired_concepts CASCADE;
CREATE TABLE retired_concepts AS
WITH last_non_uk_active AS (
    SELECT
        c.id,
                first_value(c.active) OVER
            (PARTITION BY c.id ORDER BY effectivetime DESC) AS active
    FROM sources_archive.sct2_concept_full_merged c
    WHERE moduleid NOT IN (
                           999000011000001104, --UK Drug extension
                           999000021000001108  --UK Drug extension reference set module
        )
),
    killed_by_intl AS (
        SELECT id
        FROM last_non_uk_active
        WHERE active = 0
    ),
    current_module AS (
        SELECT
            c.id,
                    first_value(moduleid) OVER
                (PARTITION BY c.id ORDER BY effectivetime DESC) AS moduleid
        FROM sources_archive.sct2_concept_full_merged c
    )
SELECT DISTINCT
    c.concept_id,
    c.concept_code,
    c.vocabulary_id
FROM concept c
JOIN current_module cm ON
    c.concept_code = cm.id :: text
            AND cm.moduleid IN (
                                999000011000001104, --UK Drug extension
                                999000021000001108  --UK Drug extension reference set module
        )
            AND c.vocabulary_id = 'SNOMED'
    --Not killed by international release
--Concepts here are expected to be "recovered" by their original
--module and deprecated normally.
LEFT JOIN killed_by_intl k ON
    k.id :: text = c.concept_code
WHERE
    k.id IS NULL
;
--2. Delete references to retired concepts from _manual tables
-- Separate script deprecaes them, should have no effect when ran in devv5
DELETE FROM concept_relationship_manual crm
WHERE
    EXISTS (
        SELECT 1
        FROM retired_concepts rc
        WHERE
            (rc.concept_code, 'SNOMED') IN (
                (crm.concept_code_1, crm.vocabulary_id_1),
                (crm.concept_code_2, crm.vocabulary_id_2))
    )
;
DELETE FROM concept_synonym_manual csm
WHERE
    (csm.synonym_concept_code, csm.synonym_vocabulary_id) IN (
        SELECT concept_code, vocabulary_id
        FROM retired_concepts
    )
;
DELETE FROM concept_manual cm
WHERE
    (cm.concept_code, cm.vocabulary_id) IN (
        SELECT concept_code, vocabulary_id
        FROM retired_concepts
    )