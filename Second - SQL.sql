--QUERIES:
	--What are the top 5 brands by receipts scanned for most recent month? 
	--The top 5 brands can be retrieved from considering the count of receipt items or receipts alone
	SELECT name 
	FROM Brands 
	WHERE brandCode in 
	(
		SELECT Top 5 b.name
		FROM brands b join receipt_items ri on b.brandCode = ri.brandCode
		inner join receipts r on ri.receiptId = r.receiptId 
		WHERE (DATEADD(MONTH, -1, GETDATE())) = MONTH(r.dateScanned)
		GROUP BY b.brandCode
		ORDER BY count(ri.riId)
	)
	
	SELECT name 
	FROM Brands 
	WHERE brandCode in 
	(
	SELECT Top 5 b.name
	FROM brands b join receipt_items ri on b.brandCode = ri.brandCode
	inner join receipts r on ri.receiptId = r.receiptId 
	WHERE (DATEADD(MONTH, -1, GETDATE())) = MONTH(r.dateScanned)
	GROUP BY b.brandCode
	ORDER BY count(r.receiptId))

	--When considering average spend from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
	SELECT rewardReceiptStatus as ReceiptStatus, AVG(amountSpent) as AverageAmount
	FROM Receipts
	WHERE rewardReceiptStatus IN ('Accepted', 'Rejected')
	GROUP BY rewardReceiptStatus;
	

	--When considering total number of items purchased from receipts with 'rewardsReceiptStatus’ of ‘Accepted’ or ‘Rejected’, which is greater?
	SELECT r.rewardReceiptStatus as ReceiptStatus, count(ri.riId) as TotalNumberOfItems
	FROM Receipts r JOIN Receipt_Items ri on r.receiptId = ri.receiptId
	WHERE r.rewardReceiptStatus IN ('Accepted', 'Rejected')
	GROUP BY r.rewardReceiptStatus;
	
	--How does the ranking of the top 5 brands by receipts scanned for the recent month compare to the ranking for the previous month?
	--Solution: As per my understanding, based on the top 5 brands in the recent month, the query retrieves the positions of the brands in the prior month so that both rankings can be compared.
	
	WITH RecentMonth AS
	(
		SELECT brandCode, Rnk as 'RecentMonthRank' FROM (
		SELECT b.brandCode, RANK() OVER(ORDER BY COUNT(ri.riId)) as Rnk FROM Receipt_Items ri
		JOIN Brands b ON ri.brandCode=b.brandCode
		JOIN Receipts r ON r.receiptId=ri.receiptId
		WHERE MONTH(DATEADD(MONTH, -1, GETDATE())) = MONTH(dateScanned)
		GROUP BY b.brandCode
	) t WHERE Rnk <= 5
	),
	PreviousMonth AS
	(
		SELECT b.brandCode, RANK() OVER(ORDER BY COUNT(ri.riId)) as 'PreviousMonthRank' FROM Receipt_Items ri
		JOIN Brands b ON ri.brandCode=b.brandCode
		JOIN Receipts r ON r.receiptId=ri.receiptId
		WHERE MONTH(DATEADD(MONTH, -2, GETDATE())) = MONTH(dateScanned)
		GROUP BY b.brandCode
	)
	SELECT p.brandCode, r.RecentMonthRank, p.PreviousMonthRank FROM RecentMonth r
	JOIN PreviousMonth p ON r.brandCode = p.brandCode

	--Which brand has the most spend among users who were created within the past 6 months?
	with Users_past6months as (
		SELECT userId
		FROM users 
		WHERE month(createdDate) >= MONTH(DATEADD(MONTH, -6, GETDATE()))
	),
	amountSpentByBrands as 
	(SELECT b.brandId, sum(r.amountSpent) as totalMoney
	FROM Users_past6months u JOIN Receipts r on  r.receiptId = u.userId 
	JOIN Receipt_Items ri on ri.receiptId = r.receiptId  
	JOIN Brands b on b.brandCode = ri.brandCode
	GROUP BY b.brandId )

	SELECT TOP 1 b.name as TopBrand
	FROM amountSpentByBrands a JOIN Brands b on a.brandId = b.brandId
	ORDER BY a.totalMoney DESC;

	--Which brand has the most transactions among users who were created within the past 6 months?
	with Users_past6months as (
		SELECT userId
		FROM users 
		WHERE month(createdDate) >= MONTH(DATEADD(MONTH, -6, GETDATE()))
	),
	brandTransactions AS
	(
	SELECT b.brandId,  COUNT(r.receiptId) AS transactions FROM Users_past6months u
	JOIN Receipts r ON r.userId=u.userId
	JOIN Receipt_Items ri ON ri.receiptId=r.receiptId
	JOIN Brands b ON b.brandCode=ri.brandCode
	GROUP BY b.brandId, r.receiptId
	)

	SELECT top 1 b.name as TopBrandTransactions
	FROM brandTransactions a JOIN Brands b on a.brandId = b.brandId
	ORDER BY a.transactions desc;