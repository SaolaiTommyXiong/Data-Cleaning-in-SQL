-- Cleaning Data in SQL 

Select *
From Portfolio.dbo.NashvilleHousing

-- Standardize Date Format

Select SaleDate
From Portfolio.dbo.NashvilleHousing

ALTER TABLE Portfolio.dbo.NashvilleHousing
Add SaleDateConverted Date; 

Update NashvilleHousing
SET SaleDateConverted = Convert(Date,SaleDate)

Select SaleDateConverted, CONVERT(Date,SaleDate)
From Portfolio.dbo.NashvilleHousing

-- Populate Property Address Data, Property Address has null values

Select PropertyAddress
From Portfolio.dbo.NashvilleHousing
Where PropertyAddress is null

--ParcelID always matches PropertyAddress
Select *
From Portfolio.dbo.NashvilleHousing
Order by ParcelID


--Looks at which Property Adddresses have Null Values
Select A.ParcelID,A.PropertyAddress,B.ParcelID,B.PropertyAddress,ISNULL(A.PropertyAddress,B.PropertyAddress)
From Portfolio.dbo.NashvilleHousing A
JOIN Portfolio.dbo.NashvilleHousing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is null

--Updated Null Values
Update A
SET propertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
From Portfolio.dbo.NashvilleHousing A
JOIN Portfolio.dbo.NashvilleHousing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is null

-- Break out Property Address into Individual Columns (Address, City, State)

Select PropertyAddress
From Portfolio.dbo.NashvilleHousing

--CHARINDEX returns position number
SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)) as Address,CHARINDEX(',',PropertyAddress)
From Portfolio.dbo.NashvilleHousing

--Removes the comma from end of address string
SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
From Portfolio.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
From Portfolio.dbo.NashvilleHousing


-- Adds address and city columns, populating it with the split data
ALTER TABLE Portfolio.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255); 

Update Portfolio.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE Portfolio.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255); 

Update Portfolio.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

Select * 
From Portfolio.dbo.NashvilleHousing

--Using PARSENAME to split owner address
Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From Portfolio.dbo.NashvilleHousing

ALTER TABLE Portfolio.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255); 

ALTER TABLE Portfolio.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255); 

ALTER TABLE Portfolio.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255); 

Update Portfolio.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

Update Portfolio.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Update Portfolio.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

Select * 
From Portfolio.dbo.NashvilleHousing

-- Changing Y and N to Yes and No in "Sold as Vacant" Field

Select Distinct(SoldAsVacant),Count(SoldAsVacant)
From Portfolio.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Portfolio.dbo.NashvilleHousing

Update Portfolio.dbo.NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- Remove Duplicates, not standard to delete data in SQL

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
From Portfolio.dbo.NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num >1

-- Check Duplicates to make sure there are 0
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
From Portfolio.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num >1
Order by PropertyAddress

--Delete Unused Columns

Select * 
From Portfolio.dbo.NashvilleHousing

Alter TABLE Portfolio.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress

Alter TABLE Portfolio.dbo.NashvilleHousing
DROP COLUMN SaleDate