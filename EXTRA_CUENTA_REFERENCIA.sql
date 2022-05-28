CREATE OR REPLACE PROCEDURE APERTURA_CUENTA_REFERENCIA(IBAN_REF IN CUENTA.IBAN%TYPE, SWIFT_REF IN CUENTA.SWIFT%TYPE,
                                                        NOM_BANCO IN CTA_REF.NOMBRE_BANCO%TYPE, SUCURS IN CTA_REF.SUCURSAL%TYPE,
                                                        PAIS_REF IN CTA_REF.PAIS%TYPE, SALDO_REF IN CTA_REF.SALDO%TYPE,
                                                        F_APERTURA IN CTA_REF.FECHA_APERTURA%TYPE, ESTADO_REF IN CTA_REF.ESTADO%TYPE,
                                                        DIVISA_REF IN CTA_REF.DIVISA_ABREV%TYPE) IS
    BEGIN
        SAVEPOINT APERTURA_REFERENCIA;
        INSERT INTO CUENTA (IBAN, SWIFT) VALUES (IBAN_REF, SWIFT_REF);
        INSERT INTO CTA_REF 
            (IBAN, NOMBRE_BANCO, SUCURSAL, PAIS, SALDO, FECHA_APERTURA, ESTADO, DIVISA_ABREV)
        VALUES
            (IBAN_REF, NOM_BANCO, SUCURS, PAIS_REF, SALDO_REF, F_APERTURA, ESTADO_REF, DIVISA_REF);
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK TO APERTURA_REFERENCIA;
            RAISE;
    END;
    