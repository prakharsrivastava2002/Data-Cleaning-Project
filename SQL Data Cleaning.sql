SELECT SaleDate2
FROM SqlPortfolio..NashvilleHousing

--Changing SaleDate to Date format to remove the unnecessary time after it
ALTER TABLE SqlPortfolio..NashvilleHousing
ADD SaleDate2 Date;

UPDATE SqlPortfolio..NashvilleHousing
SET SaleDate2 = CONVERT(Date,SaleDate)


--Populate Property Address Data to populate the NULL values
SELECT * 
FROM SqlPortfolio..NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)	--ISNULL is used to fill the 1st parameter 
FROM SqlPortfolio..NashvilleHousing a																				-- wIth 2nd parameter if 1st is NULL
JOIN SqlPortfolio..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL			--What we did here is that joined the table with itself on PID and UID and said where a.PA is NULL fill it with value of b.PA


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM SqlPortfolio..NashvilleHousing a																				-- wIth 2nd parameter if 1st is NULL
JOIN SqlPortfolio..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL		


-- Now Breaking Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM SqlPortfolio..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM SqlPortfolio..NashvilleHousing

ALTER TABLE SqlPortfolio..NashvilleHousing   -- Now Adding two Columns to Table and Setting them as what we got from the above query
ADD PropertySplitAddress nvarchar(255);

UPDATE SqlPortfolio..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE SqlPortfolio..NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE SqlPortfolio..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress));

SELECT *
FROM SqlPortfolio..NashvilleHousing			--Checking if it worked


--NOW DOING THE SAME FOR OwnerAddress but Using ParseName

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM SqlPortfolio..NashvilleHousing


ALTER TABLE SqlPortfolio..NashvilleHousing   -- Now Adding 3 Columns to Table and Setting them as what we got from the above query
ADD OwnerSplitAddress nvarchar(255);

UPDATE SqlPortfolio..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE SqlPortfolio..NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE SqlPortfolio..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE SqlPortfolio..NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE SqlPortfolio..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


SELECT *
FROM SqlPortfolio..NashvilleHousing


--Changing Y and N to Yes and No in SoldAsVacant field

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM SqlPortfolio..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 ELSE SoldAsVacant
	 END
FROM SqlPortfolio..NashvilleHousing

UPDATE SqlPortfolio..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 ELSE SoldAsVacant
	 END


-- REMOVING DUPLICATES
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY
				UniqueID
			) row_num

FROM SqlPortfolio..NashvilleHousing
)

DELETE
FROM RowNumCTE
WHERE row_num >1 


--DELETE UNUSED COLUMNS

ALTER TABLE SqlPortfolio..NashvilleHousing 
DROP COLUMN SaleDate							--Removing SaleDate since we Made SaleDate2 so SaleDate has no use now

SELECT *
FROM SqlPortfolio..NashvilleHousing