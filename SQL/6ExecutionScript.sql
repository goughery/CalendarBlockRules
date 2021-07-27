-- ===========================================================================================
-- Author:		 Jeffery Gough
-- Create date:  2021-07-16
-- Description:	 Execution script used to populate the Calendar Availability Table. 
-- Instructions: Create artifacts in order of number in the title. Then, use this script to execute
--				 The sp_CreateCalendar stored procedure.

-- Files:
-- 1Create_AvailableBlockRules.sql
-- 2Insert_AvailableBlockRules.sql
-- 2Create_fn_IntToBinary.sql
-- 3CreateTFn_GetNamedDaysFromBinary.sql
-- 4Create_sp_AvailabilityLogic.sql
-- 5Create_sp_CreateCalendar.sql
-- 6ExecutionScript.sql

-- Objects Created:
-- dbo.AvailableBlockRules table
-- dbo.CalendarAvailability (created after runtime)
-- dbo.sp_AvailabilityLogic
-- dbo.Tfn_GetNamedDaysFromBinary
-- dbo.fn_IntToBinary
-- ===========================================================================================

--Goal: Expand the rules table into dates and times with the corresponding availability.
--		Creates a table that includes all possible date and time slots, then
--		updates this table according to the rule definitions for each provider.
--Notes:The rule_text and rule definition for rule_id 8 mismatch. I kept the row as-is, meaning this calendar 
--		sets a Block rule from 7/1-7/31 from 8-1pm on Mondays and Saturdays
--		Created on Azure SQL Database.
-- ===========================================================================================

if 
OBJECT_ID('dbo.AvailableBlockRules') IS NOT NULL AND 
OBJECT_ID('dbo.sp_AvailabilityLogic') IS NOT NULL AND
OBJECT_ID('dbo.sp_CreateCalendar') IS NOT NULL AND
OBJECT_ID('dbo.Tfn_GetNamedDaysFromInt') IS NOT NULL AND
OBJECT_ID('dbo.fn_IntToBinary') IS NOT NULL
	exec [dbo].[sp_CreateCalendar]
ELSE
	PRINT '
	(Cannot create calendar table: Not all objects created)'

-- =======================================UNIT TESTS====================================================

DECLARE @TestVar int;

SELECT @TestVar = COUNT(*) FROM [dbo].[CalendarAvailability]
WHERE [Availability] = 'Block' 
AND provider_id = 1



IF (@TestVar) = 52 
	PRINT 'Aggregate Block Test: PASS'
ELSE
	PRINT 'Aggregate Block Test: FAIL'

SELECT @TestVar = COUNT(*) FROM [dbo].[CalendarAvailability]
WHERE [Availability] = 'Available' 
AND provider_id = 1

IF (@TestVar) = 103 
	PRINT 'Aggregate Available Test: PASS'
ELSE
	PRINT 'Aggregate Available Test: FAIL'


----Rule 1 Test----
SELECT @TestVar = COUNT(*) FROM [dbo].[CalendarAvailability]
WHERE [Availability] = 'Block' 
AND provider_id = 1
AND DateTimeStart >='2021-07-31 08:00:00.000' AND DateTimeStart < '2021-07-31 11:00:00.00'


IF (@TestVar) = 3
	PRINT 'Rule_id 1: PASS'
ELSE
	PRINT 'Rule_id 1: FAIL'

----Rule 2 Test----
SELECT @TestVar = COUNT(*) FROM [dbo].[CalendarAvailability]
WHERE [Availability] = 'Available' 
AND provider_id = 1
AND DateTimeStart >='2021-07-31 08:00:00.000' AND DateTimeStart < '2021-07-31 13:00:00.000'

IF (@TestVar) = 2 
	PRINT 'Rule_id 2: PASS'
ELSE
	PRINT 'Rule_id 2: FAIL'

----Rule 8 Test----
SELECT @TestVar = COUNT(*) FROM [dbo].[CalendarAvailability]
WHERE [Availability] = 'Block' 
AND provider_id = 1
AND DateTimeStart >='2021-07-01 08:00:00.000' AND DateTimeStart < '2021-07-31 13:00:00.000'
AND DATENAME(weekday, DateTimeStart) in ('Monday', 'Saturday')


IF (@TestVar) = 39 
	PRINT 'Rule_id 8: PASS'
ELSE
	PRINT 'Rule_id 8: FAIL'


--SELECT * FROM [dbo].[CalendarAvailability]

