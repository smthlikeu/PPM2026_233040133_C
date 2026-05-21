# Jawaban Pertanyaan Refleksi - Modul Pertemuan 3

## 1. Apa beda StatelessWidget dan StatefulWidget? Sebutkan satu contoh konkret kapan masing-masing dipakai.

**Perbedaan:**

| Aspek | StatelessWidget | StatefulWidget |
|-------|-----------------|-----------------|
| **State Internal** | Tidak memiliki state | Memiliki state yang bisa berubah |
| **Rebuild** | Hanya saat parent rebuild | Bisa rebuild via `setState()` |
| **Lifecycle** | Hanya `build()` | `initState()`, `build()`, `dispose()` |
| **Performa** | Lebih ringan | Lebih berat |
| **Immutable** | Immutable (final fields) | Mutable (state bisa berubah) |

**Contoh Konkret:**

- **StatelessWidget**: `DetailCatatanPage` — menampilkan data statis dari parameter constructor, tidak perlu perubahan selama halaman terbuka
- **StatefulWidget**: `HomePage` — daftar catatan bisa berubah (tambah, edit, hapus, filter), UI perlu di-update dengan `setState()`

---

## 2. Mengapa kita harus memanggil setState() saat mengubah data? Apa yang terjadi kalau lupa?

**Alasan memanggil setState():**
- `setState()` memberi tahu Flutter bahwa data telah berubah
- Flutter kemudian me-rebuild widget tersebut untuk menampilkan UI terbaru
- Tanpa `setState()`, perubahan data internal tidak akan tercermin di UI

**Jika lupa setState():**
```dart
// ❌ SALAH - Data berubah tapi UI tidak refresh
_catatan.add(catatanBaru);

// ✅ BENAR - Data berubah dan UI refresh
setState(() {
  _catatan.add(catatanBaru);
});
```

**Contoh dari kode:**
```dart
void _hapusCatatan(String id) {
  setState(() {
    _semuaCatatan.removeWhere((c) => c.id == id);  // ← setState wrapper
  });
}
```

---

## 3. Apa fungsi GlobalKey<FormState>? Mengapa tidak cukup TextEditingController saja?

**Fungsi GlobalKey<FormState>:**
- `GlobalKey<FormState>` adalah "remote control" untuk Form
- Digunakan memanggil method penting:
  - `.validate()` — trigger semua validator di Form
  - `.save()` — simpan nilai dari field (optional)
  - `.reset()` — reset semua field ke nilai awal

**Mengapa TextEditingController tidak cukup:**
```dart
// ❌ Dengan controller saja, tidak bisa validate
_judulCtrl.text;  // Bisa baca, tapi tidak bisa trigger validasi

// ✅ Dengan Form + GlobalKey, bisa validate & handle error
if (!_formKey.currentState!.validate()) {
  // Validasi gagal, error message tampil di bawah field
  return;
}
```

**Perbedaan fungsi:**
- **TextEditingController**: untuk membaca/menulis nilai TextField
- **GlobalKey<FormState>**: untuk mengontrol Form (validate, save, reset)

**Implementasi di kode:**
```dart
final _formKey = GlobalKey<FormState>();

void _simpan() {
  if (!_formKey.currentState!.validate()) return; // ← Gunakan formKey
  // ... lanjut proses simpan
}
```

---

## 4. Mengapa TextEditingController perlu di-dispose()?

**Alasan:**
- `TextEditingController` adalah object yang mengalokasikan resource (listener, memory, dll)
- Jika tidak di-dispose, resource tersebut akan terus menempati memory
- Bisa menyebabkan **memory leak** saat widget di-destroy dan recreate berkali-kali

**Lifecycle Resource:**
```dart
class _TambahCatatanPageState extends State<TambahCatatanPage> {
  final _judulCtrl = TextEditingController();  // ← Allocate resource
  
  @override
  void dispose() {
    _judulCtrl.dispose();  // ← Free resource, PENTING!
    super.dispose();
  }
}
```

**Analogi:**
- Seperti membuka file → harus ditutup
- Seperti membuka database connection → harus di-close
- Jika tidak, file handle / connection akan "bocor"

**Best Practice:**
```dart
// Untuk setiap controller yang dibuat, harus di-dispose
final _judulCtrl = TextEditingController();
final _isiCtrl = TextEditingController();
final _emailCtrl = TextEditingController();

@override
void dispose() {
  _judulCtrl.dispose();
  _isiCtrl.dispose();
  _emailCtrl.dispose();
  super.dispose();
}
```

---

## 5. Apa beda Navigator.push dengan Navigator.pushNamed? Kapan pakai yang mana?

**Perbedaan:**

| Aspek | Navigator.push | Navigator.pushNamed |
|-------|-----------------|---------------------|
| **Syntax** | `Navigator.push(context, MaterialPageRoute(...))` | `Navigator.pushNamed(context, '/detail')` |
| **Setup** | Inline, tidak perlu setup di awal | Harus daftarkan di `routes` atau `onGenerateRoute` |
| **Readability** | Sulit dilacak kalau banyak | Mudah dilacak, seperti URL |
| **Maintenance** | Ribet untuk project besar | Rapi untuk project besar |

**Kapan pakai:**

- **push**: untuk app kecil / prototyping cepat, atau saat route sangat sederhana
  ```dart
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => const DetailPage(),
  ));
  ```

- **pushNamed**: untuk app medium/besar dengan banyak route, lebih terstruktur
  ```dart
  // Setup di awal (MyApp)
  onGenerateRoute: (settings) {
    switch (settings.name) {
      case '/detail': return MaterialPageRoute(...);
    }
  }
  
  // Panggil dengan pushNamed
  Navigator.pushNamed(context, '/detail');
  ```

**Implementasi di kode (tugas pertemuan 3):**
```dart
// Setup named routes di MyApp
onGenerateRoute: (settings) {
  switch (settings.name) {
    case '/tambah':
      return MaterialPageRoute(builder: (_) => const TambahCatatanPage());
    case '/edit':
      final catatan = settings.arguments as Catatan;
      return MaterialPageRoute(
        builder: (_) => TambahCatatanPage(catatanEdit: catatan),
      );
    case '/detail':
      final catatan = settings.arguments as Catatan;
      return MaterialPageRoute(
        builder: (_) => DetailCatatanPage(catatan: catatan),
      );
  }
}

// Gunakan pushNamed di berbagai tempat
Navigator.pushNamed(context, '/detail', arguments: catatan);
```

---

## 6. Bagaimana cara mengirim data balik dari halaman B ke halaman A?

**Teknik: Pop dengan value**

**Step 1: Halaman B return data saat pop**
```dart
// TambahCatatanPage
void _simpan() {
  // ... create catatan baru
  Navigator.pop(context, catatanBaru);  // ← Kirim data balik
}
```

**Step 2: Halaman A tangkap dengan await**
```dart
// HomePage
Future<void> _bukaTambahCatatan() async {
  final hasil = await Navigator.pushNamed(context, '/tambah');  // ← Await!
  
  if (hasil is Catatan) {
    setState(() => _semuaCatatan.add(hasil));  // ← Data diterima
  }
}
```

**Alur:**
```
HomePage
  └─→ Navigator.pushNamed('/tambah')
      │   [ditunggu dengan await]
      │
      └─→ TambahCatatanPage
          └─→ User isi form
          └─→ Tap Simpan
          └─→ Navigator.pop(context, catatanBaru)
              │   [return ke HomePage]
              │
              └─→ hasil = Catatan(...)
              └─→ setState() update list
              └─→ UI refresh
```

**Implementasi di kode:**
```dart
// HomePage
Future<void> _bukaTambahCatatan() async {
  final hasil = await Navigator.pushNamed(context, '/tambah');
  if (hasil is Catatan) {
    setState(() {
      _semuaCatatan.add(hasil.copyWith(id: DateTime.now().toString()));
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Catatan "${hasil.judul}" ditambahkan')),
    );
  }
}

// TambahCatatanPage
void _simpan() {
  if (!_formKey.currentState!.validate()) return;
  final catatanBaru = Catatan(...);
  Navigator.pop(context, catatanBaru);
}
```

---

## 7. Mengapa kita perlu cek if (!mounted) return; setelah await?

**Alasan:**

Setelah `await Navigator.pushNamed()` selesai (user kembali ke halaman A), ada kemungkinan:
1. Halaman A sudah di-dispose (user navigasi ke halaman lain saat form masih terbuka)
2. Widget sudah hilang dari widget tree
3. Context tidak lagi valid

Jika tetap menggunakan `context` tanpa cek, akan error:
```
PlatformException: MissingPluginException: No implementation found 
for method showSnackBar on channel...
```

**Solusi: Cek flag `mounted`**
```dart
Future<void> _bukaTambahCatatan() async {
  final hasil = await Navigator.pushNamed(context, '/tambah');
  
  if (hasil is Catatan) {
    setState(() => _semuaCatatan.add(hasil));
  }

  // Cek apakah widget masih hidup sebelum pakai context
  if (!mounted) return;
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Catatan "${hasil.judul}" ditambahkan')),
  );
}
```

**Penjelasan `mounted`:**
- `mounted = true` → widget masih di widget tree, `context` valid
- `mounted = false` → widget sudah di-dispose, `context` tidak valid
- Otomatis diatur oleh Flutter saat `dispose()` dipanggil

**Best Practice:**
```dart
// Setiap kali pakai context setelah await, cek mounted dulu
if (!mounted) return;
ScaffoldMessenger.of(context).showSnackBar(...);
```

---

## Summary Jawaban Refleksi

| No | Pertanyaan | Jawaban Singkat |
|----|------------|-----------------|
| 1 | Beda Stateless vs Stateful | Stateless = immutable / display only, Stateful = mutable / data bisa berubah |
| 2 | Mengapa setState() | Agar Flutter tahu rebuild widget, tanpa itu UI tidak update |
| 3 | Fungsi GlobalKey<FormState> | Control Form (validate, save, reset), tidak hanya baca nilai |
| 4 | Mengapa dispose controller | Agar tidak memory leak, bebaskan resource saat widget di-destroy |
| 5 | Beda push vs pushNamed | push = inline cepat, pushNamed = terstruktur untuk app besar |
| 6 | Kirim data B → A | Gunakan `Navigator.pop(context, value)` + `await` di A |
| 7 | Cek mounted | Agar context valid, widget tidak di-dispose, tidak error |

---

## Implementasi di Tugas Pertemuan 3

Semua konsep di atas sudah diimplementasikan di project `Tugas_P4`:

✅ StatefulWidget di HomePage dan TambahCatatanPage  
✅ setState() untuk update list saat tambah/edit/hapus/filter  
✅ Form + GlobalKey<FormState> dengan validator lengkap  
✅ TextEditingController dengan dispose() di setiap controller  
✅ Named routes di MyApp.onGenerateRoute  
✅ Passing data via arguments (push) dan pop (return)  
✅ Await + mounted check di HomePage._bukaTambahCatatan()  

**Semua 3 tugas mandiri juga sudah implemented:**
1. ✅ Edit Catatan
2. ✅ Filter Kategori
3. ✅ Validasi Email Lanjutan

