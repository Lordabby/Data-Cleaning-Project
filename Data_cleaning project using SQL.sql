--PROJECT: CLEANING DATA IN SQL
--SKILLS DEMONSTARTED; HANDLING NULLS, DATA FORMATTING,TABLE UPDATE,REMOVING DUPLICATE DATA,REMOVING UNNEEDED FIELD, 
--SPLITTING DATA INTO NEW FIELDS, CASE STATEMENT
SELECT*
FROM projects..nashvile_housing
ORDER BY ParcelID;

--STANDARDIZE DATE FORMAT
SELECT SaleDate, CAST(SaleDate AS DATE) as sale_date
FROM projects..nashvile_housing
ORDER BY SaleDate 

ALTER TABLE projects..nashvile_housing
ADD sale_date DATE

UPDATE  projects..nashvile_housing
SET sale_date = CAST(SaleDate AS DATE)

SELECT sale_date
FROM projects..nashvile_housing
ORDER BY sale_date ASC;

--POPULATING BLANK PROPERTY ADDRESS WITH VALUES IN CORRESPONDING PROPERTY ADDRESS HAVING SAME PAERCELID USING SELF JOIN
SELECT PropertyAddress
FROM projects..nashvile_housing
WHERE PropertyAddress IS NULL

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) 
FROM projects..nashvile_housing a
 JOIN projects..nashvile_housing b
 ON a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
 WHERE  a.PropertyAddress IS NULL;

---TESTING
--ALTER  TABLE projects..nashvile_housing
--DROP COLUMN property_address

--UPDATE projects..nashvile_housing
--SET property_address = PropertyAddress --= COALESCE(a.PropertyAddress,b.PropertyAddress) 
--FROM projects..nashvile_housing

--UPDATE a
--SET property_address = COALESCE(a.PropertyAddress,b.PropertyAddress) 
--FROM projects..nashvile_housing a
-- JOIN projects..nashvile_housing b
-- ON a.ParcelID = b.ParcelID
-- AND a.[UniqueID ] <> b.[UniqueID ]
-- WHERE  a.PropertyAddress IS NULL
---
 UPDATE  a
 SET PropertyAddress = COALESCE(a.PropertyAddress,b.PropertyAddress) 
FROM projects..nashvile_housing a
 JOIN projects..nashvile_housing b
 ON a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
 WHERE  a.PropertyAddress IS NULL;



 --SPLITTING PROPERTY ADDRESS INTO TWO FIELDS( ADRESS, CITY)
 SELECT *
FROM projects..nashvile_housing
ORDER BY ParcelID ASC;

 SELECT PropertyAddress, SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) AS address,
 SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS city
 FROM projects..nashvile_housing
 ORDER BY ParcelID ASC

 ALTER TABLE projects..nashvile_housing
 ADD address VARCHAR(255)

 UPDATE projects..nashvile_housing
 SET address = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) 

 ALTER TABLE projects..nashvile_housing
 ADD city VARCHAR(255)

 UPDATE projects..nashvile_housing
 SET city = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

 SELECT *
 FROM projects..nashvile_housing

 --SPLITTING  STATE DATA FROM OWNER ADDRESS USING PARSENAME()
 SELECT OwnerAddress, PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS state
 FROM projects..nashvile_housing


 ALTER TABLE projects..nashvile_housing
 ADD state VARCHAR(255)

 UPDATE projects..nashvile_housing
 SET state = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

 -- STANDARDIZING DATA COLUMN 'SOLDAS VACANT' TO ONLY (YES, NO VALUES) USING CASE STATEMENT

 SELECT SoldAsVacant, COUNT(*)
 FROM projects..nashvile_housing
 GROUP BY SoldAsVacant
 ORDER BY 2 DESC

 SELECT SoldAsVacant,
 CASE
 WHEN SoldAsVacant = 'Y' THEN 'Yes'
 WHEN SoldAsVacant = 'N' THEN 'No'
 ELSE SoldAsVacant
 END
 FROM projects..nashvile_housing

 UPDATE  projects..nashvile_housing
 SET SoldAsVacant = CASE
 WHEN SoldAsVacant = 'Y' THEN 'Yes'
 WHEN SoldAsVacant = 'N' THEN 'No'
 ELSE SoldAsVacant
 END

 -- REMOVING DUPLICATE ROWS USING WINDOW FUNCTION (ROW_NUMBER) WITH CTE
 
 SELECT *, ROW_NUMBER () OVER(PARTITION BY ParcelID,LegalReference ORDER BY UniqueID) AS row_num
 FROM projects..nashvile_housing
 ORDER BY ParcelID ASC

  
  WITH row_num_tab AS
  ( SELECT *, ROW_NUMBER () OVER(PARTITION BY ParcelID,
 LegalReference ORDER BY UniqueID) AS row_num
 FROM projects..nashvile_housing )

 SELECT *
  FROM row_num_tab
  WHERE row_num >1
  ORDER BY LegalReference ASC;

-- REMOVING UNNEEDED FIELD(OwnerAddress, TaxDistrict, PropertyAddress, SaleDate).

 ALTER TABLE projects..nashvile_housing
 DROP COLUMN  PropertyAddress, SaleDate 

--NOTE: The duplicated rows were eliminated using the legal reference and the parcel id since it's rarely possible for different property to have the same parcelid and same legal reference at the same time.
--prior to the removal of any field from the datasets, it's advisableto have a backup in case of necessity.
--THANKS :)