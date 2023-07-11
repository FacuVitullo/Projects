-- Standarize the SaleDate column.

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
from Housing

UPDATE Housing
SET housing.SaleDate = CONVERT(Date, housing.SaleDate)
-- This does not work for some reason.

ALTER TABLE Housing
ADD SaleDateConverted DATE
-- Creating a new column

UPDATE Housing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- Removing the SaleDate column so we now only have one.
ALTER TABLE Housing DROP COlUMN SaleDate
GO

-- Checking it all worked:
SELECT * FROM Housing

-- ----------------------------------------------------------------------------------
-- PropertyAddress has some null values, so we want to complete those.
-- We can see that ParcelID is related to property Adress, so we will use that connection if we can.

SELECT * FROM Housing
Where PropertyAddress is null

-- Here we do a self join to see what can we complete.
SELECT a.PropertyAddress, a.parcelID, b.propertyAddress, b.Parcelid
FROM housing a
JOIN housing b ON a.ParcelID = b.ParcelID and a.uniqueid <> b.uniqueid
WHERE a.propertyAddress is null

-- Now we use the information on the third column to complete the first one.
UPDATE a
SET a.propertyAddress = ISNULL(a.propertyAddress, b.propertyAddress)
FROM housing a
JOIN housing b ON a.ParcelID = b.ParcelID and a.uniqueid <> b.uniqueid
WHERE a.propertyAddress is null

--  Checking if it worked.
SELECT * FROM Housing

-----------------------------------------------------------------------------------------------
-- We keep normalizing our data, to do so, we need to break the propertyAddress column into individual columns
-- With the address and the city.
-- One can notice that the city and the address are separated by a coma, so we can use that to separate the columns.


SELECT
SUBSTRING(propertyAddress, 1, CHARINDEX(',', propertyaddress)- 1),
SUBSTRING(propertyAddress, CHARINDEX(',', propertyaddress) + 1, LEN(propertyAddress)) AS city
FROM housing

-- So that takes all the text before the comma. (The 1 means that we start at the first character).
-- The - 1 comand is to remove the last character (which is the comma)
-- Similar for the +1 in the third line of code.

-- So now we can wreate the two new columns and then drop the propertyaddress one.


ALTER TABLE Housing
ADD PropertyAddressSplit TEXT;

UPDATE Housing
SET PropertyAddressSplit = SUBSTRING(propertyAddress, 1, CHARINDEX(',', propertyaddress)- 1) 

ALTER TABLE Housing
ADD City TEXT;

Update Housing
SET City = SUBSTRING(propertyAddress, CHARINDEX(',', propertyaddress) + 1, LEN(propertyAddress))



SELECT * FROM housing

-- Removing the SaleDate column so we now only have one.
ALTER TABLE Housing DROP COlUMN PropertyAddress
go


--------------------------------------------------------
-- Now we do something similar to owneraddress.
SELECT owneraddress,
PARSENAME(REPLACE(owneraddress, ',', '.'), 3) as state,
PARSENAME(REPLACE(owneraddress, ',', '.'), 2) as state,
PARSENAME(REPLACE(owneraddress, ',', '.'), 1) as state
FROM housing

-- Parsename only works with ., that is why we use replace to change it.
SELECT a.propertyaddresssplit, a.city, b.ownerAddress FROM housing a
join housing b  ON a.ParcelID = b.ParcelID 
-- Here we can see that the informationin owner address is repeated, except for the state, so we only need to
-- save the state and create a new column.

ALTER TABLE Housing
ADD state TEXT;

UPDATE Housing
SET state = PARSENAME(REPLACE(owneraddress, ',', '.'), 1) 


ALTER TABLE housing DROP COlUMN owneraddress
go


---- Now let's do the same with owner names.
-- Because in some names we have dots ., we use this method instead.
SELECT
SUBSTRING(REPLACE(ownername, ',', ''), 1, CHARINDEX(',', ownername) ),
SUBSTRING(ownername, CHARINDEX(',', ownername) + 1, LEN(ownername)) 
FROM housing
-----------------------------
ALTER TABLE Housing
ADD FirstName TEXT;

Update Housing
SET FirstName = SUBSTRING(ownername, CHARINDEX(',', ownername) + 1, LEN(ownername)) 
-----------------------------------------------
ALTER TABLE Housing
ADD LastName TEXT;

Update Housing
SET LastName = SUBSTRING(REPLACE(ownername, ',', ''), 1, CHARINDEX(',', ownername) )

------
ALTER TABLE housing DROP COlUMN ownername
go

-- Sold as vacant has two types of data on it. N, Y, no, and yes.
-- We want to use only No or Yes so let's solve that.

SELECT DISTINCT(soldAsVacant), COUNT(soldasvacant) FROM housing
group by soldasvacant


SELECT soldasvacant,
 CASE WHEN soldasvacant = 'Y' THEN 'Yes'
      WHEN soldasvacant = 'N' THEN 'No'
	  ELSE soldasvacant
	  END
FROM housing


----- Now we update that column


UPDATE Housing
SET SoldAsVacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes'
      WHEN soldasvacant = 'N' THEN 'No'
	  ELSE soldasvacant
	  END
FROM housing


SELECT * FROM housing


-------------------------------------------------------------------------
-- Removing duplicates.
-- We assing a row_num to each individual column, if we get a row_num = 2 or 3, it means that the column is repeated

WITH RowNumCTE AS(
SELECT * ,
    ROW_NUMBER() OVER (PARTITION BY ParcelID, 
	                  
					                SalePrice,
									LegalReference,
									Acreage
									
									

					
					   ORDER BY uniqueid) row_num
FROM housing
)


SELECT * FROM RowNumCTE
WHERE row_num > 1


-- Now we delete the duplicates:

WITH RowNumCTE AS(
SELECT * ,
    ROW_NUMBER() OVER (PARTITION BY ParcelID, 
	                  
					                SalePrice,
									LegalReference,
									Acreage
									
									

					
					   ORDER BY uniqueid) row_num
FROM housing
)


DELETE 
FROM RowNumCTE
WHERE row_num > 1

-- Now we don't have any duplicated column.

SELECT * FROM Housing
-- Finally, change the names of the saledate and propertyadress columns so these are easier to use.

EXEC sp_RENAME 'housing.SaleDateConverted' , 'SaleDate', 'COLUMN'
EXEC sp_RENAME 'housing.PropertyAddressSplit' , 'PropertyAddress', 'COLUMN'

-- Done.