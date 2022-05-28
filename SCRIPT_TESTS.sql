-- TESTS GESTION CLIENTES
BEGIN
    -- No hemos conseguido que si falla la insercion se haga un retroceso en la secuencia
    PK_GESTION_CLIENTES.ALTA_CLIENTE('Cliente_1', 'FISICA', 'ALTA',
                                     SYSDATE, NULL, 'C/CUARTELES, 6',
                                    'MALAGA', '29002', 'ESP', NULL,
                                    'JOSE', 'JIMENEZ', '24-5-1996');
    PK_GESTION_CLIENTES.ALTA_CLIENTE('CANONICAL', 'JURIDICA', 'ALTA',
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
    PK_GESTION_CLIENTES.ALTA_AUTORIZADO('22', 'CON', 'AUT_CANONICAL_1',
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



-- TESTS PK OPERATIVA