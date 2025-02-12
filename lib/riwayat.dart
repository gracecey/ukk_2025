import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class RiwayatPage extends StatefulWidget {
  final VoidCallback? onRefresh;
  const RiwayatPage({Key? key, this.onRefresh}) : super(key: key);

  @override
  _RiwayatPageState createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  final SupabaseClient _supabase = Supabase.instance.client;
  final NumberFormat currencyFormat = NumberFormat.decimalPattern('id');
  List<Map<String, dynamic>> _transactionHistory = [];
  List<Map<String, dynamic>> _filteredTransactions = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchTransactionHistory();
  }

  Future<void> _fetchTransactionHistory() async {
    try {
      final response = await _supabase.from('penjualan').select('''
        penjualan_id,
        tanggal_penjualan,
        total_harga,
        pelanggan_id,
        pelanggan (nama_pelanggan),
        detail_penjualan (
          produk_id,
          jumlah_produk,
          subtotal,
          produk (nama_produk, harga)
        )
      ''').order('penjualan_id', ascending: false);

      if (!mounted) return;

      setState(() {
        _transactionHistory = List<Map<String, dynamic>>.from(response as List<dynamic>);
        _filteredTransactions = _transactionHistory;
      });
    } catch (error) {
      debugPrint('Error fetching transaction history: $error');
    }
  }

  void _filterTransactions(String query) {
    setState(() {
      _filteredTransactions = _transactionHistory.where((transaction) {
        final String namaPelanggan = transaction['pelanggan']['nama_pelanggan']?.toLowerCase() ?? '';
        final productNames = transaction['detail_penjualan']
            .map((detail) => detail['produk']['nama_produk'].toString().toLowerCase())
            .join(' ');
        return namaPelanggan.contains(query.toLowerCase()) || productNames.contains(query.toLowerCase());
      }).toList();
    });
  }

  String _formatDateTime(String dateTime) {
    final date = DateTime.parse(dateTime);
    return DateFormat('dd MMM yyyy').format(date); // Menghilangkan jam
  }

  void _showTransactionDetails(BuildContext context, Map<String, dynamic> transaction) {
    final formattedDate = _formatDateTime(transaction['tanggal_penjualan']);
    final detailPenjualan = List<Map<String, dynamic>>.from(transaction['detail_penjualan'] as List<dynamic>);
    final String namaPelanggan = transaction['pelanggan']['nama_pelanggan'] ?? 'Tidak diketahui';

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Detail Transaksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Nama Pelanggan: $namaPelanggan'),
                Text('Tanggal: $formattedDate'),
                Text('Total: Rp ${currencyFormat.format(transaction['total_harga'].toInt())}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Produk:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...detailPenjualan.map((detail) => ListTile(
                      leading: Icon(Icons.shopping_cart, color: Colors.purple),
                      title: Text(detail['produk']['nama_produk']),
                      subtitle: Text('Jumlah: ${detail['jumlah_produk']}'),
                      trailing: Text('Rp ${currencyFormat.format(detail['subtotal'].toInt())}'),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('Riwayat Transaksi'),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Transaksi',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: _filterTransactions,
            ),
          ),
          Expanded(
            child: _filteredTransactions.isEmpty
                ? Center(child: Text('Belum ada riwayat transaksi.'))
                : ListView.builder(
                    itemCount: _filteredTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = _filteredTransactions[index];
                      final formattedDate = _formatDateTime(transaction['tanggal_penjualan']);
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        elevation: 4,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.purpleAccent,
                            child: Icon(Icons.receipt_long, color: Colors.white),
                          ),
                          title: Text('Transaksi #${_transactionHistory.length - _transactionHistory.indexOf(transaction)}',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Tanggal: $formattedDate\nTotal: Rp ${currencyFormat.format(transaction['total_harga'])}'),
                          trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.purpleAccent),
                          onTap: () => _showTransactionDetails(context, transaction),
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
