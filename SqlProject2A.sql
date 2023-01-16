--STANDARDIZE THE SALEDATE FORMAT 
-- UPDATE METHOD NOT ALWAYS WORK  USE ALTER

SELECT SaleDate, CONVERT(date, SaleDate) 
FROM PortfolioProjectAlex.dbo.NashvilleHousing

--UPDATE NashvilleHousing
--SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateconverted date;

UPDATE NashvilleHousing
SET SaleDateconverted = CONVERT(date, SaleDate)

SELECT SaleDateconverted, CONVERT(date, SaleDate) 
FROM PortfolioProjectAlex.dbo.NashvilleHousing

-- POPULATE PROPERTY ADDRESS 

--SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) 
--FROM PortfolioProjectAlex.dbo.NashvilleHousing a
--JOIN PortfolioProjectAlex.dbo.NashvilleHousing b
--     on a.ParcelID = b.ParcelID
--	 AND a.UniqueID <> b.UniqueID 
--WHERE a.PropertyAddress is null 

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress) 
FROM PortfolioProjectAlex.dbo.NashvilleHousing a
JOIN PortfolioProjectAlex.dbo.NashvilleHousing b
     on a.ParcelID = b.ParcelID
     AND a.UniqueID <> b.UniqueID 
WHERE a.PropertyAddress is null

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
FROM PortfolioProjectAlex.dbo.NashvilleHousing 

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertyCityAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertyCityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT PropertyCityAddress
FROM PortfolioProjectAlex.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM PortfolioProjectAlex.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

-- Change Y and N to Yes and No in "Sold as Vacant" field


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProjectAlex.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2




SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProjectAlex.dbo.NashvilleHousing
GROUP BY SoldAsVacant 

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
-- REMOVE DUPLICATES

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM PortfolioProjectAlex.dbo.NashvilleHousing
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

-- DELETE UNUSED COLUMNS

SELECT *
FROM PortfolioProjectAlex.dbo.NashvilleHousing

ALTER TABLE PortfolioProjectAlex.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProjectAlex.dbo.NashvilleHousing
DROP COLUMN SaleDate