CREATE procedure [dbo].[sp_CreateCalendar]
as


-- =============================================
-- Author:		Jeffery Gough
-- Create date: 2021-07-16
-- Description:	Main script for populating the CalendarAvailability table.
-- =============================================



----------------------------------------CONSTRUCT CalendarAvailability TABLE----------------------------------------
--Similar to a Date/Time Dimension

--Drop table used later
IF OBJECT_ID('dbo.CalendarAvailability') is not null
DROP TABLE dbo.CalendarAvailability


  --Make sure the day of the week starts on Monday
  SET DATEFIRST 7,
  DATEFORMAT ymd,
  LANGUAGE US_ENGLISH

  --Retrieve first and last days of the month for provided calendar rules
  DECLARE @StartDate datetime;
  DECLARE @EndDate datetime;
  SELECT @StartDate =  DATEADD(DAY, 1, EOMONTH(MIN(start_date_time), -1)) FROM [dbo].[AvailableBlockRules]
  SELECT @EndDate =  DATEADD(hh, 23, CAST(EOMONTH(end_date_time) AS DATETIME)) FROM [dbo].[AvailableBlockRules];


  --Create number sequence table. One row for every hour in the date range.
WITH 

seq(n) AS
  (
	 SELECT 0 UNION ALL
	 SELECT n + 1 FROM seq
	 WHERE n < DATEDIFF(hh, @StartDate, @EndDate)
  ),

  --Add an hour for every row in the table above to construct the dates.
hours([DateTimeStart], [DateStart], TimeSlotStart, TimeSlotEnd) AS
  (
	SELECT 
  --easily add new columns here. 
	DateAdd(hh, n, @StartDate) AS [DateTimeStart],
	CAST(DATEADD(hh, n, @StartDate) AS Date) AS [DateStart], 
	CAST(DATEADD(hh, n, @StartDate) AS Time) AS TimeSlotStart,
	CAST(DATEADD(hh, n + 1, @StartDate) AS time) AS TimeSlotEnd FROM Seq
  ),

  --Account for any and all providers in the rules table and create date sequence for each of them. 
providers(provider_id,[DateTimeStart], [DateStart], TimeSlotStart, TimeSlotEnd) AS
  (
    SELECT p.provider_id, [hours].* 
	FROM [hours]
	CROSS APPLY (
		SELECT DISTINCT provider_id
		FROM dbo.[AvailableBlockRules]
	) p
  )



 --Create physical table and insert values from CTEs. Reserve null for calendar availability. 

SELECT *, CAST(NULL as varchar(25)) AS [Availability]
INTO dbo.CalendarAvailability 
from providers
option (maxrecursion 0)

----------------------------------------UPDATE CalendarAvailability TABLE----------------------------------------
--Update Availability table based on rules. 
--To maximize utility and avoid duplication of datetimes, and to account for overlapping of rules per a single time slot,
--availability is listed to favor existing rules. This logic can be changed in sp_AvailabilityLogic to allow newer rules
--higher priority. 


--Update the CalendarAvailability table

DECLARE @RuleCount tinyint;
DECLARE @CurrentRule tinyint;
DECLARE @provider_id tinyint;
DECLARE @start_date_time datetime;
DECLARE @end_date_time datetime;
DECLARE @rule_type tinyint;
DECLARE @days_of_week tinyint;
DECLARE @availability_type tinyint;

SET @CurrentRule = 1;
SELECT @RuleCount = max(rule_id) from [dbo].[AvailableBlockRules]

--iterate through the rules, starting with 1
--execute update SPROC with values from the rule table. 
WHILE @CurrentRule <= @RuleCount
	BEGIN
	select 
	@provider_id = provider_id, 
	@start_date_time = start_date_time, 
	@end_date_time = end_date_time, 
	@rule_type = rule_type, 
	@days_of_week = days_of_week, 
	@availability_type = availability_type
	from [dbo].[AvailableBlockRules] where rule_id = @CurrentRule;
	
	exec [dbo].[sp_AvailabilityLogic] @provider_id, @start_date_time, @end_date_time, @rule_type, @days_of_week, @availability_type 

	SET @CurrentRule = @CurrentRule + 1
END

