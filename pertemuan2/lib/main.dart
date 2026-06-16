import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart' show kIsWeb;

// ==========================================
// DATA MODELS
// ==========================================

class ProfileData {
  String name;
  String bio;
  String education;
  String contact;
  String? imagePath;

  ProfileData({
    required this.name,
    required this.bio,
    required this.education,
    required this.contact,
    this.imagePath,
  });
}

class ExperienceData {
  String title;
  String description;
  String? imagePath;

  ExperienceData({
    required this.title,
    required this.description,
    this.imagePath,
  });
}

// ==========================================
// THEME & COLOR PALETTE
// ==========================================

const _bg1 = Color(0xFF0A0E1A);
const _bg2 = Color(0xFF0D1525);
const _accent = Color(0xFF4F8EF7);
const _accentSoft = Color(0xFF7DAFFF);
const _glass = Color(0x1AFFFFFF);
const _glassBorder = Color(0x33FFFFFF);
const _textPrimary = Color(0xFFEAF0FF);
const _textSecondary = Color(0xFF7A8FAD);
const _chipBg = Color(0xFF1E2D4A);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: _bg1,
        colorScheme: const ColorScheme.dark(
          primary: _accent,
          surface: _bg2,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: _textPrimary,
          titleTextStyle: TextStyle(
            color: _textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        drawerTheme: const DrawerThemeData(
          backgroundColor: Color(0xFF0D1525),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0D1525),
          selectedItemColor: _accent,
          unselectedItemColor: _textSecondary,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _accent,
          foregroundColor: Colors.white,
        ),
        cardTheme: const CardThemeData(
          color: Colors.transparent,
          elevation: 0,
        ),
      ),
      home: const ProfilePage(),
    );
  }
}

// ==========================================
// GLASS CARD WIDGET (Reusable)
// ==========================================

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final double borderRadius;

  const GlassCard({
    super.key,
    required this.child,
    this.margin,
    this.padding,
    this.blur = 16,
    this.borderRadius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _glass,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: _glassBorder, width: 1),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0x22FFFFFF),
                  Color(0x08FFFFFF),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ==========================================
// GRADIENT BACKGROUND WRAPPER
// ==========================================

class _GradientBg extends StatelessWidget {
  final Widget child;
  const _GradientBg({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark background
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0A0E1A), Color(0xFF0D1830), Color(0xFF080C17)],
            ),
          ),
        ),
        // Glow blob top-left
        Positioned(
          top: -80,
          left: -60,
          child: Container(
            width: 280,
            height: 280,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x334F8EF7), Colors.transparent],
              ),
            ),
          ),
        ),
        // Glow blob bottom-right
        Positioned(
          bottom: 50,
          right: -80,
          child: Container(
            width: 240,
            height: 240,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x22A78BFA), Colors.transparent],
              ),
            ),
          ),
        ),
        // Content
        child,
      ],
    );
  }
}

// ==========================================
// PROFILE PAGE
// ==========================================

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileData profile = ProfileData(
    name: 'Fauzan Azka Ferdianto',
    bio: 'Saya suka belajar hal baru, terutama yang berkaitan dengan teknologi dan pengembangan aplikasi mobile.',
    education: 'Universitas Pasundan — Semester 6\nIPK: 3.75',
    contact: 'azkaferdianto225@gmail.com\n+62 813-9457-9557',
  );

  List<ExperienceData> experiences = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg1,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profil Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: _textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: _GradientBg(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // === HEADER PROFIL ===
              Center(
                child: Column(
                  children: [
                    // Avatar with glow ring
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [_accent, Color(0xFFA78BFA)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _accent.withOpacity(0.4),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        key: ValueKey(profile.imagePath),
                        radius: 52,
                        backgroundImage: (profile.imagePath != null && !kIsWeb && File(profile.imagePath!).existsSync())
                            ? FileImage(File(profile.imagePath!)) as ImageProvider
                            : (kIsWeb && profile.imagePath != null)
                            ? NetworkImage(profile.imagePath!)
                            : const NetworkImage(
                          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQDKlPATmdXseR5WL2Y6ICW5HrndNveToyCmA&s',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: _textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: _accent.withOpacity(0.3), width: 1),
                      ),
                      child: const Text(
                        'Mahasiswa Teknik Informatika',
                        style: TextStyle(
                          fontSize: 13,
                          color: _accentSoft,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // === BARIS STATISTIK ===
              GlassCard(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: const Row(
                  children: [
                    Expanded(child: _StatBox(label: 'Post', value: '0')),
                    _VertDivider(),
                    Expanded(child: _StatBox(label: 'Teman', value: '128')),
                    _VertDivider(),
                    Expanded(child: _StatBox(label: 'Like', value: '1.2B')),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // === SECTION CARDS ===
              _SectionCard(
                icon: Icons.info_outline_rounded,
                title: 'Tentang Saya',
                content: profile.bio,
              ),
              _SectionCard(
                icon: Icons.school_rounded,
                title: 'Pendidikan',
                content: profile.education,
              ),
              const _SectionCard(
                icon: Icons.favorite_rounded,
                title: 'Hobi & Minat',
                content: 'Coding  •  Membaca  •  Fotografi  •  Game',
              ),
              _SectionCard(
                icon: Icons.email_rounded,
                title: 'Kontak',
                content: profile.contact,
              ),

              // Skills Card
              GlassCard(
                margin: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.star_rounded,
                          color: _accent, size: 22),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Skills',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _textPrimary,
                            ),
                          ),
                          SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _GlassChip('Flutter'),
                              _GlassChip('Dart'),
                              _GlassChip('Firebase'),
                              _GlassChip('Git'),
                              _GlassChip('REST API'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // === BONUS: PENGALAMAN SECTION ===
              if (experiences.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(top: 8, bottom: 12, left: 4),
                  child: Text(
                    'Pengalaman',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _textPrimary,
                    ),
                  ),
                ),
                ...experiences.map((exp) => GlassCard(
                  margin: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (exp.imagePath != null && ((!kIsWeb && File(exp.imagePath!).existsSync()) || kIsWeb))
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: kIsWeb
                              ? Image.network(exp.imagePath!, width: double.infinity, height: 150, fit: BoxFit.cover)
                              : Image.file(
                            File(exp.imagePath!),
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      if (exp.imagePath != null) const SizedBox(height: 12),
                      Text(
                        exp.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exp.description,
                        style: const TextStyle(
                          color: _textSecondary,
                          height: 1.5,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )),
              ],

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      // FAB → Edit Profil Page
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final updatedProfile = await Navigator.push<ProfileData>(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfilePage(profile: profile),
            ),
          );
          if (updatedProfile != null) {
            setState(() {
              profile = updatedProfile;
            });
          }
        },
        child: const Icon(Icons.edit_rounded),
      ),

      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0x99080C17),
              border: Border(
                top: BorderSide(color: _glassBorder, width: 1),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: 1,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: _accent,
              unselectedItemColor: _textSecondary,
              items: const [
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_rounded), label: 'Home'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person_rounded), label: 'Profil'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.message_rounded), label: 'Pesan'),
                BottomNavigationBarItem(
                    icon: Icon(Icons.settings_rounded), label: 'Setting'),
              ],
              onTap: (i) {},
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: _bg2,
      child: Stack(
        children: [
          // Glow di drawer
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                    colors: [Color(0x224F8EF7), Colors.transparent]),
              ),
            ),
          ),
          ListView(
            padding: EdgeInsets.zero,
            children: [
              // Drawer Header
              Container(
                height: 180,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A2A4A), Color(0xFF0D1525)],
                  ),
                  border: Border(
                    bottom: BorderSide(color: _glassBorder, width: 1),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                                colors: [_accent, Color(0xFFA78BFA)]),
                          ),
                          child: CircleAvatar(
                            key: ValueKey(profile.imagePath),
                            radius: 26,
                            backgroundImage: (profile.imagePath != null && !kIsWeb && File(profile.imagePath!).existsSync())
                                ? FileImage(File(profile.imagePath!)) as ImageProvider
                                : (kIsWeb && profile.imagePath != null)
                                ? NetworkImage(profile.imagePath!)
                                : const NetworkImage(
                              'https://avatars.githubusercontent.com/u/142674912?v=4&size=64',
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          profile.name,
                          style: const TextStyle(
                            color: _textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Text(
                          'Teknik Informatika',
                          style: TextStyle(color: _textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _DrawerItem(
                  icon: Icons.home_rounded, label: 'Beranda', onTap: () {}),
              _DrawerItem(
                  icon: Icons.person_rounded, label: 'Profil', onTap: () {}),
              _DrawerItem(
                icon: Icons.work_rounded,
                label: 'Upload Pengalaman',
                onTap: () async {
                  Navigator.pop(context);
                  final newExp = await Navigator.push<ExperienceData>(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const UploadExperiencePage()),
                  );
                  if (newExp != null) {
                    setState(() {
                      experiences.add(newExp);
                    });
                  }
                },
              ),
              _DrawerItem(
                icon: Icons.settings_rounded,
                label: 'Pengaturan',
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => _GlassDialog(
                      title: 'Pengaturan',
                      content: 'Fitur pengaturan belum tersedia.',
                      onOk: () => Navigator.pop(context),
                    ),
                  );
                },
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Divider(color: _glassBorder, height: 1),
              ),
              _DrawerItem(
                icon: Icons.widgets_rounded,
                label: 'Widget Gallery',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GalleryHome()),
                  );
                },
                accent: true,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// EDIT PROFILE PAGE
// ==========================================

class EditProfilePage extends StatefulWidget {
  final ProfileData profile;
  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _eduController;
  late TextEditingController _contactController;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _bioController = TextEditingController(text: widget.profile.bio);
    _eduController = TextEditingController(text: widget.profile.education);
    _contactController = TextEditingController(text: widget.profile.contact);
    _imagePath = widget.profile.imagePath;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (kIsWeb) {
        setState(() {
          _imagePath = image.path;
        });
      } else {
        // Simpan file ke direktori dokumen aplikasi agar permanen
        final directory = await getApplicationDocumentsDirectory();
        final String fileName = p.basename(image.path);
        final File localImage = await File(image.path).copy('${directory.path}/$fileName');
        setState(() {
          _imagePath = localImage.path;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg1,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: Colors.transparent,
      ),
      body: _GradientBg(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
          child: Column(
            children: [
              // Avatar edit
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(colors: [_accent, Color(0xFFA78BFA)]),
                      ),
                      child: CircleAvatar(
                        key: ValueKey(_imagePath),
                        radius: 60,
                        backgroundImage: (_imagePath != null && !kIsWeb && File(_imagePath!).existsSync())
                            ? FileImage(File(_imagePath!)) as ImageProvider
                            : (kIsWeb && _imagePath != null)
                            ? NetworkImage(_imagePath!)
                            : const NetworkImage('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQDKlPATmdXseR5WL2Y6ICW5HrndNveToyCmA&s'),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: _accent, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildTextField('Nama Lengkap', _nameController),
              const SizedBox(height: 16),
              _buildTextField('Tentang / Bio', _bioController, maxLines: 3),
              const SizedBox(height: 16),
              _buildTextField('Pendidikan', _eduController, maxLines: 2),
              const SizedBox(height: 16),
              _buildTextField('Kontak', _contactController),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final updated = ProfileData(
                      name: _nameController.text,
                      bio: _bioController.text,
                      education: _eduController.text,
                      contact: _contactController.text,
                      imagePath: _imagePath,
                    );
                    Navigator.pop(context, updated);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Simpan Perubahan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DemoLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: _textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: _glass,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _glassBorder)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _glassBorder)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _accent)),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// UPLOAD EXPERIENCE PAGE
// ==========================================

class UploadExperiencePage extends StatefulWidget {
  const UploadExperiencePage({super.key});

  @override
  State<UploadExperiencePage> createState() => _UploadExperiencePageState();
}

class _UploadExperiencePageState extends State<UploadExperiencePage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String? _imagePath;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (kIsWeb) {
        setState(() {
          _imagePath = image.path;
        });
      } else {
        // Simpan file ke direktori dokumen aplikasi agar permanen
        final directory = await getApplicationDocumentsDirectory();
        final String fileName = p.basename(image.path);
        final File localImage = await File(image.path).copy('${directory.path}/$fileName');
        setState(() {
          _imagePath = localImage.path;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg1,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Upload Pengalaman'),
        backgroundColor: Colors.transparent,
      ),
      body: _GradientBg(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DemoLabel('Judul Pengalaman'),
              const SizedBox(height: 6),
              _buildInput(_titleController, 'Contoh: Juara 1 Hackathon'),
              const SizedBox(height: 16),
              _DemoLabel('Deskripsi'),
              const SizedBox(height: 6),
              _buildInput(_descController, 'Ceritakan pengalaman Anda...', maxLines: 4),
              const SizedBox(height: 16),
              _DemoLabel('Gambar Pendukung'),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickImage,
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: _glassBorder, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: (_imagePath == null || (!kIsWeb && !File(_imagePath!).existsSync()))
                        ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_rounded, color: _textSecondary, size: 48),
                        SizedBox(height: 8),
                        Text('Ketuk untuk pilih gambar', style: TextStyle(color: _textSecondary)),
                      ],
                    )
                        : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: kIsWeb
                          ? Image.network(_imagePath!, fit: BoxFit.cover)
                          : Image.file(File(_imagePath!), fit: BoxFit.cover),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.isNotEmpty && _descController.text.isNotEmpty) {
                      final exp = ExperienceData(
                        title: _titleController.text,
                        description: _descController.text,
                        imagePath: _imagePath,
                      );
                      Navigator.pop(context, exp);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Simpan Pengalaman', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String hint, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: _textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: _textSecondary),
        filled: true,
        fillColor: _glass,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _glassBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _glassBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _accent)),
      ),
    );
  }
}

// ==========================================
// DRAWER ITEM
// ==========================================

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool accent;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: accent ? _accent.withOpacity(0.15) : _glass,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon,
            color: accent ? _accent : _textSecondary, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: accent ? _accent : _textPrimary,
          fontWeight: accent ? FontWeight.w600 : FontWeight.w400,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
      horizontalTitleGap: 12,
    );
  }
}

// ==========================================
// GLASS DIALOG
// ==========================================

class _GlassDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onOk;

  const _GlassDialog(
      {required this.title, required this.content, required this.onOk});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text(content,
                style: const TextStyle(color: _textSecondary, height: 1.5)),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onOk,
                style: TextButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('OK'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// HELPER WIDGETS — PROFILE
// ==========================================

class _VertDivider extends StatelessWidget {
  const _VertDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: _glassBorder);
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  const _StatBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: _textSecondary, fontSize: 12)),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: const TextStyle(
                    color: _textSecondary,
                    height: 1.5,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  final String label;
  const _GlassChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accent.withOpacity(0.25), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: _accentSoft,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET GALLERY
// ==========================================

class GalleryHome extends StatelessWidget {
  const GalleryHome({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      ('Display', Icons.image_rounded, _accent),
      ('Input', Icons.edit_rounded, const Color(0xFF34D399)),
      ('Button', Icons.smart_button_rounded, const Color(0xFFFB923C)),
      ('Feedback', Icons.notifications_rounded, const Color(0xFFA78BFA)),
      ('Layout', Icons.dashboard_rounded, const Color(0xFF2DD4BF)),
    ];

    return Scaffold(
      backgroundColor: _bg1,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Widget Gallery'),
        backgroundColor: Colors.transparent,
      ),
      body: _GradientBg(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final (name, icon, color) = categories[i];
            return GlassCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border:
                    Border.all(color: color.withOpacity(0.3), width: 1),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                title: Text(name,
                    style: const TextStyle(
                        color: _textPrimary, fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: _textSecondary),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CategoryPage(name: name, color: color)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CategoryPage extends StatelessWidget {
  final String name;
  final Color color;
  const CategoryPage({super.key, required this.name, required this.color});

  @override
  Widget build(BuildContext context) {
    final body = switch (name) {
      'Display' => const _DisplayDemo(),
      'Input' => const _InputDemo(),
      'Button' => const _ButtonDemo(),
      'Feedback' => const _FeedbackDemo(),
      'Layout' => const _LayoutDemo(),
      _ => const Center(child: Text('?')),
    };

    return Scaffold(
      backgroundColor: _bg1,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.transparent,
      ),
      body: _GradientBg(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
          child: body,
        ),
      ),
    );
  }
}

// ==========================================
// DEMO — DISPLAY
// ==========================================

class _DisplayDemo extends StatelessWidget {
  const _DisplayDemo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _DemoLabel('Card'),
        GlassCard(
          padding: EdgeInsets.zero,
          child: const ListTile(
            leading: Icon(Icons.album_rounded, color: _accent),
            title: Text('Judul Item',
                style: TextStyle(color: _textPrimary)),
            subtitle: Text('Sub-judul',
                style: TextStyle(color: _textSecondary)),
          ),
        ),
        const SizedBox(height: 20),
        const _DemoLabel('Chip'),
        const Wrap(
          spacing: 8,
          children: [
            _GlassChip('Flutter'),
            _GlassChip('Dart'),
            _GlassChip('Mobile'),
          ],
        ),
        const SizedBox(height: 20),
        const _DemoLabel('Divider'),
        const Divider(color: _glassBorder, thickness: 1),
        const SizedBox(height: 20),
        const _DemoLabel('CircleAvatar & Icon'),
        Row(children: [
          const CircleAvatar(
              backgroundColor: _chipBg,
              child: Text('A', style: TextStyle(color: _textPrimary))),
          const SizedBox(width: 12),
          CircleAvatar(
              backgroundColor: const Color(0xFF34D399).withOpacity(0.2),
              child: const Icon(Icons.check, color: Color(0xFF34D399))),
          const SizedBox(width: 12),
          const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 40),
        ]),
      ],
    );
  }
}

// ==========================================
// DEMO — INPUT
// ==========================================

class _InputDemo extends StatefulWidget {
  const _InputDemo();

  @override
  State<_InputDemo> createState() => _InputDemoState();
}

class _InputDemoState extends State<_InputDemo> {
  bool _checked = false;
  bool _switched = true;
  double _slider = 0.5;
  String? _dropdown = 'Apel';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _DemoLabel('TextField'),
        const SizedBox(height: 6),
        TextField(
          style: const TextStyle(color: _textPrimary),
          decoration: InputDecoration(
            filled: true,
            fillColor: _glass,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _glassBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _glassBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _accent),
            ),
            labelText: 'Nama',
            labelStyle: const TextStyle(color: _textSecondary),
            hintText: 'Ketik nama Anda',
            hintStyle: const TextStyle(color: _textSecondary),
          ),
        ),
        const SizedBox(height: 16),
        const _DemoLabel('Checkbox'),
        CheckboxListTile(
          title: const Text('Saya setuju',
              style: TextStyle(color: _textPrimary)),
          value: _checked,
          activeColor: _accent,
          checkColor: Colors.white,
          onChanged: (v) => setState(() => _checked = v ?? false),
        ),
        const _DemoLabel('Switch'),
        SwitchListTile(
          title: const Text('Notifikasi aktif',
              style: TextStyle(color: _textPrimary)),
          value: _switched,
          activeColor: _accent,
          onChanged: (v) => setState(() => _switched = v),
        ),
        const _DemoLabel('Slider'),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: _accent,
            thumbColor: _accent,
            inactiveTrackColor: _accent.withOpacity(0.2),
            overlayColor: _accent.withOpacity(0.1),
          ),
          child: Slider(
              value: _slider,
              onChanged: (v) => setState(() => _slider = v)),
        ),
        Text('Nilai: ${(_slider * 100).toStringAsFixed(0)}%',
            style: const TextStyle(color: _textSecondary)),
        const SizedBox(height: 12),
        const _DemoLabel('Dropdown'),
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: DropdownButton<String>(
            value: _dropdown,
            isExpanded: true,
            dropdownColor: _bg2,
            style: const TextStyle(color: _textPrimary),
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: _textSecondary),
            items: ['Apel', 'Jeruk', 'Mangga']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) => setState(() => _dropdown = v),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// DEMO — BUTTON
// ==========================================

class _ButtonDemo extends StatelessWidget {
  const _ButtonDemo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _DemoLabel('ElevatedButton'),
        const SizedBox(height: 6),
        ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: _accent),
            child: const Text('Elevated')),
        const SizedBox(height: 14),
        const _DemoLabel('FilledButton'),
        FilledButton(onPressed: () {}, child: const Text('Filled')),
        const SizedBox(height: 14),
        const _DemoLabel('OutlinedButton'),
        OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
                foregroundColor: _accent,
                side: const BorderSide(color: _accent)),
            child: const Text('Outlined')),
        const SizedBox(height: 14),
        const _DemoLabel('TextButton'),
        TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(foregroundColor: _accentSoft),
            child: const Text('Text Button')),
        const SizedBox(height: 14),
        const _DemoLabel('ElevatedButton.icon'),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.send_rounded, size: 16),
          label: const Text('Dengan Icon'),
          style: ElevatedButton.styleFrom(backgroundColor: _accent),
        ),
        const SizedBox(height: 14),
        const _DemoLabel('IconButton'),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.favorite_rounded,
              color: Color(0xFFF87171), size: 30),
        ),
      ],
    );
  }
}

// ==========================================
// DEMO — FEEDBACK
// ==========================================

class _FeedbackDemo extends StatelessWidget {
  const _FeedbackDemo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _DemoLabel('SnackBar'),
        const SizedBox(height: 6),
        ElevatedButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('Halo dari SnackBar!'),
              backgroundColor: _bg2,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: _glassBorder)),
            ));
          },
          style: ElevatedButton.styleFrom(backgroundColor: _accent),
          child: const Text('Tampilkan SnackBar'),
        ),
        const SizedBox(height: 14),
        const _DemoLabel('AlertDialog'),
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => _GlassDialog(
                title: 'Konfirmasi',
                content: 'Yakin ingin lanjut?',
                onOk: () => Navigator.pop(context),
              ),
            );
          },
          style: ElevatedButton.styleFrom(backgroundColor: _accent),
          child: const Text('Tampilkan Dialog'),
        ),
        const SizedBox(height: 20),
        const _DemoLabel('LinearProgressIndicator'),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: 0.6,
            minHeight: 8,
            backgroundColor: _accent.withOpacity(0.15),
            valueColor: const AlwaysStoppedAnimation(_accent),
          ),
        ),
        const SizedBox(height: 20),
        const _DemoLabel('CircularProgressIndicator'),
        const SizedBox(height: 12),
        const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(_accent),
            strokeWidth: 3,
          ),
        ),
      ],
    );
  }
}

// ==========================================
// DEMO — LAYOUT
// ==========================================

class _LayoutDemo extends StatelessWidget {
  const _LayoutDemo();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _DemoLabel('Stack — widget bertumpuk'),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 120,
            child: Stack(
              children: [
                Container(
                    color: const Color(0xFF1A2A4A),
                    width: double.infinity),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF87171).withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 12,
                  right: 12,
                  child: Icon(Icons.star_rounded,
                      size: 40, color: Color(0xFFFBBF24)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const _DemoLabel('Wrap — auto-pindah baris saat penuh'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            8,
                (i) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF2DD4BF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF2DD4BF).withOpacity(0.3)),
              ),
              child: Text('Item ${i + 1}',
                  style: const TextStyle(
                      color: Color(0xFF2DD4BF), fontSize: 12)),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const _DemoLabel('GridView (crossAxisCount: 3)'),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: GridView.count(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            physics: const NeverScrollableScrollPhysics(),
            children: List.generate(6, (i) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFA78BFA).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: const Color(0xFFA78BFA).withOpacity(0.2)),
                    ),
                    alignment: Alignment.center,
                    child: Text('${i + 1}',
                        style: const TextStyle(
                            color: Color(0xFFA78BFA),
                            fontWeight: FontWeight.bold,
                            fontSize: 18)),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// SHARED DEMO LABEL
// ==========================================

class _DemoLabel extends StatelessWidget {
  final String text;
  const _DemoLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: _textSecondary,
          fontSize: 12,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
