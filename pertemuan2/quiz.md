# Kebutuhan Proyek: Fitur Edit Profil & Unggah Pengalaman (Flutter)

Anda diminta untuk melanjutkan pengerjaan aplikasi dari **Modul 2 Tugas Mandiri** untuk memenuhi kriteria Quiz Praktikum Pemrograman Mobile 2026. Implementasikan fitur-fitur di bawah ini menggunakan framework Flutter.

---

## 1. Spesifikasi Dependensi & Teknis
* Tambahkan dependensi berikut ke dalam `pubspec.yaml` Anda:
    ```yaml
    dependencies:
      flutter:
        sdk: flutter
      image_picker: ^1.1.2
    ```
* Pastikan untuk melakukan `import` package `image_picker` pada file utama (`main.dart`) atau file terkait yang membutuhkan akses galeri/kamera.
* *Catatan Troubleshoot:* Jika gambar tidak ter-render atau terjadi eror setelah menambahkan dependensi, jalankan perintah `flutter pub get` di terminal, hentikan aplikasi yang sedang berjalan (`close running project`), lalu jalankan kembali (`run/debug`).

---

## 2. Fitur Utama: Halaman Edit Profil
Buatlah halaman baru untuk **Edit Profil** yang dapat diakses dengan menekan tombol **"Edit Profil"** (Floating Action Button / tombol ikon pensil) yang berada di halaman utama ("Profil Saya").

Halaman Edit Profil harus mencakup komponen dan fungsionalitas berikut:
* **AppBar:** Memiliki tombol kembali (`←`) dan judul "Edit Profil".
* **Mengubah Foto Profil:** * Menampilkan area/avatar foto profil saat ini.
    * Menyediakan tombol/opsi "Foto Profil dari Galeri" menggunakan `image_picker`.
    * Perubahan foto profil harus langsung **terbaca dan tampil di halaman utama** setelah disimpan.
* **Mengubah Informasi Profil (Minimal 3 Section):** Menyediakan form input text (TextFormField) untuk mengubah minimal 3 informasi yang ada di halaman utama. Pilihan section yang tersedia:
    * Nama Lengkap (Contoh default: *Rifs Ramadhani*)
    * Bio/Tentang (Contoh default: *Belajar Flutter!*)
    * Pendidikan (Contoh default: *Teknik Informatika - Semester 8*)
    * Lokasi (Contoh default: *Bandung, Jawa Barat*)
    * Kontak (Contoh default: *rifs@student.ac.id*)
    * Skills
* **Tombol Aksi:** Menyediakan tombol **"Simpan Perubahan"** untuk menerapkan data baru ke halaman utama.

---

## 3. Fitur Bonus (Opsional - Implementasikan untuk Nilai Tambah)

### A. Section Card Pengalaman di Halaman Utama
* Buatlah sebuah section baru bernama **"Pengalaman"** yang terletak di halaman utama.
* Posisinya berada di bawah section card **"Skills"**.
* Komponen di dalam Card Pengalaman meliputi:
    * Gambar Pengalaman
    * Judul Pengalaman
    * Deskripsi singkat Pengalaman

### B. Navigasi melalui Drawer (Menu Utama)
* Tambahkan item menu baru pada komponen Drawer dengan label **"Upload Pengalaman"**.
* Ketika item tersebut ditekan, arahkan (`Navigator.push`) pengguna ke halaman **"Upload Pengalaman"**.

### C. Halaman Upload / Edit Pengalaman
Buatlah halaman form baru bernama **"Upload Pengalaman"** yang berisi:
* **AppBar:** Judul "Upload Pengalaman" dan tombol kembali.
* **Input Data:**
    * Form Input untuk **Judul Pengalaman**.
    * Form Input untuk **Deskripsi Pengalaman**.
    * Area "Ketuk untuk pilih gambar" untuk mengunggah gambar pendukung menggunakan `image_picker`.
* **Tombol Aksi:** Menyediakan tombol **"Simpan Pengalaman"** untuk mengirim dan menampilkan data tersebut ke dalam list/card pengalaman di halaman utama.

---

## Kriteria Output Kode yang Diharapkan
1. Kode bersih, terstruktur, dan menggunakan *state management* yang sesuai (misal: `StatefulWidget` dasar atau *state management* yang sudah diajarkan di modul sebelumnya) agar perubahan data di halaman edit langsung merefleksikan halaman utama.
2. UI/UX konsisten menggunakan komponen dasar Material Design (seperti `Card`, `ListTile`, `TextField`, `FloatingActionButton`, dan `Drawer`).