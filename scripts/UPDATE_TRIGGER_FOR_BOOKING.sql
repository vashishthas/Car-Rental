-------------------------------------------------------------------------------------------
--Trigger Name: UPDATE_CAR_DETAILS
--This trigger updates the availability flag, mileage and location in the car table 
--when the car is returned.
-------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER UPDATE_CAR_DETAILS
AFTER UPDATE ON BOOKING_DETAILS
FOR EACH ROW
WHEN (NVL(TO_CHAR(NEW.ACT_RET_DT_TIME),'NULL') <> 'NULL' OR NEW.BOOKING_STATUS ='C')
DECLARE
BEGIN
    IF :NEW.BOOKING_STATUS ='C' THEN
      UPDATE CAR SET AVAILABILITY_FLAG = 'A' , LOC_ID = :NEW.PICKUP_LOC WHERE REGISTRATION_NUMBER = :NEW.REG_NUM;
    ELSE 
      IF NVL(TO_CHAR(:NEW.ACT_RET_DT_TIME),'NULL') <> 'NULL' THEN
        UPDATE CAR SET AVAILABILITY_FLAG = 'A' , LOC_ID = :NEW.DROP_LOC, MILEAGE = MILEAGE+GET_MILEAGE WHERE REGISTRATION_NUMBER = :NEW.REG_NUM;
      END IF;
    END IF;
END;
/

create or replace function get_mileage
return number
as
mileage CAR.MILEAGE%type;
begin
mileage := dbms_random.value(100,10000);
return mileage;
end;
/