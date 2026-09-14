-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 14 Sep 2026 pada 04.43
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `sistem_penyewaan_alat`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_alat`
--

CREATE TABLE `tb_alat` (
  `id_alat` int(11) NOT NULL,
  `id_kategori` int(11) NOT NULL,
  `kode_alat` varchar(20) NOT NULL,
  `nama_alat` varchar(100) NOT NULL,
  `stok_total` int(11) NOT NULL DEFAULT 0,
  `stok_tersedia` int(11) NOT NULL DEFAULT 0,
  `harga_sewa_per_hari` decimal(12,2) NOT NULL,
  `status` enum('aktif','nonaktif') NOT NULL DEFAULT 'aktif'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_alat`
--

INSERT INTO `tb_alat` (`id_alat`, `id_kategori`, `kode_alat`, `nama_alat`, `stok_total`, `stok_tersedia`, `harga_sewa_per_hari`, `status`) VALUES
(1, 1, 'TND-001', 'Tenda Dome 4 Orang', 10, 9, 75000.00, 'aktif'),
(2, 1, 'SLB-001', 'Sleeping Bag', 20, 19, 25000.00, 'aktif'),
(3, 2, 'CNO-001', 'Canoe 2 Orang', 5, 4, 150000.00, 'aktif'),
(4, 3, 'PWB-001', 'Power Bank 20000mAh', 15, 14, 20000.00, 'aktif');

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_detail_sewa`
--

CREATE TABLE `tb_detail_sewa` (
  `id_detail` int(11) NOT NULL,
  `id_transaksi` int(11) NOT NULL,
  `id_alat` int(11) NOT NULL,
  `jumlah` int(11) NOT NULL,
  `harga_satuan` decimal(12,2) NOT NULL,
  `subtotal` decimal(12,2) GENERATED ALWAYS AS (`jumlah` * `harga_satuan`) STORED
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_detail_sewa`
--

INSERT INTO `tb_detail_sewa` (`id_detail`, `id_transaksi`, `id_alat`, `jumlah`, `harga_satuan`) VALUES
(1, 1, 3, 1, 150000.00),
(2, 1, 4, 1, 20000.00),
(3, 1, 2, 1, 25000.00),
(4, 1, 1, 1, 75000.00);

--
-- Trigger `tb_detail_sewa`
--
DELIMITER $$
CREATE TRIGGER `trg_kurangi_stok` AFTER INSERT ON `tb_detail_sewa` FOR EACH ROW BEGIN
  UPDATE tb_alat
  SET stok_tersedia = stok_tersedia - NEW.jumlah
  WHERE id_alat = NEW.id_alat;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_kategori_alat`
--

CREATE TABLE `tb_kategori_alat` (
  `id_kategori` int(11) NOT NULL,
  `nama_kategori` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_kategori_alat`
--

INSERT INTO `tb_kategori_alat` (`id_kategori`, `nama_kategori`) VALUES
(1, 'Perkemahan'),
(2, 'Alat Air'),
(3, 'Elektronik');

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_pelanggan`
--

CREATE TABLE `tb_pelanggan` (
  `id_pelanggan` int(11) NOT NULL,
  `nama_pelanggan` varchar(100) NOT NULL,
  `no_identitas` varchar(30) NOT NULL,
  `no_hp` varchar(20) NOT NULL,
  `alamat` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_pelanggan`
--

INSERT INTO `tb_pelanggan` (`id_pelanggan`, `nama_pelanggan`, `no_identitas`, `no_hp`, `alamat`, `created_at`) VALUES
(1, 'Andi Saputra', '3201010101010001', '081234567890', 'Jl. Merdeka No. 1, Bogor', '2026-09-14 01:49:58');

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_pengembalian`
--

CREATE TABLE `tb_pengembalian` (
  `id_pengembalian` int(11) NOT NULL,
  `id_transaksi` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `tanggal_kembali_aktual` date NOT NULL,
  `jumlah_hari_terlambat` int(11) NOT NULL DEFAULT 0,
  `denda` decimal(12,2) NOT NULL DEFAULT 0.00,
  `total_pembayaran` decimal(12,2) NOT NULL,
  `catatan` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Trigger `tb_pengembalian`
--
DELIMITER $$
CREATE TRIGGER `trg_kembalikan_stok` AFTER INSERT ON `tb_pengembalian` FOR EACH ROW BEGIN
  UPDATE tb_alat a
  JOIN tb_detail_sewa d ON d.id_alat = a.id_alat
  SET a.stok_tersedia = a.stok_tersedia + d.jumlah
  WHERE d.id_transaksi = NEW.id_transaksi;

  UPDATE tb_transaksi_sewa
  SET status = 'selesai'
  WHERE id_transaksi = NEW.id_transaksi;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_role`
--

CREATE TABLE `tb_role` (
  `id_role` int(11) NOT NULL,
  `nama_role` varchar(50) NOT NULL,
  `deskripsi` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_role`
--

INSERT INTO `tb_role` (`id_role`, `nama_role`, `deskripsi`) VALUES
(1, 'admin', 'Akses penuh: kelola user, alat, laporan'),
(2, 'petugas', 'Akses transaksi harian: sewa & pengembalian');

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_transaksi_sewa`
--

CREATE TABLE `tb_transaksi_sewa` (
  `id_transaksi` int(11) NOT NULL,
  `kode_transaksi` varchar(20) NOT NULL,
  `id_pelanggan` int(11) NOT NULL,
  `id_user` int(11) NOT NULL,
  `tanggal_sewa` date NOT NULL,
  `tanggal_rencana_kembali` date NOT NULL,
  `status` enum('berjalan','selesai','terlambat') NOT NULL DEFAULT 'berjalan',
  `total_biaya` decimal(12,2) NOT NULL DEFAULT 0.00,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_transaksi_sewa`
--

INSERT INTO `tb_transaksi_sewa` (`id_transaksi`, `kode_transaksi`, `id_pelanggan`, `id_user`, `tanggal_sewa`, `tanggal_rencana_kembali`, `status`, `total_biaya`, `created_at`) VALUES
(1, 'TRX-20260914-3C52', 1, 1, '2026-09-14', '2026-09-15', 'berjalan', 270000.00, '2026-09-14 01:51:21');

-- --------------------------------------------------------

--
-- Struktur dari tabel `tb_users`
--

CREATE TABLE `tb_users` (
  `id_user` int(11) NOT NULL,
  `id_role` int(11) NOT NULL,
  `username` varchar(50) NOT NULL,
  `password` varchar(255) NOT NULL,
  `nama_lengkap` varchar(100) NOT NULL,
  `status_aktif` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `tb_users`
--

INSERT INTO `tb_users` (`id_user`, `id_role`, `username`, `password`, `nama_lengkap`, `status_aktif`, `created_at`) VALUES
(1, 1, 'admin', '$2b$10$jYr7Js73NIRFALOUETZhfeDpOiCYbR.0aFRH2GH980tq3W4L497Ta', 'Administrator', 1, '2026-09-14 01:49:58'),
(2, 2, 'petugas1', '$2b$10$jYr7Js73NIRFALOUETZhfeDpOiCYbR.0aFRH2GH980tq3W4L497Ta', 'Budi Petugas', 1, '2026-09-14 01:49:58');

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `tb_alat`
--
ALTER TABLE `tb_alat`
  ADD PRIMARY KEY (`id_alat`),
  ADD UNIQUE KEY `kode_alat` (`kode_alat`),
  ADD KEY `id_kategori` (`id_kategori`);

--
-- Indeks untuk tabel `tb_detail_sewa`
--
ALTER TABLE `tb_detail_sewa`
  ADD PRIMARY KEY (`id_detail`),
  ADD KEY `id_transaksi` (`id_transaksi`),
  ADD KEY `id_alat` (`id_alat`);

--
-- Indeks untuk tabel `tb_kategori_alat`
--
ALTER TABLE `tb_kategori_alat`
  ADD PRIMARY KEY (`id_kategori`);

--
-- Indeks untuk tabel `tb_pelanggan`
--
ALTER TABLE `tb_pelanggan`
  ADD PRIMARY KEY (`id_pelanggan`),
  ADD UNIQUE KEY `no_identitas` (`no_identitas`);

--
-- Indeks untuk tabel `tb_pengembalian`
--
ALTER TABLE `tb_pengembalian`
  ADD PRIMARY KEY (`id_pengembalian`),
  ADD KEY `id_transaksi` (`id_transaksi`),
  ADD KEY `id_user` (`id_user`);

--
-- Indeks untuk tabel `tb_role`
--
ALTER TABLE `tb_role`
  ADD PRIMARY KEY (`id_role`),
  ADD UNIQUE KEY `nama_role` (`nama_role`);

--
-- Indeks untuk tabel `tb_transaksi_sewa`
--
ALTER TABLE `tb_transaksi_sewa`
  ADD PRIMARY KEY (`id_transaksi`),
  ADD UNIQUE KEY `kode_transaksi` (`kode_transaksi`),
  ADD KEY `id_pelanggan` (`id_pelanggan`),
  ADD KEY `id_user` (`id_user`);

--
-- Indeks untuk tabel `tb_users`
--
ALTER TABLE `tb_users`
  ADD PRIMARY KEY (`id_user`),
  ADD UNIQUE KEY `username` (`username`),
  ADD KEY `id_role` (`id_role`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `tb_alat`
--
ALTER TABLE `tb_alat`
  MODIFY `id_alat` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT untuk tabel `tb_detail_sewa`
--
ALTER TABLE `tb_detail_sewa`
  MODIFY `id_detail` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT untuk tabel `tb_kategori_alat`
--
ALTER TABLE `tb_kategori_alat`
  MODIFY `id_kategori` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `tb_pelanggan`
--
ALTER TABLE `tb_pelanggan`
  MODIFY `id_pelanggan` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT untuk tabel `tb_pengembalian`
--
ALTER TABLE `tb_pengembalian`
  MODIFY `id_pengembalian` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `tb_role`
--
ALTER TABLE `tb_role`
  MODIFY `id_role` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT untuk tabel `tb_transaksi_sewa`
--
ALTER TABLE `tb_transaksi_sewa`
  MODIFY `id_transaksi` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT untuk tabel `tb_users`
--
ALTER TABLE `tb_users`
  MODIFY `id_user` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `tb_alat`
--
ALTER TABLE `tb_alat`
  ADD CONSTRAINT `tb_alat_ibfk_1` FOREIGN KEY (`id_kategori`) REFERENCES `tb_kategori_alat` (`id_kategori`);

--
-- Ketidakleluasaan untuk tabel `tb_detail_sewa`
--
ALTER TABLE `tb_detail_sewa`
  ADD CONSTRAINT `tb_detail_sewa_ibfk_1` FOREIGN KEY (`id_transaksi`) REFERENCES `tb_transaksi_sewa` (`id_transaksi`) ON DELETE CASCADE,
  ADD CONSTRAINT `tb_detail_sewa_ibfk_2` FOREIGN KEY (`id_alat`) REFERENCES `tb_alat` (`id_alat`);

--
-- Ketidakleluasaan untuk tabel `tb_pengembalian`
--
ALTER TABLE `tb_pengembalian`
  ADD CONSTRAINT `tb_pengembalian_ibfk_1` FOREIGN KEY (`id_transaksi`) REFERENCES `tb_transaksi_sewa` (`id_transaksi`),
  ADD CONSTRAINT `tb_pengembalian_ibfk_2` FOREIGN KEY (`id_user`) REFERENCES `tb_users` (`id_user`);

--
-- Ketidakleluasaan untuk tabel `tb_transaksi_sewa`
--
ALTER TABLE `tb_transaksi_sewa`
  ADD CONSTRAINT `tb_transaksi_sewa_ibfk_1` FOREIGN KEY (`id_pelanggan`) REFERENCES `tb_pelanggan` (`id_pelanggan`),
  ADD CONSTRAINT `tb_transaksi_sewa_ibfk_2` FOREIGN KEY (`id_user`) REFERENCES `tb_users` (`id_user`);

--
-- Ketidakleluasaan untuk tabel `tb_users`
--
ALTER TABLE `tb_users`
  ADD CONSTRAINT `tb_users_ibfk_1` FOREIGN KEY (`id_role`) REFERENCES `tb_role` (`id_role`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
