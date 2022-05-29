-- EJERCICIO 2.A
CREATE OR REPLACE VIEW V_SALDOS AS
    SELECT 
            CASE
                WHEN PA.IDENT IS NULL THEN C.IDENT
                WHEN PA.IDENT IS NOT NULL THEN PA.IDENT
            END "IDENTIFICACION",
            CF.IBAN, 
            CASE 
                WHEN S.IBAN IS NULL THEN DE.SALDO
                WHEN S.IBAN IS NOT NULL THEN CR.SALDO
            END "SALDO",
            D.ABREV "ABREVIATURA", D.CAMBIO_EUR "CAMBIOEURO"
    FROM ((((CLIENTE C LEFT JOIN (PERS_AUTORIZ PA JOIN AUTORIZACION A ON (PA.ID = A.PERS_AUTORIZ_ID)) ON (C.ID = A.EMPRESA_ID)
            JOIN CTA_FINTECH CF ON (C.ID = CF.CLIENTE_ID))
                LEFT JOIN SEGREGADA S ON (S.IBAN = CF.IBAN))
                    LEFT JOIN DEPOSITADA_EN DE ON (DE.CTA_POOLED_IBAN = CF.IBAN))
                        LEFT JOIN CTA_REF CR ON (CR.IBAN = DE.CTA_REF_IBAN OR S.CTA_REF_IBAN = CR.IBAN))
                            LEFT JOIN DIVISA D ON (D.ABREV = CR.DIVISA_ABREV);
SELECT * FROM V_SALDOS;

-- EJERCICIO 2.B
CREATE SEQUENCE SQ_CLIENTE START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SQ_PERSONA START WITH 1 INCREMENT BY 1;

-- EJERCICIO 2.C
-- DAMOS EL GRANT DE CREAR TRIGGER A NUESTRO USUARIO DESDE SYSTEM
GRANT CREATE TRIGGER TO FINTECH;

CREATE SEQUENCE SQ_TRANSACCION START WITH 1 INCREMENT BY 1;
CREATE OR REPLACE TRIGGER TR_TRANSACCION BEFORE INSERT ON TRANSACCION
    FOR EACH ROW
    BEGIN
        :NEW.ID := SQ_TRANSACCION.NEXTVAL;
    END;

-- EJERCICIOS 3.A Y 3.B
CREATE OR REPLACE VIEW V_TARJETA_MENSUAL AS
    SELECT C.IDENT "IDENTIFICACION", T.NUM_TARJETA "NUMERO_TARJETA", SUM(M.CANTIDAD) "GASTO", M.DIVISA_ABREV "ABREVIATURA"
    FROM (CLIENTE C JOIN TARJETA T ON (C.ID = T.CLIENTE_ID)) JOIN MOVIMIENTO M ON (T.ID = M.TARJETA_ID)
    GROUP BY C.IDENT, T.NUM_TARJETA, M.DIVISA_ABREV; 
SELECT * FROM V_TARJETA_MENSUAL;

CREATE OR REPLACE VIEW V_PAGOS_PENDIENTES AS
    SELECT C.IDENT "IDENTIFICACION", T.NUM_TARJETA "NUMERO_TARJETA", COUNT(M.ESTADO) "PENDIENTES", M.DIVISA_ABREV "ABREVIATURA"
    FROM (CLIENTE C JOIN TARJETA T ON (C.ID = T.CLIENTE_ID)) JOIN MOVIMIENTO M ON (T.ID = M.TARJETA_ID)
    WHERE M.ESTADO = 'PENDIENTE'
    GROUP BY C.IDENT, T.NUM_TARJETA, M.DIVISA_ABREV;

-- EJERCICIO 3.C
CREATE OR REPLACE PROCEDURE P_COBRO IS
    CURSOR MOVIMIENTOS_A_COBRAR IS SELECT ID, CANTIDAD, TARJETA_ID, DIVISA_ABREV FROM MOVIMIENTO WHERE ESTADO = 'PENDIENTE' AND MODO_OPERACION = 'DEBITO';
    ID_MOVIMIENTO           MOVIMIENTO.ID%TYPE;
    CANTIDAD_MOVIMIENTO     MOVIMIENTO.CANTIDAD%TYPE;
    ID_TARJETA              MOVIMIENTO.TARJETA_ID%TYPE;
    DIVISA_MOVIMIENTO       MOVIMIENTO.DIVISA_ABREV%TYPE;
    IBAN_FINTECH            TARJETA.CUENTA_IBAN%TYPE;
    ES_POOLED               NUMBER;
    IBAN_CUENTA_REFERENCIA  DEPOSITADA_EN.CTA_REF_IBAN%TYPE;
    OLD_SALDO               CTA_REF.SALDO%TYPE;
    
    BEGIN
        SAVEPOINT P_COBRO;
        OPEN MOVIMIENTOS_A_COBRAR;
        LOOP
            FETCH MOVIMIENTOS_A_COBRAR INTO ID_MOVIMIENTO, CANTIDAD_MOVIMIENTO, ID_TARJETA, DIVISA_MOVIMIENTO;
            SELECT CUENTA_IBAN INTO IBAN_FINTECH FROM TARJETA WHERE ID = ID_TARJETA;
            SELECT COUNT(P.IBAN) INTO ES_POOLED FROM CTA_POOLED P WHERE P.IBAN = IBAN_FINTECH;
            
            IF ES_POOLED > 0 THEN
                SELECT R.IBAN, D.SALDO INTO IBAN_CUENTA_REFERENCIA, OLD_SALDO 
                    FROM DEPOSITADA_EN D JOIN CTA_REF R ON (D.CTA_REF_IBAN = R.IBAN) 
                    WHERE D.CTA_POOLED_IBAN = IBAN_FINTECH AND R.DIVISA_ABREV = DIVISA_MOVIMIENTO;
                
                IF OLD_SALDO >= CANTIDAD_MOVIMIENTO THEN
                    UPDATE DEPOSITADA_EN
                        SET
                            SALDO = OLD_SALDO - CANTIDAD_MOVIMIENTO
                        WHERE CTA_POOLED_IBAN = IBAN_FINTECH AND CTA_REF_IBAN = IBAN_CUENTA_REFERENCIA; 
                ELSE
                    DBMS_OUTPUT.PUT_LINE(' NO SE HA PODIDO REALIZAR EL COBRO DEL MOVIMIENTO CON ID ' || ID_MOVIMIENTO || '. 
                                EL SALDO ES INFERIOR A LA CANTIDAD A ');
                END IF;
            ELSE
                SELECT S.CTA_REF_IBAN, R.SALDO INTO IBAN_CUENTA_REFERENCIA, OLD_SALDO 
                    FROM SEGREGADA S JOIN CTA_REF R ON (R.IBAN = S.CTA_REF_IBAN)
                    WHERE S.IBAN = IBAN_FINTECH;
                    
                IF OLD_SALDO >= CANTIDAD_MOVIMIENTO THEN
                    UPDATE CTA_REF
                        SET
                            SALDO = OLD_SALDO - CANTIDAD_MOVIMIENTO
                        WHERE IBAN = IBAN_CUENTA_REFERENCIA;
                ELSE
                    DBMS_OUTPUT.PUT_LINE(' NO SE HA PODIDO REALIZAR EL COBRO DEL MOVIMIENTO CON ID ' || ID_MOVIMIENTO || '. 
                                EL SALDO ES INFERIOR A LA CANTIDAD A ');
                END IF;
            END IF;
            
            UPDATE MOVIMIENTO
                SET
                    ESTADO = 'COBRADO'
                WHERE ID = ID_MOVIMIENTO;
        END LOOP;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK TO P_COBRO;
            RAISE;
    END;


-- EJERCICIO 3.D
-- DESDE SYSTEM
GRANT CREATE JOB TO FINTECH;

-- DESDE FINTECH
BEGIN  
    DBMS_SCHEDULER.CREATE_JOB (
        JOB_NAME        => 'J_LIQUIDAR',
        JOB_TYPE        => 'PLSQL_BLOCK',
        JOB_ACTION      => 'P_COBRO',
        REPEAT_INTERVAL => 'FREQ=MONTHLY;BYMONTHDAY = 1',
        COMMENTS        => 'JOB PARA REALIZAR EL COBRO DE TODOS LOS MOVIMIENTOS DE DEBITO'
    );
    -- DBMS_SCHEDULER.DROP_JOB(JOB_NAME => 'J_LIQUIDAR');
END;
