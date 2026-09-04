-- nih_parsed_view.sql flattens the raw_json into individual columns via SQLite's
-- json_extract(), the same idea as an earlier Oracle version of this view
-- (JSON_TABLE) but SQLite doesn't have Oracle's CLOB-vs-BI-tool
-- visibility problem this exists for general query convenience (plain
-- SQL, pandas.read_sql, DuckDB, etc. without every consumer re-writing
-- the same json_extract calls).
--
-- Sourced from nih_raw_projects_current (not the base table) so a future
-- manual removal (marked via is_current, not a hard DELETE) is correctly
-- excluded.
--
-- Field shapes verified against real NIH RePORTER records. Not
-- exhaustive; raw_json still has everything, add a column here if
-- something else turns out to be commonly needed.
--
-- Arrays (principal_investigators, program_officers, agency_ic_fundings,
-- spending_categories, covid_response) come back from json_extract() as
-- JSON text already no FORMAT JSON needed like Oracle's JSON_TABLE.

create view if not exists nih_parsed as
   select appl_id,
          project_num,
          core_project_num,
          fiscal_year,
          json_extract(
             raw_json,
             '$.project_title'
          ) as project_title,
          json_extract(
             raw_json,
             '$.activity_code'
          ) as activity_code,
          json_extract(
             raw_json,
             '$.agency_code'
          ) as agency_code,
          json_extract(
             raw_json,
             '$.award_type'
          ) as award_type,
          json_extract(
             raw_json,
             '$.award_amount'
          ) as award_amount,
          json_extract(
             raw_json,
             '$.direct_cost_amt'
          ) as direct_cost_amt,
          json_extract(
             raw_json,
             '$.indirect_cost_amt'
          ) as indirect_cost_amt,
          json_extract(
             raw_json,
             '$.cfda_code'
          ) as cfda_code,
          json_extract(
             raw_json,
             '$.cong_dist'
          ) as cong_dist,
          json_extract(
             raw_json,
             '$.contact_pi_name'
          ) as contact_pi_name,
          json_extract(
             raw_json,
             '$.funding_mechanism'
          ) as funding_mechanism,
          json_extract(
             raw_json,
             '$.mechanism_code_dc'
          ) as mechanism_code_dc,
          json_extract(
             raw_json,
             '$.opportunity_number'
          ) as opportunity_number,
          json_extract(
             raw_json,
             '$.project_detail_url'
          ) as project_detail_url,
          json_extract(
             raw_json,
             '$.project_serial_num'
          ) as project_serial_num,
          json_extract(
             raw_json,
             '$.subproject_id'
          ) as subproject_id,
          json_extract(
             raw_json,
             '$.arra_funded'
          ) as arra_funded,
          json_extract(
             raw_json,
             '$.is_active'
          ) as is_active,
          json_extract(
             raw_json,
             '$.is_new'
          ) as is_new,

    -- dates left as ISO8601 text (SQLite has no native date type);
    -- nih_indicators.sql operates on these directly via julianday()/strftime()
          json_extract(
             raw_json,
             '$.award_notice_date'
          ) as award_notice_date,
          json_extract(
             raw_json,
             '$.budget_start'
          ) as budget_start,
          json_extract(
             raw_json,
             '$.budget_end'
          ) as budget_end,
          json_extract(
             raw_json,
             '$.project_start_date'
          ) as project_start_date,
          json_extract(
             raw_json,
             '$.project_end_date'
          ) as project_end_date,
          json_extract(
             raw_json,
             '$.date_added'
          ) as date_added,

    -- flattened nested objects
          json_extract(
             raw_json,
             '$.agency_ic_admin.code'
          ) as agency_ic_admin_code,
          json_extract(
             raw_json,
             '$.agency_ic_admin.abbreviation'
          ) as agency_ic_admin_abbreviation,
          json_extract(
             raw_json,
             '$.agency_ic_admin.name'
          ) as agency_ic_admin_name,
          json_extract(
             raw_json,
             '$.organization.org_name'
          ) as organization_org_name,
          json_extract(
             raw_json,
             '$.organization.org_city'
          ) as organization_org_city,
          json_extract(
             raw_json,
             '$.organization.org_state'
          ) as organization_org_state,
          json_extract(
             raw_json,
             '$.organization.org_country'
          ) as organization_org_country,
          json_extract(
             raw_json,
             '$.organization.dept_type'
          ) as organization_dept_type,
          json_extract(
             raw_json,
             '$.organization.primary_duns'
          ) as organization_primary_duns,
          json_extract(
             raw_json,
             '$.organization.primary_uei'
          ) as organization_primary_uei,
          json_extract(
             raw_json,
             '$.organization.org_ipf_code'
          ) as organization_org_ipf_code,
          json_extract(
             raw_json,
             '$.organization.org_zipcode'
          ) as organization_org_zipcode,
          json_extract(
             raw_json,
             '$.organization_type.name'
          ) as organization_type_name,
          json_extract(
             raw_json,
             '$.organization_type.code'
          ) as organization_type_code,
          json_extract(
             raw_json,
             '$.geo_lat_lon.lat'
          ) as geo_lat,
          json_extract(
             raw_json,
             '$.geo_lat_lon.lon'
          ) as geo_lon,
          json_extract(
             raw_json,
             '$.project_num_split.activity_code'
          ) as project_num_split_activity_code,
          json_extract(
             raw_json,
             '$.project_num_split.ic_code'
          ) as project_num_split_ic_code,
          json_extract(
             raw_json,
             '$.project_num_split.serial_num'
          ) as project_num_split_serial_num,
          json_extract(
             raw_json,
             '$.project_num_split.support_year'
          ) as project_num_split_support_year,
          json_extract(
             raw_json,
             '$.full_study_section.srg_code'
          ) as full_study_section_code,
          json_extract(
             raw_json,
             '$.full_study_section.name'
          ) as full_study_section_name,

    -- short arrays, kept as JSON text (not exploded into separate rows 
    -- a true one-row-per-PI view would be a second, different-grain view)
          json_extract(
             raw_json,
             '$.principal_investigators'
          ) as principal_investigators_json,
          json_extract(
             raw_json,
             '$.program_officers'
          ) as program_officers_json,
          json_extract(
             raw_json,
             '$.agency_ic_fundings'
          ) as agency_ic_fundings_json,
          json_extract(
             raw_json,
             '$.spending_categories'
          ) as spending_categories_json,
          json_extract(
             raw_json,
             '$.covid_response'
          ) as covid_response_json,

    -- long free text
          json_extract(
             raw_json,
             '$.abstract_text'
          ) as abstract_text,
          json_extract(
             raw_json,
             '$.phr_text'
          ) as phr_text,
          json_extract(
             raw_json,
             '$.terms'
          ) as terms,
          json_extract(
             raw_json,
             '$.pref_terms'
          ) as pref_terms,
          json_extract(
             raw_json,
             '$.spending_categories_desc'
          ) as spending_categories_desc
     from nih_raw_projects_current;