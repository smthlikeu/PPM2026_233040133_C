import 'package:flutter/material.dart';

import 'db_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

// ============ Model Data ============
class Catatan {
  final int? id;
  final String judul;
  final String isi;
  final String kategori;
  final String? email;
  final DateTime dibuatPada;

  Catatan({
    this.id,
    required this.judul,
    required this.isi,
    required this.kategori,
    this.email,
    required this.dibuatPada,
  });

  // === Dart object → row Map ===
  Map<String, Object?> toMap() => {
    if (id != null) 'id': id,
    'judul': judul,
    'isi': isi,
    'kategori': kategori,
    'email': email,
    'dibuat_pada': dibuatPada.millisecondsSinceEpoch,
  };

  // === Row Map → Dart object ===
  static Catatan fromMap(Map<String, Object?> m) => Catatan(
    id: m['id'] as int?,
    judul: m['judul'] as String,
    isi: m['isi'] as String,
    kategori: m['kategori'] as String,
    email: m['email'] as String?,
    dibuatPada: DateTime.fromMillisecondsSinceEpoch(m['dibuat_pada'] as int),
  );

  // Helper untuk Edit — copy dengan beberapa field diganti.
  Catatan copyWith({
    String? judul,
    String? isi,
    String? kategori,
    String? email,
  }) =>
      Catatan(
        id: id,
        judul: judul ?? this.judul,
        isi: isi ?? this.isi,
        kategori: kategori ?? this.kategori,
        email: email ?? this.email,
        dibuatPada: dibuatPada,
      );
}

// ============ Main App ============
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
      },
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/form':
            final arg = settings.arguments;
            return MaterialPageRoute(
              builder: (_) => CatatanFormPage(initial: arg as Catatan?),
            );
          case '/detail':
            final c = settings.arguments as Catatan;
            return MaterialPageRoute(
              builder: (_) => DetailCatatanPage(catatan: c),
            );
        }
        return null;
      },
    );
  }
}

// ============ Helper Functions ============
String _formatTanggal(DateTime tanggal) {
  final bulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];
  return '${tanggal.day} ${bulan[tanggal.month - 1]} ${tanggal.year} ${tanggal.hour.toString().padLeft(2, '0')}:${tanggal.minute.toString().padLeft(2, '0')}';
}

bool _isValidEmail(String email) {
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  return emailRegex.hasMatch(email);
}

// ============ Home Page ============
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Catatan>> _futureCatatan;
  String _filterKategori = 'Semua';
  final _kategoriOpsi = const ['Semua', 'Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    _muatUlang();
  }

  void _muatUlang() {
    setState(() {
      _futureCatatan = DbHelper.instance.getAll();
    });
  }

  Future<void> _bukaForm({Catatan? initial}) async {
    await Navigator.pushNamed(context, '/form', arguments: initial);
    _muatUlang();   // apapun hasilnya (insert/update/batal), reload dari DB
  }

  Future<void> _konfirmasiHapus(Catatan c) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus catatan?'),
        content: Text('"${c.judul}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (yakin == true) {
      await DbHelper.instance.delete(c.id!);
      if (!mounted) return;
      _muatUlang();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${c.judul}" dihapus')),
      );
    }
  }

  List<Catatan> _filterCatatan(List<Catatan> semua) {
    if (_filterKategori == 'Semua') return semua;
    return semua.where((c) => c.kategori == _filterKategori).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Mahasiswa'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _muatUlang,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Dropdown
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              initialValue: _filterKategori,
              decoration: InputDecoration(
                labelText: 'Filter Kategori',
                prefixIcon: const Icon(Icons.filter_list),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: _kategoriOpsi
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (v) => setState(() => _filterKategori = v!),
            ),
          ),
          // List Catatan dengan FutureBuilder
          Expanded(
            child: FutureBuilder<List<Catatan>>(
              future: _futureCatatan,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final data = snapshot.data ?? const [];
                final filtered = _filterCatatan(data);
                if (filtered.isEmpty) {
                  return _EmptyState(
                    message: _filterKategori == 'Semua'
                        ? 'Belum ada catatan'
                        : 'Tidak ada catatan dengan kategori "$_filterKategori"',
                  );
                }
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder: (context, i) => _itemCatatan(filtered[i]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bukaForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }

  Widget _itemCatatan(Catatan c) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(
          c.judul,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text(c.kategori),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTanggal(c.dibuatPada),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          Navigator.pushNamed(context, '/detail', arguments: c);
        },
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _bukaForm(initial: c),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _konfirmasiHapus(c),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ Empty State Widget ============
class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/form'),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Catatan'),
          ),
        ],
      ),
    );
  }
}

// ============ Catatan Form Page (CREATE + EDIT) ============
class CatatanFormPage extends StatefulWidget {
  final Catatan? initial;
  const CatatanFormPage({super.key, this.initial});

  @override
  State<CatatanFormPage> createState() => _CatatanFormPageState();
}

class _CatatanFormPageState extends State<CatatanFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judulCtrl;
  late final TextEditingController _isiCtrl;
  late final TextEditingController _emailCtrl;
  late String _kategori;
  final _kategoriOpsi = const ['Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

  bool get _isEdit => widget.initial != null;
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill kalau edit. Kalau create, string kosong.
    _judulCtrl = TextEditingController(text: widget.initial?.judul ?? '');
    _isiCtrl = TextEditingController(text: widget.initial?.isi ?? '');
    _emailCtrl = TextEditingController(text: widget.initial?.email ?? '');
    _kategori = widget.initial?.kategori ?? 'Kuliah';
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _menyimpan = true);
    try {
      if (_isEdit) {
        final updated = widget.initial!.copyWith(
          judul: _judulCtrl.text.trim(),
          isi: _isiCtrl.text.trim(),
          kategori: _kategori,
          email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        );
        await DbHelper.instance.update(updated);
      } else {
        final baru = Catatan(
          judul: _judulCtrl.text.trim(),
          isi: _isiCtrl.text.trim(),
          kategori: _kategori,
          email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
          dibuatPada: DateTime.now(),
        );
        await DbHelper.instance.insert(baru);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEdit ? 'Catatan diperbarui' : 'Catatan ditambahkan'),
      ));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _menyimpan = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Catatan' : 'Tambah Catatan'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Judul Field
            TextFormField(
              controller: _judulCtrl,
              decoration: InputDecoration(
                labelText: 'Judul',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Judul wajib diisi';
                if (v.trim().length < 3) return 'Minimal 3 karakter';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Kategori Dropdown
            DropdownButtonFormField<String>(
              initialValue: _kategori,
              decoration: InputDecoration(
                labelText: 'Kategori',
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: _kategoriOpsi
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (v) => setState(() => _kategori = v!),
            ),
            const SizedBox(height: 16),

            // Isi Field
            TextFormField(
              controller: _isiCtrl,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Isi',
                prefixIcon: const Icon(Icons.notes),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                alignLabelWithHint: true,
              ),
              validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Isi wajib diisi' : null,
            ),
            const SizedBox(height: 16),

            // Email Field
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email Pengirim',
                hintText: 'contoh@email.com',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              validator: (v) {
                if (v != null && v.trim().isNotEmpty) {
                  if (!_isValidEmail(v.trim())) {
                    return 'Format email tidak valid (cth: user@domain.com)';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Tombol Simpan
            FilledButton.icon(
              onPressed: _menyimpan ? null : _simpan,
              icon: _menyimpan
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.save),
              label: Text(_isEdit ? 'Perbarui' : 'Simpan'),
            ),
            const SizedBox(height: 12),

            // Tombol Batal
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
              label: const Text('Batal'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============ Detail Catatan Page ============
class DetailCatatanPage extends StatelessWidget {
  final Catatan catatan;

  const DetailCatatanPage({super.key, required this.catatan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.pushNamed(context, '/form', arguments: catatan);
              if (context.mounted) Navigator.pop(context); // tutup detail juga
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul
            Text(
              catatan.judul,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 12),

            // Metadata Row
            Row(
              children: [
                Chip(
                  label: Text(catatan.kategori),
                  backgroundColor: Colors.indigo[100],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _formatTanggal(catatan.dibuatPada),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),

            // Email jika ada
            if (catatan.email != null && catatan.email!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.email, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    catatan.email!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],

            const Divider(height: 32),

            // Isi Catatan
            Text(
              'Isi Catatan:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              catatan.isi,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Kembali
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali ke Daftar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


