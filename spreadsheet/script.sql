-- Medicare Prescriptions Data
-- In this exercise, you will be working with a database created from the 2017 Medicare Part D Prescriber Public Use File, available at https://data.cms.gov/provider-summary-by-type-of-service/medicare-part-d-prescribers/medicare-part-d-prescribers-by-provider-and-drug.

-- 1. a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

-- SELECT npi, SUM(total_claim_count) AS total_claims
-- FROM prescription
-- GROUP BY npi
-- ORDER BY total_claims DESC
-- LIMIT 10;

--     b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name,  specialty_description, and the total number of claims.

-- SELECT prescription.npi, SUM(total_claim_count) AS total_claims, nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
-- FROM prescription
-- LEFT JOIN prescriber
-- ON prescription.npi = prescriber.npi
-- GROUP BY prescription.npi, nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
-- ORDER BY total_claims DESC
-- LIMIT 10;

-- 2. a. Which specialty had the most total number of claims (totaled over all drugs)?

-- SELECT specialty_description, SUM(total_claim_count) AS total_claims
-- FROM prescriber
-- LEFT JOIN prescription
-- ON prescription.npi = prescriber.npi
-- WHERE total_claim_count IS NOT NULL
-- GROUP BY specialty_description
-- ORDER BY total_claims DESC
-- LIMIT 10;


--     b. Which specialty had the most total number of claims for opioids?

-- SELECT specialty_description, SUM(total_claim_count) AS total_claims
-- FROM prescriber AS p1
-- LEFT JOIN prescription AS p2
-- ON p2.npi = p1.npi
-- LEFT JOIN drug AS d
-- ON p2.drug_name = d.drug_name
-- WHERE total_claim_count IS NOT NULL
-- AND opioid_drug_flag = 'Y'
-- OR long_acting_opioid_drug_flag = 'Y'
-- GROUP BY specialty_description
-- ORDER BY total_claims DESC
-- LIMIT 10;

--     c. **Challenge Question:** Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?
--     d. **Difficult Bonus:** *Do not attempt until you have solved all other problems!* For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

-- 3. a. Which drug (generic_name) had the highest total drug cost?

-- SELECT d.generic_name, p.total_drug_cost
-- FROM prescription AS p
-- LEFT JOIN drug AS d
-- ON p.drug_name = d.drug_name
-- GROUP BY d.generic_name, p.total_drug_cost
-- ORDER BY p.total_drug_cost DESC
-- LIMIT 10;


--     b. Which drug (generic_name) has the hightest total cost per day? **Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.

-- SELECT d.generic_name, ROUND(p.total_drug_cost/NULLIF(p.total_day_supply, 0), 2) AS daily_cost
-- FROM drug AS d
-- LEFT JOIN prescription AS p
-- ON p.drug_name = d.drug_name
-- WHERE ROUND(p.total_drug_cost/NULLIF(p.total_day_supply, 0))>0
-- GROUP BY d.generic_name, p.total_drug_cost, daily_cost, p.total_day_supply
-- ORDER BY daily_cost DESC;
-- *borrowed Christian's NULLIF, try again with IS NOT NULL later*


-- 4. a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs.

-- SELECT d.drug_name, d.opioid_drug_flag, d.antibiotic_drug_flag,
-- CASE
-- WHEN d.opioid_drug_flag = 'Y' THEN 'opioid'
-- WHEN d.antibiotic_drug_flag = 'Y' THEN 'antibiotic'
-- ELSE 'neither'
-- END AS drug_type
-- FROM drug AS d;

--     b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.

-- SELECT SUM(total_drug_cost) AS money, s.drug_type
-- FROM
-- (SELECT drug.drug_name,
-- CASE
-- WHEN drug.opioid_drug_flag = 'Y' THEN 'opioid'
-- WHEN drug.antibiotic_drug_flag = 'Y' THEN 'antibiotic'
-- ELSE 'neither'
-- END AS drug_type
-- FROM drug) AS s
-- LEFT JOIN prescription AS p 
-- ON s.drug_name = p.drug_name
-- WHERE drug_type IS NOT NULL
-- GROUP BY drug_type
-- ORDER BY money;

-- 5. a. How many CBSAs are in Tennessee? **Warning:** The cbsa table contains information for all states, not just Tennessee.

-- SELECT DISTINCT(cbsa)
-- FROM cbsa
-- WHERE cbsaname LIKE '%TN%';

--DISTINCT? ^^^

--     b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

-- SELECT c.cbsaname, SUM(p.population) AS total_pop
-- FROM cbsa AS c
-- LEFT JOIN population AS p
-- ON p.fipscounty = c.fipscounty
-- GROUP BY c.cbsaname
-- HAVING c.cbsaname LIKE '%TN%'
-- ORDER BY total_pop DESC;

--ORDER BY total_pop ASC;
-- ^ for small population


--     c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

-- SELECT f.county, p.population
-- FROM fips_county AS f
-- LEFT JOIN cbsa AS c
-- ON c.fipscounty = f.fipscounty
-- LEFT JOIN population AS p
-- ON p.fipscounty = c.fipscounty
-- WHERE county NOT IN (c.cbsa)
-- AND p.population IS NOT NULL
-- AND c.cbsaname LIKE '%TN%'
-- GROUP by f.county, p.population
-- ORDER BY p.population DESC;

-- ^^^ different output from the others, not sure if this is right


-- 6. 
--     a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count > 3000;


--     b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

SELECT p.drug_name, total_claim_count, d.opioid_drug_flag
FROM prescription AS p
LEFT JOIN drug AS d
ON p.drug_name = d.drug_name
WHERE total_claim_count > 3000;

--     c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

SELECT p.drug_name, total_claim_count, d.opioid_drug_flag, p2.nppes_provider_last_org_name, p2.nppes_provider_first_name
FROM prescription AS p
LEFT JOIN drug AS d
ON p.drug_name = d.drug_name
LEFT JOIN prescriber AS p2
ON p2.npi = p.npi
WHERE total_claim_count > 3000;

-- 7. The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. **Hint:** The results from all 3 parts will have 637 rows.


--     a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management') in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). **Warning:** Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

-- SELECT specialty_description, npi, drug_name
-- FROM prescriber
-- CROSS JOIN drug AS d
-- WHERE specialty_description = 'Pain Management'
-- AND nppes_provider_city = 'NASHVILLE'
-- AND d.opioid_drug_flag = 'Y'
-- GROUP BY specialty_description, npi, drug_name;

--     b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).


    
--     c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.
