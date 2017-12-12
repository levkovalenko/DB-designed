-- Запрос №1 - вывод работников, чья зарплата больше средней
CREATE INDEX staff_salaries_index ON staff(worker_salary ASC);
-- создание индекса для таблицы staff по столбцу worker_slary для вывода в порядке возрастания.

SELECT
  full_name,
  worker_salary
FROM staff
WHERE worker_salary >
      (SELECT AVG(worker_salary) AS tmp_salary
       FROM staff)
ORDER BY worker_salary ASC;
-- запрос на вывод полного имени и зарплаты работников, чья зарплата превышает среднюю.
-- запрос включает в себя подзапрос для подсчета среденей зарплаты персонала.
-- вывод запроса сортируется по значению заработной платы в порядке возрастания.
-- оптимизация запроса заключается в том, что проводится индексирование столбца,
-- по которому проводится выборка. индексирование проводится с заданным правилом сортировки

-- Проведение анлиза с помощью EXPLAIN показало, что без индексов
-- Scan on staff cost = 18.40 (0.115 ms)
-- Aggregate cost = 17.01 (0.061 ms)
-- Sort cost = 42.94 (0.219 ms)
-- запланированное время на операцию: 1.394 ms
-- затраченное время на операцию: 0.431 ms

-- После введения индексов результаты оказались:
-- Scan on staff cost = 1.23 (0.107 ms)
-- Aggregate cost = 1.20 (0.039 ms)
-- Sort cost = 2.50 (0.168 ms)
-- запланированное время на операцию: 0.343 ms
-- затраченное время на операцию: 0.278 ms
------------------------------------------------------------------------------------------------

--Запрос №2 - ввывод поездок актуальных на сегодняшний день.
CREATE INDEX jorneys_depature_date_index ON jorneys(date_depature ASC);
-- создание индекса для таблицы  jorneys по столбцу 
-- date_depature для сортировки в порядке возрастания

SELECT
  city_depature,
  city_arrive,
  date_depature,
  date_arrive,
  (date_arrive - date_depature) AS jorney_duration
FROM jorneys
WHERE date_depature > now() :: DATE
ORDER BY date_depature, jorney_duration ASC;
-- запрос на вывод информации о поездке, актуальной на сегодняшний день,
-- в порядке возрастания даты и продолжительности поездки.
-- к имеющейся информации о таблице - добавляется столбец jorney_duration
-- продолжительность поездки в днях, далее происходит выборка тех поездок, 
-- дата начала которых позже сегодняшней. После этого производится сортировка
-- сначала по дате отправления, затемп по продолжительности поездки в порядке возрастания.
-- оптимизация заключается в создании индекса по столбцу date_depature
-- индексирование производится с заданным правилом сортировки

-- Проведение анлиза с помощью EXPLAIN показало, что без индексов
-- Scan on jorneys cost = 23.57 (0.130 ms)
-- Sort cost = 34.33 (0.075 ms)
-- запланированное время на операцию: 0.384 ms
-- затраченное время на операцию: 0.180 ms

-- После введения индексов результаты оказались:
-- Scan on jorneys cost = 1.18 (0.091 ms)
-- Sort cost = 1.21 (0.05 ms)
-- запланированное время на операцию: 0.243 ms
-- затраченное время на операцию: 0.144 ms
------------------------------------------------------------------------------------------------
-- Запрос №3 - вывод информации о клиенте по поиску имени
CREATE INDEX clients_full_name_hash_index ON clients USING HASH (full_name);
-- индекс полного имени клиента с использованием ХЭШ'а - это важно

CREATE INDEX clients_age_index ON clients(client_age ASC);
-- индекс сортировки по возрасту клиентов в порядке возрастания

CREATE INDEX clients_full_name_index ON clients(full_name ASC);
-- индекс сортировки по имени клиентов

SELECT
  full_name,
  client_age,
  phone_number,
  pasport_number
FROM clients
WHERE full_name LIKE 'Leo%'
ORDER BY full_name, client_age;
-- запрос на вывод информации оклиентах в порядке лексикографического
-- увеличения полного имени, а затем возраста
-- оптимизация запроса заключается в добавлении трех индексов, 
-- отвечающих за сортировку и быстрый поиск(Hash поиск по базе)
-- индексирование производится по двум столбцам в отдельности 
--с заданным правилом сортировки

-- Проведение анлиза с помощью EXPLAIN показало, что без индексов
-- Scan on clients cost = 17.50 (0.136 ms)
-- Sort cost = 17.53 (0.059 ms)
-- запланированное время на операцию: 0.241 ms
-- затраченное время на операцию: 0.228 ms

-- После введения индексов результаты оказались:
-- Scan on jorneys cost = 1.18 (0.093 ms)
-- Sort cost = 1.21 (0.054 ms)
-- запланированное время на операцию: 0.223 ms
-- затраченное время на операцию: 0.162 ms
-----------------------------------------------------------------------------------------------

-- Запрос №4 - вывод информации о самом старом и молодом членах экипажа
CREATE INDEX staff_age_index ON staff(worker_age ASC);
-- создание индекса для таблицы  staff по столбцу 
-- worker_age для сортировки в порядке возрастания

SELECT
  full_name,
  phone_number,
  pasport_number,
  number_of_worked_years,
  worker_age,
  worker_salary
FROM staff
WHERE worker_age IN (SELECT MAX(worker_age) AS max_age
                     FROM staff)
      OR worker_age IN (SELECT MIN(worker_age) AS min_age
                        FROM staff)
ORDER BY worker_age ASC;
-- запрос на вывод информации о самых старших и младших сотрудниках
-- отсортированных по возрасту в проядке возрастания
-- запрос включает в себя два подзапроса с агрегатными функциями подсчета 
-- максимума и минимума по столбцу worker_age
-- оптимизация заключается в индексировании столбца worker_age  сс
-- заданным правилом сортировки в порядке возрастания.

-- Проведение анлиза с помощью EXPLAIN показало, что без индексов
-- Scan on staff cost = 3.62 (0.115 ms)
-- Aggregate cost = 1.20 (0.029 ms)
-- Sort cost = 3.84 (0.246 ms)
-- запланированное время на операцию: 2.052 ms
-- затраченное время на операцию: 0.591 ms

-- После введения индексов результаты оказались:
-- Scan on staff cost = 3.15 (0.104 ms)
-- Aggregate cost = 0.95 (0.011 ms)
-- Sort cost = 3,25 (0.0.144 ms)
-- запланированное время на операцию: 0.643 ms
-- затраченное время на операцию: 0.395 ms
-----------------------------------------------------------------------------------------------