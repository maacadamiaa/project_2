1. Нужно вывести машину, которая стояла дольше всех без движений.
    
-- Создание таблицы
CREATE TABLE Car_Location_Data (
    car_id INTEGER,
    latitude NUMERIC,
    longitude NUMERIC,
    datetime TIMESTAMP
);

-- Вставка данных в таблицу
INSERT INTO Car_Location_Data (car_id, latitude, longitude, datetime) VALUES
(1, 55.7558, 37.6173, '2023-01-01 12:00:00'),
(1, 55.7558, 37.6173, '2023-01-01 12:01:00'),
(1, 55.7558, 37.6175, '2023-01-01 12:03:00'),
(2, 54.7368, 55.7617, '2023-01-01 12:00:00'),
(2, 54.7368, 55.7617, '2023-01-01 12:02:00'),
(2, 54.7380, 55.7619, '2023-01-01 12:05:00'),
(3, 54.7381, 55.7612, '2023-01-01 12:00:00'),
(3, 54.7381, 55.7612, '2023-01-01 12:17:00'),
(3, 54.7381, 55.7612, '2023-01-01 12:18:00');

-- Проверка вставленных данных
--создаю временную таблицу и новые столбцы со следующим значением времени и геолокации
WITH new_table AS (
   SELECT Car_id,
          Latitude,
          Longitude,
          datetime,
          LEAD(datetime) OVER (PARTITION BY Car_id ORDER BY datetime) AS next_datetime,
          LEAD(Latitude) OVER (PARTITION BY Car_id ORDER BY datetime) AS next_latitude,
          LEAD(Longitude) OVER (PARTITION BY Car_id ORDER BY datetime) AS next_longitude
   FROM Car_Location_Data
),

--создаю дополнительную временную таблицу, в ней ищу разницу между следующим значением времени и текущим, а также осталвю только те строки, в которых геолокация со следующим значением геолокации совпадает
diff_table AS (
   SELECT Car_id,
          latitude,
          longitude,
          datetime,
          next_datetime - datetime as diff
   FROM new_table     
   WHERE Latitude = next_latitude AND Longitude = next_longitude
)

--вывожу идентификаторы машин и общее время простоев, сортирую по убыванию, ограничиваю таблицу первым значением, т.е. максимальным
SELECT Car_id,
       SUM(diff) OVER (PARTITION BY car_id) as outage
FROM diff_table
ORDER BY outage DESC
LIMIT 1;
