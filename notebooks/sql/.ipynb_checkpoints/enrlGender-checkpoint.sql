WITH CURR_BASE AS ( SELECT  SGBSTDN_PIDM PIDM,
                            ENRL_TERM.SFRSTCR_TERM_CODE REG_TERM,
                            MAX(SGBSTDN_TERM_CODE_EFF) CURR_BASE     --return every unique pidm/term combo from SFRSTCR, then find max SGBSTDN record for that student pidm in that term
                    FROM BANNER.SATURN.SGBSTDN BASE
                    INNER JOIN (SELECT DISTINCT SFRSTCR_PIDM, SFRSTCR_TERM_CODE
                                FROM BANNER.SATURN.SFRSTCR
                                WHERE SFRSTCR_RSTS_CODE IN (    SELECT STVRSTS_CODE
                                                                FROM BANNER.SATURN.STVRSTS
                                                                WHERE STVRSTS_INCL_SECT_ENRL = 'Y')
                                    AND SFRSTCR_PTRM_CODE != 'H') ENRL_TERM ON ENRL_TERM.SFRSTCR_PIDM = BASE.SGBSTDN_PIDM
                    WHERE BASE.SGBSTDN_TERM_CODE_EFF <= ENRL_TERM.SFRSTCR_TERM_CODE
                    GROUP BY SGBSTDN_PIDM, ENRL_TERM.SFRSTCR_TERM_CODE)
SELECT  CB.PIDM,
        CB.REG_TERM,
        SPBPERS_SEX,
        CASE
            WHEN S.SGBSTDN_COLL_CODE_1 IN ('01','51', '21') THEN 'Liberal Arts/Sciences'
            WHEN S.SGBSTDN_COLL_CODE_1 IN ('03','53', '23') THEN 'Professional Studies'
            WHEN S.SGBSTDN_COLL_CODE_1 IN ('62','12', '32') THEN 'School of Education'
            WHEN S.SGBSTDN_COLL_CODE_1 IN ('14','64', '34') THEN 'School of Business'
            WHEN S.SGBSTDN_COLL_CODE_1 IN ('05', '25') THEN 'School of Pharmacy'
            ELSE 'Other'
        END AS COLLEGE
FROM CURR_BASE CB
LEFT OUTER JOIN BANNER.SATURN.SGBSTDN S ON S.SGBSTDN_PIDM = CB.PIDM AND S.SGBSTDN_TERM_CODE_EFF = CB.CURR_BASE
LEFT OUTER JOIN BANNER.SATURN.SPBPERS ON SPBPERS_PIDM = CB.PIDM
WHERE S.SGBSTDN_LEVL_CODE='UG'
    AND REG_TERM='202570'
    AND COLLEGE!='Other'