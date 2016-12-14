-- input tables creation
CREATE TABLE DRUG_CONCEPT_STAGE
(
   CONCEPT_NAME        VARCHAR2(255 Byte),
   VOCABULARY_ID       VARCHAR2(20 Byte),
   CONCEPT_CLASS_ID    VARCHAR2(25 Byte),
   STANDARD_CONCEPT    VARCHAR2(1 Byte),
   CONCEPT_CODE        VARCHAR2(50 Byte),
   POSSIBLE_EXCIPIENT  VARCHAR2(1 Byte),
   DOMAIN_ID           VARCHAR2(25 Byte),
   VALID_START_DATE    DATE,
   VALID_END_DATE      DATE,
   INVALID_REASON      VARCHAR2(1 Byte)
);

CREATE TABLE DS_STAGE
(
   DRUG_CONCEPT_CODE        VARCHAR2(255 Byte),
   INGREDIENT_CONCEPT_CODE  VARCHAR2(255 Byte),
   BOX_SIZE                 INTEGER,
   AMOUNT_VALUE             FLOAT(126),
   AMOUNT_UNIT              VARCHAR2(255 Byte),
   NUMERATOR_VALUE          FLOAT(126),
   NUMERATOR_UNIT           VARCHAR2(255 Byte),
   DENOMINATOR_VALUE        FLOAT(126),
   DENOMINATOR_UNIT         VARCHAR2(255 Byte)
);

CREATE TABLE INTERNAL_RELATIONSHIP_STAGE
(
   CONCEPT_CODE_1     VARCHAR2(50 Byte),
   CONCEPT_CODE_2     VARCHAR2(50 Byte)
);


CREATE TABLE RELATIONSHIP_TO_CONCEPT
(
   CONCEPT_CODE_1     VARCHAR2(255 Byte),
   VOCABULARY_ID_1    VARCHAR2(20 Byte),
   CONCEPT_ID_2       INTEGER,
   PRECEDENCE         INTEGER,
   CONVERSION_FACTOR  FLOAT(126)
);

CREATE TABLE PC_STAGE
(
   PACK_CONCEPT_CODE  VARCHAR2(255 Byte),
   DRUG_CONCEPT_CODE  VARCHAR2(255 Byte),
   AMOUNT             NUMBER,
   BOX_SIZE           NUMBER
);


CREATE TABLE CONCEPT_SYNONYM_STAGE
(
   SYNONYM_CONCEPT_ID     NUMBER,
   SYNONYM_NAME           VARCHAR2(255 Byte)   NOT NULL,
   SYNONYM_CONCEPT_CODE   VARCHAR2(255 Byte)     NOT NULL,
   SYNONYM_VOCABULARY_ID  VARCHAR2(255 Byte)     NOT NULL,
   LANGUAGE_CONCEPT_ID    NUMBER
)
TABLESPACE USERS;

