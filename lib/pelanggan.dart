import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PelangganScreen extends StatefulWidget {
  @override
  _PelangganScreenState createState() => _PelangganScreenState();
}

class _PelangganScreenState extends State<PelangganScreen> {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchPelanggan() async {
    final response = await supabase.from('pelanggan').select();
    return response;
  }

  Future<void> deletePelanggan(int id) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus pelanggan ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                await supabase.from('pelanggan').delete().eq('pelanggan_id', id);
                Navigator.pop(context);
                setState(() {});
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
        title: Text("Daftar Pelanggan", style: TextStyle(color: Colors.white)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        child: Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PelangganForm()),
          ).then((_) => setState(() {}));
        },
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchPelanggan(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
          final pelangganList = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: pelangganList.length,
            itemBuilder: (context, index) {
              final pelanggan = pelangganList[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple,
                    child: Text(
                      pelanggan['nama_pelanggan'][0].toUpperCase(),
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(pelanggan['nama_pelanggan'], style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    "Alamat: ${pelanggan['alamat']}\nTelepon: ${pelanggan['nomor_telepon']}",
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
                            MaterialPageRoute(builder: (context) => PelangganForm(pelanggan: pelanggan)),
                          ).then((_) => setState(() {}));
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deletePelanggan(pelanggan['pelanggan_id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PelangganForm extends StatefulWidget {
  final Map<String, dynamic>? pelanggan;
  PelangganForm({this.pelanggan});

  @override
  _PelangganFormState createState() => _PelangganFormState();
}

class _PelangganFormState extends State<PelangganForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    if (widget.pelanggan != null) {
      namaController.text = widget.pelanggan!['nama_pelanggan'];
      alamatController.text = widget.pelanggan!['alamat'];
      teleponController.text = widget.pelanggan!['nomor_telepon'];
    }
  }

  Future<void> submitForm() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'nama_pelanggan': namaController.text,
        'alamat': alamatController.text,
        'nomor_telepon': teleponController.text,
      };

      if (widget.pelanggan == null) {
        await supabase.from('pelanggan').insert(data);
      } else {
        await supabase.from('pelanggan').update(data).eq('pelanggan_id', widget.pelanggan!['pelanggan_id']);
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
          widget.pelanggan == null ? "Tambah Pelanggan" : "Edit Pelanggan",
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
                decoration: InputDecoration(labelText: "Nama Pelanggan"),
                validator: (value) => value!.isEmpty ? "Nama tidak boleh kosong" : null,
              ),
              TextFormField(
                controller: alamatController,
                decoration: InputDecoration(labelText: "Alamat"),
                validator: (value) => value!.isEmpty ? "Alamat tidak boleh kosong" : null,
              ),
              TextFormField(
                controller: teleponController,
                decoration: InputDecoration(labelText: "Nomor Telepon"),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? "Nomor telepon tidak boleh kosong" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12)),
                onPressed: submitForm,
                child: Text("Simpan", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
