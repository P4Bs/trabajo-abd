CREATE OR REPLACE PACKAGE BODY PK_GESTION_CUENTAS AS
    PROCEDURE APERTURA_CUENTA(ID_CLIENTE IN CLIENTE.ID%TYPE, IBAN_CUENTA IN CUENTA.IBAN%TYPE,
                                SWIFT_CUENTA IN CUENTA.SWIFT%TYPE,
                                FECHA_APERTURA_FINTECH IN CTA_FINTECH.FECHA_APERTURA%TYPE, FECHA_CIERRE_FINTECH IN CTA_FINTECH.FECHA_CIERRE%TYPE,
                                CLASIFICACION_FINTECH IN CTA_FINTECH.CLASIFICACION%TYPE, COMISION_SEGREGADA IN SEGREGADA.COMISION%TYPE,
                                IBAN_REF IN CUENTA.IBAN%TYPE, SWIFT_REF IN CUENTA.SWIFT%TYPE,
                                NOMBRE_BANCO_REF IN CTA_REF.NOMBRE_BANCO%TYPE, SUCURSAL_REF IN CTA_REF.SUCURSAL%TYPE,
                                PAIS_REF IN CTA_REF.PAIS%TYPE, SALDO_REF IN CTA_REF.SALDO%TYPE,
                                FECHA_APERTURA_REF IN CTA_REF.FECHA_APERTURA%TYPE, DIVISA_REF IN CTA_REF.DIVISA_ABREV%TYPE) IS        
        ESTA_CLIENTE            NUMBER;
        REFERENCIA_YA_INSERTADA NUMBER;
        ESTADO_CLIENTE          CLIENTE.ESTADO%TYPE;
        
        BEGIN
            SAVEPOINT APERTURA_CUENTA;
            SELECT COUNT(C.ID) INTO ESTA_CLIENTE FROM CLIENTE C WHERE C.ID = ID_CLIENTE;
    
            IF ESTA_CLIENTE != 0 THEN
                SELECT C.ESTADO INTO ESTADO_CLIENTE FROM CLIENTE C WHERE C.ID = ID_CLIENTE;
                IF ESTADO_CLIENTE = 'BAJA' THEN
                    RAISE CLIENTE_DADO_BAJA_EXCEP;
                END IF;
                
                IF IBAN_REF IS NOT NULL THEN
                    SELECT COUNT(C.IBAN) INTO REFERENCIA_YA_INSERTADA 
                        FROM CUENTA C LEFT JOIN CTA_REF R ON (C.IBAN = R.IBAN)
                        WHERE C.IBAN = IBAN_REF;
                    IF REFERENCIA_YA_INSERTADA > 0 THEN
                        RAISE CTA_REF_YA_EXISTE_EXCEP;
                    END IF;
                END IF;
                
                INSERT INTO CUENTA
                    (IBAN, SWIFT)
                    VALUES
                    (IBAN_CUENTA, SWIFT_CUENTA);
                INSERT INTO CTA_FINTECH
                    (IBAN, ESTADO, FECHA_APERTURA, FECHA_CIERRE, CLASIFICACION, CLIENTE_ID)
                    VALUES
                    (IBAN_CUENTA, 'ACTIVA', FECHA_APERTURA_FINTECH, FECHA_CIERRE_FINTECH, CLASIFICACION_FINTECH, ID_CLIENTE);
                    
                IF IBAN_REF IS NULL THEN
                    INSERT INTO CTA_POOLED (IBAN) VALUES (IBAN_CUENTA);
                ELSE
                    INSERT INTO CUENTA
                        (IBAN, SWIFT)
                        VALUES
                        (IBAN_REF, SWIFT_REF);
                    INSERT INTO CTA_REF
                        (IBAN, NOMBRE_BANCO, SUCURSAL, PAIS, SALDO, FECHA_APERTURA, ESTADO, DIVISA_ABREV)
                        VALUES
                        (IBAN_REF, NOMBRE_BANCO_REF, SUCURSAL_REF, PAIS_REF, SALDO_REF, FECHA_APERTURA_REF, 'ACTIVA', DIVISA_REF);
                    INSERT INTO SEGREGADA
                        (IBAN, COMISION, CTA_REF_IBAN)
                        VALUES(IBAN_CUENTA, COMISION_SEGREGADA, IBAN_REF);
                END IF;
            ELSE
                RAISE CLIENTE_INEXISTENTE_EXCEP;
            END IF;
            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO APERTURA_CUENTA;
                RAISE;
        END;
    
    PROCEDURE CIERRE_CUENTA(IBAN_CUENTA IN CUENTA.IBAN%TYPE) IS
        CURSOR SALDOS IS SELECT D.SALDO, D.CTA_REF_IBAN FROM DEPOSITADA_EN D WHERE D.CTA_POOLED_IBAN = IBAN_CUENTA;
        SALDO DEPOSITADA_EN.SALDO%TYPE;
        IBAN_REF DEPOSITADA_EN.CTA_REF_IBAN%TYPE;
        
        ES_POOLED       NUMBER;
        ES_SEGREGADA    NUMBER;
        SALDO_REF       CTA_REF.SALDO%TYPE;
        
        BEGIN
            SAVEPOINT CIERRE_CUENTA;
            SELECT COUNT(P.IBAN) INTO ES_POOLED FROM CTA_POOLED P WHERE P.IBAN = IBAN_CUENTA;
            SELECT COUNT(S.IBAN) INTO ES_SEGREGADA FROM SEGREGADA S WHERE S.IBAN = IBAN_CUENTA;
            
            IF ES_POOLED != 0 THEN
                OPEN SALDOS;
                LOOP
                    FETCH SALDOS INTO SALDO, IBAN_REF;
                    IF SALDOS%FOUND THEN
                        IF SALDO > 0 THEN
                            RAISE SALDO_MAYOR_CERO_EXCEP;
                        ELSE
                            DELETE FROM DEPOSITADA_EN D WHERE D.CTA_POOLED_IBAN = IBAN_CUENTA AND D.CTA_REF_IBAN = IBAN_REF;
                        END IF;
                    ELSE
                        EXIT;
                    END IF; 
                END LOOP;
            ELSIF ES_SEGREGADA != 0 THEN
                SELECT C.SALDO INTO SALDO_REF FROM SEGREGADA S LEFT JOIN CTA_REF C ON (S.CTA_REF_IBAN = C.IBAN) WHERE S.IBAN = IBAN_CUENTA;
                IF SALDO_REF > 0 THEN
                    RAISE SALDO_MAYOR_CERO_EXCEP;
                END IF;         
            END IF;
            
            UPDATE CTA_FINTECH F
                SET
                    F.ESTADO = 'CERRADA',
                    F.FECHA_CIERRE = SYSDATE()
                WHERE F.IBAN = IBAN_CUENTA;
            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO CIERRE_CUENTA;
                RAISE;
        END;
END PK_GESTION_CUENTAS;