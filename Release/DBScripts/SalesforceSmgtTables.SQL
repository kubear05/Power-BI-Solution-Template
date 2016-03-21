CREATE SCHEMA [Smgt]

GO

CREATE TABLE [Smgt].[ActualSales](
	[InvoiceId] [varchar](50) NULL,
	[ActualSales] DECIMAL NULL,
	[InvoiceDate] DATE NULL,
	[AccountId] VARCHAR(50) NULL,
	[ProductId] VARCHAR(50) NULL
) ON [PRIMARY]


GO

CREATE TABLE [Smgt].[configuration] (
    [id]                     INT           IDENTITY (1, 1) NOT NULL,
    [configuration_group]    VARCHAR (150) NOT NULL,
    [configuration_subgroup] VARCHAR (150) NOT NULL,
    [name]                   VARCHAR (150) NOT NULL,
    [value]                  VARCHAR (max) NULL,
    CONSTRAINT [pk_configuration] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO

CREATE TABLE [Smgt].[date](
	date_key               INT NOT NULL,
	full_date              DATE NOT NULL,
	day_of_week            TINYINT NOT NULL,
	day_num_in_month       TINYINT NOT NULL,
	day_name               CHAR(9) NOT NULL,
	day_abbrev             CHAR(3) NOT NULL,
	weekday_flag           CHAR(1) NOT NULL,
	week_num_in_year       TINYINT NOT NULL,
	week_begin_date        DATE NOT NULL,
	week_begin_date_key    INT NOT NULL,
	[month]                TINYINT NOT NULL,
	month_name             CHAR(9) NOT NULL,
	month_abbrev           CHAR(3) NOT NULL,
	[quarter]              TINYINT NOT NULL,
	[year]                 SMALLINT NOT NULL,
	yearmo                 INT NOT NULL,
	fiscal_month           TINYINT NOT NULL,
	fiscal_quarter         TINYINT NOT NULL,
	fiscal_year            SMALLINT NOT NULL,
	last_day_in_month_flag CHAR(1) NOT NULL,
	same_day_year_ago_date DATE NOT NULL,
	same_day_year_ago_key  INT NOT NULL,
	day_num_in_year       AS datepart(dayofyear, full_date),
	[quarter_name] AS Concat('Q', [quarter]),
	fiscal_quarter_name AS Concat('Q', fiscal_quarter),
	[FiscalQuarterCompleteName] AS Concat('FY', SUBSTRING(CONVERT(VARCHAR,[fiscal_year]),3,2)  ,' Q', [fiscal_quarter]),
	[FiscalYearCompleteName] AS Concat('FY', SUBSTRING(CONVERT(VARCHAR,[fiscal_year]),3,2)),
	[FiscalMonthCompleteName] AS Concat(month_abbrev, ' ' , SUBSTRING(CONVERT(VARCHAR,[fiscal_year]),3,2)),
    CONSTRAINT PK_Dim_Date PRIMARY KEY CLUSTERED (date_key) 
);

GO

CREATE TABLE [Smgt].[Quotas](
	[Amount] [decimal](18, 0) NULL,
	[Date] [date] NULL,
	[OwnerId] VARCHAR(50) NULL,
	[ProductId] VARCHAR(50) NULL
) ON [PRIMARY]

GO


GO


CREATE TABLE [Smgt].[Targets](
	[ProductId] VARCHAR(50) NULL,
	[BusinessUnitId] VARCHAR(50) NULL,
	[TerritoryId] VARCHAR(50) NULL,
	[Target] DECIMAL NULL,
	[Date] DATE NULL
) ON [PRIMARY]



GO

CREATE TABLE [Smgt].[userMapping] (
    [OwnerId] VARCHAR (50) NULL,
	[DomainUser] VARCHAR(50) NULL
);


GO

