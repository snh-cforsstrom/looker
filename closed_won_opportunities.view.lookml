- view: closed_won_opportunities
  sql_table_name: dbo.ClosedWonOpportunities
  fields:

  - dimension: account_name__account_name
    type: string
    sql: ${TABLE}."Account Name  Account Name"

  - dimension: amount
    type: number
    sql: ${TABLE}.Amount

  - dimension: billing_city
    type: string
    sql: ${TABLE}."Billing City"

  - dimension: billing_state
    type: string
    sql: ${TABLE}."Billing State"

  - dimension: client_code
    type: string
    sql: ${TABLE}."Client Code"

  - dimension_group: close
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}."Close Date"

  - dimension: customer_status
    type: string
    sql: ${TABLE}."Customer Status"

  - dimension: opportunity_name
    type: string
    sql: ${TABLE}."Opportunity Name"

  - dimension: opportunity_owner__full_name
    type: string
    sql: ${TABLE}."Opportunity Owner  Full Name"

  - dimension: opportunity_record_type
    type: string
    sql: ${TABLE}."Opportunity Record Type"

  - dimension: products
    type: string
    sql: ${TABLE}.Products

  - measure: count
    type: count
    drill_fields: [opportunity_name, account_name__account_name, opportunity_owner__full_name]