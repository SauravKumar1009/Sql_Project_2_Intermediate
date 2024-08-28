
-- Create the database
CREATE DATABASE OnlineRetailDB_;
GO

-- Use the database
USE OnlineRetailDB_;
Go

-- Create the Customers table
CREATE TABLE Customers (
	CustomerID INT PRIMARY KEY IDENTITY(1,1),
	FirstName NVARCHAR(50),
	LastName NVARCHAR(50),
	Email NVARCHAR(100),
	Phone NVARCHAR(50),
	Address NVARCHAR(255),
	City NVARCHAR(50),
	State NVARCHAR(50),
	ZipCode NVARCHAR(50),
	Country NVARCHAR(50),
	CreatedAt DATETIME DEFAULT GETDATE()
);

-- Create the Products table
CREATE TABLE Products (
	ProductID INT PRIMARY KEY IDENTITY(1,1),
	ProductName NVARCHAR(100),
	CategoryID INT,
	Price DECIMAL(10,2),
	Stock INT,
	CreatedAt DATETIME DEFAULT GETDATE()
);

-- Create the Categories table
CREATE TABLE Categories (
	CategoryID INT PRIMARY KEY IDENTITY(1,1),
	CategoryName NVARCHAR(100),
	Description NVARCHAR(255)
);

-- Create the Orders table
CREATE TABLE Orders (
	OrderId INT PRIMARY KEY IDENTITY(1,1),
	CustomerId INT,
	OrderDate DATETIME DEFAULT GETDATE(),
	TotalAmount DECIMAL(10,2),
	FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Alter / Rename the Column Name
EXEC sp_rename 'OnlineRetailDB.dbo.Orders.CustomerId', 'CustomerID', 'COLUMN'; 

-- Create the OrderItems table
CREATE TABLE OrderItems (
	OrderItemID INT PRIMARY KEY IDENTITY(1,1),
	OrderID INT,
	ProductID INT,
	Quantity INT,
	Price DECIMAL(10,2),
	FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
	FOREIGN KEY (OrderId) REFERENCES Orders(OrderID)
);

-- Insert sample data into Categories table
INSERT INTO Categories (CategoryName, Description) 
VALUES 
('Electronics', 'Devices and Gadgets'),
('Clothing', 'Apparel and Accessories'),
('Books', 'Printed and Electronic Books');

-- Insert sample data into Products table
INSERT INTO Products(ProductName, CategoryID, Price, Stock)
VALUES 
('Smartphone', 1, 699.99, 50),
('Laptop', 1, 999.99, 30),
('T-shirt', 2, 19.99, 100),
('Jeans', 2, 49.99, 60),
('Fiction Novel', 3, 14.99, 200),
('Science Journal', 3, 29.99, 150);

-- Insert sample data into Customers table
INSERT INTO Customers(FirstName, LastName, Email, Phone, Address, City, State, ZipCode, Country)
VALUES 
('Sameer', 'Khanna', 'sameer.khanna@example.com', '123-456-7890', '123 Elm St.', 'Springfield', 
'IL', '62701', 'USA'),
('Jane', 'Smith', 'jane.smith@example.com', '234-567-8901', '456 Oak St.', 'Madison', 
'WI', '53703', 'USA'),
('harshad', 'patel', 'harshad.patel@example.com', '345-678-9012', '789 Dalal St.', 'Mumbai', 
'Maharashtra', '41520', 'INDIA');

INSERT INTO Customers(FirstName, LastName, Email, Phone, Address, City, State, ZipCode, Country)
VALUES 
('Saurav', 'Kumar', 'saurav.k@example.com', '123-123-7890', '123 Elm St.', 'Springfield', 
'GJ', '85640', 'INDIA');

-- Insert sample data into Orders table
INSERT INTO Orders(CustomerId, OrderDate, TotalAmount)
VALUES 
(1, GETDATE(), 719.98),
(2, GETDATE(), 49.99),
(3, GETDATE(), 44.98);

-- Insert sample data into OrderItems table
INSERT INTO OrderItems(OrderID, ProductID, Quantity, Price)
VALUES 
(1, 1, 1, 699.99),
(1, 3, 1, 19.99),
(2, 4, 1,  49.99),
(3, 5, 1, 14.99),
(3, 6, 1, 29.99);

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
	 


	   
       
       

       








