-------------------------------------------------------------------------------------------
--Trigger Name: GENERATE_BILLING
--This trigger generates the bill and inserts a row in Billing_Details table
-------------------------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER GENERATE_BILLING
AFTER UPDATE ON BOOKING_DETAILS
FOR EACH ROW
WHEN (NVL(TO_CHAR(NEW.ACT_RET_DT_TIME),'NULL') <> 'NULL' AND NEW.BOOKING_STATUS ='R')
DECLARE
-- declaration section
lastBillId BILLING_DETAILS.BILL_ID%TYPE;
newBillId BILLING_DETAILS.BILL_ID%TYPE;
discountAmt BILLING_DETAILS.DISCOUNT_AMOUNT%TYPE;
totalLateFee BILLING_DETAILS.TOTAL_LATE_FEE%TYPE;
totalTax BILLING_DETAILS.TAX_AMOUNT%TYPE;
totalAmountBeforeDiscount BILLING_DETAILS.TOTAL_AMOUNT%TYPE;
finalAmount BILLING_DETAILS.TOTAL_AMOUNT%TYPE;

BEGIN

  SELECT BILL_ID INTO lastBillId FROM ( SELECT BILL_ID, ROWNUM AS RN FROM  BILLING_DETAILS) 
  WHERE RN= (SELECT MAX(ROWNUM) FROM BILLING_DETAILS);
  
  newBillId := 'BL' || TO_CHAR(TO_NUMBER(SUBSTR(lastBillId,3))+1);
  
  CALCULATE_LATE_FEE_AND_TAX(:NEW.ACT_RET_DT_TIME, :NEW.RET_DT_TIME, :NEW.REG_NUM,:NEW.AMOUNT, totalLateFee, totalTax);
  
  totalAmountBeforeDiscount := :NEW.AMOUNT + totalLateFee + totalTax;
  
  CALCULATE_DISCOUNT_AMOUNT(:NEW.DL_NUM, totalAmountBeforeDiscount, :NEW.DISCOUNT_CODE, discountAmt);
  
  finalAmount := totalAmountBeforeDiscount - discountAmt;  
  --insert new bill into the billing_details table
  INSERT INTO BILLING_DETAILS (BILL_ID,BILL_DATE,BILL_STATUS,DISCOUNT_AMOUNT,TOTAL_AMOUNT,TAX_AMOUNT,BOOKING_ID,TOTAL_LATE_FEE) 
  VALUES (newBillId,to_date(SYSDATE,'YYYY-MM-DD'),'P',discountAmt,finalAmount,totalTax,:NEW.BOOKING_ID,totalLateFee);
  
END;
/









