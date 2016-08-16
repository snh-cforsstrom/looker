- connection: snh-test

- include: "*.view.lookml"       # include all the views
- include: "*.dashboard.lookml"  # include all the dashboards

- explore: pf_nar
- explore: pf_nar_with_sf
- explore: nar_sf_raw