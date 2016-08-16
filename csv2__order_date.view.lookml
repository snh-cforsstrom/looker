- view: csv2__order_date
  sql_table_name: dbo.[CSV2 - Order Date]
  fields:

  - dimension: account
    type: string
    sql: ${TABLE}.Account

  - dimension: addon_subtotal
    type: number
    sql: ${TABLE}."Addon subtotal"

  - dimension: adjustment_subtotal
    type: number
    sql: ${TABLE}."Adjustment subtotal"

  - dimension: billed_statecourt_fees
    type: number
    sql: ${TABLE}."Billed state/court fees"

  - dimension: graced_statecourt_fees
    type: number
    sql: ${TABLE}."Graced state/court fees"

  - dimension: included
    type: string
    sql: ${TABLE}."Included?"

  - dimension: order_number
    type: number
    sql: ${TABLE}."Order number"

  - dimension: request_type
    type: string
    sql: ${TABLE}."Request Type"

  - dimension: suborder_number
    type: number
    sql: ${TABLE}."Suborder number"

  - dimension: tax
    type: number
    sql: ${TABLE}.Tax

  - dimension_group: time_component_completed
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}."Time Component Completed"

  - dimension_group: time_entered
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}."Time Entered"

  - dimension_group: time_first_completed
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}."Time first completed"

  - dimension: years_searched
    type: number
    sql: ${TABLE}."Years Searched"

  - dimension: years_searched_surcharge
    type: number
    sql: ${TABLE}."Years Searched Surcharge"

  - measure: count
    type: count
    drill_fields: []

