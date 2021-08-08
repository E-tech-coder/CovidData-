SELECT TOP 100 * 
FROM NashvillHousing..NashvillHousing

-- Standardize data format

Select CONVERT(Date, SaleDate)
From NashvillHousing..NashvillHousing

ALTER TABLE NashvillHousing..NashvillHousing
ADD ConvertedDate Date;

UPDATE NashvillHousing..NashvillHousing
SET ConvertedDate = CONVERT(Date, SaleDate)

-- Populate the NULL data in PropertyAddress

Select *
From NashvillHousing..NashvillHousing
Where PropertyAddress is null

Select a.[UniqueID ], b.[UniqueID ], a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress
From NashvillHousing..NashvillHousing a
 Join NashvillHousing..NashvillHousing b
	On a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- The two properties that have the same ParcelID but different UniqueID have the the Property address

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvillHousing..NashvillHousing a
 Join NashvillHousing..NashvillHousing b
	On a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Split adress into several columns to make it easier to use

select * 
From NashvillHousing..NashvillHousing

Select SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)
From NashvillHousing..NashvillHousing

Select SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))
From NashvillHousing..NashvillHousing

ALTER TABLE NashvillHousing..NashvillHousing
Add SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) nvarchar(255),
	PropertySplitCity nvarchar(255);

UPDATE NashvillHousing..NashvillHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

UPDATE NashvillHousing..NashvillHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))



select * 
From NashvillHousing..NashvillHousing

ALTER TABLE NashvillHousing..NashvillHousing
ADD OwnerSplitAddress nvarchar(255),
	OwnerSplitCity nvarchar(255),
	OwnerSplitState nvarchar(255)

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
	PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
	PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
From NashvillHousing..NashvillHousing

UPDATE NashvillHousing..NashvillHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant),count(SoldAsVacant)
From NashvillHousing..NashvillHousing
Group by SoldAsVacant

SELECT
	Distinct(CASE WHEN SoldAsVacant = 'N' then 'No'
		 WHEN SoldAsVacant = 'Y' then 'Yes'
		 ELSE SoldAsVacant
		 END)
From NashvillHousing..NashvillHousing
Group by SoldAsVacant

UPDATE NashvillHousing..NashvillHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' then 'No'
		 WHEN SoldAsVacant = 'Y' then 'Yes'
		 ELSE SoldAsVacant
		 END

-- Drop unused columns
ALTER TABLE NashvillHousing..NashvillHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


-- Remove Duplicates using CTE

Select *
From NashvillHousing..NashvillHousing

WITH rownumCTE AS (
SELECT *, 
	ROW_NUMBER() OVER (PARTITION BY ParcelID,
	PropertySplitAddress,
	SalePrice,
	OwnerName,
	TotalValue,
	LegalReference,
	YearBuilt ORDER BY UniqueID) AS rownum
From NashvillHousing..NashvillHousing
)
SELECT * 
FROM rownumCTE
WHERE rownum > 1


WITH rownumCTE AS (
SELECT *, 
	ROW_NUMBER() OVER (PARTITION BY ParcelID,
	PropertySplitAddress,
	SalePrice,
	OwnerName,
	TotalValue,
	LegalReference,
	YearBuilt ORDER BY UniqueID) AS rownum
From NashvillHousing..NashvillHousing
)
SELECT * 
FROM rownumCTE
WHERE rownum = 1

