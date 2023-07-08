/* 
sql data cleaning
*/


select * 
from data_cleaning..HouseDetails

--convert salesDate to date format

select SalesDate
from data_cleaning..HouseDetails

Alter table data_cleaning..HouseDetails
Add SalesDate date

Update data_cleaning..HouseDetails
SET SalesDate = convert(date,SaleDate)


-- Fill NULL values in propertyAdress

select PropertyAddress
from data_cleaning..HouseDetails
where PropertyAddress is NULL

Update a
set a.propertyAddress = b.PropertyAddress
from data_cleaning..HouseDetails a
join data_cleaning..HouseDetails b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from data_cleaning..HouseDetails a
join data_cleaning..HouseDetails b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null



-- split property address and owner address(state,city)

Alter table data_cleaning..HouseDetails
Add PropertyCity nvarchar(255)

Update data_cleaning..HouseDetails
SET PropertyCity = SUBSTRING(PropertyAddress,1,CHARINDEX(',', PropertyAddress) -1)

Alter table data_cleaning..HouseDetails
Add PropertyState nvarchar(255)

Update data_cleaning..HouseDetails
SET PropertyState = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select PropertyCity, PropertyState
from data_cleaning..HouseDetails

Alter table data_cleaning..HouseDetails
Add OwnersAddress nvarchar(255)

Update data_cleaning..HouseDetails
SET OwnersAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

Alter table data_cleaning..HouseDetails
Add OwnersCity nvarchar(255)

Update data_cleaning..HouseDetails
SET OwnersCity = PARSENAME(replace(OwnerAddress,',','.'),2)

Alter table data_cleaning..HouseDetails
Add OwnerState nvarchar(255)

Update data_cleaning..HouseDetails
SET OwnerState = PARSENAME(replace(OwnerAddress,',','.'),1)

Select *
from data_cleaning..HouseDetails



--remove duplicates

WITH DUPL_CTE AS
(
Select *, ROW_NUMBER() over (partition by ParcelID,
									   PropertyAddress,
									   SaleDate,
									   SalePrice,
									   LegalReference
									   Order By
										UniqueID
										)row_num
from data_cleaning..HouseDetails
)
Delete
from DUPL_CTE
where row_num>1
--order by propertyAddress



-- replace 'Y' with 'Yes' and 'N' with 'No' in SoldAsVacant

Select distinct(SoldAsVacant), count(SoldAsVacant) as counts
from data_cleaning..HouseDetails
group by SoldAsVacant
order by counts desc

Update data_cleaning..HouseDetails
SET SoldAsVacant = 'No'
where SoldAsVacant = 'N'

Update data_cleaning..HouseDetails
SET SoldAsVacant = 'Yes'
where SoldAsVacant = 'Y'


