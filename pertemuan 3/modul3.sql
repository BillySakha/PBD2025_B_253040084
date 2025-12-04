--membuat database
CREATE DATABASE RetailStoreDB;
GO

--memakai database
USE RetailStoreDB;
GO

/*Schema adalah wadah atau folder khusus di
dalam sebuah database yang digunakan untuk 
mengelompokkan tabel, view, function, dan 
objek-objek lainnya*/

--membuat skema Production
CREATE SCHEMA Production;
GO

--membuat skema Sales
CREATE SCHEMA Sales;
GO

--membuat skema HumanResources
CREATE SCHEMA HumanResources;
GO

--membuat tabel 
CREATE TABLE Production.Product (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    ProductNumber NVARCHAR(50) NOT NULL,
    Color NVARCHAR(20) NULL,
    Size NVARCHAR(10) NULL,
    ListPrice DECIMAL(10,2) NOT NULL DEFAULT 0
);

--membuat tabel Sales.SalesOrderDetail
CREATE TABLE Sales.SalesOrderDetail (
    SalesOrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    SalesOrderID INT NOT NULL,
    ProductID INT NOT NULL,
    OrderQty INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,
    LineTotal AS (OrderQty * UnitPrice) PERSISTED,
    SpecialOfferID INT NULL,
    FOREIGN KEY (ProductID) REFERENCES Production.Product(ProductID)
);

--membuat tabel HumanResources.Employee
CREATE TABLE HumanResources.Employee (
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    JobTitle NVARCHAR(100) NOT NULL
);

--memasukkan data ke tabel Production.Product
INSERT INTO Production.Product (Name, ProductNumber, Color, Size, ListPrice)
VALUES
('Road Bike Pro', 'RB-001', 'Red', 'L', 3500),
('Road Bike Entry', 'RB-101', 'Red', 'M', 1200),
('Mountain Bike XL', 'MB-500', 'Blue', 'XL', 2100),
('City Bike Small', 'CB-020', 'Black', 'S', 900),
('Helmet Pro', 'HL-001', 'Red', NULL, 150),
('Helmet Basic', 'HL-050', 'Black', NULL, 80),
('Gloves Sport', 'GL-020', 'Blue', NULL, 50),
('Tire Road 700C', 'TR-700', NULL, NULL, 45),
('Water Bottle', 'WB-100', NULL, NULL, 20),
('Cycling Jersey', 'CJ-200', 'Red', 'M', 300),
('Cycling Jersey', 'CJ-300', 'Black', 'L', 320);

--memasukkan data ke tabel Sales.SalesOrderDetail 
INSERT INTO Sales.SalesOrderDetail (SalesOrderID, ProductID, OrderQty, UnitPrice, SpecialOfferID)
VALUES
(1, 1, 3, 3500, 1),
(1, 2, 1, 1200, 1),
(2, 1, 2, 3500, 2),
(3, 3, 4, 2100, 1),
(3, 4, 10, 900, 1),
(4, 5, 2, 150, 3),
(4, 6, 5, 80, 3),
(5, 7, 3, 50, 2),
(6, 8, 20, 45, 1),
(7, 9, 1, 20, 2),
(8, 10, 6, 300, 2),
(8, 11, 7, 320, 1),
(9, 1, 5, 3500, 1),   
(10, 3, 2, 2100, 1);  

-- memasukkan data ke tabel HumanResources.Employee
INSERT INTO HumanResources.Employee (JobTitle)
VALUES
('Sales Representative'),
('Sales Manager'),
('Technician'),
('Technician'),
('Senior Engineer'),
('Engineer');



/*
   Nama     : NAMA_LO
   NIM      : NIM_LO
   Kelas    : KELAS_LO
   Modul    : 3 - Retrieval Data (SELECT)
*/

-- PENTING: Sekarang kita pake RetailStoreDB (bukan AdventureWorks lagi)
USE RetailStoreDB;
GO

-- ===========================
-- BAGIAN 1: SELECT DASAR
-- ===========================

-- Latihan 1.1: Tampilkan Seluruh Data Produk
SELECT * FROM Production.Product;

-- Latihan 1.2: Tampilkan Kolom Spesifik
SELECT Name, ProductNumber, ListPrice
FROM Production.Product;

-- Latihan 1.3: Alias Kolom
SELECT Name AS [Nama Barang], ListPrice AS 'Harga Jual'
FROM Production.Product;

-- Latihan 1.4: Kalkulasi (Derived Column)
-- Menghitung estimasi harga jika naik 10%
SELECT Name, ListPrice, (ListPrice * 1.1) AS HargaBaru
FROM Production.Product;

-- Latihan 1.5: Menggabungkan String
SELECT Name + ' (' + ProductNumber + ')' AS ProdukLengkap
FROM Production.Product;
GO

-- ===========================
-- BAGIAN 2: FILTER DATA (WHERE)
-- ===========================

-- Latihan 2.1: Filter Kondisi Tunggal (Warna Merah)
SELECT Name, Color, ListPrice
FROM Production.Product
WHERE Color = 'Red';

-- Latihan 2.2: Filter Numerik (Harga diatas 1000)
SELECT Name, ListPrice
FROM Production.Product
WHERE ListPrice > 1000;

-- Latihan 2.3: Kondisi Jamak (AND) - Hitam DAN Mahal
SELECT Name, Color, ListPrice
FROM Production.Product
WHERE Color = 'Black' AND ListPrice > 500;

-- Latihan 2.4: Kondisi Jamak (IN) - Merah, Biru, atau Hitam
SELECT Name, Color
FROM Production.Product
WHERE Color IN ('Red', 'Blue', 'Black');

-- Latihan 2.5: Filter Pola String (LIKE) - Ada kata 'Road'
SELECT Name, ProductNumber
FROM Production.Product
WHERE Name LIKE '%Road%';
GO

-- ===========================
-- BAGIAN 3: GROUP BY
-- ===========================

-- Latihan 3.1: Hitung Total Baris Produk
SELECT COUNT(*) AS TotalProduk
FROM Production.Product;

-- Latihan 3.2: Pengelompokan Berdasarkan Warna
SELECT Color, COUNT(*) AS JumlahProduk
FROM Production.Product
GROUP BY Color;

-- Latihan 3.3: Agregasi Numerik (SalesOrderDetail)
-- Menghitung total terjual per produk
SELECT ProductID, SUM(OrderQty) AS TotalTerjual, AVG(UnitPrice) AS RataRataHarga
FROM Sales.SalesOrderDetail
GROUP BY ProductID;

-- Latihan 3.4: Grouping Lebih dari 1 Kolom (Warna & Ukuran)
SELECT Color, Size, COUNT(*) AS Jumlah
FROM Production.Product
GROUP BY Color, Size;
GO

-- ===========================
-- BAGIAN 4: HAVING
-- ===========================

-- Latihan 4.1: Filter Group Dasar (Warna yg jumlahnya > 2)
-- Catatan: Di data lo jumlahnya dikit, jadi gw ganti > 2 biar muncul hasilnya
SELECT Color, COUNT(*) AS Jumlah
FROM Production.Product
GROUP BY Color
HAVING COUNT(*) > 2;

-- Latihan 4.2: Kombinasi WHERE dan HAVING
SELECT Color, COUNT(*) AS Jumlah
FROM Production.Product
WHERE ListPrice > 500
GROUP BY Color
HAVING COUNT(*) > 1;

-- Latihan 4.3: Filter Total Penjualan (OrderQty > 10)
-- Disesuaikan dengan data sampel lo
SELECT ProductID, SUM(OrderQty) AS TotalQty
FROM Sales.SalesOrderDetail
GROUP BY ProductID
HAVING SUM(OrderQty) > 10;

-- Latihan 4.4: Filter Rata-Rata (SpecialOfferID)
SELECT SpecialOfferID, AVG(OrderQty) AS RataRataBeli
FROM Sales.SalesOrderDetail
GROUP BY SpecialOfferID
HAVING AVG(OrderQty) < 5;
GO

-- ===========================
-- BAGIAN 5: ADVANCED SELECT
-- ===========================

-- Latihan 5.1: DISTINCT (Jabatan Unik)
SELECT DISTINCT JobTitle
FROM HumanResources.Employee;

-- Latihan 5.2: ORDER BY (Urut Harga Termahal)
SELECT Name, ListPrice
FROM Production.Product
ORDER BY ListPrice DESC;

-- Latihan 5.3: TOP (3 Produk Termahal)
SELECT TOP 3 Name, ListPrice
FROM Production.Product
ORDER BY ListPrice DESC;

-- Latihan 5.4: OFFSET FETCH (Pagination - Halaman 2)
-- Lewati 5 data pertama, ambil 3 data berikutnya
SELECT Name, ListPrice
FROM Production.Product
ORDER BY ListPrice DESC
OFFSET 5 ROWS
FETCH NEXT 3 ROWS ONLY;

-- Latihan 5.5: Kompleksitas Penuh
-- 3 Warna dengan nilai stok tertinggi
SELECT TOP 3 Color, SUM(ListPrice) AS TotalNilaiStok
FROM Production.Product
WHERE ListPrice > 0
GROUP BY Color
ORDER BY TotalNilaiStok DESC;
GO

-- ===========================
-- TUGAS MANDIRI (RETAIL CHALLENGE)
-- ===========================

-- Mencari produk performa tinggi:
-- 1. Beli minimal 2 item
-- 2. Total pendapatan > 5000 (disesuaikan data lo)
-- 3. Top 10
SELECT TOP 10 
    ProductID, 
    SUM(LineTotal) AS TotalPendapatan
FROM Sales.SalesOrderDetail
WHERE OrderQty >= 2
GROUP BY ProductID
HAVING SUM(LineTotal) > 5000
ORDER BY TotalPendapatan DESC;
GO





