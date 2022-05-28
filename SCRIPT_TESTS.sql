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

-- TESTS PK OPERATIVA | TODO : HACER ESTO 
BEGIN
    PK_GESTION_CLIENTES.ALTA_CLIENTE(SQ_CLIENTE.NEXTVAL,'Cliente_2', 'FISICA', 'ALTA',
                                     SYSDATE, NULL, 'C/BODEGUEROS, 6',
                                    'MALAGA', '29006', 'ESP', NULL,
                                    'PEPE', 'MORENO', '13-2-1998');
    PK_GESTION_CLIENTES.ALTA_CLIENTE(SQ_CLIENTE.NEXTVAL, 'CLIENTE_3', 'FISICA', 'ALTA',
                                    SYSDATE, NULL, 'C/CISTER, 4',
                                    'MALAGA', '29015', 'ESP', NULL,
                                    'MANUEL', 'JIMENEZ', '13-8-2001');
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