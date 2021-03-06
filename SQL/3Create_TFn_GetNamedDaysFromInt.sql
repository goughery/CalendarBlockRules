-- =============================================
-- Author:		Jeffery Gough
-- Create date: 7-17-2021
-- Description:	Convert an integer representation of weekdays into a list of day names

-- =============================================
CREATE FUNCTION [dbo].[Tfn_GetNamedDaysFromInt]
(	
	-- Add the parameters for the function here
	@days_of_week_int int
)
RETURNS @d Table (days varchar(25))
AS
BEGIN
	DECLARE @days_of_week_binary char(7);

	set @days_of_week_binary =  dbo.fn_IntToBinary(@days_of_week_int)

	IF CHARINDEX('1', @days_of_week_binary, 1) = 1
		INSERT INTO @d VALUES ('Monday')
	IF CHARINDEX('1', @days_of_week_binary, 2) = 2
		INSERT INTO @d VALUES ('Tuesday')
	IF CHARINDEX('1', @days_of_week_binary, 3) = 3
		INSERT INTO @d VALUES ('Wednesday')
	IF CHARINDEX('1', @days_of_week_binary, 4) = 4
		INSERT INTO @d VALUES ('Thursday')
	IF CHARINDEX('1', @days_of_week_binary, 5) = 5
		INSERT INTO @d VALUES ('Friday')
	IF CHARINDEX('1', @days_of_week_binary, 6) = 6
		INSERT INTO @d VALUES ('Saturday')
	IF CHARINDEX('1', @days_of_week_binary, 7) = 7
		INSERT INTO @d VALUES ('Sunday')
	RETURN
END
