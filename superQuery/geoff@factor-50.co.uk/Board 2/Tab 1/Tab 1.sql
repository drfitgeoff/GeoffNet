SELECT TOTAL_CLAIMED/TOTAL_PAID, POLICY_NO AS CLR FROM
(SELECT SUM(IF(TYPE = 'P', AMOUNT_PAID, 0)) AS TOTAL_PAID, SUM(IF(TYPE = 'D', AMOUNT_PAID, 0)) AS TOTAL_CLAIMED, POLICY_NO FROM
(SELECT A.*, POLICY_COMMENCEMENT_DT, CURR_CANC_DT FROM
(SELECT (TOTAL_DUE - TOTAL_OWED) AS AMOUNT_PAID, 'P' AS TYPE, DT_PAID, POLICY_NO_CONFORMED AS POLICY_NO FROM SH_CLEAN.CHARGES_DIRECT_CONFORMED WHERE DT_PAID BETWEEN @YearOI AND DATE_ADD(@YearOI, INVERVAL 1 YEAR)
UNION ALL
SELECT PROP_PAID AS AMOUNT_PAID, 'P' AS TYPE, DT_PAID, POLICY_NO_CONFORMED AS POLICY_NO FROM SH_FINAL.F50_CHARGES_GROUP_UNGROUPED WHERE DT_PAID BETWEEN @YearOI AND DATE_ADD(@YearOI, INVERVAL 1 YEAR)
UNION ALL
SELECT PAID_AMOUNT AS AMOUNT_PAID, 'D' AS TYPE, POLICY_MONTH_START AS DT_PAID, POLICY_NO_CONFORMED AS POLICY_NO FROM SH_FINAL.CLAIMS_2 WHERE POLICY_MONTH_START BETWEEN @YearOI AND DATE_ADD(@YearOI, INVERVAL 1 YEAR)) AS A INNER JOIN
SH_CLEAN.POLICIES_CONFORMED ON A.POLICY_NO = POLICIES_CONFORMED.POLICY_NO WHERE POLICY_COMMENCEMENT_DT <= @YearOI AND COALESCE(CURR_CANC_DT, '2020-01-01') >= DATE_ADD(@YearOI, INVERVAL 1 YEAR)) GROUP BY POLICY_NO) WHERE TOTAL_PAID > 0 ORDER BY CLR