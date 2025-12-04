/*
   Nama     : Billy Barbar Sakha
   NIM      : 253040084
   Kelas    : B
   Modul    : 2 (DML)
*/

USE master;
GO

-- Reset Database biar bersih
IF DB_ID('TokoRetailDB') IS NOT NULL
BEGIN
    ALTER DATABASE TokoRetailDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE TokoRetailDB;
END
GO

CREATE DATABASE TokoRetailDB;
GO

USE TokoRetailDB;
GO

-- 1. Membuat Tabel-Tabel (DDL Persiapan)
CREATE TABLE KategoriProduk (
    KategoriID INT IDENTITY(1,1) PRIMARY KEY,
    NamaKategori VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Produk (
    ProdukID INT IDENTITY(1001, 1) PRIMARY KEY,
    SKU VARCHAR(20) NOT NULL UNIQUE,
    NamaProduk VARCHAR(150) NOT NULL,
    Harga DECIMAL(10, 2) NOT NULL,
    Stok INT NOT NULL,
    KategoriID INT NULL,
    CONSTRAINT CHK_HargaPositif CHECK (Harga >= 0),
    CONSTRAINT CHK_StokPositif CHECK (Stok >= 0),
    CONSTRAINT FK_Produk_Kategori FOREIGN KEY (KategoriID) REFERENCES KategoriProduk (KategoriID)
);

CREATE TABLE Pelanggan (
    PelangganID INT IDENTITY(1,1) PRIMARY KEY,
    NamaDepan VARCHAR(50) NOT NULL,
    NamaBelakang VARCHAR(50) NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    NoTelepon VARCHAR(20) NULL,
    TanggalDaftar DATE DEFAULT GETDATE()
);

CREATE TABLE PesananHeader (
    PesananID INT IDENTITY (50001, 1) PRIMARY KEY,
    PelangganID INT NOT NULL,
    TanggalPesanan DATETIME2 DEFAULT GETDATE(),
    StatusPesanan VARCHAR(20) NOT NULL,
    CONSTRAINT CHK_StatusPesanan CHECK (StatusPesanan IN ('Baru', 'Proses', 'Selesai', 'Batal')),
    CONSTRAINT FK_Pesanan_Pelanggan FOREIGN KEY (PelangganID) REFERENCES Pelanggan (PelangganID) ON DELETE NO ACTION
);

CREATE TABLE PesananDetail (
    PesananDetailID INT IDENTITY(1,1) PRIMARY KEY,
    PesananID INT NOT NULL,
    ProdukID INT NOT NULL,
    Jumlah INT NOT NULL,
    HargaSatuan DECIMAL(10, 2) NOT NULL,
    CONSTRAINT CHK_JumlahPositif CHECK (Jumlah > 0),
    CONSTRAINT FK_Detail_Header FOREIGN KEY (PesananID) REFERENCES PesananHeader(PesananID) ON DELETE CASCADE,
    CONSTRAINT FK_Detail_Produk FOREIGN KEY (ProdukID) REFERENCES Produk (ProdukID)
);
GO

-- Latihan 1: Insert Data Pelanggan & Kategori
INSERT INTO Pelanggan (NamaDepan, NamaBelakang, Email, NoTelepon)
VALUES 
('Budi', 'Santoso', 'budi.santoso@email.com', '081234567890'),
('Citra', 'Lestari', 'citra.lestari@email.com', NULL);

INSERT INTO KategoriProduk (NamaKategori)
VALUES ('Elektronik'), ('Pakaian'), ('Buku');
GO

-- Latihan 2: Insert Produk (Referensi ke Kategori)
INSERT INTO Produk (SKU, NamaProduk, Harga, Stok, KategoriID)
VALUES
('ELEC-001', 'Laptop Pro 14 inch', 15000000.00, 50, 1),
('PAK-001', 'Kaos Polos Putih', 75000.00, 200, 2),
('BUK-001', 'Dasar-Dasar SQL', 120000.00, 100, 3);
GO

-- Latihan 3: Cek Error Constraint (Uncomment jika ingin test)
-- INSERT INTO Pelanggan (NamaDepan, Email) VALUES ('Budi', 'budi.santoso@email.com'); -- Error Unique
-- INSERT INTO Produk (SKU, NamaProduk, Harga, Stok, KategoriID) VALUES ('XXX-001', 'Produk Aneh', 1000, 10, 99); -- Error FK

-- Latihan 4: Update No Telepon Citra
BEGIN TRAN
    UPDATE Pelanggan
    SET NoTelepon = '085566778899'
    WHERE PelangganID = 2;
COMMIT TRAN
GO

-- Latihan 5: Naikkan Harga Elektronik 10%
BEGIN TRAN
    UPDATE Produk
    SET Harga = Harga * 1.10
    WHERE KategoriID = 1;
COMMIT TRAN
GO

-- Latihan 6: Hapus Produk Buku
BEGIN TRAN
    DELETE FROM Produk
    WHERE SKU = 'BUK-001';
COMMIT TRAN
GO

-- Latihan 7: Simulasi Salah Update & Rollback
BEGIN TRAN
    -- Ceritanya salah update semua stok jadi 0
    UPDATE Produk SET Stok = 0;
    -- Batalkan perubahan
    ROLLBACK TRAN
GO

-- Latihan 8: Cek Foreign Key saat Delete
INSERT INTO PesananHeader (PelangganID, StatusPesanan) VALUES (1, 'Baru');

-- Ini bakal error kalau dijalankan (karena Budi sudah punya pesanan)
-- DELETE FROM Pelanggan WHERE PelangganID = 1; 
GO

-- Latihan 9: Insert Select (Arsip)
CREATE TABLE ProdukArsip (
    ProdukID INT PRIMARY KEY,
    SKU VARCHAR(20) NOT NULL,
    NamaProduk VARCHAR(150) NOT NULL,
    Harga DECIMAL(10, 2) NOT NULL,
    TanggalArsip DATE DEFAULT GETDATE()
);
GO

BEGIN TRAN
    -- Kosongkan stok Kaos dulu
    UPDATE Produk SET Stok = 0 WHERE SKU = 'PAK-001';

    -- Pindahkan ke Arsip
    INSERT INTO ProdukArsip (ProdukID, SKU, NamaProduk, Harga)
    SELECT ProdukID, SKU, NamaProduk, Harga
    FROM Produk
    WHERE Stok = 0;

    -- Hapus dari tabel utama
    DELETE FROM Produk WHERE Stok = 0;
COMMIT TRAN
GO

-- Cek hasil akhir
SELECT * FROM Produk;
SELECT * FROM ProdukArsip;