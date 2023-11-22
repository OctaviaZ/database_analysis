-- debt ratio

with debtRatioTable as (
    SELECT stock, endDate, totalAssets, totalLiab, 
    totalLiab/totalAssets as debtRatio 
    FROM balanceSheetHistory_annually)


-- YOY (year over year) growth of debt ratio

,debtRatioIncreTable as (
    select z.*, (z.debtRatio - z.prev_debtRatio) as debtRatio_Incre
    from (
        select stock, date(endDate) as endDate, debtRatio
        , lag(debtRatio, 1, null) 
        over ( partition by stock order by date(endDate)) as prev_debtRatio
        from debtRatioTable) z)

        
-- five companies increased the most debt ratio in the last year

select * from debtRatioIncreTable 
where endDate like "2019%"
order by debtRatio_Incre desc limit 5;


-- net income to assets ratio (ROA - return on assets)

select IA.stock, IA.endDate, IA.netIncome, BA.totalAssets, IA.netIncome/BA.totalAssets as ROA
from incomeStatementHistory_annually IA
inner join balanceSheetHistory_annually BA
on IA.stock = BA.stock and IA.endDate = BA.endDate;


-- companies with debt to asset ratio greater than 1 in the last year. 

with debtRatioTable as (
    SELECT stock, endDate, totalAssets, totalLiab, 
    totalLiab/totalAssets as debtRatio 
    FROM balanceSheetHistory_annually)
        
select * from debtRatioTable
where debtRatio > 1 and endDate like "2019%";