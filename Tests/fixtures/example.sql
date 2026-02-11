-- TTL Configuration Script
-- Production Environment: 360 days retention

ALTER TABLE events 
SET TTL timestamp + INTERVAL 360 DAY;

SELECT 
    name,
    engine,
    metadata_path
FROM system.tables 
WHERE database = 'signoz';
