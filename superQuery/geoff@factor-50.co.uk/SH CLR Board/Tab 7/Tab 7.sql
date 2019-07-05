WITH CLR_FINDER AS (
  SELECT
    TOTAL_CLAIMED / TOTAL_PAID AS CLR,
    POLICY_NO
  FROM
    (
      SELECT
        SUM(IF(TYPE = 'P', AMOUNT_PAID, 0)) AS TOTAL_PAID,
        SUM(IF(TYPE = 'D', AMOUNT_PAID, 0)) AS TOTAL_CLAIMED,
        POLICY_NO
      FROM
        (
          SELECT
            A.*,
            POLICY_COMMENCEMENT_DT,
            CURR_CANC_DT
          FROM
            (
              SELECT
                (TOTAL_DUE - TOTAL_OWED) AS AMOUNT_PAID,
                'P' AS TYPE,
                DT_PAID,
                POLICY_NO_CONFORMED AS POLICY_NO
              FROM
                SH_CLEAN.cp_charges_direct_NEW
              WHERE
                DT_PAID BETWEEN @YearOI 
                AND DATE_ADD(@YearOI, INTERVAL 1 YEAR)
                AND CHARGE_TYPE_DESC LIKE "%Premium%"
              UNION ALL
              SELECT
                PROP_PAID AS AMOUNT_PAID,
                'P' AS TYPE,
                DT_PAID,
                POLICY_NO_CONFORMED AS POLICY_NO
              FROM
                SH_FINAL.F50_CHARGES_GROUP_UNGROUPED
              WHERE
                DT_PAID BETWEEN @YearOI
                AND DATE_ADD(@YearOI, INTERVAL 1 YEAR)
                AND CHARGE_TYPE LIKE "%Premium%"
              UNION ALL
              SELECT
                PAID_AMOUNT AS AMOUNT_PAID,
                'D' AS TYPE,
                POLICY_MONTH_START AS DT_PAID,
                POLICY_NO_CONFORMED AS POLICY_NO
              FROM
                SH_FINAL.CLAIMS_2
              WHERE
                POLICY_MONTH_START BETWEEN @YearOI
                AND DATE_ADD(@YearOI, INTERVAL 1 YEAR)
                
            ) AS A
            INNER JOIN SH_CLEAN.POLICIES_CONFORMED ON A.POLICY_NO = POLICIES_CONFORMED.POLICY_NO
          WHERE
            POLICY_COMMENCEMENT_DT <= @YearOI
            AND COALESCE(CURR_CANC_DT, '2020-01-01') >= DATE_ADD(@YearOI, INTERVAL 1 YEAR)
        )
      GROUP BY
        POLICY_NO
    )
  WHERE
    TOTAL_PAID > 0
  ORDER BY
    CLR
)
SELECT
  COUNT(*) AS Count,
  AVG(CLR) Avg_CLR,
 RENEWAL_DUE
FROM
  SH_MODEL.LC_MODELLING_SAMPLE_V2 A
  INNER JOIN CLR_FINDER ON A.POLICY_NO = CLR_FINDER.POLICY_NO
GROUP BY
 RENEWAL_DUE