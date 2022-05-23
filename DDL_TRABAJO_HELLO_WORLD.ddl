-- Generado por Oracle SQL Developer Data Modeler 21.4.2.059.0838
--   en:        2022-03-26 22:12:58 CET
--   sitio:      Oracle Database 11g
--   tipo:      Oracle Database 11g



-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

CREATE TABLE autorizacion (
    tipo            VARCHAR2(3 CHAR) NOT NULL,
    pers_autoriz_id INTEGER NOT NULL,
    empresa_id      INTEGER NOT NULL
);

ALTER TABLE autorizacion ADD CONSTRAINT autorizacion_pk PRIMARY KEY ( pers_autoriz_id );

CREATE TABLE cliente (
    id            INTEGER NOT NULL,
    ident         VARCHAR2(20 CHAR) NOT NULL,
    tipo_cliente  VARCHAR2(10 CHAR) NOT NULL,
    estado        VARCHAR2(10 CHAR) NOT NULL,
    fecha_alta    DATE NOT NULL,
    fecha_baja    DATE,
    direccion     VARCHAR2(40 CHAR) NOT NULL,
    ciudad        VARCHAR2(20 CHAR) NOT NULL,
    codigo_postal VARCHAR2(20 CHAR) NOT NULL,
    pais          VARCHAR2(40 CHAR) NOT NULL
);

ALTER TABLE cliente ADD CONSTRAINT cliente_pk PRIMARY KEY ( id );

ALTER TABLE cliente ADD CONSTRAINT cliente_ident_un UNIQUE ( ident );

CREATE TABLE cta_fintech (
    iban           VARCHAR2(40 CHAR) NOT NULL,
    estado         VARCHAR2(10 CHAR) NOT NULL,
    fecha_apertura DATE NOT NULL,
    fecha_cierre   DATE,
    clasificacion  VARCHAR2(20 CHAR),
    cliente_id     INTEGER NOT NULL
);

ALTER TABLE cta_fintech ADD CONSTRAINT cta_fintech_pk PRIMARY KEY ( iban );

CREATE TABLE cta_pooled (
    iban VARCHAR2(40 CHAR) NOT NULL
);

ALTER TABLE cta_pooled ADD CONSTRAINT cta_pooled_pk PRIMARY KEY ( iban );

CREATE TABLE cta_ref (
    iban           VARCHAR2(40 CHAR) NOT NULL,
    nombre_banco   VARCHAR2(20 CHAR) NOT NULL,
    sucursal       VARCHAR2(20 CHAR),
    pais           VARCHAR2(20 CHAR),
    saldo          FLOAT(2) NOT NULL,
    fecha_apertura DATE NOT NULL,
    estado         VARCHAR2(10 CHAR),
    divisa_abrev   VARCHAR2(10 CHAR) NOT NULL
);

ALTER TABLE cta_ref ADD CONSTRAINT cta_ref_pk PRIMARY KEY ( iban );

CREATE TABLE cuenta (
    iban  VARCHAR2(40 CHAR) NOT NULL,
    swift VARCHAR2(15 CHAR)
);

ALTER TABLE cuenta ADD CONSTRAINT cuenta_pk PRIMARY KEY ( iban );

CREATE TABLE depositada_en (
    saldo           FLOAT(2) NOT NULL,
    cta_pooled_iban VARCHAR2(40 CHAR) NOT NULL,
    cta_ref_iban    VARCHAR2(40 CHAR) NOT NULL
);

ALTER TABLE depositada_en ADD CONSTRAINT depositada_en_pk PRIMARY KEY ( cta_pooled_iban,
                                                                        cta_ref_iban );

CREATE TABLE divisa (
    abrev      VARCHAR2(10 CHAR) NOT NULL,
    nombre     VARCHAR2(30 CHAR) NOT NULL,
    simbolo    CHAR(5 CHAR),
    cambio_eur FLOAT(3) NOT NULL
);

ALTER TABLE divisa ADD CONSTRAINT divisa_pk PRIMARY KEY ( abrev );

CREATE TABLE empresa (
    id           INTEGER NOT NULL,
    razon_social VARCHAR2(20 CHAR) NOT NULL
);

ALTER TABLE empresa ADD CONSTRAINT empresa_pk PRIMARY KEY ( id );

CREATE TABLE individual (
    id               INTEGER NOT NULL,
    nombre           VARCHAR2(20 CHAR) NOT NULL,
    apellido         VARCHAR2(20 CHAR) NOT NULL,
    fecha_nacimiento DATE
);

ALTER TABLE individual ADD CONSTRAINT individual_pk PRIMARY KEY ( id );

CREATE TABLE movimiento (
    id              INTEGER NOT NULL,
    fecha_operacion DATE NOT NULL,
    concepto        VARCHAR2(40 CHAR) NOT NULL,
    emisor          VARCHAR2(20 CHAR) NOT NULL,
    tipo_emisor     VARCHAR2(20 CHAR) NOT NULL,
    cantidad        NUMBER(10, 2) NOT NULL,
    modo_operacion  VARCHAR2(20 CHAR) NOT NULL,
    estado	    VARCHAR2(20 CHAR) NOT NULL,
    fecha_pago      DATE NOT NULL,
    n_plazos        VARCHAR2(2 CHAR),
    tiempo_plazo    VARCHAR2(3 CHAR),
    transaccion_id  INTEGER NOT NULL,
    tarjeta_id      INTEGER NOT NULL,
    divisa_abrev   VARCHAR2(10 CHAR) NOT NULL
);

CREATE UNIQUE INDEX movimiento__idx ON
    movimiento (
        transaccion_id
    ASC );

ALTER TABLE movimiento ADD CONSTRAINT movimiento_pk PRIMARY KEY ( id );

CREATE TABLE pers_autoriz (
    id               INTEGER NOT NULL,
    ident            VARCHAR2(20 CHAR) NOT NULL,
    nombre           VARCHAR2(20 CHAR) NOT NULL,
    apellido         VARCHAR2(20 CHAR) NOT NULL,
    direccion        VARCHAR2(40 CHAR) NOT NULL,
    fecha_nacimiento DATE,
    estado           VARCHAR2(10 CHAR),
    fecha_inicio     DATE,
    fecha_fin        DATE
);

ALTER TABLE pers_autoriz ADD CONSTRAINT pers_autoriz_pk PRIMARY KEY ( id );

ALTER TABLE pers_autoriz ADD CONSTRAINT pers_autoriz_ident_un UNIQUE ( ident );

CREATE TABLE segregada (
    iban         VARCHAR2(40 CHAR) NOT NULL,
    comision     FLOAT(2),
    cta_ref_iban VARCHAR2(40 CHAR) NOT NULL
);

CREATE UNIQUE INDEX segregada__idx ON
    segregada (
        cta_ref_iban
    ASC );

ALTER TABLE segregada ADD CONSTRAINT segregada_pk PRIMARY KEY ( iban );

CREATE TABLE tarjeta (
    id                   INTEGER NOT NULL,
    fecha_caducidad      DATE NOT NULL,
    fecha_activacion     DATE NOT NULL,
    num_tarjeta          VARCHAR2(18 CHAR) NOT NULL,
    cvc                  VARCHAR2(4 CHAR) NOT NULL,
    tipo_tarjeta         VARCHAR2(20 CHAR) NOT NULL,
    limite_cobro_mensual VARCHAR2(10 CHAR) NOT NULL,
    limite_online        VARCHAR2(10 CHAR) NOT NULL,
    limite_diario        VARCHAR2(10 CHAR) NOT NULL,
    cliente_id           INTEGER NOT NULL,
    cuenta_iban          VARCHAR2(40 CHAR) NOT NULL
);

ALTER TABLE tarjeta ADD CONSTRAINT tarjeta_pk PRIMARY KEY ( id );

CREATE TABLE transaccion (
    id                		INTEGER NOT NULL,
    fecha_instruccion 		DATE NOT NULL,
    cantidad          		NUMBER(10, 2) NOT NULL,
    fecha_ejecucion   		DATE,
    tipo              		VARCHAR2(20 CHAR) NOT NULL,
    comision          		FLOAT(2),
    internacional     		CHAR(1),
    divisa_abrev_origen 	VARCHAR2(10 CHAR) NOT NULL,
    divisa_abrev_destino	VARCHAR2(10 CHAR) NOT NULL,
    cuenta_iban_origen      	VARCHAR2(40 CHAR) NOT NULL,
    cuenta_iban_destino      	VARCHAR2(40 CHAR) NOT NULL
);

ALTER TABLE transaccion ADD CONSTRAINT transaccion_pk PRIMARY KEY ( id );

ALTER TABLE autorizacion
    ADD CONSTRAINT autorizacion_empresa_fk FOREIGN KEY ( empresa_id )
        REFERENCES empresa ( id );

ALTER TABLE autorizacion
    ADD CONSTRAINT autorizacion_pers_autoriz_fk FOREIGN KEY ( pers_autoriz_id )
        REFERENCES pers_autoriz ( id );

ALTER TABLE cta_fintech
    ADD CONSTRAINT cta_fintech_cliente_fk FOREIGN KEY ( cliente_id )
        REFERENCES cliente ( id );

ALTER TABLE cta_fintech
    ADD CONSTRAINT cta_fintech_cuenta_fk FOREIGN KEY ( iban )
        REFERENCES cuenta ( iban );

ALTER TABLE cta_pooled
    ADD CONSTRAINT cta_pooled_cta_fintech_fk FOREIGN KEY ( iban )
        REFERENCES cta_fintech ( iban );

ALTER TABLE cta_ref
    ADD CONSTRAINT cta_ref_cuenta_fk FOREIGN KEY ( iban )
        REFERENCES cuenta ( iban );

ALTER TABLE cta_ref
    ADD CONSTRAINT cta_ref_divisa_fk FOREIGN KEY ( divisa_abrev )
        REFERENCES divisa ( abrev );

ALTER TABLE depositada_en
    ADD CONSTRAINT depositada_en_cta_pooled_fk FOREIGN KEY ( cta_pooled_iban )
        REFERENCES cta_pooled ( iban );

ALTER TABLE depositada_en
    ADD CONSTRAINT depositada_en_cta_ref_fk FOREIGN KEY ( cta_ref_iban )
        REFERENCES cta_ref ( iban );

ALTER TABLE empresa
    ADD CONSTRAINT empresa_cliente_fk FOREIGN KEY ( id )
        REFERENCES cliente ( id );

ALTER TABLE individual
    ADD CONSTRAINT individual_cliente_fk FOREIGN KEY ( id )
        REFERENCES cliente ( id );

ALTER TABLE movimiento
    ADD CONSTRAINT movimiento_tarjeta_fk FOREIGN KEY ( tarjeta_id )
        REFERENCES tarjeta ( id );

ALTER TABLE movimiento
    ADD CONSTRAINT movimiento_transaccion_fk FOREIGN KEY ( transaccion_id )
        REFERENCES transaccion ( id );

ALTER TABLE movimiento
    ADD CONSTRAINT movimiento_divisa_fk FOREIGN KEY ( divisa_abrev )
	REFERENCES divisa ( abrev );

ALTER TABLE segregada
    ADD CONSTRAINT segregada_cta_fintech_fk FOREIGN KEY ( iban )
        REFERENCES cta_fintech ( iban );

ALTER TABLE segregada
    ADD CONSTRAINT segregada_cta_ref_fk FOREIGN KEY ( cta_ref_iban )
        REFERENCES cta_ref ( iban );

ALTER TABLE tarjeta
    ADD CONSTRAINT tarjeta_cliente_fk FOREIGN KEY ( cliente_id )
        REFERENCES cliente ( id );

ALTER TABLE tarjeta
    ADD CONSTRAINT tarjeta_cuenta_fk FOREIGN KEY ( cuenta_iban )
        REFERENCES cuenta ( iban );

ALTER TABLE transaccion
    ADD CONSTRAINT transaccion_cuenta_fk FOREIGN KEY ( cuenta_iban )
        REFERENCES cuenta ( iban );

ALTER TABLE transaccion
    ADD CONSTRAINT transaccion_cuenta_fkv2 FOREIGN KEY ( cuenta_iban2 )
        REFERENCES cuenta ( iban );

ALTER TABLE transaccion
    ADD CONSTRAINT transaccion_divisa_fk FOREIGN KEY ( divisa_abrev )
        REFERENCES divisa ( abrev );

ALTER TABLE transaccion
    ADD CONSTRAINT transaccion_divisa_fkv2 FOREIGN KEY ( divisa_abrev2 )
        REFERENCES divisa ( abrev );

--  ERROR: No Discriminator Column found in Arc FKArc_1 - constraint trigger for Arc cannot be generated 

--  ERROR: No Discriminator Column found in Arc FKArc_1 - constraint trigger for Arc cannot be generated

--  ERROR: No Discriminator Column found in Arc FKArc_2 - constraint trigger for Arc cannot be generated 

--  ERROR: No Discriminator Column found in Arc FKArc_2 - constraint trigger for Arc cannot be generated

--  ERROR: No Discriminator Column found in Arc FKArc_3 - constraint trigger for Arc cannot be generated 

--  ERROR: No Discriminator Column found in Arc FKArc_3 - constraint trigger for Arc cannot be generated



-- Informe de Resumen de Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                            15
-- CREATE INDEX                             2
-- ALTER TABLE                             39
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                           0
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                          0
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   6
-- WARNINGS                                 0
