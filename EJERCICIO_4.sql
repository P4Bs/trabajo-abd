-- DESDE FINTECH
BEGIN  
    DBMS_SCHEDULER.CREATE_JOB (
        JOB_NAME        => 'J_CAMBIO_EURO',
        JOB_TYPE        => 'PLSQL_BLOCK',
        JOB_ACTION      => 'UPDATE DIVISA D, V_COTIZACIONES C,
                                SET D.CAMBIO_EUR = C.CAMBIOEURO
                            WHERE D.ABREV = C.ABREV',
        REPEAT_INTERVAL => 'FREQ=DAILY;BYHOUR=0;BYMINUTE=5',
        COMMENTS        => 'JOB PARA ACTUALIZAR LA TABLA DIVISA CON LOS DATOS DE LA VISTA V_COTIZACIONES'
    );
    -- DBMS_SCHEDULER.DROP_JOB(JOB_NAME => 'J_CAMBIO_EURO');
END;

CREATE OR REPLACE PROCEDURE P_COBRO_APLAZADO IS
    CURSOR MOVIMIENTOS_A_COBRAR IS SELECT ID, CANTIDAD, TARJETA_ID, DIVISA_ABREV FROM MOVIMIENTO WHERE ESTADO = 'PENDIENTE' AND (MODO_OPERACION = 'CREDITO' OR MODO_OPERACION = 'APLAZADO');
    ID_MOVIMIENTO           MOVIMIENTO.ID%TYPE;
    CANTIDAD_MOVIMIENTO     MOVIMIENTO.CANTIDAD%TYPE;
    ID_TARJETA              MOVIMIENTO.TARJETA_ID%TYPE;
    DIVISA_MOVIMIENTO       MOVIMIENTO.DIVISA_ABREV%TYPE;
    IBAN_FINTECH            TARJETA.CUENTA_IBAN%TYPE;
    ES_POOLED               NUMBER;
    IBAN_CUENTA_REFERENCIA  DEPOSITADA_EN.CTA_REF_IBAN%TYPE;
    OLD_SALDO               CTA_REF.SALDO%TYPE;
    
    BEGIN
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
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE(' HA OCURRIDO UN ERROR EN EL PROCESO DE COBRO');
    END;
