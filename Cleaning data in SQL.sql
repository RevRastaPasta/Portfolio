
-- Showing all data

select *
from PortfolioProject..NashvilleHousing



-- Standarizing SaleDate date format

alter table nashvillehousing
add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date, SaleDate)



-- Populating Property Address data

select *
from PortfolioProject..NashvilleHousing
where PropertyAddress is null
order by ParcelID

Select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, isnull(a.propertyaddress, b.propertyaddress)
from PortfolioProject..NashvilleHousing A
join PortfolioProject..NashvilleHousing B
on a.parcelid = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.propertyaddress is null

update A
set propertyaddress = isnull(a.propertyaddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing A
join PortfolioProject..NashvilleHousing B
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 



-- Splitting up property address into Address, City

Select PropertyAddress
from PortfolioProject..NashvilleHousing

Select substring(propertyaddress, 1, charindex(',', propertyaddress) -1) as Address,
Substring(propertyaddress, charindex(',', propertyaddress) +1, len(propertyaddress)) as Address
from PortfolioProject..NashvilleHousing

alter table nashvillehousing
add SplitPropertyAddress nvarchar(255),
SplitPropertyCity nvarchar(255)
update NashvilleHousing
set SplitPropertyAddress = Substring(PropertyAddress, 1, charindex(',', propertyaddress) -1),
SplitPropertyCity = Substring(propertyaddress, charindex(',', propertyaddress) +1, len(propertyaddress))



-- Splitting up owner address into address, city, state

Alter table nashvillehousing
add SplitOwnerAddress nvarchar(255),
	SplitOwnerCity nvarchar(255),
	SplitOwnerState nvarchar(255)
update Nashvillehousing
set SplitOwnerAddress = parsename(replace(Owneraddress, ',', '.') , 3),
SplitOwnerCity = PARSENAME(replace(OwnerAddress, ',', '.') , 2),
SplitOwnerState = PARSENAME(replace(OwnerAddress, ',', '.') , 1)



-- Standarize the SoldAsVacant column values, replace Y/N with Yes/No

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		When SoldAsVacant ='N' then 'No'
		else SoldAsVacant
		end

select distinct(soldasvacant), count(soldasvacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2



-- Remove duplicates

with RowNumCTE as(
	select *, ROW_NUMBER() over (partition by parcelID, propertyaddress, saleprice, saledate, legalreference
	order by uniqueid) row_num
from PortfolioProject..NashvilleHousing)

select *
from RowNumCTE
where row_num > 1
order by Propertyaddress



-- Deleting unused columns

alter table nashvillehousing
drop column owneraddress, taxdistrict, propertyaddress, saledate
