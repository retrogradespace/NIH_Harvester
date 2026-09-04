-- nih_indicators multi-year-funding (MYF) analysis, ported from an
-- earlier Oracle version of this same logic to SQLite.
-- Logic and column semantics are IDENTICAL only the date arithmetic
-- syntax changes (SQLite has no native DATE type, so julianday()/strftime()
-- replace Oracle's CAST(... AS DATE) subtraction and EXTRACT()).
-- FUNDING_CLASSIFICATION has 5 values, not an original draft's 3 the
-- same "Undefined Funding" refinement (Incremental Funding / Budget
-- Exceeds Project / Missing Dates split out) applies here unchanged.
--
-- Computed for EVERY row, not pre-filtered to any institution or award
-- type filter downstream same as any other nih_parsed column.

create view if not exists nih_indicators as
   with durations as (
      select p.*,
             cast(julianday(budget_end) - julianday(budget_start) as integer) as budget_duration_days,
             cast(julianday(project_end_date) - julianday(project_start_date) as integer) as project_duration_days
        from nih_parsed p
   )
   select d.*,
          case
             when project_duration_days = budget_duration_days
                and project_duration_days >= 365 then
                1
             else
                0
          end as is_myf,
          case
             when budget_duration_days is null
                 or project_duration_days is null then
                'Missing Dates'
             when project_duration_days = budget_duration_days
                and project_duration_days >= 365 then
                'Multi-year Funding'
             when project_duration_days = budget_duration_days
                and project_duration_days < 365 then
                'Single Year Funding'
             when budget_duration_days > project_duration_days then
                'Budget Exceeds Project'
             else
                'Incremental Funding'
          end as funding_classification,

       -- Fiscal Year (Oct 1): Jan 1 .. Oct 1 falls in the current calendar
       -- year's FY, Oct 2 onward rolls into next calendar year's.
          case
             when award_notice_date is null then
                null
             when cast(strftime(
                '%m',
                award_notice_date
             ) as integer) < 10
                 or ( cast(strftime(
                   '%m',
                   award_notice_date
                ) as integer) = 10
                and cast(strftime(
                '%d',
                award_notice_date
             ) as integer) = 1 ) then
                cast(strftime(
                   '%Y',
                   award_notice_date
                ) as integer)
             else
                cast(strftime(
                   '%Y',
                   award_notice_date
                ) as integer) + 1
          end as fiscal_year_oct1
     from durations d;