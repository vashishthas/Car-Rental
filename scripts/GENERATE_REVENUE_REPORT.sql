-------------------------------------------------------------------------------------------
--Procedure Name: GENERATE_REVENUE_REPORT
--This stored procedure calculates and generates the monthly revenue report.
-------------------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE GENERATE_REVENUE_REPORT AS
--local declarations
    thisLocationID LOCATION_DETAILS.LOCATION_ID%TYPE;  
    currentLocationID LOCATION_DETAILS.LOCATION_ID%TYPE;
    locationName LOCATION_DETAILS.LOCATION_NAME%TYPE;  
    thisCategoryName CAR_CATEGORY.CATEGORY_NAME%TYPE; 
    thisNoOfCars integer;  thisRevenue DECIMAL(15,2);
    
--Cursor declaration
    CURSOR CURSOR_REPORT IS SELECT TABLE1.LOCATIONID, TABLE1.CATNAME ,TABLE1.NOOFCARS,
    SUM(NVL((TABLE2.AMOUNT),0)) AS REVENUE FROM (SELECT LC.LID AS LOCATIONID, LC.CNAME AS CATNAME ,
    COUNT(C.REGISTRATION_NUMBER) AS NOOFCARS FROM (SELECT L.LOCATION_ID AS LID, CC.CATEGORY_NAME AS CNAME FROM 
    CAR_CATEGORY CC CROSS JOIN LOCATION_DETAILS L) LC LEFT OUTER JOIN CAR C ON LC.CNAME = C.CAR_CATEGORY_NAME AND LC.LID = C.LOC_ID
    GROUP BY LC.LID, LC.CNAME ORDER BY LC.LID) TABLE1 LEFT OUTER JOIN (SELECT BC.PLOC AS PICKLOC,BC.CNAME AS CNAMES, 
    SUM(BL.TOTAL_AMOUNT) AS AMOUNT FROM (SELECT B.PICKUP_LOC AS PLOC, C1.CAR_CATEGORY_NAME AS CNAME, B.BOOKING_ID AS BID 
    FROM BOOKING_DETAILS B INNER JOIN CAR C1 ON B.REG_NUM = C1.REGISTRATION_NUMBER) BC INNER JOIN BILLING_DETAILS BL ON BC.BID = BL.BOOKING_ID WHERE 
    (to_date (SYSDATE,'dd-MM-yyyy') - to_date(BL.BILL_DATE,'dd-MM-yyyy')) <=30 GROUP BY BC.PLOC,BC.CNAME ORDER BY BC.PLOC) TABLE2
    ON TABLE1.LOCATIONID=TABLE2.PICKLOC AND TABLE1.CATNAME = TABLE2.CNAMES GROUP BY  TABLE1.LOCATIONID, TABLE1.CATNAME, TABLE1.NOOFCARS 
    ORDER BY TABLE1.LOCATIONID;
BEGIN
    dbms_output.put_line(' ');
    dbms_output.put_line('Revenue Report');
    dbms_output.put_line('**************');
    dbms_output.put_line(' ');
    OPEN CURSOR_REPORT;
    FETCH CURSOR_REPORT INTO thisLocationID, thisCategoryName, thisNoOfCars, thisRevenue;
    IF CURSOR_REPORT%NOTFOUND THEN
      dbms_output.put_line('No Report to be Generated');
    ELSE
      currentLocationID := thisLocationID;
      <<LABEL_NEXTLOC>>
      SELECT LOCATION_NAME INTO locationName from LOCATION_DETAILS WHERE LOCATION_ID = currentLocationID;
      dbms_output.put_line('Location Name: '|| locationName);
      dbms_output.put_line(' ');
      dbms_output.put_line('Car Category' || '    '||'Number of Cars' ||'    '|| 'Revenue');
      dbms_output.put_line('------------' || '    '||'--------------' ||'    '|| '-------');
      dbms_output.put_line(thisCategoryName || RPAD(' ', (16 - LENGTH(thisCategoryName)))||thisNoOfCars 
      ||RPAD(' ', (18 - LENGTH(thisNoOfCars)))|| thisRevenue);
      LOOP
        FETCH CURSOR_REPORT INTO thisLocationID, thisCategoryName, thisNoOfCars, thisRevenue;
        EXIT WHEN (CURSOR_REPORT%NOTFOUND);
        IF thisLocationID = currentLocationID THEN
          dbms_output.put_line(thisCategoryName || RPAD(' ', (16 - LENGTH(thisCategoryName)))||thisNoOfCars 
          ||RPAD(' ', (18 - LENGTH(thisNoOfCars)))|| thisRevenue);
        ELSE
          currentLocationID := thisLocationID;
          dbms_output.put_line(' ');
          dbms_output.put_line('*********************************************************************************************************');
          dbms_output.put_line(' ');
          GOTO LABEL_NEXTLOC;
        END IF;        
      END LOOP;
    END IF;
END;
/










