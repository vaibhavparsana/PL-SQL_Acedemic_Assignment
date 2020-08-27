/************************************************************************************                                                              *
* Write a stored procedure that can be used to find the number of cars and total amount 
* of money a customer has spent on all cars they have bought.*
*************************************************************************************/
CREATE OR REPLACE PROCEDURE get_car_count_and_total (
    v_custname      IN    saleinv.custname%TYPE
    , v_car_count     OUT   saleinv.carsaleprice%TYPE
    , v_price_total   OUT   saleinv.carsaleprice%TYPE
) AS
BEGIN
    SELECT
        COUNT(saleinvno)
        , SUM(carsaleprice)
    INTO
        v_car_count
    , v_price_total
    FROM
        saleinv
    WHERE
        custname = v_custname
    GROUP BY
        custname;

END;
/

SET SERVEROUTPUT ON;

DECLARE
    CURSOR p_sales IS
    SELECT
        custname
    FROM
        saleinv
    GROUP BY
        custname
    ORDER BY
        custname;

    v_custname      saleinv.custname%TYPE;
    v_car_count     saleinv.carsaleprice%TYPE;
    v_price_total   saleinv.carsaleprice%TYPE;
BEGIN
    FOR p_sale IN p_sales LOOP
        get_car_count_and_total(p_sale.custname, v_car_count, v_price_total);
    END LOOP;
END;
/





/************************************************************************************                                                               *
* Write an anonymous block that would prompt the user to enter a city and uses the 
* procedure created previously (in #1) to display the number of cars and the total amount 
* spent on cars from all the customers from that city. You can use a cursor or a collection 
* to store all the customers from the city and loop through and call the procedure within 
* to display the number of cars and the money spent by the customers. Keep in mind that 
* each city may have been stored in the database in different case spellings 
* (for example OAKVILLE, oakville or Oakville are to be treated as identical). 
*************************************************************************************/
SET SERVEROUTPUT ON;

ACCEPT p_city PROMPT 'Enter customer city: '

DECLARE
    CURSOR p_customers IS
    SELECT
        customer.custname
    FROM
        customer
        INNER JOIN saleinv ON customer.custname = saleinv.custname
    WHERE
        upper(customer.custcity) = upper('&p_city')
    GROUP BY
        customer.custname
    ORDER BY
        customer.custname;

    v_custname      si.customer.custname%TYPE;
    v_car_count     si.saleinv.carsaleprice%TYPE;
    v_price_total   si.saleinv.carsaleprice%TYPE;
    v_count         NUMBER(6);
BEGIN
    FOR p_customer IN p_customers LOOP
        get_car_count_and_total(p_customer.custname, v_car_count, v_price_total);
        dbms_output.put_line(p_customer.custname
                             || ' =>'
                             || upper('&p_city')
                             || '=>'
                             || v_car_count
                             || '=>'
                             || v_price_total);

    END LOOP;

    SELECT
        COUNT(*)
    INTO v_count
    FROM
        (
            SELECT
                customer.custname
            FROM
                customer
                INNER JOIN saleinv ON customer.custname = saleinv.custname
            WHERE
                upper(customer.custcity) = upper('&p_city')
            GROUP BY
                customer.custname
            ORDER BY
                customer.custname
        );

    dbms_output.put_line(v_count
                         || ' customers in '
                         || upper('&p_city'));
END;
/




/************************************************************************************                                                                *
* Create a trigger for car table that will reject inserting or updating values for 
* carlistprice that are either negative or larger than 250000. 
*************************************************************************************/
CREATE OR REPLACE TRIGGER carlistprice_check BEFORE
    INSERT OR UPDATE OF carlistprice ON car
    FOR EACH ROW
DECLARE
    price_out_of_range EXCEPTION;
BEGIN
    IF :new.carlistprice < 0 OR :new.carlistprice >= 250000 THEN
        RAISE price_out_of_range;
    END IF;
EXCEPTION
    WHEN price_out_of_range THEN
        raise_application_error(-20300, 'You can not update or insert values for carlistprice that are either negative or larger than 250000'
        );
END;
/



/************************************************************************************                                                               *
* Write a script with three commands. An INSERT statement inserting a new record in car table. 
* You will have to deal with referential integrity constraints caused by purchinvno, custname etc. 
* Insert values for all columns in the car table and make sure that the value for carlistprice 
* is between 1 and 249999.99. Write an UPDATE statement and update the carlistprice to a value that 
* is either negative or greater than 250000. Follow by a COMMIT. Execute the script and 
* show the response from the server. 
*************************************************************************************/
INSERT INTO car (
    carserial
    , custname
    , carmake
    , carmodel
    , caryear
    , extcolor
    , cartrim
    , enginetype
    , purchinvno
    , purchcost
    , freightcost
    , carlistprice
) VALUES (
    '1s1s1s5z'
    , 'RAJINDER SINGH'
    , 'JAGUAR'
    , 'S-TYPE'
    , '1992'
    , 'RED'
    , 'LEATHER'
    , '3.5LT'
    , '223456'
    , 11111
    , 111
    , 24999.99
);

UPDATE car
SET
    car.carlistprice = 250000
WHERE
    car.carserial = '1s1s1s5z';

COMMIT WORK;

