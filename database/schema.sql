/****** Object:  Table [dbo].[Detainees] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Detainees](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[JailRosterId] [int] NOT NULL,
	[Age] [int] NOT NULL,
	[DateBooked] [datetime] NOT NULL,
	[HousingFacility] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[Name] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_dbo.Detainees] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Table [dbo].[OffenseLevels] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[OffenseLevels](
	[OffenseLevel] [varchar](40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OffenseSeriousness] [int] NULL
) ON [PRIMARY]
GO

/****** Object:  Table [dbo].[Offenses] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Offenses](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[DetaineeId] [int] NOT NULL,
	[OffenseName] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CodeSection] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[OffenseLevel] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[CauseNumber] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BondType] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[BondAmount] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
	[ChargeReleased] [nvarchar](max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
 CONSTRAINT [PK_dbo.Offenses] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/****** Object:  Index [IX_DetaineeId] ******/
CREATE NONCLUSTERED INDEX [IX_DetaineeId] ON [dbo].[Offenses]
(
	[DetaineeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

/****** Object:  View [dbo].[DetaineesAndMostSeriousOffense] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE view DetaineesAndMostSeriousOffense as
	select * from Detainees
GO

/****** Object:  View [dbo].[DetaineesAndOffenses] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[DetaineesAndOffenses]
AS
SELECT        dbo.Detainees.Id, dbo.Detainees.JailRosterId, dbo.Detainees.Age, dbo.Detainees.DateBooked, dbo.Detainees.HousingFacility, dbo.Detainees.Name, 
                         dbo.Offenses.Id AS Expr1, dbo.Offenses.DetaineeId, dbo.Offenses.OffenseName, dbo.Offenses.CodeSection, dbo.Offenses.OffenseLevel, 
                         dbo.Offenses.CauseNumber, dbo.Offenses.BondType, dbo.Offenses.BondAmount, dbo.Offenses.ChargeReleased
FROM            dbo.Detainees INNER JOIN
                         dbo.Offenses ON dbo.Detainees.Id = dbo.Offenses.DetaineeId
GO

/****** Object:  View [dbo].[DetaineesByHousingFacility] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create view DetaineesByHousingFacility
	as
	select HousingFacility, count(*) Count from Detainees group by HousingFacility
GO

/****** Object:  View [dbo].[JailPopulationBreakdownByType] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

create view JailPopulationBreakdownByType as
with Categories
	as ( select 
	case ChargeReleased
		when 'still active' then OffenseLevel
		else 'post trial'
			
	end category,
	*
	from MostSeriousOffense  )
	select category, count(*) count from Categories group by category
GO

/****** Object:  View [dbo].[JailPopulationBreakdownByType2] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[JailPopulationBreakdownByType2] as
with Categories
	as ( select 
	case ChargeReleased
		when 'still active' then OffenseLevel 
		else 'post trial'
	end majorcategory,

	case ChargeReleased
		when 'still active' then OffenseLevel + '-' + OffenseName
		else 'post trial'
	end category,
	*
	from MostSeriousOffense  )
	select majorcategory, category from Categories
GO

/****** Object:  View [dbo].[MostSeriousOffense] ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[MostSeriousOffense]
	as
	with MaxSeriousness as 
		( 
		select 
				DetaineeId, 
				max(l.OffenseSeriousness) MaxOffenseSeriousness 
			from Offenses 
				o left outer join OffenseLevels l 
			on 
				o.OffenseLevel = l.OffenseLevel 
		group by DetaineeId 
		),
	SeriousOffenses as ( select 
		ms.DetaineeId, 
		( select top 1 Id from offenses o inner join OffenseLevels l on o.OffenseLevel = l.OffenseLevel  where o.DetaineeId = ms.DetaineeId and l.OffenseSeriousness = ms.MaxOffenseSeriousness ) OffenseId
		from MaxSeriousness ms )
	select 
		d.Id DetaineeId, 
		d.Age Age,
		d.Name Name,
		o.Id OffenseId,
		o.OffenseLevel OffenseLevel,
		o.OffenseName OffenseName,
		o.BondAmount BondAmount,
		o.ChargeReleased ChargeReleased
		from SeriousOffenses so inner join Detainees d on d.Id = so.DetaineeId
	inner join Offenses o on o.id = so.OffenseId
			
GO

ALTER TABLE [dbo].[Offenses]  WITH CHECK ADD  CONSTRAINT [FK_dbo.Offenses_dbo.Detainees_DetaineeId] FOREIGN KEY([DetaineeId])
REFERENCES [dbo].[Detainees] ([Id])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[Offenses] CHECK CONSTRAINT [FK_dbo.Offenses_dbo.Detainees_DetaineeId]
GO
