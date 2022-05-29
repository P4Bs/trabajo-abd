CREATE OR REPLACE PACKAGE BODY PK_OPERATIVA AS
    PROCEDURE INSERTAR_TRANSACCION(ID_TRANS IN TRANSACCION.ID%TYPE,
                                    FECHA_INST IN TRANSACCION.FECHA_INSTRUCCION%TYPE, CANTIDAD_TRANS IN TRANSACCION.CANTIDAD%TYPE,
                                    FECHA_EJEC IN TRANSACCION.FECHA_EJECUCION%TYPE, TIPO_TRANS IN TRANSACCION.TIPO%TYPE,
                                    COMISION_TRANS IN TRANSACCION.COMISION%TYPE, INTERNACIONAL_TRANS IN TRANSACCION.INTERNACIONAL%TYPE,
                                    DIVISA_ORIGEN IN TRANSACCION.DIVISA_ABREV_ORIGEN%TYPE, DIVISA_DESTINO IN TRANSACCION.DIVISA_ABREV_DESTINO%TYPE,
                                    IBAN_ORIGEN IN TRANSACCION.CUENTA_IBAN_ORIGEN%TYPE, IBAN_DESTINO IN TRANSACCION.CUENTA_IBAN_DESTINO%TYPE) IS
        ES_POOLED_ORIGEN        NUMBER;
        ES_POOLED_DESTINO       NUMBER;
        IBAN_REFERENCIA_ORIGEN  CTA_REF.IBAN%TYPE;
        IBAN_REFERENCIA_DESTINO CTA_REF.IBAN%TYPE;
        SALDO_ORIGEN            FLOAT;
        SALDO_DESTINO           FLOAT;
        CAMBIO_EUR_ORIGEN       DIVISA.CAMBIO_EUR%TYPE;
        CAMBIO_EUR_DESTINO      DIVISA.CAMBIO_EUR%TYPE;
        
        BEGIN
            SAVEPOINT INSERTAR_TRANSACCION;
            SELECT COUNT(IBAN_ORIGEN) INTO ES_POOLED_ORIGEN FROM CTA_POOLED P WHERE P.IBAN = IBAN_ORIGEN;
            SELECT COUNT(IBAN_DESTINO) INTO ES_POOLED_DESTINO FROM CTA_POOLED P WHERE P.IBAN = IBAN_DESTINO;
            
            IF ES_POOLED_ORIGEN > 0 THEN
                SELECT R.IBAN, R.SALDO INTO IBAN_REFERENCIA_ORIGEN, SALDO_ORIGEN 
                    FROM DEPOSITADA_EN D JOIN CTA_REF R ON (D.CTA_REF_IBAN = R.IBAN) 
                    WHERE D.CTA_POOLED_IBAN = IBAN_ORIGEN AND R.DIVISA_ABREV = DIVISA_ORIGEN;
            ELSE
                SELECT R.IBAN, R.SALDO INTO IBAN_REFERENCIA_ORIGEN, SALDO_ORIGEN
                    FROM SEGREGADA S JOIN CTA_REF R ON (S.CTA_REF_IBAN = R.IBAN)
                    WHERE S.IBAN = IBAN_ORIGEN;
            END IF;
            
            
            IF ES_POOLED_DESTINO > 0 THEN
                SELECT R.IBAN, R.SALDO INTO IBAN_REFERENCIA_DESTINO, SALDO_DESTINO
                    FROM DEPOSITADA_EN D JOIN CTA_REF R ON (D.CTA_REF_IBAN = R.IBAN) 
                    WHERE D.CTA_POOLED_IBAN = IBAN_DESTINO AND R.DIVISA_ABREV = DIVISA_DESTINO;
            ELSE
                SELECT R.IBAN, R.SALDO INTO IBAN_REFERENCIA_DESTINO, SALDO_DESTINO
                    FROM SEGREGADA S JOIN CTA_REF R ON (S.CTA_REF_IBAN = R.IBAN)
                    WHERE S.IBAN = IBAN_DESTINO;
            END IF;
            
            SELECT CAMBIO_EUR INTO CAMBIO_EUR_ORIGEN
                FROM DIVISA
                WHERE ABREV = DIVISA_ORIGEN;
                
            SELECT CAMBIO_EUR INTO CAMBIO_EUR_DESTINO
                FROM DIVISA
                WHERE ABREV = DIVISA_DESTINO;
            
            IF TIPO_TRANS = 'INGRESO' THEN
                SALDO_ORIGEN := SALDO_ORIGEN + CANTIDAD_TRANS / CAMBIO_EUR_ORIGEN;
                SALDO_DESTINO := SALDO_DESTINO - CANTIDAD_TRANS / CAMBIO_EUR_DESTINO;
            ELSIF TIPO_TRANS = 'CARGO' THEN
                SALDO_ORIGEN := SALDO_ORIGEN - CANTIDAD_TRANS / CAMBIO_EUR_ORIGEN;
                SALDO_DESTINO := SALDO_DESTINO + CANTIDAD_TRANS / CAMBIO_EUR_DESTINO;
            ELSE
                RAISE TIPO_TRANSACCION_EXCEP;
            END IF;
            
            DBMS_OUTPUT.PUT_LINE(SALDO_ORIGEN);
            DBMS_OUTPUT.PUT_LINE(SALDO_DESTINO);   
            DBMS_OUTPUT.PUT_LINE(CANTIDAD_TRANS); 
            
            UPDATE CTA_REF R
                SET
                    R.SALDO = SALDO_ORIGEN
                WHERE IBAN = IBAN_REFERENCIA_ORIGEN;
            
            UPDATE CTA_REF R
                SET
                    R.SALDO = SALDO_DESTINO
                WHERE IBAN = IBAN_REFERENCIA_DESTINO;
            
            INSERT INTO TRANSACCION
                (ID, FECHA_INSTRUCCION, CANTIDAD, FECHA_EJECUCION, TIPO, COMISION, INTERNACIONAL, DIVISA_ABREV_ORIGEN, DIVISA_ABREV_DESTINO, CUENTA_IBAN_ORIGEN, CUENTA_IBAN_DESTINO)
            VALUES
                (ID_TRANS, FECHA_INST, CANTIDAD_TRANS, FECHA_EJEC, TIPO_TRANS, COMISION_TRANS, INTERNACIONAL_TRANS, DIVISA_ORIGEN, DIVISA_DESTINO, IBAN_ORIGEN, IBAN_DESTINO);
            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO INSERTAR_TRANSACCION;
                RAISE;
        END;

    PROCEDURE CAMBIO_DIVISA(IBAN_CUENTA TRANSACCION.CUENTA_IBAN_ORIGEN%TYPE,
                            DIVISA_ORIGEN TRANSACCION.DIVISA_ABREV_ORIGEN%TYPE, DIVISA_DESTINO TRANSACCION.DIVISA_ABREV_DESTINO%TYPE) IS
        IBAN_REFERENCIA_ORIGEN  CTA_REF.IBAN%TYPE;
        IBAN_REFERENCIA_DESTINO CTA_REF.IBAN%TYPE;
        SALDO_ORIGEN            CTA_REF.SALDO%TYPE;
        SALDO_DESTINO           CTA_REF.SALDO%TYPE;
        NUEVO_SALDO             FLOAT;
        CAMBIO_EUR_ORIGEN       DIVISA.CAMBIO_EUR%TYPE;
        CAMBIO_EUR_DESTINO      DIVISA.CAMBIO_EUR%TYPE;
        
        BEGIN
            SAVEPOINT CAMBIO_DIVISA;
            SELECT R.IBAN, DE.SALDO, D.CAMBIO_EUR INTO IBAN_REFERENCIA_ORIGEN, SALDO_ORIGEN, CAMBIO_EUR_ORIGEN
                FROM DEPOSITADA_EN DE JOIN CTA_REF R ON (DE.CTA_REF_IBAN = R.IBAN) JOIN DIVISA D ON (R.DIVISA_ABREV = D.ABREV)
                WHERE DE.CTA_POOLED_IBAN = IBAN_CUENTA AND R.DIVISA_ABREV = DIVISA_ORIGEN;
                
            SELECT R.IBAN, DE.SALDO, D.CAMBIO_EUR INTO IBAN_REFERENCIA_DESTINO, SALDO_DESTINO, CAMBIO_EUR_DESTINO
                FROM DEPOSITADA_EN DE JOIN CTA_REF R ON (DE.CTA_REF_IBAN = R.IBAN) JOIN DIVISA D ON (R.DIVISA_ABREV = D.ABREV)
                WHERE DE.CTA_POOLED_IBAN = IBAN_CUENTA AND R.DIVISA_ABREV = DIVISA_DESTINO;
                
            UPDATE CTA_REF R
                SET
                    R.SALDO = 0
                WHERE IBAN = IBAN_REFERENCIA_ORIGEN;
                
            UPDATE DEPOSITADA_EN D
                SET
                    D.SALDO = 0
                WHERE CTA_POOLED_IBAN = IBAN_CUENTA AND CTA_REF_IBAN = IBAN_REFERENCIA_ORIGEN;
            
            DBMS_OUTPUT.PUT_LINE(SALDO_DESTINO + SALDO_ORIGEN * CAMBIO_EUR_ORIGEN/CAMBIO_EUR_DESTINO);
            NUEVO_SALDO := SALDO_DESTINO + SALDO_ORIGEN * CAMBIO_EUR_ORIGEN/CAMBIO_EUR_DESTINO;
            
            UPDATE CTA_REF R
                SET
                    R.SALDO = NUEVO_SALDO
                WHERE IBAN = IBAN_REFERENCIA_DESTINO;
                
            UPDATE DEPOSITADA_EN D
                SET
                    D.SALDO = NUEVO_SALDO
                WHERE CTA_POOLED_IBAN = IBAN_CUENTA AND CTA_REF_IBAN = IBAN_REFERENCIA_DESTINO;
                
            INSERT INTO TRANSACCION
                (FECHA_INSTRUCCION, CANTIDAD, FECHA_EJECUCION, TIPO, COMISION, INTERNACIONAL, DIVISA_ABREV_ORIGEN, DIVISA_ABREV_DESTINO, CUENTA_IBAN_ORIGEN, CUENTA_IBAN_DESTINO)
                VALUES
                (SYSDATE(), SALDO_ORIGEN * CAMBIO_EUR_ORIGEN, NULL, 'CAMBIO_DIVISA', NULL, NULL, DIVISA_ORIGEN, DIVISA_DESTINO, IBAN_CUENTA, IBAN_CUENTA);
            COMMIT;
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK TO CAMBIO_DIVISA;
                RAISE;
        END;
END PK_OPERATIVA;