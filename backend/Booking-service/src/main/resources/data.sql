UPDATE reservation SET status = 'EN_ATTENTE' WHERE status = 'CREATED';
UPDATE reservation SET status = 'ANNULEE' WHERE status = 'CANCELLED';
UPDATE reservation SET check_in_date = start_date WHERE check_in_date IS NULL AND start_date IS NOT NULL;
UPDATE reservation SET check_out_date = end_date WHERE check_out_date IS NULL AND end_date IS NOT NULL;
