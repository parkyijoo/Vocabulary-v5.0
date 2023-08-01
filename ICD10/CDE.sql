--ICD10 with mapping
DROP TABLE icd10;
CREATE TABLE icd10 as (
SELECT cs.concept_code,
       cs.concept_name,
       c.concept_id as target_concept_id,
       crs.concept_code_2 as target_concept_code,
       c.concept_name as target_concept_name,
       c.concept_class_id as target_concept_class,
       c.standard_concept as target_standard_concept,
       c.invalid_reason as target_invalid_reason,
       c.domain_id as target_domain_id,
       crs.vocabulary_id_2 as target_vocabulary_id
FROM dev_icd10.concept_stage cs
LEFT JOIN dev_icd10.concept_relationship_stage crs
on cs.concept_code = crs.concept_code_1
    and relationship_id = 'Maps to'
LEFT JOIN concept c on crs.concept_code_2 = c.concept_code
and c.standard_concept = 'S'
and c.invalid_reason is null
where cs.concept_class_id != 'ICD10 Hierarchy');

SELECT * FROM icd10;

SELECT * FROM concept where concept_code = '308133005'; -- notS

-- ICD10CM with mapping
DROP TABLE icd10cm;
CREATE TABLE icd10cm as (
SELECT cs.concept_code,
       cs.concept_name,
       c.concept_id as target_concept_id,
       crs.concept_code_2 as target_concept_code,
       c.concept_name as target_concept_name,
       c.concept_class_id as target_concept_class,
       c.standard_concept as target_standard_concept,
       c.invalid_reason as target_invalid_reason,
       c.domain_id as target_domain_id,
       crs.vocabulary_id_2 as target_vocabulary_id
FROM dev_icd10cm.concept_stage cs
LEFT JOIN dev_icd10cm.concept_relationship_stage crs
on cs.concept_code = crs.concept_code_1
    and relationship_id = 'Maps to'
LEFT JOIN concept c on crs.concept_code_2 = c.concept_code
and c.standard_concept = 'S'
and c.invalid_reason is null);

SELECT * FROM icd10cm;

DROP TABLE dev_icd10.icd_cde ;
TRUNCATE TABLE dev_icd10.icd_cde;
CREATE TABLE dev_icd10.icd_cde
(
    concept_name_id      serial primary key,
    concept_name         varchar,
    group_id             int,
    concept_code_icd10   varchar,
    concept_code_icd10cm varchar,
    concept_code_icd10gm varchar,
    concept_code_cim10   varchar,
    concept_code_kcd7    varchar,
    concept_code_icd10cn varchar,
    target_concept_id int,
    target_concept_name varchar,
    target_concept_class varchar,
    target_standard_concept varchar,
    target_invalid_reason varchar,
    target_domain_id varchar,
    target_vocabulary_id varchar
);

--icd10 insertion
INSERT INTO dev_icd10.icd_cde
(concept_name,
 concept_code_icd10,
 target_concept_id,
 target_concept_name,
 target_concept_class,
 target_standard_concept,
 target_invalid_reason,
 target_domain_id,
 target_vocabulary_id
)
SELECT DISTINCT
concept_name,
concept_code,
target_concept_id,
target_concept_name,
target_concept_class,
target_standard_concept,
target_invalid_reason,
target_domain_id,
target_vocabulary_id
FROM icd10
WHERE (
       COALESCE(concept_code, 'x!x'),
       COALESCE(concept_name, 'x!x')
       --COALESCE(source_code_description_synonym, 'x!x')
          --,COALESCE (source_concept_id, -9876543210)
          )
          NOT IN (
          SELECT COALESCE(concept_code, 'x!x'),
                 COALESCE(concept_name, 'x!x')
                 --COALESCE(source_code_description_synonym, 'x!x')
                 --,COALESCE (source_concept_id, -9876543210)
          FROM dev_icd10.icd_cde
      )
AND concept_name !~* 'Invalid'
order by concept_code, concept_name
;

--insert concept_codes for the concepts already presented in CDE
UPDATE dev_icd10.icd_cde a
SET concept_code_icd10
        = b.concept_code
FROM icd10 b
WHERE COALESCE(a.concept_name, 'x!x') = COALESCE(b.concept_name, 'x!x')
     AND COALESCE(a.concept_code_icd10, 'x!x') = COALESCE(b.concept_code, 'x!x')
  --AND COALESCE(a.source_code_description_synonym, 'x!x') = COALESCE(b.source_code_description_synonym, 'x!x')
--AND COALESCE (source_concept_id, -9876543210) = COALESCE (b.source_concept_id, -9876543210)
;

--icd10cm insertion
INSERT INTO dev_icd10.icd_cde
(concept_name,
 concept_code_icd10cm,
 target_concept_id,
 target_concept_name,
 target_concept_class,
 target_standard_concept,
 target_invalid_reason,
 target_domain_id,
 target_vocabulary_id
)
SELECT DISTINCT
concept_name,
concept_code,
target_concept_id,
target_concept_name,
target_concept_class,
target_standard_concept,
target_invalid_reason,
target_domain_id,
target_vocabulary_id
FROM icd10cm
WHERE (
       --COALESCE(concept_code, 'x!x'),
       COALESCE(concept_name, 'x!x')
       --COALESCE(source_code_description_synonym, 'x!x')
          --,COALESCE (source_concept_id, -9876543210)
          )
          NOT IN (
          SELECT
                 --COALESCE(concept_code, 'x!x'),
                 COALESCE(concept_name, 'x!x')
                 --COALESCE(source_code_description_synonym, 'x!x')
                 --,COALESCE (source_concept_id, -9876543210)
          FROM dev_icd10.icd_cde
      )
AND concept_name !~* 'Invalid'
order by concept_code, concept_name;

--insert concept_codes for the concepts already presented in CDE
UPDATE dev_icd10.icd_cde a
SET concept_code_icd10cm
        = b.concept_code
FROM icd10cm b
WHERE COALESCE(a.concept_name, 'x!x') = COALESCE(b.concept_name, 'x!x')
  --AND COALESCE(a.concept_code_icd10cm, 'x!x') = COALESCE(b.concept_code, 'x!x')
  --AND COALESCE(a.source_code_description_synonym, 'x!x') = COALESCE(b.source_code_description_synonym, 'x!x')
--AND COALESCE (source_concept_id, -9876543210) = COALESCE (b.source_concept_id, -9876543210)
;

--icd10gm insertion
INSERT INTO dev_icd10.icd_cde
(concept_name,
 concept_code_icd10gm,
 target_concept_id,
 target_concept_name,
 target_concept_class,
 target_standard_concept,
 target_invalid_reason,
 target_domain_id,
 target_vocabulary_id
)
SELECT DISTINCT
concept_name,
concept_code,
target_concept_id,
target_concept_name,
target_concept_class,
target_standard_concept,
target_invalid_reason,
target_domain_id,
target_vocabulary_id
FROM dev_icd10gm.concept_stage
WHERE (
       --COALESCE(concept_code, 'x!x'),
       COALESCE(concept_name, 'x!x')
       --COALESCE(source_code_description_synonym, 'x!x')
          --,COALESCE (source_concept_id, -9876543210)
          )
          NOT IN (
          SELECT
                 --COALESCE(concept_code, 'x!x'),
                 COALESCE(concept_name, 'x!x')
                 --COALESCE(source_code_description_synonym, 'x!x')
                 --,COALESCE (source_concept_id, -9876543210)
          FROM dev_icd10.icd_cde
      )
AND concept_name !~* 'Invalid'
order by concept_code, concept_name;

--insert concept_codes for the concepts already presented in CDE
UPDATE dev_icd10.icd_cde a
SET concept_code_icd10gm
        = b.concept_code
FROM dev_icd10gm.concept_stage b
WHERE COALESCE(a.concept_name, 'x!x') = COALESCE(b.concept_name, 'x!x')
  --AND COALESCE(a.concept_code_icd10cm, 'x!x') = COALESCE(b.concept_code, 'x!x')
  --AND COALESCE(a.source_code_description_synonym, 'x!x') = COALESCE(b.source_code_description_synonym, 'x!x')
--AND COALESCE (source_concept_id, -9876543210) = COALESCE (b.source_concept_id, -9876543210)
;

--kcd7
INSERT INTO dev_icd10.icd_cde
(concept_name,
 concept_code_kcd7,
 target_concept_id,
 target_concept_name,
 target_concept_class,
 target_standard_concept,
 target_invalid_reason,
 target_domain_id,
 target_vocabulary_id
)
SELECT DISTINCT
concept_name,
concept_code,
target_concept_id,
target_concept_name,
target_concept_class,
target_standard_concept,
target_invalid_reason,
target_domain_id,
target_vocabulary_id
FROM dev_kcd7.concept_stage
WHERE (
       --COALESCE(concept_code, 'x!x'),
       COALESCE(concept_name, 'x!x')
       --COALESCE(source_code_description_synonym, 'x!x')
          --,COALESCE (source_concept_id, -9876543210)
          )
          NOT IN (
          SELECT
                 --COALESCE(concept_code, 'x!x'),
                 COALESCE(concept_name, 'x!x')
                 --COALESCE(source_code_description_synonym, 'x!x')
                 --,COALESCE (source_concept_id, -9876543210)
          FROM dev_icd10.icd_cde
      )
AND concept_name !~* 'Invalid'
order by concept_code, concept_name;

--insert concept_codes for the concepts already presented in CDE
UPDATE dev_icd10.icd_cde a
SET concept_code_kcd7
        = b.concept_code
FROM dev_kcd7.concept_stage b
WHERE COALESCE(a.concept_name, 'x!x') = COALESCE(b.concept_name, 'x!x')
  --AND COALESCE(a.concept_code_icd10cm, 'x!x') = COALESCE(b.concept_code, 'x!x')
  --AND COALESCE(a.source_code_description_synonym, 'x!x') = COALESCE(b.source_code_description_synonym, 'x!x')
--AND COALESCE (source_concept_id, -9876543210) = COALESCE (b.source_concept_id, -9876543210)
;

--icd10cn
INSERT INTO dev_icd10.icd_cde
(concept_name,
 concept_code_icd10cn,
 target_concept_id,
 target_concept_name,
 target_concept_class,
 target_standard_concept,
 target_invalid_reason,
 target_domain_id,
 target_vocabulary_id
)
SELECT DISTINCT
concept_name,
concept_code,
target_concept_id,
target_concept_name,
target_concept_class,
target_standard_concept,
target_invalid_reason,
target_domain_id,
target_vocabulary_id
FROM dev_icd10cn.concept_stage
WHERE (
       --COALESCE(concept_code, 'x!x'),
       COALESCE(concept_name, 'x!x')
       --COALESCE(source_code_description_synonym, 'x!x')
          --,COALESCE (source_concept_id, -9876543210)
          )
          NOT IN (
          SELECT
                 --COALESCE(concept_code, 'x!x'),
                 COALESCE(concept_name, 'x!x')
                 --COALESCE(source_code_description_synonym, 'x!x')
                 --,COALESCE (source_concept_id, -9876543210)
          FROM dev_icd10.icd_cde
      )
AND concept_name !~* 'Invalid'
order by concept_code, concept_name;

--insert concept_codes for the concepts already presented in CDE
UPDATE dev_icd10.icd_cde a
SET concept_code_icd10cn
        = b.concept_code
FROM dev_icd10cn.concept_stage b
WHERE COALESCE(a.concept_name, 'x!x') = COALESCE(b.concept_name, 'x!x')
  --AND COALESCE(a.concept_code_icd10cm, 'x!x') = COALESCE(b.concept_code, 'x!x')
  --AND COALESCE(a.source_code_description_synonym, 'x!x') = COALESCE(b.source_code_description_synonym, 'x!x')
--AND COALESCE (source_concept_id, -9876543210) = COALESCE (b.source_concept_id, -9876543210)
;

--cim10 insertion -- not inserted. needs source review
INSERT INTO dev_icd10.icd_cde
(concept_name,
 concept_code_cim10,
 target_concept_id,
 target_concept_name,
 target_concept_class,
 target_standard_concept,
 target_invalid_reason,
 target_domain_id,
 target_vocabulary_id
)
SELECT DISTINCT
concept_name,
concept_code,
target_concept_id,
target_concept_name,
target_concept_class,
target_standard_concept,
target_invalid_reason,
target_domain_id,
target_vocabulary_id
FROM dev_cim10.concept_stage
WHERE (
       --COALESCE(concept_code, 'x!x'),
       COALESCE(concept_name, 'x!x')
       --COALESCE(source_code_description_synonym, 'x!x')
          --,COALESCE (source_concept_id, -9876543210)
          )
          NOT IN (
          SELECT
                 --COALESCE(concept_code, 'x!x'),
                 COALESCE(concept_name, 'x!x')
                 --COALESCE(source_code_description_synonym, 'x!x')
                 --,COALESCE (source_concept_id, -9876543210)
          FROM dev_icd10.icd_cde
      )
AND concept_name !~* 'Invalid'
order by concept_code, concept_name;

--insert concept_codes for the concepts already presented in CDE
UPDATE dev_icd10.icd_cde a
SET concept_code_cim10 --specify the exact customer
        = b.concept_code
FROM dev_cim10.concept_stage b
WHERE COALESCE(a.concept_name, 'x!x') = COALESCE(b.concept_name, 'x!x')
  --AND COALESCE(a.concept_code_icd10cm, 'x!x') = COALESCE(b.concept_code, 'x!x')
  --AND COALESCE(a.source_code_description_synonym, 'x!x') = COALESCE(b.source_code_description_synonym, 'x!x')
--AND COALESCE (source_concept_id, -9876543210) = COALESCE (b.source_concept_id, -9876543210)
;

SELECT * FROM dev_icd10.icd_cde
order by  concept_name, concept_code_icd10
;

-- array delta function
CREATE OR REPLACE FUNCTION get_non_overlapping_elements(arr1 text[], arr2 text[])
RETURNS text[] AS
$$
DECLARE
  result_arr text[];
  element1 text;
  element2 text;
BEGIN
  -- Initialize an empty array to store non-overlapping elements
  result_arr := '{}';

  -- Loop through the elements of the first array
  FOREACH element1 IN ARRAY arr1
  LOOP
    -- Check if the element does not exist in the second array
    IF element1 = ANY(arr2) THEN
      CONTINUE; -- Skip if there is an overlap
    ELSE
      -- Append the non-overlapping element to the result array
      result_arr := result_arr || element1;
    END IF;
  END LOOP;

  -- Loop through the elements of the second array
  FOREACH element2 IN ARRAY arr2
  LOOP
    -- Check if the element does not exist in the first array
    IF element2 = ANY(arr1) THEN
      CONTINUE; -- Skip if there is an overlap
    ELSE
      -- Append the non-overlapping element to the result array
      result_arr := result_arr || element2;
    END IF;
  END LOOP;

  -- Remove any duplicates from the result array
  result_arr := ARRAY(SELECT DISTINCT unnest(result_arr));

  -- Return the final non-overlapping elements
  RETURN result_arr;
END;
$$
LANGUAGE plpgsql;


DROP TABLE by_code_join;
CREATE TABLE by_code_join as (
SELECT icd10.concept_code as concept_code,
       icd10.concept_name as icd10_name,
       icd10cm.concept_name as icd10cm_name,
       get_non_overlapping_elements(regexp_split_to_array(lower(regexp_replace(regexp_replace(icd10.concept_name,'[[:punct:]]','','gi'),'ae','e','gi')),' '),regexp_split_to_array(lower(regexp_replace(regexp_replace(icd10cm.concept_name,'[[:punct:]]','','gi'),'ae','e','gi')),' ')) as delta_array,
       icd10.target_concept_id as icd10_target_concept_id,
       icd10.target_concept_code as icd10_target_concept_code,
       icd10.target_concept_name as icd10_target_concept_name,
       icd10.target_concept_class as icd10_target_concept_class,
       icd10.target_standard_concept as icd10_target_standard_concept,
       icd10.target_invalid_reason as icd10_target_invalid_reason,
       icd10.target_domain_id as icd10_target_domain_id,
       icd10.target_vocabulary_id as icd10_target_vocabulary_id,
       icd10cm.target_concept_id as icd10cm_target_concept_id,
       icd10cm.target_concept_code as icd10cm_target_concept_code,
       icd10cm.target_concept_name as icd10cm_target_concept_name,
       icd10cm.target_concept_class as icd10cm_target_concept_class,
       icd10cm.target_standard_concept as icd10cm_target_standard_concept,
       icd10cm.target_invalid_reason as icd10cm_target_invalid_reason,
       icd10cm.target_domain_id as icd10cm_target_domain_id,
       icd10cm.target_vocabulary_id as icd10cm_target_vocabulary_id
FROM icd10 JOIN icd10cm
on icd10.concept_code = icd10cm.concept_code);

ALTER TABLE by_code_join add sim_flag int null;
UPDATE by_code_join SET sim_flag = '1'
WHERE delta_array in ('{}', '{of}', '{and,fetus}', '{lesion,sites}',  '{malignant,neoplasm}', '{neoplasm}', '{unspecified,and,other}', '{other}', '{behavior,or,unknown,behaviour}', '{unspecified}', '{site}', '{affective}', '{major}', '{and}', '{firesetting,pathological}')

UPDATE by_code_join SET sim_flag = '1'
WHERE delta_array in ('{the}', '{abortion}', '{an,abortion}', '{and,other}', '{and,other}', '{bus,of}', '{bus,on}',  '{current}', '{cyclist}', '{dependence,and}', '{encounter}', '{face}', '{face,and}', '{fascia}', '{fetus}', '{findings}', '{fingers}', '{fingers,and}', '{for,encounter}');

UPDATE by_code_join SET sim_flag = '1'
WHERE delta_array in ('{cycle,cyclist}', '{cycle,pedal}', '{cycle,rider,cyclist}', '{elsewhere,classified,complications,and,intraoperative,not}', '{elsewhere,classified,not}', '{elsewhere,to,chapters}', '{elsewhere,to,other,chapters}', '{examination,special,encounter}', '{heavy,vehicle,transport,of}', '{heavy,vehicle,transport,of}', '{in}', '{in,sites,spine,unspecified,site,multiple}', '{including,other,and,unilateral}', '{joint,of}', '{joints,of}', '{kidney,renal}', '{kidney,renal,chronic}', '{knee,and}', '{monocular,one,eye}', '{newborn}', '{nontraumatic}', '{occupant}', '{of,occupant}', '{on,occupant}', '{part,of}', '{passenger,any,driver}', '{region}', '{region,of}', '{region,other}', '{regions}', '{regions}', '{site,specified}', '{special}', '{specified}', '{strain}', '{subluxation,and}', '{suspected}', '{unspecified,and}', '{unspecified,site,multiple,sites}', '{vehicle,occupant}', '{vertebre,other}', '{while,a,occupant}', '{while,a,of,occupant}', '{while,a,rider}', '{while,cycle,a,cyclist}', '{with}');    )

UPDATE by_code_join SET sim_flag = '1'
WHERE delta_array in ('{rider}', '{motorcycle}',  '{threewheeled,vehicle,of}', '{threewheeled,vehicle}', '{45x46xx,45,xx,x46}', '{46x,x,46}', '{46xx,xx,46}', '{47,47xxx,xxx}',  '{47xxy,xxy,47}', '{47xyy,47,xyy}', '{a,eye}', '{a,of,occupant}', '{abnormal,tuberculosis,for,nonspecific,tuberculin}', '{abuse,stimulant,to,behavioural,harmful,mental,including,use,stimulants,due,caffeine,of,and,disorders}', '{abuse,to,behavioural,harmful,mental,hallucinogen,use,due,of,and,disorders,hallucinogens}', '{abuse,to,behavioural,harmful,mental,use,due,of,and,disorders}', '{abuse,to,behavioural,harmful,mental,use,due,of,and,disorders}', '{abuse,to,behavioural,harmful,mental,use,due,of,and,disorders,cannabinoids,cannabis}', '{abuse,to,behavioural,harmful,mental,use,opioid,opioids,due,of,and,disorders}', '{accessory}', '{acute}', '{adolescent,and}', '{adult,acute}', '{adult,autosomal,type,dominant}', '{adults,childhood,and,in}', '{adverse,abuse,potential,underdosing,effect,and,of,by,with}', '{adverse,antidiarrhoeal,antidiarrheal,underdosing,effect,and,of,by}', '{adverse,antiparasitic,antiparasitics,underdosing,effect,of,by}', '{adverse,antithrombotic,underdosing,effect,and,of,by,drugs}', '{adverse,cephalosporins,underdosing,effect,of,by,cefalosporins}', '{adverse,effect,of,and,by}', '{adverse,elsewhere,classified,underdosing,effect,and,of,by,not}', '{adverse,elsewhere,classified,underdosing,effect,of,by,not}', '{adverse,hypnotic,sedative,sedativehypnotic,underdosing,effect,of}', '{adverse,otorhinorlaryngological,otorhinolaryngological,underdosing,effect,of}', '{adverse,rifampicins,rifamycins,underdosing,effect,and,of,by}', '{adverse,their,underdosing,effect,of,by}', '{adverse,underdosing,effect,and,of}', '{adverse,underdosing,effect,and,of,by}', '{adverse,underdosing,effect,and,of,by,the}', '{adverse,underdosing,effect,by}', '{adverse,underdosing,effect,of,by}', '{adverse,underdosing,effect,other,and,of,by}', '{agents,adverse,agent,underdosing,effect,and,of,by}', '{agents,adverse,primarily,underdosing,effect,of,by,drugs}', '{air,airconditioner,conditioner}', '{air,leak,and}', '{alone}', '{alone,shaft}', '{alone,unspecified,closed,shaft}' )

UPDATE by_code_join SET sim_flag = '1' where concept_code in (
with arr as
    (SELECT DISTINCT concept_code, delta_array [1] as array_1, delta_array [2] as array_2
FROM by_code_join where array_length(delta_array, 1) = 2 and by_code_join.sim_flag is null)
SELECT concept_code FROM arr where  devv5.similarity(array_1::text, array_2::text) > 0.31);

UPDATE by_code_join SET sim_flag = '1'
WHERE icd10_target_concept_id = by_code_join.icd10cm_target_concept_id;

SELECT * FROM by_code_join WHERE sim_flag is null; --2164 rows

SELECT DISTINCT delta_array FROM by_code_join where by_code_join.sim_flag = '1'; --1031 including {}













