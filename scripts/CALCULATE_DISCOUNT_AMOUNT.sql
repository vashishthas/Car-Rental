-------------------------------------------------------------------------------------------
--Procedure Name: CALCULATE_DISCOUNT_AMOUNT
--This stored procedure calculates the discount amount for a booking.
-------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE CALCULATE_DISCOUNT_AMOUNT
(dlNum IN CUSTOMER_DETAILS.DL_NUMBER%TYPE,
amount IN BILLING_DETAILS.TOTAL_AMOUNT%TYPE,
discountCode IN DISCOUNT_DETAILS.DISCOUNT_CODE%TYPE, 
discountAmt OUT BILLING_DETAILS.DISCOUNT_AMOUNT%TYPE) AS
--local declarations
memberType CUSTOMER_DETAILS.MEMBERSHIP_TYPE%TYPE;
discountPercentage DISCOUNT_DETAILS.DISCOUNT_PERCENTAGE%TYPE; 
BEGIN
  SELECT MEMBERSHIP_TYPE INTO memberType FROM CUSTOMER_DETAILS WHERE DL_NUMBER = dlNum;
  IF NVL(discountCode,'NULL') <> 'NULL' THEN
    SELECT DISCOUNT_PERCENTAGE INTO discountPercentage FROM DISCOUNT_DETAILS WHERE DISCOUNT_CODE = discountCode;
    IF memberType = 'M' THEN
      discountAmt := amount * ((discountPercentage+10)/100);
    ELSE
      discountAmt := amount * (discountPercentage/100);
    END IF;
  ELSE
    IF memberType = 'M' THEN
      discountAmt := amount * 0.1;
    ELSE
      discountAmt := 0;
    END IF;
  END IF;
END;
/
