CREATE TABLE [dbo].[AvailableBlockRules](

       [rule_id] [tinyint] IDENTITY (1,1) PRIMARY KEY NOT NULL,

       [provider_id] [tinyint] NOT NULL,

       [start_date_time] [datetime] NOT NULL,

       [end_date_time] [datetime] NOT NULL,

       [rule_type] [tinyint] NOT NULL,

       [days_of_week] [smallint] NULL,

       [availability_type] [tinyint] NOT NULL,

       [rule_text] [varchar](500) NULL

) ON [PRIMARY]

GO