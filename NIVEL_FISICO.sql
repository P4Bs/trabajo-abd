/*  
    HELLO WORLD : INTEGRANTES
        -> Francisco Javier Coca Sores
        -> Francisco Javier Jiménez Montes
        -> Juan Marqués Garrido
        -> Pablo Jesús Moreno Polo
*/

-- CONSULTA PARA BORRAR LAS TABLAS    
select 'drop table ' || table_name || ' cascade constraints; '  from user_tables;
-- TOMAMOS LAS FILAS DE LA CONSULTA, LAS PEGAMOS Y LAS EJECUTAMOS
drop table AUTORIZACION cascade constraints; 
drop table CLIENTE cascade constraints; 
drop table CTA_FINTECH cascade constraints; 
drop table CTA_POOLED cascade constraints; 
drop table CTA_REF cascade constraints; 
drop table CUENTA cascade constraints; 
drop table DEPOSITADA_EN cascade constraints; 
drop table DIVISA cascade constraints; 
drop table EMPRESA cascade constraints; 
drop table INDIVIDUAL cascade constraints; 
drop table MOVIMIENTO cascade constraints; 
drop table PERS_AUTORIZ cascade constraints; 
drop table SEGREGADA cascade constraints; 
drop table TARJETA cascade constraints; 
drop table TRANSACCION cascade constraints; 

/* PASO 1 */
-- DESDE SYSTEM
CREATE TABLESPACE TS_FINTECH DATAFILE 'FINTECH_DBF.dbf' SIZE 10M AUTOEXTEND ON;
SELECT * FROM DBA_TABLESPACES WHERE TABLESPACE_NAME = 'TS_FINTECH';

-- CREAMOS EL USUARIO Y LE DAMOS LOS PERMISOS :>
CREATE USER fintech IDENTIFIED BY fintech
    DEFAULT TABLESPACE TS_FINTECH
    QUOTA UNLIMITED ON TS_FINTECH;
GRANT CREATE TABLE TO fintech;
GRANT CREATE VIEW TO fintech;
GRANT CREATE MATERIALIZED VIEW TO fintech;
GRANT CREATE SEQUENCE TO fintech;
GRANT CREATE PROCEDURE TO fintech;
GRANT CREATE SYNONYM TO fintech;
GRANT CONNECT TO fintech;

-- CREAMOS EL TABLESPACES DE INDICES Y LE ASIGNAMOS QUOTA AL USUARIO
CREATE TABLESPACE TS_INDICES DATAFILE 'INDICES_DBF.dbf' SIZE 50M AUTOEXTEND ON;
ALTER USER fintech QUOTA UNLIMITED ON TS_INDICES;

-- CONSULTAMOS EN EL DICCIONARIO DE DATOS LOS METADATOS DE LOS INDICES
SELECT * FROM DBA_TABLESPACES WHERE TABLESPACE_NAME = 'TS_FINTECH' OR TABLESPACE_NAME = 'TS_INDICES';
SELECT * FROM DBA_USERS WHERE USERNAME = 'FINTECH';
SELECT * FROM DBA_DATA_FILES WHERE TABLESPACE_NAME = 'TS_FINTECH' OR TABLESPACE_NAME = 'TS_INDICES';


/* PASO 2*/
-- DESDE FINTECH
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

CREATE UNIQUE INDEX movimiento_idx ON
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

CREATE UNIQUE INDEX segregada_idx ON
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

--EJECUTAMOS LAS LINEAS PARA BORRAR TODO EL ESQUEMA GENERADO
select 'drop table ' || table_name || ' cascade constraints; '  from user_tables;
-- COPIAMOS, PEGAMOS Y EJECUTAMOS LA SALIDA DEL COMANDO SUPERIOR


/* PASO 3*/
-- LA IMPORTACION DE LOS DATOS SE LLEVA A CABO EN SQL DEVELOPER. LOS DATOS SON IMPORTADOS CORRECTAMENTE :>.


/* PASO 4*/
-- DESDE SYSTEM
CREATE OR REPLACE DIRECTORY DIRECTORIO_EXT AS 'C:\Users\app\alumnos\admin\orcl\dpdump';
GRANT READ, WRITE ON DIRECTORY DIRECTORIO_EXT TO FINTECH;

-- DESDE FINTECH
CREATE TABLE COTIZACION_EXT (
    Nombre NVARCHAR2(50), 
    Fecha NVARCHAR2(50),
    Valor1Euro NVARCHAR2(50),
    VariacionPorc NVARCHAR2(50),
    VariacionMes NVARCHAR2(50),
    VariacionAnyo NVARCHAR2(50),
    ValorEnEuros NVARCHAR2(50)
    )
ORGANIZATION EXTERNAL
( DEFAULT DIRECTORY directorio_ext 
    ACCESS PARAMETERS
    ( RECORDS DELIMITED BY NEWLINE
        SKIP 1
        CHARACTERSET WE8ISO8859P1
    FIELDS TERMINATED BY ';'
    )
    LOCATION ('cotizacion.csv')
);

-- CONSULTAMOS LOS DATOS Y OBSERVAMOS QUE LA CONSULTA SE EJECUTA CORRECTAMENTE
SELECT * FROM COTIZACION_EXT;

-- SENTENCIAS PARA REALIZAR SELECCION Y CREAR VISTAS
SELECT D.ABREV, D.NOMBRE, D.SIMBOLO, TO_NUMBER( C.VALORENEUROS), TO_DATE(FECHA,'dd/mm/yyyy') 
FROM COTIZACION_EXT C JOIN DIVISA D 
    ON C.NOMBRE = D.NOMBRE;
    
CREATE VIEW V_COTIZACIONES AS   (
                                    SELECT D.ABREV, D.NOMBRE, D.SIMBOLO, 
                                        TO_NUMBER( C.VALORENEUROS) CAMBIOEURO, TO_DATE(FECHA, 'dd/mm/yyyy') FECHA
                                    FROM COTIZACION_EXT C JOIN DIVISA D ON C.NOMBRE = D.NOMBRE
                                    WHERE (D.NOMBRE, TO_DATE(FECHA, 'dd/mm/yyyy')) 
                                        IN (SELECT NOMBRE, MAX(TO_DATE(FECHA, 'dd/mm/yyyy')) 
                                            FROM COTIZACION_EXT GROUP BY NOMBRE)
                                );


/* PASO 5 */
-- DESDE FINTECH

-- CREAMOS EL INDICE SOBRE LA FUNCION
CREATE INDEX IDENT_CLIENTE_INDEX ON CLIENTE(UPPER(IDENT))
    TABLESPACE TS_INDICES;
    
SELECT * FROM USER_INDEXES; -- OBSERVAMOS QUE EL INDICE CREADO APARECE
SELECT * FROM USER_TABLES;
/*
    - LA TABLA CLIENTE RESIDE EN EL TABLESPACE 'TS_FINTECH'
    - LOS INDICES RESIDEN EN EL TABLESPACE 'TS_INDICES'
*/
CREATE BITMAP INDEX DIVISA_REFERENCIA ON CTA_REF(DIVISA_ABREV)
    TABLESPACE TS_INDICES;
-- SI CONSULTAMOS DE NUEVO OBSERVAMOS QUE EL INDICE CREADO ES DE TIPO BITMAP


/* PASO 6 */
-- DESDE FINTECH
CREATE MATERIALIZED VIEW VM_COTIZA
    REFRESH START WITH SYSDATE NEXT SYSDATE + 1
    AS SELECT * FROM COTIZACION_EXT;


/* PASO 7 */
-- DESDE FINTECH
CREATE SYNONYM COTIZACION FOR VM_COTIZA;