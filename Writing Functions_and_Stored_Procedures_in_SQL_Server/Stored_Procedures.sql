-- Stored Procedures!!
-- Learn how to create, update, and execute stored procedures. Investigate the differences between stored procedures and user defined functions, including appropriate scenarios for each.

--     CREATE PROCEDURE with OUTPUT
-- Create a Stored Procedure named cuspSumRideHrsSingleDay in the dbo schema that accepts a date and returns the total ride hours for the date passed.


-- Create the stored procedure
CREATE PROCEDURE dbo.cuspSumRideHrsSingleDay
    -- Declare the input parameter
	@DateParm date,
    -- Declare the output parameter
	@RideHrsOut numeric OUTPUT
AS
-- Don't send the row count 
SET NOCOUNT ON
BEGIN
-- Assign the query result to @RideHrsOut
SELECT
	@RideHrsOut = SUM(DATEDIFF(second, StartDate, EndDate))/3600
FROM CapitalBikeShare
-- Cast StartDate as date and compare with @DateParm
WHERE CAST(StartDate AS date) = @DateParm
RETURN
END


-- Use SP to INSERT
-- Create a stored procedure named cusp_RideSummaryCreate in the dbo schema that will insert a record into the RideSummary table.


-- Create the stored procedure
CREATE PROCEDURE dbo.cusp_RideSummaryCreate 
    (@DateParm date, @RideHrsParm numeric)
AS
BEGIN
SET NOCOUNT ON
-- Insert into the Date and RideHours columns
INSERT INTO dbo.RideSummary(Date, RideHours)
-- Use values of @DateParm and @RideHrsParm
VALUES(@DateParm, @RideHrsParm) 

-- Select the record that was just inserted
SELECT 
    -- Select Date column
	Date,
    -- Select RideHours column
    RideHours
FROM dbo.RideSummary
-- Check whether Date equals @DateParm
WHERE Date = @DateParm
END;



-- Use SP to UPDATE
-- Create a stored procedure named cuspRideSummaryUpdate in the dbo schema that will update an existing record in the RideSummary table.


-- Create the stored procedure
CREATE PROCEDURE dbo.cuspRideSummaryUpdate
	-- Specify @Date input parameter
	(@Date date,
     -- Specify @RideHrs input parameter
     @RideHrs numeric(18,0))
AS
BEGIN
SET NOCOUNT ON
-- Update RideSummary
UPDATE RideSummary
-- Set
SET
	Date = @Date,
    RideHours = @RideHrs
-- Include records where Date equals @Date
WHERE Date = @Date
END;



-- Use SP to DELETE
-- Create a stored procedure named cuspRideSummaryDelete in the dbo schema that will delete an existing record in the RideSummary table and RETURN the number of rows affected via output parameter.


-- Create the stored procedure
CREATE PROCEDURE dbo.cuspRideSummaryDelete
	-- Specify @DateParm input parameter
	(@DateParm date,
     -- Specify @RowCountOut output parameter
     @RowCountOut int OUTPUT)
AS
BEGIN
-- Delete record(s) where Date equals @DateParm
DELETE FROM dbo.RideSummary
WHERE Date = @DateParm
-- Set @RowCountOut to @@ROWCOUNT
SET @RowCountOut = @@ROWCOUNT
END;



-- EXECUTE with OUTPUT parameter
-- Execute the dbo.cuspSumRideHrsSingleDay stored procedure and capture the output parameter.

-- Create @RideHrs
DECLARE @RideHrs AS numeric(18,0)
-- Execute the stored procedure
EXEC dbo.cuspSumRideHrsSingleDay
    -- Pass the input parameter
	@DateParm = '3/1/2018',
    -- Store the output in @RideHrs
	@RideHrsOut = @RideHrs OUTPUT
-- Select @RideHrs
SELECT @RideHrs AS RideHours


-- EXECUTE with return value
-- Execute dbo.cuspRideSummaryUpdate to change the RideHours to 300 for '3/1/2018'. Store the return code from the stored procedure.


-- Create @ReturnStatus
DECLARE @ReturnStatus AS int
-- Execute the SP, storing the result in @ReturnStatus
EXEC @ReturnStatus=dbo.cuspRideSummaryUpdate
    -- Specify @DateParm
	@DateParm = '3/1/2018',
    -- Specify @RideHrs
	@RideHrs = 300

-- Select the columns of interest
SELECT
	@ReturnStatus AS ReturnStatus,
    Date,
    RideHours
FROM dbo.RideSummary
WHERE Date = '3/1/2018';



-- EXECUTE with OUTPUT & return value
-- Store and display both the output parameter and return code when executing dbo.cuspRideSummaryDelete SP.

-- Create @ReturnStatus
DECLARE @ReturnStatus AS int
-- Create @RowCount
DECLARE @RowCount AS int

-- Execute the SP, storing the result in @ReturnStatus
EXEC @ReturnStatus = dbo.cuspRideSummaryDelete
    -- Specify @DateParm
	@DateParm = '3/1/2018',
    -- Specify RowCountOut
	@RowCountOut = @RowCount OUTPUT

-- Select the columns of interest
SELECT
	@ReturnStatus AS ReturnStatus,
    @RowCount AS 'RowCount';



--     Your very own TRY..CATCH
-- Alter dbo.cuspRideSummaryDelete to include an intentional error so we can see how the TRY CATCH block works.

-- Alter the stored procedure
CREATE OR ALTER PROCEDURE dbo.cuspRideSummaryDelete
	-- (Incorrectly) specify @DateParm
	@DateParm nvarchar(30),
    -- Specify @Error
	@Error nvarchar(max) = NULL OUTPUT
AS
SET NOCOUNT ON
BEGIN
  -- Start of the TRY block
  BEGIN TRY
  	  -- Delete
      DELETE FROM RideSummary
      WHERE Date = @DateParm
  -- End of the TRY block
  END TRY
  -- Start of the CATCH block
  BEGIN CATCH 
		SET @Error = 
		'Error_Number: '+ CAST(ERROR_NUMBER() AS VARCHAR) +
		'Error_Severity: '+ CAST(ERROR_SEVERITY() AS VARCHAR) +
		'Error_State: ' + CAST(ERROR_STATE() AS VARCHAR) + 
		'Error_Message: ' + ERROR_MESSAGE() + 
		'Error_Line: ' + CAST(ERROR_LINE() AS VARCHAR)
  -- End of the CATCH block
  END CATCH
END;



-- CATCH an error
-- Execute dbo.cuspRideSummaryDelete and pass an invalid @DateParm value of '1/32/2018' to see how the error is handled. The invalid date will be accepted by the nvarchar data type of @DateParm, but the error will occur when SQL attempts to convert it to a valid date when executing the stored procedure.


-- Create @ReturnCode
DECLARE @ReturnCode AS int
-- Create @ErrorOut
DECLARE @ErrorOut AS nvarchar(max)
-- Execute the SP, storing the result in @ReturnCode
EXECUTE @ReturnCode = dbo.cuspRideSummaryDelete
    -- Specify @DateParm
	@DateParm = '1/32/2018',
    -- Assign @ErrorOut to @Error
	@Error = @ErrorOut OUTPUT
-- Select @ReturnCode and @ErrorOut
SELECT
	@ReturnCode AS ReturnCode,
    @ErrorOut AS ErrorMessage;



    