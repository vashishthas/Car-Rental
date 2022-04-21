-------------------------------------------------------------------------------------------
--Procedure Name: CALCULATE_LATE_FEE_AND_TAX
--This stored procedure calculates the total late fee and tax.
-------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE CALCULATE_LATE_FEE_AND_TAX
(actualReturnDateTime IN BOOKING_DETAILS.ACT_RET_DT_TIME%TYPE,
ReturnDateTime IN BOOKING_DETAILS.RET_DT_TIME%TYPE,
regNum IN BOOKING_DETAILS.REG_NUM%TYPE, 
amount IN BOOKING_DETAILS.AMOUNT%TYPE,
totalLateFee OUT BILLING_DETAILS.TOTAL_AMOUNT%TYPE,
totalTax OUT BILLING_DETAILS.TAX_AMOUNT%TYPE ) AS
--local declarations
lateFeePerHour CAR_CATEGORY.LATE_FEE_PER_HOUR%TYPE;
hourDifference DECIMAL(10,2);
BEGIN
  SELECT LATE_FEE_PER_HOUR INTO lateFeePerHour 
  FROM CAR_CATEGORY CC INNER JOIN CAR C ON CC.CATEGORY_NAME = C.CAR_CATEGORY_NAME 
  WHERE C.REGISTRATION_NUMBER = regNum;
  
  IF actualReturnDateTime > ReturnDateTime THEN
    hourDifference := (TO_DATE (TO_CHAR (actualReturnDateTime, 'dd/mm/yyyy  hh24:mi:ss'), 'dd/mm/yyyy  hh24:mi:ss')
                      - TO_DATE (TO_CHAR (ReturnDateTime, 'dd/mm/yyyy  hh24:mi:ss'),'dd/mm/yyyy  hh24:mi:ss'))*(24);
    totalLateFee := hourDifference * lateFeePerHour;
  ELSE
    totalLateFee := 0;
  END IF;
  totalTax := (amount + totalLateFee)*0.0825;
END;
/


