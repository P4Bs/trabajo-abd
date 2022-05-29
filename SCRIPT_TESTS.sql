-- TESTS GESTION CLIENTES
BEGIN
    -- No hemos conseguido que si falla la insercion se haga un retroceso en la secuencia
    PK_GESTION_CLIENTES.ALTA_CLIENTE(SQ_CLIENTE.NEXTVAL, 'Cliente_1', 'FISICA', 'ALTA',
                                     SYSDATE, NULL, 'C/CUARTELES, 6',
                                    'MALAGA', '29002', 'ESP', NULL,
                                    'JOSE', 'JIMENEZ', '24-5-1996');
    PK_GESTION_CLIENTES.ALTA_CLIENTE(SQ_CLIENTE.NEXTVAL, 'CANONICAL', 'JURIDICA', 'ALTA',
                                        SYSDATE, NULL, 'C/GRANADA, 3',
                                        'MALAGA', '29015', 'ESP', 'SL',
                                        NULL, NULL, NULL);
END;
SELECT * FROM CLIENTE;
SELECT * FROM INDIVIDUAL;
SELECT * FROM EMPRESA;

BEGIN
    PK_GESTION_CLIENTES.MODIFICAR_CLIENTE('Cliente_1','ALTA', NULL, 'C/HEROE DE SOSTOA, 15',
                                            'MALAGA', '29003', 'ESP');
END;
SELECT * FROM CLIENTE;

BEGIN
    PK_GESTION_CLIENTES.BAJA_CLIENTE('Cliente_1', SYSDATE);
END;
SELECT * FROM CLIENTE;

BEGIN
    PK_GESTION_CLIENTES.ALTA_AUTORIZADO('22', 'CON', 
                                        SQ_PERSONA.NEXTVAL, 'AUT_CANONICAL_1',
                                        'IKER', 'JIMENEZ', 'C/ CALVO, 4', '14-6-1993',
                                        SYSDATE, NULL);
END;
SELECT * FROM PERS_AUTORIZ;
SELECT * FROM AUTORIZACION;

BEGIN
    PK_GESTION_CLIENTES.MODIFICAR_AUTORIZADO('22', '2',
                                                'CON', 'IKER', 'GONZALEZ',
                                                'C/ LA UNION, 8', '14-6-1993',
                                                'ACTIVO', SYSDATE, NULL
                                            );
END;
SELECT * FROM PERS_AUTORIZ;
SELECT * FROM AUTORIZACION;

BEGIN
    PK_GESTION_CLIENTES.ELIMINAR_AUTORIZADOS('22');
END;
SELECT * FROM PERS_AUTORIZ;
SELECT * FROM EMPRESA;
SELECT * FROM AUTORIZACION;

-- TESTS GESTION CUENTAS
BEGIN
    PK_GESTION_CLIENTES.ALTA_CLIENTE(SQ_CLIENTE.NEXTVAL,'Cliente_2', 'FISICA', 'ALTA',
                                     SYSDATE, NULL, 'C/BODEGUEROS, 6',
                                    'MALAGA', '29006', 'ESP', NULL,
                                    'PEPE', 'MORENO', '13-2-1998');
    PK_GESTION_CLIENTES.ALTA_CLIENTE(SQ_CLIENTE.NEXTVAL, 'CLIENTE_3', 'FISICA', 'ALTA',
                                    SYSDATE, NULL, 'C/CISTER, 4',
                                    'MALAGA', '29015', 'ESP', NULL,
                                    'MANUEL', 'JIMENEZ', '13-8-2001');
END;
SELECT * FROM CLIENTE;

BEGIN     
    PK_GESTION_CUENTAS.APERTURA_CUENTA('41', 'ES5600754254234435629239',
                                        NULL,
                                        SYSDATE, NULL,
                                        NULL,
                                        'ES4314659844877793142346', NULL,
                                        NULL,
                                        NULL,
                                        'BBVA', 'C/ SALITRE BB, 6',
                                        'ESP', 0, SYSDATE, NULL,
                                        'EUR'
                                        );
    PK_GESTION_CUENTAS.APERTURA_CUENTA('61', 'ES5030045746482445253576',
                                        NULL,
                                        SYSDATE, NULL,
                                        NULL,
                                        NULL, 'ES6304877658986216822278',
                                        NULL,
                                        NULL,
                                        'BBVA', 'C/ SALITRE BB, 6',
                                        'ESP', 0, SYSDATE, NULL,
                                        'EUR'
                                        );
END;
SELECT * FROM CUENTA;
SELECT * FROM CTA_FINTECH;
SELECT * FROM CTA_REF;
SELECT * FROM CTA_POOLED;
SELECT * FROM SEGREGADA;
SELECT * FROM DEPOSITADA_EN;

BEGIN
    PK_GESTION_CUENTAS.CIERRE_CUENTA('ES5600754254234435629239');
END;
SELECT * FROM CTA_FINTECH;
SELECT * FROM DEPOSITADA_EN;

-- TESTS PK OPERATIVA
-- PROCEDIMIENTO INSERTAR TRANSACCION
BEGIN
    PK_GESTION_CLIENTES.ALTA_CLIENTE(SQ_CLIENTE.NEXTVAL,'Transaccion1', 'FISICA', 'ALTA',
                                     SYSDATE, NULL, 'C/CARPIO, 6',
                                    'MALAGA', '29002', 'ESP', NULL,
                                    'MIGUEL', 'GOMEZ', '11-7-1993');
    PK_GESTION_CLIENTES.ALTA_CLIENTE(SQ_CLIENTE.NEXTVAL, 'Transaccion2', 'FISICA', 'ALTA',
                                        SYSDATE, NULL, 'C/IBSEN, 11',
                                        'MALAGA', '29004', 'ESP', NULL,
                                        'LUIS', 'PEREZ', '22-4-1989');
END;

BEGIN
    PK_GESTION_CUENTAS.APERTURA_CUENTA('81', 'ES4514659518316312472747',
                                        NULL,
                                        SYSDATE, NULL,
                                        NULL,
                                        'ES3201284443692957823852', NULL,
                                        NULL,
                                        NULL,
                                        'BBVA', 'C/ SALITRE BB, 6',
                                        'ESP', 10000, SYSDATE, NULL,
                                        'EUR'
                                        );
    PK_GESTION_CUENTAS.APERTURA_CUENTA('82',
                                        'ES5920804517103573583342', NULL,
                                        SYSDATE, NULL,
                                        NULL,
                                        NULL, 'ES3220386569077575131776',
                                        NULL,
                                        NULL,
                                        'BBVA', 'C/ SALITRE BB, 6',
                                        'ESP', 10000,
                                        SYSDATE, NULL,
                                        'EUR'
                                        );
END;

BEGIN
    PK_OPERATIVA.INSERTAR_TRANSACCION('321',
                                        SYSDATE, 200,
                                        NULL, 'CARGO',
                                        NULL, NULL,
                                        'EUR', 'EUR',
                                        'ES4514659518316312472747', 'ES5920804517103573583342'
                                        );
END;
SELECT * FROM CTA_REF;

-- PROCEDIMIENTO CAMBIO_DIVISA
BEGIN
    PK_GESTION_CLIENTES.ALTA_CLIENTE(SQ_CLIENTE.NEXTVAL,'Cambio_Divisa', 'FISICA', 'ALTA',
                                     SYSDATE, NULL, 'C/LOS MONTES, 6',
                                    'MALAGA', '29022', 'ESP', NULL,
                                    'JORGE', 'JIMENEZ', '14-3-1988');
END;
SELECT * FROM CLIENTE;

BEGIN
    PK_GESTION_CUENTAS.APERTURA_CUENTA('101', 'ES2320801935609752334384',
                                        NULL,
                                        SYSDATE, NULL,
                                        NULL,
                                        'ES7520382127074632458753', NULL,
                                        NULL,
                                        NULL,
                                        'BBVA', 'C/ SALITRE BB, 6',
                                        'ESP', 200, SYSDATE, NULL,
                                        'EUR'
                                        );
END;

BEGIN
    INSERT INTO CUENTA
        (IBAN, SWIFT)
    VALUES
        ('ES0514658777864183252189', NULL);
        
    INSERT INTO CTA_REF
        (IBAN, NOMBRE_BANCO, SUCURSAL, PAIS, SALDO, FECHA_APERTURA, ESTADO, DIVISA_ABREV)
    VALUES
        ('ES0514658777864183252189', 'BBVA', 'C/ SALITRE BB, 6', 'ESP', 100, SYSDATE, NULL, 'USD');
        
    INSERT INTO DEPOSITADA_EN
        (SALDO, CTA_POOLED_IBAN, CTA_REF_IBAN)
    VALUES
        (100, 'ES2320801935609752334384', 'ES0514658777864183252189');
END;

BEGIN
    PK_OPERATIVA.CAMBIO_DIVISA('ES2320801935609752334384', 'EUR', 'USD');
END;