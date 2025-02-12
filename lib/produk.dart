import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home.dart';

class ProdukScreen extends StatefulWidget {
  @override
  _ProdukScreenState createState() => _ProdukScreenState();
}

class _ProdukScreenState extends State<ProdukScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _produkList = [];
  List<Map<String, dynamic>> _filteredProduk = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProduk();
    _searchController.addListener(() {
      _filterProduk(_searchController.text);
    });
  }

  Future<void> fetchProduk() async {
    final response = await supabase.from('produk').select().order('created_at', ascending: false);
    setState(() {
      _produkList = List<Map<String, dynamic>>.from(response);
      _filteredProduk = _produkList;
    });
  }

  void _filterProduk(String query) {
    setState(() {
      _filteredProduk = _produkList.where((produk) {
        final namaProduk = produk['nama_produk'].toLowerCase();
        return namaProduk.contains(query.toLowerCase());
      }).toList();
    });
  }

  Future<void> deleteProduk(int id) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus produk ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                await supabase.from('produk').delete().eq('produk_id', id);
                Navigator.pop(context);
                fetchProduk();
              },
              child: Text('Hapus'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
        title: Text("Daftar Produk", style: TextStyle(color: Colors.white)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProdukForm()),
          ).then((_) => fetchProduk());
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Produk',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          Expanded(
            child: _filteredProduk.isEmpty
                ? Center(child: Text('Produk tidak ditemukan.'))
                : ListView.builder(
                    padding: EdgeInsets.all(10),
                    itemCount: _filteredProduk.length,
                    itemBuilder: (context, index) {
                      final produk = _filteredProduk[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.purple,
                            child: Text(
                              produk['nama_produk'][0].toUpperCase(),
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(produk['nama_produk'], style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            "Harga: Rp ${produk['harga']} | Stok: ${produk['stok']}",
                            style: TextStyle(color: Colors.black54),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProdukForm(produk: produk),
                                    ),
                                  ).then((_) => fetchProduk());
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => deleteProduk(produk['produk_id']),
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
    );
  }
}

class ProdukForm extends StatefulWidget {
  final Map<String, dynamic>? produk;
  ProdukForm({this.produk});

  @override
  _ProdukFormState createState() => _ProdukFormState();
}

class _ProdukFormState extends State<ProdukForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();
  final TextEditingController stokController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    if (widget.produk != null) {
      namaController.text = widget.produk!['nama_produk'];
      hargaController.text = widget.produk!['harga'].toString();
      stokController.text = widget.produk!['stok'].toString();
    }
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'nama_produk': namaController.text,
        'harga': double.parse(hargaController.text),
        'stok': int.parse(stokController.text),
      };

      if (widget.produk == null) {
        await supabase.from('produk').insert(data);
      } else {
        await supabase.from('produk').update(data).eq('produk_id', widget.produk!['produk_id']);
      }

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: Text(
          widget.produk == null ? "Tambah Produk" : "Edit Produk",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: namaController,
                decoration: InputDecoration(labelText: "Nama Produk"),
                validator: (value) => value!.isEmpty ? "Nama produk tidak boleh kosong" : null,
              ),
              ElevatedButton(onPressed: submitForm, child: Text("Simpan")),
            ],
          ),
        ),
      ),
    );
  }
}
