import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'produk.dart';
import 'pelanggan.dart';
import 'transaksi.dart';
import 'riwayat.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  int _selectedIndex = 3;

  Future<List<Map<String, dynamic>>> _fetchUsers() async {
    final response = await supabase.from('user').select();
    return response;
  }

  Future<void> _addUser() async {
    final _formKey = GlobalKey<FormState>();
    TextEditingController usernameController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah User'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username tidak boleh kosong';
                    }
                    if (value.length < 3) {
                      return 'Username minimal 3 karakter';
                    }
                    return null;
                  },      
                ),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await supabase.from('user').insert({
                    'username': usernameController.text,
                    'password': passwordController.text,
                    'created_at': DateTime.now().toIso8601String(),
                  });
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editUser(int id, String oldUsername, String oldPassword) async {
    final _formKey = GlobalKey<FormState>();
    TextEditingController usernameController = TextEditingController(text: oldUsername);
    TextEditingController passwordController = TextEditingController(text: oldPassword);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit User'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Username tidak boleh kosong';
                    }
                    if (value.length < 3) {
                      return 'Username minimal 3 karakter';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Password minimal 6 karakter';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await supabase.from('user').update({
                    'username': usernameController.text,
                    'password': passwordController.text,
                  }).eq('id', id);
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteUser(int id) async {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus user ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await supabase.from('user').delete().eq('id', id);
              Navigator.pop(context); // Tutup dialog
              setState(() {}); // Perbarui tampilan
            },
            child: Text('Hapus'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      );
    },
  );
}


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Konfirmasi Logout'),
          content: Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text('Iya'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text(
          'Kasir Cafe',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
    body: _selectedIndex == 0
    ? _buildUserList()
    : _selectedIndex == 1
        ? ProdukScreen()
        : _selectedIndex == 2
            ? PelangganScreen()
            : _selectedIndex == 3
                ? TransaksiScreen()
                : RiwayatPage(), // TAMBAHKAN INI


      bottomNavigationBar: BottomNavigationBar(
  items: [
    BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
    BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Produk'),
    BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Pelanggan'),
    BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Transaksi"),
    BottomNavigationBarItem(icon: Icon(Icons.history), label: "Riwayat"),
  ],
  currentIndex: _selectedIndex,
  selectedItemColor: Colors.purple, // Warna ikon saat dipilih
  unselectedItemColor: Colors.grey, // Warna ikon saat tidak dipilih
  type: BottomNavigationBarType.fixed, // Menjaga tampilan label tetap terlihat
  onTap: _onItemTapped,
),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _addUser,
              backgroundColor: Colors.purple,
              child: Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildUserList() {
    return FutureBuilder(
      future: _fetchUsers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('Tidak ada user'));
        }
        final users = snapshot.data as List<Map<String, dynamic>>;
        return ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple,
                  child: Text(
                    user['username'][0].toUpperCase(),
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(user['username'], style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Password: ${user['password']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editUser(user['id'], user['username'], user['password']),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteUser(user['id']),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
