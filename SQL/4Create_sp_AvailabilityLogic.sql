CREATE PROCEDURE [dbo].[sp_AvailabilityLogic] 
	-- Add the parameters for the stored procedure here
	@provider_id tinyint, 
	@start_date_time datetime, 
	@end_date_time datetime, 
	@rule_type tinyint, 
	@days_of_week_int tinyint,
	@availability_type tinyint

AS

-- =============================================
-- Author:		Jeffery Gough
-- Create date: 2021-07-16
-- Description:	SPROC that handles updating the CalendarAvailability table based on calendar rule logic.
--				Accepts rule table parameters
-- =============================================

BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @availability_text varchar(30);


	IF @availability_type = 1
		SET @availability_text = 'Available'
	else
		SET @availability_text = 'Block'

	IF @rule_type = 0
		UPDATE dbo.CalendarAvailability 
		SET [Availability] = @availability_text
		WHERE DateTimeStart >= @start_date_time and DateTimeStart < @end_date_time
		AND Provider_id = @provider_id
		--Add line below to keep rules intact. Newer rules will NOT overwrite older ones
		--Remove line for newer rules to take precendence over older ones
		AND [Availability] IS NULL

	IF @rule_type = 1
		UPDATE dbo.CalendarAvailability 
		SET [Availability] = @availability_text
		WHERE TimeSlotStart >= CAST(@start_date_time as time) and TimeSlotStart < CAST(@end_date_time as time)
		AND DateTimeStart >= @start_date_time and DateTimeStart < @end_date_time
		AND Provider_id = @provider_id
		--Add line below to keep rules intact. Newer rules will NOT overwrite older ones
		--Remove line for newer rules to take precendence over older ones
		AND [Availability] IS NULL

	IF @rule_type = 2

		UPDATE dbo.CalendarAvailability 
		SET [Availability] = @availability_text
		WHERE TimeSlotStart >= CAST(@start_date_time as time) and TimeSlotStart < CAST(@end_date_time as time)
		AND DateTimeStart >= @start_date_time and DateTimeStart < @end_date_time
		AND DATENAME(dw, DateTimeStart) IN (SELECT * FROM Tfn_GetNamedDaysFromInt(@days_of_week_int))
		AND Provider_id = @provider_id
		--Add line below to keep rules intact. Newer rules will NOT overwrite older ones
		--Remove line for newer rules to take precendence over older ones
		AND [Availability] IS NULL

		
END


