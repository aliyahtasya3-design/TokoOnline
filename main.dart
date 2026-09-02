import 'dart:async';

// 1. Custom Exceptions
class StokHabisException implements Exception {
  final String msg; StokHabisException(this.msg);
  @override String toString() => 'StokHabisException: $msg';
}
class ProdukTidakAda implements Exception {
  final String msg; ProdukTidakAda(this.msg);
  @override String toString() => 'ProdukTidakAda: $msg';
}

// 2. Mixin
mixin BisaDiskon {
  bool validasiDiskon(double p) => p >= 0 && p <= 100;
  double hitungHargaDiskon(double h, double p) {
    if (!validasiDiskon(p)) throw ArgumentError('Diskon 0-100%');
    return h - (h * (p / 100));
  }
}

// 3. Abstract Class & Implementations
abstract class Produk {
  String id, nama; double harga; int stok;
  Produk(this.id, this.nama, this.harga, this.stok);
  void deskripsi();
}

class ProdukDigital extends Produk with BisaDiskon {
  double ukuranMB; String formatFile;
  ProdukDigital(super.id, super.nama, super.harga, super.stok, this.ukuranMB, this.formatFile);

  @override
  void deskripsi() => print('[Digital] $nama ($formatFile) - Rp$harga | Stok: $stok');
}

class ProdukFisik extends Produk with BisaDiskon {
  double beratGram; String dimensi;
  ProdukFisik(super.id, super.nama, super.harga, super.stok, this.beratGram, this.dimensi);

  @override
  void deskripsi() => print('[Fisik] $nama ($beratGram g) - Rp$harga | Stok: $stok');
}

// 4. Keranjang
class Keranjang {
  final List<Produk> list = [];

  void tambah(Produk p) {
    if (p.stok <= 0) throw StokHabisException('Stok ${p.nama} habis!');
    list.add(p);
    print('✓ Masuk keranjang: ${p.nama}');
  }

  void hapus(String id) {
    int idx = list.indexWhere((p) => p.id == id);
    if (idx == -1) throw ProdukTidakAda('ID $id tidak ditemukan di keranjang!');
    print('✓ Dihapus: ${list[idx].nama}');
    list.removeAt(idx);
  }

  double totalHarga() => list.fold(0, (sum, p) => sum + p.harga);
}

// 5. TokoService (Async)
class TokoService {
  final List<Produk> katalog;
  TokoService(this.katalog);

  Future<Produk> cariProduk(String nama) async {
    await Future.delayed(Duration(milliseconds: 500));
    return katalog.firstWhere(
      (p) => p.nama.toLowerCase().contains(nama.toLowerCase()),
      orElse: () => throw ProdukTidakAda('Produk "$nama" tidak ada.'),
    );
  }

  Future<void> prosesCheckout(Keranjang k) async {
    await Future.delayed(Duration(milliseconds: 500));
    if (k.list.isEmpty) throw Exception('Keranjang kosong!');
    for (var p in k.list) {
      if (p.stok <= 0) throw StokHabisException('${p.nama} kehabisan stok!');
      p.stok--;
    }
    print('✓ Checkout Berhasil! Total: Rp${k.totalHarga()}');
  }
}

// 6. Main Program
void main() async {
  var p1 = ProdukDigital('D1', 'E-Book Dart', 50000, 5, 10.0, 'PDF');
  var p2 = ProdukFisik('F1', 'Mouse Wireless', 150000, 0, 200, '10x5cm');
  var service = TokoService([p1, p2]);
  var keranjang = Keranjang();

  // Test Diskon Mixin
  print('Harga Diskon: Rp${p1.hitungHargaDiskon(p1.harga, 20)}');

  // Async & Error Handling
  try {
    var cari1 = await service.cariProduk('Dart');
    keranjang.tambah(cari1);

    var cari2 = await service.cariProduk('Mouse');
    keranjang.tambah(cari2); // Memicu StokHabisException
  } catch (e) {
    print('Error: $e');
  }

  try {
    keranjang.hapus('ID_SALAH'); // Memicu ProdukTidakAda
  } catch (e) {
    print('Error: $e');
  }

  try {
    await service.prosesCheckout(keranjang);
  } catch (e) {
    print('Error: $e');
  }
}