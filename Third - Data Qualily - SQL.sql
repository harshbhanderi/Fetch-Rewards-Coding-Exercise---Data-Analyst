--FetchRewards Analytics Engineer Assessment
--Creation of Table 1: Users
Create table Users (
	userId varchar(25) ,
	state varchar(2),
	createdDate datetime CONSTRAINT DF_Users_createdDate DEFAULT GETDATE() not null,
	lastLogin datetime,
	role varchar(20),
	active bit not null,
	signupSource varchar(20),
    CONSTRAINT PK_Users_userId PRIMARY KEY NONCLUSTERED (userId)	
	)
	--From the users json file, all the data can be stored using the attributes of the table mentioned above.
	--Primary and Foreign key analysis: Primary key userId should not be null. There no null values in the JSON data given for this column.
	--We can see that lastLogin, signupsource and state have missing values. 
	--Roles can also be seperated into a new table depending on the different capacities, for now most values are 'consumer'

--Creation of Table 2: Brands
	Create table Brands (
	brandId varchar(25),
	barCode bigint,
	brandCode varchar(25) not null,
	name varchar(25),
	topBrand bit,
	cpgId varchar(25),
	categoryId int
	CONSTRAINT PK_Brands_brandsId PRIMARY KEY NONCLUSTERED (brandId),
	CONSTRAINT UC_Brands_brandCode UNIQUE (brandCode),
	CONSTRAINT FK_Brands_Category FOREIGN KEY (categoryId) REFERENCES Category(categoryId),
	CONSTRAINT FK_Brands_CPG FOREIGN KEY (cpgId) REFERENCES CPG(cpgId)
	)

	--From the brands json data file, the attributes for brands table has been established.
	--Primary and Foreign key analysis:  Primary key brand_id has no null values; and there is also a unique constraint on brandCode since it is being used as a foreign key.

	
--Creation of Table 3: Category	
	Create table Category (
	categoryId int IDENTITY(1,1),
	category varchar(25),
	categoryCode varchar(25),
	CONSTRAINT PK_Category_categoryId PRIMARY KEY NONCLUSTERED (categoryId)
	)
	--From the brands json data file, adhering to rules of Normalization, Category values has been seperated into a new table and relationship is established through brandId. The idea being each brand has a particular category.
	--Primary and Foreign key analysis: The primary key is an autoincrement numeric assigned to each row. Category is related to brands through brand_id
	--From the data, it is observed that category and categoryCode have similar values, if there is no particular meaning/requirement to store them twice, one of the column can be retained instead of two.
	--There are many null values in the category and categoryCode values

--Creation of Table 4: CPG
	Create table CPG (
	cpgId varchar(25),
	cpgRef varchar(25),
	CONSTRAINT PK_CPG_cpgId PRIMARY KEY NONCLUSTERED (cpgId)
	)
	--CPG is another table derived from the Brands json data. The object contains cpg_id and cpg_ref which have been converted into columns in the table
	--Primary and Foreign key analysis: cpg_id has been identified as the primary key; and the table references Brands through Brand_id
	--Most of the ref values are set to 'cogs' (Other value used being 'cpgs'). More information would be needed to understand how these values need to ne utilized.

--Creation of Table 5: Receipts
	Create table Receipts (
	receiptId varchar(50) not null,
	bonusPointsEarned bigint,
	bonusPointsEarnedReason varchar(200),
	createdDate datetime not null,
	dateScanned datetime not null,
	finishedDate datetime,
	modifyDate datetime,
	pointsAwardedDate datetime,
	pointsEarned float,
	purchaseDate datetime,
	itemCount float,
	rewardReceiptStatus varchar(30),
	amountSpent float,
	userId varchar(25)
	CONSTRAINT PK_Receipts_receiptId PRIMARY KEY NONCLUSTERED (receiptId),
	CONSTRAINT FK_Receipts_Users FOREIGN KEY (userId) REFERENCES Users(userId)
	);

	--The above mentioned attributes were derived after flattening the receipts json data. 
	--Primary and Foreign key analysis: The primary key is the receiptId which is unique for each entry and the userId has been designated as the foregin key to get information about the user who made the purchase. 
	--There are more than 50% null values for columns like bonusPointsEarned, bonusPointsEarnedReason, finishedDate, pointsAwardedDate, pointsEarned. Depending the business value the following attributes can be retained or eliminated. 

--Creation of Table 6: Receipt_Items
Create table Receipt_Items (
	riId int IDENTITY(1,1) ,
	barcode    bigint,                            
	description    varchar(max) ,                       
	finalPrice     float,                        
	itemPrice      float,                        
	needsFetchReview  bit,                    
	partnerItemId int,                            
	preventTargetGapPoints bit,                
	quantityPurchased int ,                     
	userFlaggedBarcode bigint,                 
	userFlaggedNewItem bit,                    
	userFlaggedPrice float,                      
	userFlaggedQuantity float,                  
	receiptId   varchar(50),                            
	needsFetchReviewReason varchar(50),               
	pointsNotAwardedReason     varchar(100),           
	pointsPayerId varchar(50),                         
	rewardsGroup  varchar(30),                        
	rewardsProductPartnerId varchar(30),         
	userFlaggedDescription varchar(30),                
	originalMetaBriteBarcode  bigint,            
	originalMetaBriteDescription varchar(100) ,      
	brandCode varchar(25)  ,                          
	competitorRewardsGroup  varchar(25),              
	discountedItemPrice float,                  
	originalReceiptItemText varchar(30),              
	itemNumber bigint,                           
	originalMetaBriteQuantityPurchased int, 
	pointsEarned float,                         
	targetPrice float,                           
	competitiveProduct bit,                    
	originalFinalPrice float,                    
	originalMetaBriteItemPrice float ,          
	deleted bit ,                              
	priceAfterCoupon float   ,                  
	metabriteCampaignId varchar(50)	
	CONSTRAINT PK_Receipt_Items_riId PRIMARY KEY NONCLUSTERED (riId)
	CONSTRAINT FK_Receipt_Items_Receipts FOREIGN KEY (receiptId) REFERENCES Receipts(receiptId),
	CONSTRAINT FK_Brands_ReceiptItems FOREIGN KEY (brandCode) REFERENCES Brands(brandCode)
	)

	--Receipt_Items has been created from the object attribute of Receipts. 
	--All the attributes in the object list have been added as attributes.
	--Data quality check: An auto increment unique value has been created which acts as the primary key. It is referencing the receipts and brands table through the attributes receipt_id and brandCode respectively.
	--Observation: There are about 6941 rows in the table with some attributes having 90% of NaN values, suitable columns depending on the use case can be utilized for business purpose. For now, all the attributes have been retained.
	--We can create a seperate table for user_flagged information and metabrite campaign information. Since there are many null values in these columns, I have retained them under receipt_items
	--The only relationship between receipt_items and brands is through brandCode, hence it is important that it is not null and unique. In the existing data, brandCode does not comply with both these conditions 

