SELECT NAME FROM sys.tables;

select top 2 * from Customers;
select top 2 * from Categories;
select top 2 * from Orders;
select top 2 * from OrderItems;
select top 2 * from Products;

USE OnlineRetailDB_;

-- Q1. Retrive all orders for a specific customer (Whose customerID is 1)
       SELECT O.OrderId,O.OrderDate,O.TotalAmount,P.ProductName,C.Quantity,C.Price
	   FROM Orders O 
	   JOIN OrderItems C 
	   ON O.OrderId = C.OrderID
	   JOIN Products P 
	   ON C.ProductID = P.ProductID
	   WHERE O.CustomerID = 1 ;

-- Q2. Find the total sales for each product
       SELECT P.ProductID,
	          P.ProductName,
			  SUM(Oi.Quantity * Oi.Price) AS 'Total Sales'
	   FROM Products P 
	   LEFT JOIN OrderItems Oi 
	   ON P.ProductID = Oi.ProductID
	   GROUP BY P.ProductID,P.ProductName 
	   ORDER BY 'Total Sales' DESC;

-- Q3. Calculate the average order value
       
	   SELECT AVG(TotalAmount) AS 'AVG AMOUNT' FROM Orders ;

-- Q4. List the top 5 customers by total spending
   -- Method 1
       SELECT TOP 5 
	              C.CustomerID,
				  C.FirstName,
				  C.LastName,
				  SUM(O.TotalAmount) AS TotalSpending
	   FROM Customers C 
	   JOIN Orders O 
	   ON C.CustomerID = O.CustomerId
	   GROUP BY C.CustomerID,C.FirstName,C.LastName ;

   -- Method 2
	   WITH CTE AS 
	   (
	   SELECT TOP 5 C.CustomerID,C.FirstName,C.LastName,SUM(O.TotalAmount) AS TotalAmount,
	   ROW_NUMBER() OVER(ORDER BY SUM(O.TotalAmount)DESC) AS TS
	   FROM Customers C 
	   JOIN Orders O 
	   ON C.CustomerID = O.CustomerId
	   GROUP BY C.CustomerID,C.FirstName,C.LastName 
	   )
	   SELECT * FROM CTE WHERE TS <= 5;
	   
-- Q5.Retrieve the most popular product category (The products which are most sold)
      SELECT TOP 1 
	             C.CategoryName,
				 C.Description,
				 SUM(O.Quantity) AS 'Total Quantity Sold'
      FROM Categories C
	  JOIN Products P 
	  ON C.CategoryID = P.CategoryID 
	  JOIN OrderItems O 
	  ON P.ProductID = O.ProductID 
	  GROUP BY C.CategoryName,C.Description
	  ORDER BY 'Total Quantity Sold' DESC ;

-- Q6.List all products that are out of stocks
      
	  SELECT * FROM Products WHERE Stock = 0;
	  
	  -- If we have to display the name of the category
	  SELECT P.ProductID,P.ProductName,C.CategoryName,P.Stock
	  FROM Products P JOIN Categories C
	  ON P.CategoryID = C.CategoryID 
	  WHERE P.Stock = 0;
	  

-- Q7.Find customers who placed order in last 30 days
      SELECT C.FirstName,C.LastName,O.CustomerID,O.TotalAmount,O.OrderDate
	  FROM Orders O JOIN Customers C
	  ON O.CustomerID = C.CustomerID
	  WHERE O.OrderDate >= DATEADD(DAY,-30,GETDATE()) ;
	  
-- Q8.Calculate the total number of orders placed each month
      SELECT 
	        YEAR(OrderDate) AS Year,
			MONTH(OrderDate) AS MONTH,
			COUNT(OrderId) AS 'COUNT OF ORDERS'
	  FROM Orders
	  GROUP BY YEAR(OrderDate),MONTH(OrderDate) ;

-- Q9.Retrieve the details of the most recent order
      SELECT TOP 1 O.OrderId,O.OrderDate,O.TotalAmount,C.FirstName,C.LastName
	  FROM Orders O JOIN Customers C
	  ON O.CustomerID = C.CustomerID 
	  ORDER BY O.OrderId DESC;

-- Q10.Find the average price of products in each category
       SELECT 
	         P.ProductID,
			 P.ProductName,
			 C.CategoryName,
			 AVG(P.Price) AS Avg_Price
	   FROM Products P JOIN Categories C
	   ON P.CategoryID = C.CategoryID 
	   GROUP BY P.ProductID,P.ProductName,C.CategoryName ;

-- Q11.List customers who never placed an order
       SELECT C.CustomerID,C.FirstName,C.LastName,O.OrderId,O.OrderDate
	   FROM Customers C LEFT JOIN Orders O
	   ON C.CustomerID = O.CustomerID 
	   WHERE O.OrderId IS NULL ;

-- Q12.Retrieve the total quantity sold for each product
       SELECT   
	        P.ProductID,
	        P.ProductName,
			SUM(O.Quantity) AS 'TOTAL QUANTITY SOLD'
	   FROM 
	   Products P LEFT JOIN OrderItems O
	   ON P.ProductID = O.ProductID 
	   GROUP BY P.ProductID,P.ProductName
       -- ORDER BY 'TOTAL QUANTITY SOLD' DESC;

	  
-- Q13.Calculate the total revenue generated from each category.
	   SELECT 
	         C.CategoryID,
			 C.CategoryName,
			 SUM((O.Quantity*O.Price)) AS 'Total Revenue'
	   FROM Categories C JOIN Products P 
	   ON C.CategoryID = P.CategoryID
	   JOIN OrderItems O 
	   ON P.ProductID = O.ProductID
	   GROUP BY C.CategoryID,C.CategoryName
	   ORDER BY 'Total Revenue' DESC;

-- Q14.Find the highest-priced product in each category.
	   SELECT 
	        C.CategoryName,
			MAX(P.Price) AS MaxPrice 
	   FROM Categories C JOIN Products P
	   ON C.CategoryID = P.CategoryID
	   GROUP BY C.CategoryName
	   ORDER BY MaxPrice DESC;

-- Q15.Retrieve orders with a total amount greater than a specific value (eg - $500)
       SELECT C.FirstName,C.LastName,C.Email,O.TotalAmount
	   FROM Customers C JOIN Orders O 
	   ON C.CustomerID = O.CustomerID 
	   WHERE O.TotalAmount > $500 ;

-- Q16.List products along with the number of orders they appear in
	   SELECT 
	        P.ProductName,
			COUNT(OI.Quantity) AS 'NO OF ORDERS'
	   FROM Products P JOIN OrderItems OI
	   ON P.ProductID = OI.ProductID
	   GROUP BY P.ProductName;

-- Q17.Find the top 3 most frequently ordered products.
       SELECT TOP 3 
	          P.ProductID,
			  P.ProductName,
			  COUNT(OI.Quantity)
	   FROM Products P JOIN OrderItems OI
	   ON P.ProductID = OI.ProductID
	   GROUP BY P.ProductID,P.ProductName
	   ORDER BY COUNT(OI.Quantity) DESC;
       
-- Q18.Calculate the total number of customers from each country.
       SELECT 
	        COUNTRY,
			COUNT(CustomerID) AS 'NO OF CUTOMERS'
	   FROM Customers
	   GROUP BY Country
	   ORDER BY 'NO OF CUTOMERS';

-- Q19.Retrieve the list of customers along with their total spending
       SELECT 
	        C.CustomerID,
			C.FirstName,
			C.LastName,
			C.Email,
			SUM(O.TotalAmount)
	   FROM Customers C JOIN Orders O
	   ON C.CustomerID = O.CustomerID
	   GROUP BY C.CustomerID,C.FirstName,C.LastName,C.Email;
	   
-- Q20.List orders with more than a specified number of items (Eg - 0 items)
       SELECT 
	        OI.ProductID,
			COUNT(OI.Quantity) AS 'NO OF ITEMS'
	   FROM OrderItems OI JOIN Orders O 
	   ON OI.OrderID = O.OrderId
       GROUP BY OI.ProductID 
	   HAVING COUNT(OI.Quantity)> 0;

-- End of Project
	 


	   
       
       

       








