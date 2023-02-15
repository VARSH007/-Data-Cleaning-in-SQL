select * from nash_housing;

-- standardize data formate

Select SaleDate, CONVERT(date,SaleDate)
from nash_housing; 

ALTER TABLE nash_housing 
ADD saledateconverted date;

update nash_housing
SET saledateconverted = convert(date,SaleDate);

-- select * from nash_housing;
-- --------------------------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data
select * from nash_housing
order by parcelid;

select t1.parcelid, t1.propertyaddress, t2.parcelid, t2.propertyaddress, ISNULL(t1.propertyaddress,t2.propertyaddress)
from nash_housing t1
join nash_housing t2
on t1.parcelid = t2.parcelid
and t1.uniqueid <> t2.uniqueid
where t1.propertyaddress is null;

update t1
set propertyaddress = isnull(t1.propertyaddress,t2.propertyaddress)
from nash_housing t1
join nash_housing t2
on t1.parcelid = t2.parcelid
and t1.uniqueid <> t2.uniqueid
where t1.propertyaddress is null
-- ----------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

-- propertyaddress

select PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as address, 
SUBSTRING(propertyaddress, charindex(',',propertyaddress) + 1, len(propertyaddress)) as city
from nash_housing;

ALTER TABLE nash_housing
add Property_Split_Address varchar(255);
Update nash_housing
set Property_Split_Address = SUBSTRING(propertyaddress, 1, charindex(',', propertyaddress) -1);
ALTER TABLE nash_housing
add Property_Split_City varchar(255);
Update nash_housing
set Property_Split_City = SUBSTRING(propertyaddress, charindex(',',propertyaddress) + 1, len(propertyaddress))


select OwnerAddress from PortfolioProject.dbo.nash_housing;

select  
PARSENAME(REPLACE(OwnerAddress, ',','.') , 3), 
PARSENAME(REPLACE(OwnerAddress, ',','.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',','.') , 1) 
from PortfolioProject.dbo.nash_housing;

AlTER TABLE PortfolioProject.dbo.nash_housing
ADD Owner_split_address nchar(255);
UPDATE PortfolioProject.dbo.nash_housing
SET Owner_split_address = PARSENAME(REPLACE(OwnerAddress, ',','.') , 3)

ALTER TABLE PortfolioProject.dbo.nash_housing
ADD Owner_split_city nchar(255);
UPDATE PortfolioProject.dbo.nash_housing
SET Owner_split_city = PARSENAME(REPLACE(OwnerAddress, ',','.') , 2)

ALTER TABLE PortfolioProject.dbo.nash_housing
ADD Owner_split_state nchar(255);
UPDATE PortfolioProject.dbo.nash_housing
SET Owner_split_state = PARSENAME(REPLACE(OwnerAddress,',','.') , 1)

select * from PortfolioProject.dbo.nash_housing;

-- -------------------------------------------------------------------------------------------------------------------------
select soldasvacant from PortfolioProject.dbo.nash_housing where SoldAsVacant LIKE 'y';
select soldasvacant from PortfolioProject.dbo.nash_housing where SoldAsVacant LIKE 'n';

-- Change Y and N to Yes and No in "Sold as Vacant" field

UPDATE PortfolioProject.dbo.nash_housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
						WHEN SoldAsVacant = 'N' THEN 'No'
						Else SoldAsVacant
				   END 

-- -----------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates

select ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference from PortfolioProject.dbo.nash_housing order by parcelid;

WITH RowNumCTE AS(
select *, ROW_NUMBER() OVER (PARTITION BY Parcelid, propertyaddress,saleprice, saledate, legalreference order by uniqueid) row_num 
from  PortfolioProject.dbo.nash_housing )
select * from RowNumCTE where row_num > 1
order by PropertyAddress

-- we have 104  duplicate records
-- deleting duplicates
WITH RowNumCTE AS(
select *, ROW_NUMBER() OVER (PARTITION BY Parcelid, propertyaddress,saleprice, saledate, legalreference order by uniqueid) row_num 
from  PortfolioProject.dbo.nash_housing )
DELETE  from RowNumCTE where row_num > 1

-- ----------------------------------------------------------------------------------------------------------------------------


-- Delete Unused Columns
Select * From  PortfolioProject.dbo.nash_housing

ALTER TABLE  PortfolioProject.dbo.nash_housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

