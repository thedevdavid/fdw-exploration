CREATE MATERIALIZED VIEW mv_local_data AS
SELECT * FROM remote_table;

REFRESH MATERIALIZED VIEW mv_local_data;