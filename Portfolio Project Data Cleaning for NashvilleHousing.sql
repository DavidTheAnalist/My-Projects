/*

-- Cleaning Data In SQL Queries

*/

SELECT *
From PortfolioProject..NashvilleHousing

/*

-- Standardised Date Format

*/


SELECT SaleDateConverted, convert(date, saledate)
From PortfolioProject..NashvilleHousing


Update NashvilleHousing
SET SaleDate = convert(date, saledate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = convert(date, saledate)



---------------------------------------------------------------------------------------------------
-- Populate Property Address Date

SELECT *
From PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing as a
   Join PortfolioProject..NashvilleHousing as b
   on a.ParcelID = b.ParcelID
   and a.[UniqueID ] <> b.[UniqueID ]
   Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing as a
   Join PortfolioProject..NashvilleHousing as b
   on a.ParcelID = b.ParcelID
   and a.[UniqueID ] <> b.[UniqueID ]
   Where a.PropertyAddress is null



   ---------------------------------------------------------------------------------------------------------------
   --Breaking out Address into Individual Columns 

SELECT PropertyAddress
From PortfolioProject..NashvilleHousing


SELECT 
Substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address
, Substring(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) as Address
From PortfolioProject..NashvilleHousing



ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))


SELECT *
From PortfolioProject..NashvilleHousing



SELECT OwnerAddress
From PortfolioProject..NashvilleHousing

SELECT 
Parsename(Replace(Owneraddress, ',', '.'), 3)
,Parsename(Replace(Owneraddress, ',', '.'), 2)
,Parsename(Replace(Owneraddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = Parsename(Replace(Owneraddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = Parsename(Replace(Owneraddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = Parsename(Replace(Owneraddress, ',', '.'), 1)


---------------------------------------------------------------------------------------------------------
--Changing Y and N to Yes and No in "Sold as Vacant"


SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From PortfolioProject..NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


--------------------------------------------------------------------------------------------------------------------
-- Removing Duplicates

With RowNumCTE as(
Select *,
  Row_Number() OVER(
     Partition by ParcelID,
	              PropertyAddress,
				  SalePrice,
				  SaleDate,
				  LegalReference
				  ORDER BY
				    UniqueID
					) row_num
From PortfolioProject..NashvilleHousing
--Order by ParcelID
)
Select*
From RowNumCTE
Where row_num > 1
order by PropertyAddress



---------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns


Select *
From PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate