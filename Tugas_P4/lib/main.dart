import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ============ Model Data ============
class Catatan {
  final String? id;
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

  // Copy constructor untuk edit
  Catatan copyWith({
    String? id,
    String? judul,
    String? isi,
    String? kategori,
    String? email,
    DateTime? dibuatPada,
  }) {
    return Catatan(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      isi: isi ?? this.isi,
      kategori: kategori ?? this.kategori,
      email: email ?? this.email,
      dibuatPada: dibuatPada ?? this.dibuatPada,
    );
  }
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
          case '/tambah':
            return MaterialPageRoute(
              builder: (_) => const TambahCatatanPage(),
            );
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
  // Data state
  final List<Catatan> _semuaCatatan = [
    Catatan(
      id: '1',
      judul: 'Belajar Flutter',
      isi: 'Mempelajari Stateful Widget, Form, dan Navigation.',
      kategori: 'Kuliah',
      email: 'flutter@example.com',
      dibuatPada: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  String _filterKategori = 'Semua';
  final _kategoriOpsi = const ['Semua', 'Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

  // Filter catatan berdasarkan kategori (TUGAS MANDIRI #2)
  List<Catatan> get _catatanTerfilter {
    if (_filterKategori == 'Semua') return _semuaCatatan;
    return _semuaCatatan.where((c) => c.kategori == _filterKategori).toList();
  }

  Future<void> _bukaTambahCatatan() async {
    final hasil = await Navigator.pushNamed(context, '/tambah');

    if (hasil is Catatan) {
      setState(() {
        hasil.id == null
            ? _semuaCatatan.add(hasil.copyWith(id: DateTime.now().toString()))
            : null;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catatan "${hasil.judul}" ditambahkan'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _bukaEditCatatan(Catatan catatan) async {
    final hasil = await Navigator.pushNamed(context, '/edit', arguments: catatan);

    if (hasil is Catatan) {
      setState(() {
        final index = _semuaCatatan.indexWhere((c) => c.id == hasil.id);
        if (index >= 0) {
          _semuaCatatan[index] = hasil;
        }
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catatan "${hasil.judul}" diperbarui'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _hapusCatatan(String id) {
    setState(() {
      _semuaCatatan.removeWhere((c) => c.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Catatan dihapus'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Mahasiswa'),
        elevation: 2,
      ),
      body: Column(
        children: [
            // Filter Dropdown (TUGAS MANDIRI #2)
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
          // List Catatan
          Expanded(
            child: _catatanTerfilter.isEmpty
                ? _EmptyState(
                    message: _filterKategori == 'Semua'
                        ? 'Belum ada catatan'
                        : 'Tidak ada catatan dengan kategori "$_filterKategori"',
                  )
                : ListView.builder(
                    itemCount: _catatanTerfilter.length,
                    itemBuilder: (context, i) {
                      final c = _catatanTerfilter[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
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
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
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
                            Navigator.pushNamed(context, '/detail',
                                arguments: c);
                          },
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: const Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                                onTap: () => _bukaEditCatatan(c),
                              ),
                              PopupMenuItem(
                                child: const Row(
                                  children: [
                                    Icon(Icons.delete, size: 20,
                                        color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Hapus', style: TextStyle(
                                      color: Colors.red,
                                    )),
                                  ],
                                ),
                                onTap: () => _hapusCatatan(c.id!),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _bukaTambahCatatan,
        child: const Icon(Icons.add),
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
            onPressed: () => Navigator.pushNamed(context, '/tambah'),
            icon: const Icon(Icons.add),
            label: const Text('Tambah Catatan'),
          ),
        ],
      ),
    );
  }
}

// ============ Tambah/Edit Catatan Page ============
class TambahCatatanPage extends StatefulWidget {
  final Catatan? catatanEdit;

  const TambahCatatanPage({super.key, this.catatanEdit});

  @override
  State<TambahCatatanPage> createState() => _TambahCatatanPageState();
}

class _TambahCatatanPageState extends State<TambahCatatanPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _isiCtrl = TextEditingController();
  final _emailCtrl = TextEditingController(); // TUGAS MANDIRI #3

  String _kategori = 'Kuliah';
  final _kategoriOpsi = const ['Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    if (widget.catatanEdit != null) {
      // TUGAS MANDIRI #1: Edit Mode
      _judulCtrl.text = widget.catatanEdit!.judul;
      _isiCtrl.text = widget.catatanEdit!.isi;
      _kategori = widget.catatanEdit!.kategori;
      _emailCtrl.text = widget.catatanEdit!.email ?? '';
    }
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    final catatanBaru = Catatan(
      id: widget.catatanEdit?.id,
      judul: _judulCtrl.text.trim(),
      isi: _isiCtrl.text.trim(),
      kategori: _kategori,
      email: _emailCtrl.text.trim(),
      dibuatPada: widget.catatanEdit?.dibuatPada ?? DateTime.now(),
    );

    Navigator.pop(context, catatanBaru);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.catatanEdit != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Catatan' : 'Tambah Catatan'),
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

            // Email Field (TUGAS MANDIRI #3: Validasi Lanjutan)
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
              onPressed: _simpan,
              icon: const Icon(Icons.save),
              label: Text(isEdit ? 'Perbarui' : 'Simpan'),
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

            // Email jika ada (TUGAS MANDIRI #3)
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



