CREATE FUNCTION [dbo].[fn_IntToBinary] (@i INT) RETURNS char(7) AS

-- =============================================
-- Author:		Jeffery Gough
-- Create date: 7-17-2021
-- Description:	Convert an integer into a binary value

-- =============================================

BEGIN

	RETURN       
		CASE WHEN CONVERT(char(7), @i &    64 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(char(7), @i &    32 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(char(7), @i &    16 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(char(7), @i &     8 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(char(7), @i &     4 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(char(7), @i &     2 ) > 0 THEN '1' ELSE '0'   END +
        CASE WHEN CONVERT(char(7), @i &     1 ) > 0 THEN '1' ELSE '0'   END
	END;

