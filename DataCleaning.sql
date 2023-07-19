-- Datan esikäsittelyä
-- Checking Data

SELECT *
FROM DataCleaning.dbo.Houses

-- Tässä vaiheessa huomasin päivämäärä oli hölmösti joten muokkasin sen,
-- Lisäämällä uuden sarakkeen "DateConverted" ja asetin sille saman arvon kun "SaleDate" ja samalla asetin sille "Date" arvon joka muuttaa sen YYYY-MM-DD

ALTER TABLE DataCleaning.dbo.Houses
Add DateConverted Date;

UPDATE DataCleaning.dbo.Houses
SET DateConverted = CONVERT(Date,SaleDate)

SELECT DateConverted
FROM DataCleaning.dbo.Houses

SELECT *
FROM DataCleaning.dbo.Houses
ORDER BY ParcelID ASC

-- Tämän avulla pystyn tunnistaa kaksoiskappaleet kyseisestä taulukosta jotka perustuvat samaan ParcelID arvoihin mutta erillaisilla UniqueID arvoilla.
-- This query I am using here allows me to identify the duplicates entries in the table based on matching ParcelID values but different UniqueID values.

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM DataCleaning.dbo.Houses A
JOIN DataCleaning.dbo.Houses B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID] <> B.[UniqueID]

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM DataCleaning.dbo.Houses A
JOIN DataCleaning.dbo.Houses B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID] <> B.[UniqueID]
WHERE A.PropertyAddress IS NULL



-- Tässä vaiheessa huomasin "Property Address" sarakkeessa oli katu ja alue kaikki yhdessä paketissa joten muutin sitä semmoiseen muotoon missä on helpompi nähdä katu sekä alue erikseen
-- At this point I noticed that the "Property Address" column had the street and the area all in one package, so I changed it to the same format where it's easier to see the street and the area separately
-- Alkuperäinen / Original: 508  MATHES CT, GOODLETTSVILLE
-- Päivitetty sisältää kaksi saraketta / Updated includes two columns:
-- PropertySplitAddress: 508  MATHES CT / PropertySplitCity:  GOODLETTSVILLE

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS Address
FROM DataCleaning.dbo.Houses

ALTER TABLE DataCleaning.dbo.Houses
ADD PropertySplitAddress Nvarchar(255);

UPDATE DataCleaning.dbo.Houses
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE DataCleaning.dbo.Houses
ADD PropertySplitCity Nvarchar(255);

UPDATE DataCleaning.dbo.Houses
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

SELECT * 
FROM DataCleaning.dbo.Houses


-- Huomasin jälleen taas owneraddress sarakkeessa olevan katu, alue sekä kaupunki yhdessä sarakkeessa joten lisäsin uudet kolme saraketta OwnerSplitStreet, OwnerSplitArea, OwnerSplitCity.
-- I noticed again that the owneraddress column has street, area and city in one column, so I added three new columns OwnerSplitStreet, OwnerSplitArea, OwnerSplitCity.

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3) AS Street,
PARSENAME(REPLACE(OwnerAddress,',','.'), 2) AS Area,
PARSENAME(REPLACE(OwnerAddress,',','.'), 1) AS City
FROM DataCleaning.dbo.Houses

ALTER TABLE DataCleaning.dbo.Houses
ADD OwnerSplitStreet Nvarchar(255);

UPDATE DataCleaning.dbo.Houses
SET OwnerSplitStreet = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE DataCleaning.dbo.Houses
ADD OwnerSplitArea Nvarchar(255);

UPDATE DataCleaning.dbo.Houses
SET OwnerSplitArea = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE DataCleaning.dbo.Houses
ADD OwnerSplitCity Nvarchar(255);

UPDATE DataCleaning.dbo.Houses
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

SELECT * 
FROM DataCleaning.dbo.Houses


--
--

SELECT OwnerName
FROM DataCleaning.dbo.Houses

SELECT 
PARSENAME(REPLACE(OwnerName,',','.'), 1) AS 'First Name',
PARSENAME(REPLACE(OwnerName,',','.'), 2) AS  'Second Name'
FROM DataCleaning.dbo.Houses

ALTER TABLE DataCleaning.dbo.Houses
ADD OwnerFirstname Nvarchar(255);

ALTER TABLE DataCleaning.dbo.Houses
ADD OwnerSurname Nvarchar(255);


--
--

SELECT *
FROM DataCleaning.dbo.Houses

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant) AS 'Total Count'
FROM DataCleaning.dbo.Houses
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM DataCleaning.dbo.Houses

UPDATE DataCleaning.dbo.Houses
SET SoldAsVacant = 	
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END


-- Tällä näen kopion samasta arvosta. Niitä on yhteensä 104 kappaletta.
-- With this I see a copy of the same value. There are 104 of them in total.

--WITH RowCTE AS (
--SELECT *,
--	ROW_NUMBER() OVER(
--	PARTITION BY 
--		ParcelID,
--		PropertyAddress,
--		SalePrice,
--		SaleDate,
--		LegalReference
--		ORDER BY UniqueID) row_num
				
--FROM DataCleaning.dbo.Houses
--)
--SELECT *
--FROM RowCTE
--WHERE row_num > 1
--ORDER BY PropertyAddress


-- DELETE mahdollistaa kopioiden poiston mutta yleisesti ottaen tietokannasta ei koskaan kannata poistaa mitään mutta ajattelinpas kokeilla.
-- DELETE enables the deletion of copies, but in general, you should never delete anything from the database, but I thought I'd give it a try.

--WITH RowCTE AS (
--SELECT *,
--	ROW_NUMBER() OVER(
--	PARTITION BY 
--		ParcelID,
--		PropertyAddress,
--		SalePrice,
--		SaleDate,
--		LegalReference
--		ORDER BY UniqueID) row_num
				
--FROM DataCleaning.dbo.Houses
--)

--DELETE
--FROM RowCTE
--WHERE row_num > 1


