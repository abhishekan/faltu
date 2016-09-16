-- Create Database
CREATE DATABASE BookStoreDB
USE BookStoreDB

--Author Table
CREATE TABLE AUTHOR(
	AuthorId int IDENTITY(1,1) NOT NULL,
	AuthorName char(50), 
	DateOfBirth date,
	State char(50),
	City char(50),
	Phone bigint 
)

ALTER TABLE AUTHOR ADD CONSTRAINT pk_authorId PRIMARY KEY (AuthorId)

SELECT * FROM AUTHOR

INSERT INTO AUTHOR(AuthorName, DateOfBirth, State, City, Phone) VALUES('Abhishek', '04-01-1994', 'Maharashtra', 'Pune', 8485028926)
INSERT INTO AUTHOR(AuthorName, DateOfBirth, State, City, Phone) VALUES('Omkar', '04-01-1994', 'Maharashtra', 'Thane', 9730612333)




--Publisher table

CREATE TABLE PUBLISHER(
	PublisherId int IDENTITY(1,1) NOT NULL,
	PublisherName char(50),
	DateOfBirth date,
	State char(50),
	City char(50),
	Phone bigint 
)	
ALTER TABLE PUBLISHER ADD CONSTRAINT pk_publisherId PRIMARY KEY (PublisherId)

INSERT INTO PUBLISHER(PublisherName, DateOfBirth, State, City, Phone) VALUES('TechMax', '01-08-1993', 'Maharashtra', 'Thane', 9730612333)
INSERT INTO PUBLISHER(PublisherName, DateOfBirth, State, City, Phone) VALUES('Technical', '09-08-1992', 'Punjab', 'Chandigarh', 8485028926)
INSERT INTO PUBLISHER(PublisherName, DateOfBirth, State, City, Phone) VALUES('Nirali', '07-01-1999', 'Andhra Pradesh', 'Banglore', 7285028926)

SELECT * FROM PUBLISHER 





--Junction Table (BOOK_AUTHOR)

CREATE TABLE BOOK_AUTHOR(
	Bid int NOT NULL,
	Aid int NOT NULL,
)
ALTER TABLE BOOK_AUTHOR ADD CONSTRAINT pk_book_author PRIMARY KEY (Bid, Aid)

ALTER TABLE BOOK_AUTHOR ADD CONSTRAINT fk_BookId FOREIGN KEY(Bid) REFERENCES BOOK(BookId)
ON DELETE CASCADE


ALTER TABLE BOOK_AUTHOR ADD CONSTRAINT fk_AuthorId FOREIGN KEY(Aid) REFERENCES AUTHOR(AuthorId)
ON DELETE CASCADE


INSERT INTO BOOK_AUTHOR(Bid, Aid) VALUES(1, 1)
 
SELECT * FROM BOOK_AUTHOR



--Category Table
CREATE TABLE CATEGORY(
	CategoryId int IDENTITY(1,1) NOT NULL,
	Categoryname char(50),
	Description char(50)
)
ALTER TABLE CATEGORY ADD CONSTRAINT pk_categoryId PRIMARY KEY (CategoryId)

INSERT INTO CATEGORY(Categoryname, Description) VALUES('Technical', 'Technical_Description')
INSERT INTO CATEGORY(Categoryname, Description) VALUES('Management', 'Management_Description')

SELECT * FROM CATEGORY



--Book Table
CREATE TABLE BOOK(
	BookId int IDENTITY(1,1) NOT NULL,
	Title char(50),
	Description char(50),
	Price bigint,
	ISBN bigint,
	PublicationDate date,
	Image char(100)

)
ALTER TABLE BOOK ADD CONSTRAINT pk_bookId PRIMARY KEY (BookId)

ALTER TABLE BOOK ADD B_Cid int 
ALTER TABLE BOOK ADD B_Pid int 

ALTER TABLE BOOK ADD CONSTRAINT fk_B_Cid FOREIGN KEY(B_Cid) REFERENCES CATEGORY(CategoryId)
ON DELETE CASCADE


ALTER TABLE BOOK ADD CONSTRAINT fk_B_Pid FOREIGN KEY(B_Pid) REFERENCES PUBLISHER(PublisherId)
ON DELETE CASCADE


INSERT INTO BOOK(Title, Description, Price, ISBN, PublicationDate, Image, B_Cid, B_Pid) VALUES('Dot Net', 'Dot_Net_Description', 450, 107, '11-21-2016', 'C:\Users\omkarpa\Pictures\Dot_Net.jpeg', 1, 3)

SELECT * FROM BOOK
SELECT * FROM PUBLISHER 
SELECT * FROM CATEGORY 


--Order Table
CREATE TABLE [ORDER](
	OrderId int IDENTITY(1,1) NOT NULL,
	Date date,
	Quantity int,
	UnitPrice bigint,
	ShipingAddress char(50) 
)
ALTER TABLE [ORDER] ADD CONSTRAINT pk_orderId PRIMARY KEY (OrderId)

ALTER TABLE [ORDER] ADD O_Bid int

ALTER TABLE [ORDER] ADD CONSTRAINT fk_O_Bid FOREIGN KEY(O_Bid) REFERENCES BOOK(BookId)
ON DELETE CASCADE



INSERT INTO [ORDER](Date, Quantity, UnitPrice, ShipingAddress, O_Bid) VALUES('05-01-2013', 7, 9000, 'Mumbai', 2)

SELECT * FROM [ORDER]




-- a.) Get All the books written by specific author
SELECT * FROM BOOK WHERE BookId IN(SELECT Bid FROM BOOK_AUTHOR WHERE Aid = 2)


-- b.) Get all the books written by specific author and published by specific publisher belonging to “Technical” book Category


select * from BOOK WHERE bookid 
IN (select BookId from BOOK_AUTHOR where Aid=2) 
AND B_Pid=(select PublisherId from PUBLISHER where PublisherName='TechMax')
AND B_Cid=(select categoryid from category where Categoryname ='Technical')


-- c. Get total books published by each publisher.
SELECT B_Pid, COUNT(BookId) FROM BOOK  WHERE B_Pid IN (SELECT DISTINCT(B_Pid) FROM BOOK) GROUP BY B_Pid 


-- d. Get all the books for which the orders are placed.
SELECT * FROM BOOK B, [ORDER] O WHERE B.BookId = O.O_Bid







														-- Stored Procedures

-- 4. Write the following stored procedure using SQL Server in BookStoreDB database to support following operations:

-- a. Get All the books written by specific author
 
 CREATE PROCEDURE GetBook @AuthorId int
 AS
 BEGIN
		SELECT * FROM BOOK WHERE BookId IN (SELECT Bid FROM BOOK_AUTHOR WHERE Aid=@AuthorId) 		
 END

EXECUTE GetBook 2


-- b. Get all the books written by specific author and published by specific publisher belonging to “Technical” book Category

 CREATE PROCEDURE GetAllBook @AuthorId int, @PublisherName char(50), @CategoryName char(50)
 AS
 BEGIN
		select * from BOOK WHERE bookid 
IN (select BookId from BOOK_AUTHOR where Aid=@AuthorId) 
AND B_Pid=(select PublisherId from PUBLISHER where PublisherName=@PublisherName)
AND B_Cid=(select categoryid from category where Categoryname =@CategoryName)		
 END

 EXECUTE GetAllBook 2,TechMax,Technical


 -- c. Get total books published by each publisher.
 CREATE PROCEDURE GetTotalBooks
 AS
 BEGIN
		SELECT B_Pid, COUNT(BookId) FROM BOOK WHERE B_Pid IN (SELECT DISTINCT(B_Pid) FROM BOOK) GROUP BY B_Pid 		
 END

EXECUTE GetTotalBooks



-- d. Insert a particular book
 CREATE PROCEDURE InsertBook @AuthorId int, @Title char(50), @Description char(50), @Price bigint, @ISBN bigint, @PublicationDate date, @Image char(50), @B_Cid int, @B_Pid int								
 AS
 DECLARE @Bid int
 BEGIN
		
		INSERT INTO BOOK(Title, Description, Price, ISBN, PublicationDate, Image, B_Cid, B_Pid) VALUES(@Title, @Description, @Price, @ISBN, @PublicationDate, @Image, @B_Cid, @B_Pid)
		SELECT @Bid=BookId From BOOK WHERE Title=@Title 
		INSERT INTO BOOK_AUTHOR (Bid,Aid) VALUES(@Bid,@AuthorId)
 END

 EXECUTE InsertBook 2, 'PHP', 'PHP_Description', 150, 111, '11-11-2011', 'C:\Users\omkarpa\Pictures\PHP.jpeg', 1, 2



-- e. Update a particular book by id
 CREATE PROCEDURE UpdateBook @BookId int, @Price bigint
 AS 
 BEGIN
		
		UPDATE BOOK SET Price = @Price WHERE BookId = @BookId
 END

 EXECUTE UpdateBook 2, 2000



-- f. Delete a particular book by id
 CREATE PROCEDURE DeleteBook @BookId int
 AS 
 BEGIN
		
		DELETE FROM BOOK WHERE BookId = @BookId
 END


 EXECUTE DeleteBook 8


CREATE TABLE BOOK_HISTORY(
	BookId int NOT NULL,
	Title char(50),
	Description char(50),
	Price bigint,
	ISBN bigint,
	PublicationDate date,
	Image char(100),
	B_Cid int,
	B_Pid int
)

 SELECT * FROM BOOK
 SELECT * FROM BOOK_HISTORY
 
CREATE TRIGGER uspDELETE
ON BOOK
FOR DELETE
AS
DECLARE @ID INT,
		@BOOKNAME VARCHAR(20),
		@BOOKDESC VARCHAR(20),
		@BOOKPRICE INT,
		@BOOKISBN INT,
		@BOOKPUBDATE DATE,
		@IMAGE VARCHAR(50),
		@B_CID int,
		@B_PID int 

 BEGIN

 SELECT @ID=BookId,
		@BOOKNAME=Title,
		@BOOKDESC=Description,
		@BOOKPRICE=Price,
		@BOOKISBN=ISBN,
		@BOOKPUBDATE=PublicationDate,
		@IMAGE=Image,
		@B_CID=B_Cid,
		@B_PID=B_Pid
		 from DELETED

insert into book_history(BookId,Title,Description,Price,ISBN,PublicationDate)
values(@ID,@BOOKNAME,@BOOKDESC,@BOOKPRICE,@BOOKISBN,@BOOKPUBDATE)

END
