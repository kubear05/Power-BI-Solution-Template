CREATE VIEW [Smgt].[DateView]
AS
  SELECT [date_key],
         [full_date] AS [Date],
         [day_of_week] AS [Day of the Week],
         [day_num_in_month] AS [Day Number of the Month],
         [day_name] AS [Day Name],
         [day_abbrev] AS [Day Abbreviated],
         [weekday_flag]  AS [Weekday Flag],
         [month],
         [month_name] AS [Month Name],
         [month_abbrev],
         [quarter],
         [year],
         [same_day_year_ago_date],
         [week_begin_date] AS [Week Begin Date]
  FROM   [Smgt].[date]